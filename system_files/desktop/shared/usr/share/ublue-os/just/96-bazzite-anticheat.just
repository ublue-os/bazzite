# Check whether this system meets the requirements of Easy Anti-Cheat Linux v2 (Fortnite and other EAC v2 games)
[group("gaming")]
check-anticheat:
    #!/usr/bin/pkexec /usr/bin/bash
    set -uo pipefail
    source /usr/lib/ujust/ujust.sh

    # Requirements, and the signing keys EAC Linux v2 treats as well-known, come from:
    REQUIREMENTS_URL="https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2"
    WELL_KNOWN_KEYS='Canonical Ltd\. Master Certificate Authority|Fedora Secure Boot CA|Universal Blue|Debian Secure Boot CA|openSUSE Secure Boot CA|SUSE Linux Enterprise Secure Boot CA|Rocky Linux Secure Boot Root CA|Microsoft (Corporation )?UEFI CA|AlmaLinux Secure Boot CA'

    PASSED=0
    FAILED=0
    pass() {
        printf '%s[PASS]%s %s\n' "${green}${bold}" "${normal}" "$1"
        [[ -n ${2:-} ]] && printf '       %s\n' "$2"
        PASSED=$((PASSED + 1))
    }
    fail() {
        printf '%s[FAIL]%s %s\n' "${red}${bold}" "${normal}" "$1"
        [[ -n ${2:-} ]] && printf '       %s\n' "$2"
        FAILED=$((FAILED + 1))
    }

    CMDLINE=()
    read -ra CMDLINE </proc/cmdline
    has_karg() {
        local arg
        for arg in "${CMDLINE[@]}"; do
            [[ $arg == "$1" ]] && return 0
        done
        return 1
    }

    SYS_VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)
    CHASSIS=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)
    HANDHELD=0
    # SMBIOS chassis types 30-32 are tablet, convertible and detachable, which is how handhelds report
    [[ $SYS_VENDOR == Valve || $CHASSIS =~ ^3[012]$ ]] && HANDHELD=1

    echo "${bold}Easy Anti-Cheat Linux v2 readiness check${normal}"
    echo "Requirements: ${REQUIREMENTS_URL}"
    echo

    # 1. Signed kernel & kernel modules
    KERNEL="/usr/lib/modules/$(uname -r)/vmlinuz"
    if [[ ! -r $KERNEL ]]; then
        fail "Signed kernel" "Couldn't find the running kernel at $KERNEL"
    # sbverify exits 0 for an unsigned kernel too, and nonzero only when it can't read the file
    elif ! SIGNERS=$(sbverify --list "$KERNEL" 2>&1); then
        fail "Signed kernel" "Couldn't read the kernel's signatures (sbverify says: ${SIGNERS//$'\n'/ })"
    else
        SIGNER_CN=$(sed -n 's|^ *- subject: .*/CN=\([^/]*\).*|\1|p' <<<"$SIGNERS" | head -n1)
        if ! grep -q 'subject:' <<<"$SIGNERS"; then
            fail "Signed kernel" "Kernel $(uname -r) is not signed"
        elif grep -Eq "$WELL_KNOWN_KEYS" <<<"$SIGNERS"; then
            pass "Signed kernel" "Kernel $(uname -r) is signed by '${SIGNER_CN}'"
        else
            fail "Signed kernel" "Kernel $(uname -r) is signed by '${SIGNER_CN}', which is not a well-known key"
        fi
    fi

    UNSIGNED=()
    MODULES=0
    while read -r mod _; do
        MODULES=$((MODULES + 1))
        [[ $(cat "/sys/module/$mod/taint" 2>/dev/null) == *E* ]] && UNSIGNED+=("$mod")
    done </proc/modules
    if (( ${#UNSIGNED[@]} )); then
        fail "Signed kernel modules" "Unsigned modules loaded: ${UNSIGNED[*]}"
    elif (( $(cat /proc/sys/kernel/tainted) & 8192 )); then
        fail "Signed kernel modules" "An unsigned module was loaded during this boot (reboot to clear)"
    else
        pass "Signed kernel modules" "All ${MODULES} loaded modules are signed"
    fi

    # 2. TPM 2.0
    if [[ $(cat /sys/class/tpm/tpm0/tpm_version_major 2>/dev/null) == 2 ]]; then
        pass "TPM 2.0"
    elif [[ -e /sys/class/tpm/tpm0 ]]; then
        fail "TPM 2.0" "Found a TPM, but it isn't version 2.0"
    else
        fail "TPM 2.0" "No TPM found. Enable it in your BIOS (often called fTPM, PTT or Security Device)"
    fi

    # 3. Secure Boot, booted only with well-known keys
    SB_STATE=$(mokutil --sb-state 2>&1)
    if [[ $SB_STATE == *"SecureBoot enabled"* && $SB_STATE != *"validation is disabled"* ]]; then
        pass "Secure Boot enabled"
    else
        fail "Secure Boot enabled" "Enable Secure Boot in your BIOS (mokutil says: ${SB_STATE//$'\n'/ })"
    fi

    MOK_DIR=$(mktemp -d)
    trap 'rm -rf "$MOK_DIR"' EXIT
    # mokutil exits 0 when no keys are enrolled, and nonzero only when it can't read them
    MOK_ERR=$(cd "$MOK_DIR" && mokutil --export 2>&1 >/dev/null)
    MOK_STATUS=$?
    UNKNOWN_MOKS=()
    for der in "$MOK_DIR"/MOK-*.der; do
        [[ -e $der ]] || continue
        CERT=$(openssl x509 -inform DER -in "$der" -noout -subject -issuer 2>/dev/null)
        if ! grep -Eq "$WELL_KNOWN_KEYS" <<<"$CERT"; then
            UNKNOWN_MOKS+=("'$(sed -n 's/^subject=.*CN *= *\([^,]*\).*/\1/p' <<<"$CERT")'")
        fi
    done
    if (( MOK_STATUS )); then
        fail "Only well-known Machine Owner Keys" "Couldn't read the enrolled keys (mokutil says: ${MOK_ERR//$'\n'/ })"
    elif (( ${#UNKNOWN_MOKS[@]} )); then
        fail "Only well-known Machine Owner Keys" "Not well-known: ${UNKNOWN_MOKS[*]}. Export them with 'mokutil --export', then remove each with 'sudo mokutil --delete MOK-000N.der'"
    else
        pass "Only well-known Machine Owner Keys"
    fi

    # 4. Measured boot
    EVENT_LOG=/sys/kernel/security/tpm0/binary_bios_measurements
    if [[ ! -e $EVENT_LOG ]]; then
        fail "Measured boot" "No TPM boot measurements found"
    else
        # GRUB measures into PCRs 8 and 9, systemd-boot and systemd-stub into 11 and 12
        if ! PCRS=$(tpm2_eventlog "$EVENT_LOG" 2>/dev/null); then
            fail "Measured boot" "Couldn't read the TPM boot log"
        elif grep -Eq '^\s*PCRIndex: (8|9|11|12)$' <<<"$PCRS"; then
            pass "Measured boot" "The boot manager recorded its measurements"
        else
            fail "Measured boot" "The firmware measured the boot, but the boot manager didn't"
        fi
    fi

    # 5. IOMMU enabled, with passthrough disabled (not required on handhelds)
    PASSTHROUGH=""
    for arg in iommu=pt iommu=off iommu.passthrough=1 amd_iommu=pt amd_iommu=off intel_iommu=off; do
        has_karg "$arg" && PASSTHROUGH="$arg"
    done
    if [[ -z $PASSTHROUGH ]] && ! has_karg iommu.passthrough=0 &&
        grep -q '^CONFIG_IOMMU_DEFAULT_PASSTHROUGH=y' "/usr/lib/modules/$(uname -r)/config" 2>/dev/null; then
        PASSTHROUGH="the kernel's default"
    fi
    if compgen -G '/sys/class/iommu/*' >/dev/null && [[ -z $PASSTHROUGH ]]; then
        pass "IOMMU enabled, passthrough disabled"
    elif (( HANDHELD )); then
        pass "IOMMU enabled, passthrough disabled" "Not required on handheld devices"
    elif [[ -n $PASSTHROUGH ]]; then
        fail "IOMMU enabled, passthrough disabled" "Passthrough is on (${PASSTHROUGH}). Remove it with 'rpm-ostree kargs --delete=${PASSTHROUGH}'"
    elif grep -q GenuineIntel /proc/cpuinfo; then
        fail "IOMMU enabled, passthrough disabled" "Enable VT-d in your BIOS, then run 'rpm-ostree kargs --append-if-missing=intel_iommu=on'"
    else
        fail "IOMMU enabled, passthrough disabled" "Enable IOMMU (AMD-Vi) in your BIOS"
    fi

    # 6. Kernel lockdown in integrity mode (confidentiality mode is a superset)
    LOCKDOWN=$(sed -n 's/.*\[\(.*\)\].*/\1/p' /sys/kernel/security/lockdown 2>/dev/null)
    if [[ $LOCKDOWN == integrity || $LOCKDOWN == confidentiality ]]; then
        pass "Kernel lockdown integrity mode" "Lockdown mode is '${LOCKDOWN}'"
    else
        fail "Kernel lockdown integrity mode" "Lockdown mode is '${LOCKDOWN:-unavailable}'. Run 'rpm-ostree kargs --append-if-missing=lockdown=integrity'"
    fi

    # 7. Kexec disabled (no sysctl means the kernel was built without kexec)
    KEXEC=$(cat /proc/sys/kernel/kexec_load_disabled 2>/dev/null || echo 1)
    if [[ $KEXEC == 1 ]]; then
        pass "Kexec disabled"
    else
        fail "Kexec disabled" "Run 'rpm-ostree kargs --append-if-missing=sysctl.kernel.kexec_load_disabled=1'"
    fi

    # 8. BPF LSM active
    LSMS=$(cat /sys/kernel/security/lsm 2>/dev/null)
    if [[ ,$LSMS, == *,bpf,* ]]; then
        pass "BPF LSM active"
    else
        fail "BPF LSM active" "Active LSMs: ${LSMS:-unknown}. Run 'rpm-ostree kargs --append-if-missing=lsm=${LSMS:+$LSMS,}bpf'"
    fi

    echo
    if (( FAILED )); then
        echo "${red}${bold}${FAILED} of $((PASSED + FAILED)) checks failed.${normal} Fix the items above, then reboot and run this again."
        echo "Kernel argument changes take effect after a reboot."
        exit 0
    fi
    echo "${green}${bold}All $((PASSED + FAILED)) checks passed.${normal} This system meets the EAC Linux v2 requirements."
