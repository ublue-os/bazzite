#!/usr/bin/bash
set -euo pipefail

_on_error() {
    local rc=$?
    echo "" >&2
    echo "ERROR: script failed at line ${BASH_LINENO[0]} (exit code ${rc})." >&2
    echo "Command: ${BASH_COMMAND}" >&2
    echo "" >&2
}
trap _on_error ERR

# ostree/skopeo image imports can fail on non-UTF-8 locales when layer tarballs
# contain filenames outside pure ASCII. Force a UTF-8 locale for the conversion
# workflow so behavior is deterministic across fresh Fedora installs and
# containerized test harnesses.
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Bazzite ARM: Full end-to-end conversion from Fedora Asahi Remix to Bazzite ARM
# Based on https://gist.github.com/davidvfx07/fec3d92f6075ece27f7dd875b5dc459b
#
# Run this script on a freshly installed Fedora Asahi Remix (KDE or Minimal).
# Prerequisites: sudo dnf upgrade -y && reboot  (before running this)
#
# What this script does:
#   1. Installs podman, ostree, rpm-ostree, git
#   2. Clones the bazzite repo and builds the bazzite-arm container image locally
#   3. Converts the traditional Fedora install to an atomic/ostree system
#      WITHOUT touching the Asahi boot chain (m1n1 -> U-Boot -> GRUB)
#   4. Injects a user account into the new deployment so you can log in
#   5. Installs a first-boot systemd service that automatically rebases to
#      Bazzite ARM after the atomic reboot
#   6. Updates GRUB and reboots into atomic Fedora, which then auto-rebases
#      to Bazzite ARM on first login
#
# Safe to re-run after failures: skips steps already completed.
# Force re-deploy: OSTREE_FORCE_DEPLOY=1 bash just_scripts/asahi-rebase.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ATOMIC_BASE="quay.io/fedora-asahi-remix-atomic-desktops/base-atomic:43"
PODMAN_STORAGE_CONF="/etc/containers/storage.conf"
PODMAN_STORAGE_CONF_BACKUP=""
PODMAN_STORAGE_OVERRIDE_ACTIVE=0
PODMAN_EXT_ROOT=""
PODMAN_STORAGE_DRIVER="overlay"
PODMAN_BUILD_SECURITY_ARGS=()
PODMAN_TMPDIR=""
PODMAN_DRIVER_PROBE_LOG=""
PODMAN_DRIVER_SELECTION_NOTE=""
SLEEP_MASKED=0
DNF_CMD=""
HOST_DNF_REPO_OVERRIDE="/etc/dnf/repos.override.d/zz-bazzite-fedora-direct.repo"
HOST_DNF_REPO_OVERRIDE_ACTIVE=0
DNF5_HOST_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=0"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)
DNF4_HOST_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=False"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)

# Parse flags
# --fairydust            : use experimental Thunderbolt/USB4 kernel variant
# --external-build=PATH  : redirect podman container build storage to PATH
#                          (recommended when internal disk is below ~40 GB)
#                          PATH must already be a mounted writable directory,
#                          e.g. /mnt/external (your external SSD).
#                          After the script finishes you can wipe PATH freely.
#                          On native Linux filesystems the script probes Podman
#                          overlay storage first and falls back to 'vfs' only
#                          when overlay is not safe on that mount. Set
#                          BAZZITE_EXTERNAL_PODMAN_DRIVER=overlay|vfs|auto
#                          to override the automatic choice.
# --skip-wine            : skip native Wine aarch64 compilation (~40-60 min)
#                          x86 Wine still runs via FEX-Emu/Box64 emulation.
#                          Use this for faster first installs; rerun this
#                          script later without --skip-wine to build and
#                          deploy the native-Wine image variant.
# --build-proton         : build native Proton aarch64 from source (~2-5 hours).
#                          Proton is NOT built by default due to the long build
#                          time. Use this flag to include it.
# --build-heroic         : build native Heroic Games Launcher for aarch64.
#                          Heroic is NOT built by default due to the extra build
#                          time. Use this flag to include it.
KERNEL_VARIANT="stable"
EXTERNAL_BUILD_PATH=""
SKIP_WINE=0
BUILD_PROTON=0
BUILD_HEROIC=0
for arg in "$@"; do
    case "$arg" in
        --fairydust)           KERNEL_VARIANT="fairydust" ;;
        --external-build=*)    EXTERNAL_BUILD_PATH="${arg#--external-build=}" ;;
        --skip-wine)           SKIP_WINE=1 ;;
        --build-proton)        BUILD_PROTON=1 ;;
        --build-heroic)        BUILD_HEROIC=1 ;;
    esac
done

IMAGE_NAME="bazzite-arm"
if [[ "${KERNEL_VARIANT}" == "fairydust" ]]; then
    IMAGE_NAME="${IMAGE_NAME}-fairydust"
fi
if [[ "${SKIP_WINE}" -eq 1 ]]; then
    IMAGE_NAME="${IMAGE_NAME}-nowine"
fi

IMAGE_BRANCH=$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "experimental")
IMAGE_TAG=$(git -C "${REPO_ROOT}" rev-parse --short=12 HEAD 2>/dev/null || echo "local")
if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain --untracked-files=normal 2>/dev/null || true)" ]]; then
    IMAGE_TAG="dirty-$(date +%Y%m%d%H%M%S)"
fi
BAZZITE_IMAGE="localhost/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Kernel variant:     ${KERNEL_VARIANT}"
echo "External build dir: ${EXTERNAL_BUILD_PATH:-<none, using internal /var/lib/containers>}"
echo "Skip Wine build:    ${SKIP_WINE}"
echo "Build Heroic:       ${BUILD_HEROIC}"
echo "Build Proton:       ${BUILD_PROTON}"
echo "Local image:        ${BAZZITE_IMAGE}"

cleanup_host_overrides() {
    cleanup_external_podman_storage

    if [[ "${SLEEP_MASKED}" -eq 1 ]]; then
        sudo systemctl unmask \
            sleep.target suspend.target hibernate.target \
            hybrid-sleep.target 2>/dev/null || true
    fi

    if [[ "${HOST_DNF_REPO_OVERRIDE_ACTIVE}" -eq 1 ]]; then
        sudo rm -f "${HOST_DNF_REPO_OVERRIDE}" 2>/dev/null || true
    fi

    if [[ -n "${PODMAN_STORAGE_CONF_BACKUP}" ]]; then
        sudo install -m 0644 "${PODMAN_STORAGE_CONF_BACKUP}" "${PODMAN_STORAGE_CONF}" 2>/dev/null || true
        rm -f "${PODMAN_STORAGE_CONF_BACKUP}" 2>/dev/null || true
    elif [[ "${PODMAN_STORAGE_OVERRIDE_ACTIVE}" -eq 1 ]]; then
        sudo rm -f "${PODMAN_STORAGE_CONF}" 2>/dev/null || true
    fi
}

cleanup_external_podman_storage() {
    if [[ -n "${PODMAN_EXT_ROOT}" ]]; then
        sudo_with_container_env podman system prune -af 2>/dev/null || true
        sudo rm -rf "${PODMAN_EXT_ROOT}" 2>/dev/null || true
        PODMAN_EXT_ROOT=""
    fi
    if [[ -n "${PODMAN_TMPDIR}" ]]; then
        sudo rm -rf "${PODMAN_TMPDIR}" 2>/dev/null || true
        PODMAN_TMPDIR=""
    fi
}

cleanup_local_podman_image() {
    sudo_with_container_env podman image rm -f "${BAZZITE_IMAGE}" 2>/dev/null || true
    sudo_with_container_env podman builder prune -af 2>/dev/null || true
    sudo_with_container_env podman image prune -f 2>/dev/null || true
}

trap cleanup_host_overrides EXIT

sudo_with_container_env() {
    if [[ -n "${PODMAN_TMPDIR}" ]]; then
        sudo env TMPDIR="${PODMAN_TMPDIR}" TMP="${PODMAN_TMPDIR}" TEMP="${PODMAN_TMPDIR}" CONTAINERS_TMPDIR="${PODMAN_TMPDIR}" "$@"
    else
        sudo "$@"
    fi
}

probe_external_podman_driver() {
    local driver="$1"
    local disable_labels="${2:-0}"
    local probe_dir=""
    local probe_root=""
    local probe_tmp=""
    local probe_runroot=""
    local probe_log=""
    local probe_image="localhost/bazzite-storage-probe:${driver}-${disable_labels}"
    local probe_status="standard"
    local -a probe_build_security_args=()

    PODMAN_DRIVER_PROBE_LOG=""
    if [[ "${disable_labels}" -eq 1 ]]; then
        probe_status="label-disabled"
    fi

    probe_dir="$(sudo mktemp -d "${EXTERNAL_BUILD_PATH}/.bazzite-podman-probe-${driver}-${probe_status}.XXXXXX" 2>/dev/null || true)"
    if [[ -z "${probe_dir}" ]]; then
        PODMAN_DRIVER_SELECTION_NOTE="Could not create an external probe directory for podman ${driver}."
        return 1
    fi

    probe_root="${probe_dir}/root"
    probe_tmp="${probe_dir}/tmp"
    probe_runroot="/run/bazzite-podman-probe-${driver}-${probe_status}-$$"
    probe_log="/var/tmp/bazzite-podman-probe-${driver}-${probe_status}.log"

    cleanup_podman_probe() {
        sudo env TMPDIR="${probe_tmp}" TMP="${probe_tmp}" TEMP="${probe_tmp}" CONTAINERS_TMPDIR="${probe_tmp}" \
            podman --root "${probe_root}" --runroot "${probe_runroot}" --storage-driver "${driver}" \
            image rm -f "${probe_image}" >/dev/null 2>&1 || true
        sudo rm -rf "${probe_runroot}" "${probe_dir}" 2>/dev/null || true
    }

    sudo mkdir -p "${probe_root}" "${probe_tmp}" "${probe_dir}/context"
    sudo chmod 1777 "${probe_tmp}"

    if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
        if command -v semanage >/dev/null 2>&1; then
            sudo semanage fcontext -a -e /var/lib/containers/storage "${probe_root}" 2>/dev/null || \
                sudo semanage fcontext -m -e /var/lib/containers/storage "${probe_root}" 2>/dev/null || true
        fi
        sudo restorecon -R -F "${probe_root}" 2>/dev/null || true
    fi

    sudo tee "${probe_dir}/context/Containerfile" > /dev/null << 'EOF'
FROM quay.io/fedora/fedora:43
RUN dd if=/dev/zero of=/probe-layer-1.bin bs=1M count=32 status=none
RUN dd if=/dev/zero of=/probe-layer-2.bin bs=1M count=32 status=none
EOF

    if [[ "${disable_labels}" -eq 1 ]]; then
        probe_build_security_args=(--security-opt label=disable)
    fi

    if sudo env TMPDIR="${probe_tmp}" TMP="${probe_tmp}" TEMP="${probe_tmp}" CONTAINERS_TMPDIR="${probe_tmp}" \
        podman --root "${probe_root}" --runroot "${probe_runroot}" --storage-driver "${driver}" \
        pull --platform linux/arm64 quay.io/fedora/fedora:43 2>&1 | tee "${probe_log}" >/dev/null && \
        sudo env TMPDIR="${probe_tmp}" TMP="${probe_tmp}" TEMP="${probe_tmp}" CONTAINERS_TMPDIR="${probe_tmp}" \
        podman --root "${probe_root}" --runroot "${probe_runroot}" --storage-driver "${driver}" \
        build \
        "${probe_build_security_args[@]}" \
        --platform linux/arm64 \
        --network=none \
        -f "${probe_dir}/context/Containerfile" \
        -t "${probe_image}" \
        "${probe_dir}/context" 2>&1 | tee -a "${probe_log}" >/dev/null; then
        cleanup_podman_probe
        rm -f "${probe_log}" 2>/dev/null || true
        return 0
    fi

    PODMAN_DRIVER_PROBE_LOG="${probe_log}"
    PODMAN_DRIVER_SELECTION_NOTE="podman ${driver} probe (${probe_status}) failed."
    cleanup_podman_probe
    return 1
}

# ──────────────────────────────────────────────────────────────────────────────
# Helper: ensure /boot/loader is the loader.0 symlink ostree requires
# ──────────────────────────────────────────────────────────────────────────────
ensure_boot_loader_symlink() {
    local target
    if [[ -L /boot/loader ]]; then
        target=$(readlink /boot/loader)
        if [[ "$target" == "loader.0" || "$target" == "loader.1" ]]; then
            return 0
        fi
        echo "Replacing /boot/loader -> ${target} with ostree-compatible loader.0 symlink..."
        sudo rm -f /boot/loader
    fi

    sudo mkdir -p /boot/loader.0

    if [[ -d /boot/loader && ! -L /boot/loader ]]; then
        echo "Migrating /boot/loader directory -> /boot/loader.0 ..."
        sudo rsync -a /boot/loader/ /boot/loader.0/
        sudo rm -rf /boot/loader
    fi

    if [[ ! -d /boot/loader.0/entries ]] || \
       [[ -z "$(find /boot/loader.0/entries -name '*.conf' 2>/dev/null | head -1)" ]]; then
        for base in /boot/efi/EFI/fedora /boot/efi/EFI/Fedora; do
            if [[ -d "${base}/loader/entries" ]]; then
                echo "Migrating ${base}/loader/ -> /boot/loader.0/ ..."
                sudo rsync -a "${base}/loader/" /boot/loader.0/
                break
            fi
            if [[ -d "${base}/entries" ]]; then
                echo "Migrating ${base}/entries -> /boot/loader.0/entries/ ..."
                sudo mkdir -p /boot/loader.0/entries
                sudo rsync -a "${base}/entries/" /boot/loader.0/entries/
                break
            fi
        done
    fi

    if [[ ! -e /boot/loader ]]; then
        sudo ln -s loader.0 /boot/loader
    elif [[ ! -L /boot/loader ]]; then
        echo "ERROR: /boot/loader exists but is not a symlink. Fix manually, then re-run."
        exit 1
    fi
}

unmask_deployment_sleep_targets() {
    local deploy_dir="$1"
    local target_path target_name

    for target_name in sleep.target suspend.target hibernate.target hybrid-sleep.target; do
        target_path="${deploy_dir}/etc/systemd/system/${target_name}"
        if [[ "$(readlink "${target_path}" 2>/dev/null || true)" == "/dev/null" ]]; then
            sudo rm -f "${target_path}"
            echo "Removed inherited sleep mask from deployment: ${target_name}"
        fi
    done
}

prepare_graphical_boot_in_deployment() {
    local deploy_dir="$1"
    local systemd_root="${deploy_dir}/etc/systemd/system"

    sudo mkdir -p "${systemd_root}"

    # The intermediate atomic base can leave /etc/systemd/system/default.target
    # pointing at multi-user.target. Because /etc persists across the final
    # rebase, that would override Bazzite's graphical default and land the user
    # in a TTY even after a successful second reboot.
    sudo rm -f "${systemd_root}/default.target"
    sudo ln -sf /usr/lib/systemd/system/graphical.target \
        "${systemd_root}/default.target"

    # Our ARM build currently targets the KDE/Kinoite desktop, so ensure the
    # display-manager alias also persists across the final rebase.
    sudo rm -f "${systemd_root}/display-manager.service"
    sudo ln -sf /usr/lib/systemd/system/sddm.service \
        "${systemd_root}/display-manager.service"
}

list_stateroot_deployments() {
    find /ostree/deploy/fedora/deploy \
        -mindepth 1 -maxdepth 1 -type d \
        -printf '%f\n' 2>/dev/null | sort || true
}

resolve_deployment_dir_for_revision() {
    local revision="$1"

    find /ostree/deploy/fedora/deploy \
        -mindepth 1 -maxdepth 1 -type d \
        -name "${revision}.*" \
        -printf '%p\n' 2>/dev/null | sort -V | tail -1 || true
}

resolve_new_deployment_dir_from_snapshot() {
    local before_snapshot="$1"
    local after_snapshot
    local new_basename=""

    after_snapshot="$(list_stateroot_deployments)" || true
    new_basename="$(
        comm -13 \
            <(printf '%s\n' "${before_snapshot}" | sed '/^$/d' | sort) \
            <(printf '%s\n' "${after_snapshot}" | sed '/^$/d' | sort) \
            | tail -1
    )" || true

    if [[ -n "${new_basename}" ]]; then
        printf '/ostree/deploy/fedora/deploy/%s\n' "${new_basename}"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────────────────────────────────────
echo "================================================="
echo "  Bazzite ARM: Full Asahi -> Bazzite Conversion"
echo "================================================="
echo ""
echo "This script will:"
echo "  1. Build the Bazzite ARM image locally"
echo "     - internal build storage: needs ~40 GB free on /"
echo "     - external build storage: needs ~20 GB free on / plus ~90 GB on the external drive"
echo "       when native overlay works on that mount"
echo "     - if the script must fall back to podman vfs, expect roughly ~420 GB external"
echo "       (~220 GB with --skip-wine)"
echo "  2. Convert this Fedora install to atomic/ostree"
echo "  3. Set up your user account"
echo "  4. Reboot into atomic Fedora which auto-rebases to Bazzite ARM"
echo ""
echo "The Asahi boot chain (m1n1/U-Boot/GRUB) will NOT be touched."
echo ""
df -h / | tail -1
ROOT_FREE_GB=$(df -BG --output=avail / | awk 'NR==2{gsub("G",""); print $1}')
if [[ -n "${EXTERNAL_BUILD_PATH}" ]]; then
    REQUIRED_ROOT_FREE_GB=20
else
    REQUIRED_ROOT_FREE_GB=40
fi
if (( ROOT_FREE_GB < REQUIRED_ROOT_FREE_GB )); then
    echo ""
    echo "ERROR: ${ROOT_FREE_GB} GB free on / is not enough for this conversion."
    if [[ -n "${EXTERNAL_BUILD_PATH}" ]]; then
        echo "Need at least ${REQUIRED_ROOT_FREE_GB} GB free on / even with --external-build,"
        echo "because the atomic base deployment, local OCI handoff image, and final"
        echo "Bazzite deployment all live on the internal stateroot."
    else
        echo "Need at least ${REQUIRED_ROOT_FREE_GB} GB free on / when building on internal"
        echo "storage, because Podman image layers and /var/lib/bazzite-install briefly"
        echo "coexist before the final rebase."
        echo ""
        echo "Either increase the Asahi system partition or rerun with:"
        echo "  bash just_scripts/asahi-rebase.sh --external-build=/path/to/external-ssd"
    fi
    exit 1
fi
echo ""
read -rp "Continue? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
fi

detect_dnf() {
    if [[ -n "${DNF_CMD}" ]]; then
        return 0
    fi

    if command -v dnf5 >/dev/null 2>&1; then
        DNF_CMD="dnf5"
    elif command -v dnf >/dev/null 2>&1; then
        DNF_CMD="dnf"
    else
        echo "ERROR: dnf/dnf5 was not found. This script must run on Fedora Asahi Remix." >&2
        exit 1
    fi
}

disable_host_broken_repos() {
    local fedora_ver

    detect_dnf
    fedora_ver="$(rpm -E %fedora 2>/dev/null || echo 43)"

    # Fresh Asahi installs can land on a stale or partially synced Fedora
    # mirror, which makes normal host prerequisite installs fail before we
    # ever reach the container build. Pin the host-side prerequisite path to
    # Fedora's direct endpoints, and disable the retired Asahi hotfixes repo.
    if [[ "${DNF_CMD}" == "dnf5" ]]; then
        sudo mkdir -p "$(dirname "${HOST_DNF_REPO_OVERRIDE}")"
        sudo tee "${HOST_DNF_REPO_OVERRIDE}" > /dev/null << EOF
[fedora]
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/releases/${fedora_ver}/Everything/\$basearch/os/
metalink=
mirrorlist=

[updates]
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/updates/${fedora_ver}/Everything/\$basearch/
metalink=
mirrorlist=

[fedora-cisco-openh264]
baseurl=https://codecs.fedoraproject.org/openh264/${fedora_ver}/\$basearch/
metalink=
mirrorlist=

[updates-archive]
enabled=0

[fedora-asahi-remix-hotfixes]
enabled=0
EOF
        HOST_DNF_REPO_OVERRIDE_ACTIVE=1
    else
        sudo dnf config-manager --save \
            "--setopt=fedora.baseurl=https://dl.fedoraproject.org/pub/fedora/linux/releases/${fedora_ver}/Everything/\$basearch/os/" \
            "--setopt=fedora.metalink=" \
            "--setopt=fedora.mirrorlist=" \
            "--setopt=updates.baseurl=https://dl.fedoraproject.org/pub/fedora/linux/updates/${fedora_ver}/Everything/\$basearch/" \
            "--setopt=updates.metalink=" \
            "--setopt=updates.mirrorlist=" \
            "--setopt=fedora-cisco-openh264.baseurl=https://codecs.fedoraproject.org/openh264/${fedora_ver}/\$basearch/" \
            "--setopt=fedora-cisco-openh264.metalink=" \
            "--setopt=fedora-cisco-openh264.mirrorlist=" \
            "--setopt=updates-archive.enabled=0" \
            "--setopt=fedora-asahi-remix-hotfixes.enabled=0" >/dev/null 2>&1 || \
            sudo sed -i 's/^enabled=1/enabled=0/' \
                /etc/yum.repos.d/*hotfixes*.repo 2>/dev/null || true
    fi
}

clean_host_dnf_metadata() {
    detect_dnf
    sudo "${DNF_CMD}" clean all >/dev/null 2>&1 || true
    sudo rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

print_host_repo_debug() {
    detect_dnf

    {
        echo "Enabled host repos:"
        if [[ "${DNF_CMD}" == "dnf5" ]]; then
            sudo dnf5 repolist --enabled || true
        else
            sudo dnf repolist enabled || true
        fi
        echo
        echo "Host Fedora repo configuration:"
        sudo grep -RHE '^\[|^baseurl=|^metalink=|^mirrorlist=|^enabled=' \
            /etc/dnf/repos.override.d/*.repo \
            /etc/yum.repos.d/fedora*.repo \
            /etc/yum.repos.d/fedora-cisco-openh264.repo \
            /etc/yum.repos.d/*hotfixes*.repo 2>/dev/null || true
    } >&2
}

print_external_build_debug() {
    local external_path="${1:-}"

    [[ -n "${external_path}" ]] || return 0

    {
        echo "External build storage:"
        findmnt -T "${external_path}" -o TARGET,SOURCE,FSTYPE,OPTIONS,SIZE,USED,AVAIL -n || true
        echo
        echo "SELinux mode:"
        getenforce 2>/dev/null || true
        echo
        echo "External storage labels:"
        ls -Zd "${external_path}" 2>/dev/null || true
        [[ -n "${PODMAN_EXT_ROOT}" ]] && ls -Zd "${PODMAN_EXT_ROOT}" 2>/dev/null || true
        [[ -n "${PODMAN_TMPDIR}" ]] && ls -Zd "${PODMAN_TMPDIR}" 2>/dev/null || true
        if [[ -n "${PODMAN_DRIVER_SELECTION_NOTE}" ]]; then
            echo
            echo "Driver selection:"
            echo "${PODMAN_DRIVER_SELECTION_NOTE}"
        fi
        if [[ -n "${PODMAN_DRIVER_PROBE_LOG}" && -f "${PODMAN_DRIVER_PROBE_LOG}" ]]; then
            echo
            echo "Probe log tail (${PODMAN_DRIVER_PROBE_LOG}):"
            tail -n 40 "${PODMAN_DRIVER_PROBE_LOG}" 2>/dev/null || true
        fi
        echo
        echo "Active podman storage.conf:"
        sudo cat /etc/containers/storage.conf 2>/dev/null || true
        echo
        echo "Podman store:"
        sudo_with_container_env podman info --format '{{.Store.GraphDriverName}} {{.Store.GraphRoot}} {{.Store.RunRoot}}' 2>/dev/null || true
    } >&2
}

run_logged_step() {
    local description="$1"
    local log_file="$2"
    shift 2

    echo "${description}"
    echo "Log: ${log_file}"
    if "$@" 2>&1 | tee "${log_file}"; then
        return 0
    fi

    echo ""
    echo "ERROR: ${description} failed."
    echo "Full log: ${log_file}"
    print_log_tail "${log_file}"
    return 1
}

run_logged_retry_step() {
    local description="$1"
    local log_file="$2"
    local attempts="$3"
    shift 3

    local attempt=1
    local delay=5

    while (( attempt <= attempts )); do
        if run_logged_step "${description} (attempt ${attempt}/${attempts})" "${log_file}" "$@"; then
            return 0
        fi

        if (( attempt == attempts )); then
            return 1
        fi

        echo "${description} failed; retrying in ${delay}s..." >&2
        sleep "${delay}"
        delay=$(( delay * 2 ))
        attempt=$(( attempt + 1 ))
    done
}

dnf_upgrade_host() {
    detect_dnf
    disable_host_broken_repos

    if [[ "${DNF_CMD}" == "dnf5" ]]; then
        if sudo dnf5 upgrade -y --refresh "${DNF5_HOST_STRICT_REPO_ARGS[@]}"; then
            return 0
        fi

        echo "Host dnf5 upgrade failed; cleaning metadata and retrying once." >&2
        clean_host_dnf_metadata
        if sudo dnf5 upgrade -y --refresh "${DNF5_HOST_STRICT_REPO_ARGS[@]}"; then
            return 0
        fi

        echo "Host dnf5 upgrade failed again after metadata refresh." >&2
        print_host_repo_debug
        return 1
    else
        if sudo dnf upgrade -y --refresh "${DNF4_HOST_STRICT_REPO_ARGS[@]}"; then
            return 0
        fi

        echo "Host dnf upgrade failed; cleaning metadata and retrying once." >&2
        clean_host_dnf_metadata
        if sudo dnf upgrade -y --refresh "${DNF4_HOST_STRICT_REPO_ARGS[@]}"; then
            return 0
        fi

        echo "Host dnf upgrade failed again after metadata refresh." >&2
        print_host_repo_debug
        return 1
    fi
}

dnf_install_host() {
    detect_dnf
    disable_host_broken_repos

    if [[ "${DNF_CMD}" == "dnf5" ]]; then
        if sudo dnf5 install -y --refresh "${DNF5_HOST_STRICT_REPO_ARGS[@]}" "$@"; then
            return 0
        fi

        echo "Host dnf5 install failed; cleaning metadata and retrying once." >&2
        clean_host_dnf_metadata
        if sudo dnf5 install -y --refresh "${DNF5_HOST_STRICT_REPO_ARGS[@]}" "$@"; then
            return 0
        fi

        echo "Host dnf5 install failed again after metadata refresh." >&2
        print_host_repo_debug
        return 1
    else
        if sudo dnf install -y --refresh "${DNF4_HOST_STRICT_REPO_ARGS[@]}" "$@"; then
            return 0
        fi

        echo "Host dnf install failed; cleaning metadata and retrying once." >&2
        clean_host_dnf_metadata
        if sudo dnf install -y --refresh "${DNF4_HOST_STRICT_REPO_ARGS[@]}" "$@"; then
            return 0
        fi

        echo "Host dnf install failed again after metadata refresh." >&2
        print_host_repo_debug
        return 1
    fi
}

print_log_tail() {
    local log_file="$1"
    local benign_pattern
    local pattern

    if [[ -f "${log_file}" ]]; then
        echo ""
        echo "First relevant failure lines from ${log_file}:"
        pattern='(^|[^[:alpha:]])(error|failed|failure|cannot|could not|no match|no space left|permission denied|curl error|status code: [45][0-9][0-9]|transaction failed|depsolve|conflicting requests|nothing provides|problem:|requires|database disk image is malformed|rpmdb)([^[:alpha:]]|$)'
        benign_pattern='(Failed to preset unit: Unit bees@.*\.service does not exist|Failed to connect to audit log, ignoring: Invalid argument|rm: cannot remove .*/run/(secrets|\.containerenv).*Device or resource busy)'
        grep -Ein "${pattern}" "${log_file}" | grep -Eiv "${benign_pattern}" | head -n 120 || true
        echo ""
        echo "Last 120 lines from ${log_file}:"
        tail -n 120 "${log_file}" || true
    fi
}

cleanup_stale_first_boot_artifacts() {
    local root_prefix="${1:-}"
    local stateroot_var="${2:-}"
    local systemd_system_root="${root_prefix}/etc/systemd/system"
    local systemd_user_root="${root_prefix}/etc/systemd/user"
    local search_root
    local stale_unit

    sudo rm -rf \
        "${root_prefix}/etc/profile.d/bazzite-rebase.sh" \
        "${systemd_system_root}/bazzite-firstboot-rebase.service" \
        "${systemd_system_root}/bazzite-first-boot-rebase.service" \
        "${systemd_system_root}/bazzite-first-boot-rebase.timer" \
        "${systemd_system_root}/bazzite-first-boot-rebase-cleanup.service" \
        "${systemd_system_root}/bazzite-first-boot-flatpaks.service" \
        "${systemd_system_root}/bazzite-flatpak-manager.service" \
        "${systemd_system_root}/bazzite-flatpak-manager.service.d" \
        "${systemd_system_root}/bazzite-hardware-setup.service" \
        "${systemd_system_root}/bazzite-hardware-setup.service.d" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-firstboot-rebase.service" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-first-boot-rebase.service" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-first-boot-rebase-cleanup.service" \
        "${systemd_system_root}/timers.target.wants/bazzite-first-boot-rebase.timer" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-first-boot-flatpaks.service" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-flatpak-manager.service" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-hardware-setup.service" \
        "${systemd_system_root}/timers.target.wants/uupd.timer" \
        "${systemd_system_root}/sockets.target.wants/podman.socket" \
        "${systemd_system_root}/default.target.wants/input-remapper.service" \
        "${systemd_system_root}/graphical.target.wants/power-profiles-daemon.service" \
        "${systemd_system_root}/boot-complete.target.requires/greenboot-healthcheck.service" \
        "${systemd_system_root}/greenboot-healthcheck.service.wants/greenboot-set-rollback-trigger.service" \
        "${systemd_system_root}/systemd-update-done.service.wants/greenboot-set-rollback-trigger.service" \
        "${systemd_system_root}/multi-user.target.wants/tailscaled.service" \
        "${systemd_system_root}/multi-user.target.wants/speakersafetyd.service" \
        "${systemd_system_root}/multi-user.target.wants/greenboot-healthcheck.service" \
        "${systemd_system_root}/multi-user.target.wants/greenboot-success.target" \
        "${systemd_user_root}/bazzite-user-setup.service" \
        "${systemd_user_root}/bazzite-user-setup.service.d" \
        "${systemd_user_root}/bazzite-dynamic-fixes.service" \
        "${systemd_user_root}/bazzite-dynamic-fixes.service.d" \
        "${systemd_user_root}/default.target.wants/bazzite-user-setup.service" \
        "${systemd_user_root}/default.target.wants/bazzite-dynamic-fixes.service" \
        "${systemd_user_root}/basic.target.wants/systemd-tmpfiles-setup.service" \
        "${systemd_user_root}/xdg-desktop-autostart.target.wants/ntfs-nag.service" \
        "${root_prefix}/usr/bin/bazzite-rebase-status" \
        "${root_prefix}/usr/local/bin/bazzite-rebase-status" \
        "${root_prefix}/var/usrlocal/bin/bazzite-rebase-status" \
        "${root_prefix}/usr/bin/bazzite-rebase-finalize-staged" \
        "${root_prefix}/usr/local/bin/bazzite-rebase-finalize-staged" \
        "${root_prefix}/var/usrlocal/bin/bazzite-rebase-finalize-staged" \
        "${root_prefix}/usr/bin/bazzite-rebase-select-next-boot" \
        "${root_prefix}/usr/local/bin/bazzite-rebase-select-next-boot" \
        "${root_prefix}/var/usrlocal/bin/bazzite-rebase-select-next-boot" 2>/dev/null || true

    if [[ -n "${stateroot_var}" ]]; then
        sudo rm -f \
            "${stateroot_var}/usrlocal/bin/bazzite-rebase-status" \
            "${stateroot_var}/usrlocal/bin/bazzite-rebase-finalize-staged" \
            "${stateroot_var}/usrlocal/bin/bazzite-rebase-select-next-boot" \
            "${stateroot_var}/lib/bazzite-rebase-queued" \
            "${stateroot_var}/lib/bazzite-rebase-done" \
            "${stateroot_var}/lib/bazzite-rebase-failed" \
            "${stateroot_var}/log/bazzite-first-boot-rebase.log" 2>/dev/null || true
    fi

    # Older conversions wrote image-owned Bazzite units into /etc/systemd.
    # Purge any such legacy unit so stale ConditionPath/ExecStart values do not
    # override the vendor-owned units from the final Bazzite image.
    for search_root in "${systemd_system_root}" "${systemd_user_root}"; do
        [[ -d "${search_root}" ]] || continue

        while IFS= read -r stale_unit; do
            [[ -n "${stale_unit}" ]] || continue
            sudo rm -rf "${stale_unit}" 2>/dev/null || true
        done < <(
            sudo grep -RIlE \
                '(^ConditionPath[^=]*=/usr/lib/bazzite(|/|_)|/usr/lib/bazzite/scripts/|bazzite-rebase-status|ostree-unverified-(image|registry):.*bazzite|%h/\.bazzite-configured|/etc/bazzite/hardware_setup_done|/usr/bin/bazzite-(user|hardware)-setup)' \
                "${search_root}" 2>/dev/null || true
        )
    done
}

ensure_overlay_kernel_support() {
    if ! command -v modprobe >/dev/null 2>&1; then
        return 0
    fi

    if lsmod 2>/dev/null | grep -q '^overlay\b'; then
        echo "Kernel overlay module already loaded."
        return 0
    fi

    if sudo modprobe overlay 2>/dev/null; then
        echo "Kernel overlay module loaded for Podman."
        return 0
    fi

    if grep -qw overlay /proc/filesystems 2>/dev/null; then
        echo "Kernel overlay filesystem support is present."
        return 0
    fi

    echo "Note: could not preload the kernel overlay module. Podman may still autoload it on first use." >&2
}

require_commands() {
    local command_name
    local -a missing=()

    for command_name in "$@"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            missing+=("${command_name}")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        echo "ERROR: Required command(s) were not installed or are not in PATH:" >&2
        printf '  %s\n' "${missing[@]}" >&2
        exit 1
    fi
}

ensure_ostree_repo_bare_mode() {
    local deploys
    local mode
    local refs

    mode="$(sudo ostree config --repo=/ostree/repo get core.mode 2>/dev/null || true)"
    if [[ "${mode}" == "bare" ]]; then
        return 0
    fi

    refs="$(sudo ostree refs --repo=/ostree/repo 2>/dev/null || true)"
    deploys="$(
        find /ostree/deploy/fedora/deploy \
            -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null || true
    )"

    if [[ -z "${refs}" && -z "${deploys}" ]]; then
        if [[ -n "${mode}" ]]; then
            echo "Resetting empty OSTree repo from unsupported mode '${mode}' to 'bare'."
        fi
        sudo rm -rf /ostree/repo
        sudo mkdir -p /ostree/repo
        sudo ostree init --repo=/ostree/repo --mode=bare
        sudo ostree config --repo=/ostree/repo set core.mode bare
        return 0
    fi

    echo "ERROR: /ostree/repo is mode '${mode}', but Bazzite image imports require mode 'bare'." >&2
    echo "Existing refs or deployments were found, so the script will not rewrite the repo automatically." >&2
    echo "If this is a failed first conversion attempt with no bootable ostree deployment, remove /ostree/repo and rerun." >&2
    exit 1
}

# ──────────────────────────────────────────────────────────────────────────────
# Step 0: Collect user credentials up front
# ──────────────────────────────────────────────────────────────────────────────
# Ask for the username and password now — before the 30+ minute build — so
# the user can enter everything and walk away. The credentials are used later
# in Step 7 to inject the user account into the new ostree deployment.
echo ""
echo "--- User account for the new Bazzite system ---"
echo "(This will be your login after the conversion is complete.)"
echo ""
read -rp "  Username: " BAZZITE_USER
while [[ -z "${BAZZITE_USER}" ]]; do
    read -rp "  Username cannot be empty. Username: " BAZZITE_USER
done

if ! command -v openssl >/dev/null 2>&1; then
    echo "Installing openssl for password hashing..."
    dnf_install_host openssl
fi

read -srp "  Password: " BAZZITE_PASS
echo ""
while [[ -z "${BAZZITE_PASS}" ]]; do
    read -srp "  Password cannot be empty. Password: " BAZZITE_PASS
    echo ""
done
BAZZITE_PASS_HASH=$(printf '%s' "${BAZZITE_PASS}" | openssl passwd -6 -stdin)
unset BAZZITE_PASS
echo "  User '${BAZZITE_USER}' will be created after the build completes."
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# Step 1: Install prerequisites
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 1: Install prerequisites ---"
dnf_upgrade_host
dnf_install_host \
    podman \
    git \
    rpm-ostree \
    ostree \
    rsync \
    skopeo \
    fuse-overlayfs \
    policycoreutils-python-utils \
    openssl
require_commands podman git rpm-ostree ostree rsync skopeo openssl
ensure_overlay_kernel_support

# Prevent the system from sleeping during the 60-90 minute build.
# The build will be killed if the system suspends mid-way.
echo "Disabling sleep/suspend for the duration of this script..."
sudo systemctl mask --now \
    sleep.target suspend.target hibernate.target \
    hybrid-sleep.target 2>/dev/null || true
SLEEP_MASKED=1

# ──────────────────────────────────────────────────────────────────────────────
# Step 1b: Redirect podman build storage to external SSD (if requested)
# ──────────────────────────────────────────────────────────────────────────────
if [[ -n "${EXTERNAL_BUILD_PATH}" ]]; then
    echo ""
    echo "--- Step 1b: Configuring podman to use external build storage ---"
    if [[ ! -d "${EXTERNAL_BUILD_PATH}" ]]; then
        echo "ERROR: External build path '${EXTERNAL_BUILD_PATH}' does not exist."
        echo "Mount your external SSD first:"
        echo "  sudo mkdir -p ${EXTERNAL_BUILD_PATH}"
        echo "  sudo mount /dev/sda ${EXTERNAL_BUILD_PATH}  # adjust device as needed"
        exit 1
    fi

    EXTERNAL_BUILD_PATH=$(readlink -f "${EXTERNAL_BUILD_PATH}")
    EXTERNAL_SOURCE=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no SOURCE 2>/dev/null || true)
    EXTERNAL_TARGET=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no TARGET 2>/dev/null || true)
    EXTERNAL_FSTYPE=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no FSTYPE 2>/dev/null || true)
    EXTERNAL_OPTIONS=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no OPTIONS 2>/dev/null || true)
    EXTERNAL_MAJ_MIN=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no MAJ:MIN 2>/dev/null || true)
    ROOT_MAJ_MIN=$(findmnt -no MAJ:MIN / 2>/dev/null || true)

    if [[ -z "${EXTERNAL_SOURCE}" || -z "${EXTERNAL_TARGET}" || -z "${EXTERNAL_FSTYPE}" || -z "${EXTERNAL_OPTIONS}" || -z "${EXTERNAL_MAJ_MIN}" || -z "${ROOT_MAJ_MIN}" ]]; then
        echo "ERROR: Could not resolve the filesystem backing '${EXTERNAL_BUILD_PATH}'."
        exit 1
    fi

    if [[ "${EXTERNAL_TARGET}" == "/" || "${EXTERNAL_MAJ_MIN}" == "${ROOT_MAJ_MIN}" ]]; then

        echo "ERROR: '${EXTERNAL_BUILD_PATH}' is on the internal root filesystem, not an external drive mount."
        echo "Mount the external SSD first and pass that mount path, for example /mnt/external."
        exit 1
    fi

    case "${EXTERNAL_FSTYPE}" in
        ext4|xfs|btrfs)
            ;;
        *)
            echo "ERROR: '${EXTERNAL_BUILD_PATH}' is ${EXTERNAL_FSTYPE}, but podman build storage needs a Linux filesystem."
            echo "Reformat or mount the external build volume as ext4, xfs, or btrfs."
            exit 1
            ;;
    esac

    if [[ ",${EXTERNAL_OPTIONS}," == *,ro,* ]]; then
        echo "ERROR: '${EXTERNAL_BUILD_PATH}' is mounted read-only."
        echo "Remount it read-write before using --external-build."
        exit 1
    fi

    if [[ ",${EXTERNAL_OPTIONS}," == *,noexec,* ]]; then
        echo "ERROR: '${EXTERNAL_BUILD_PATH}' is mounted with noexec."
        echo "Podman must execute binaries from the external graphroot during the build."
        echo "Remount the filesystem with exec or use a different external drive mount."
        exit 1
    fi

    echo "External build mount:"
    findmnt -T "${EXTERNAL_BUILD_PATH}" -o TARGET,SOURCE,FSTYPE,OPTIONS,SIZE,USED,AVAIL -n

    EXTERNAL_TEST_DIR="$(sudo mktemp -d "${EXTERNAL_BUILD_PATH}/.bazzite-podman-test.XXXXXX" 2>/dev/null || true)"
    if [[ -z "${EXTERNAL_TEST_DIR}" ]]; then
        echo "ERROR: Could not create a temporary validation directory under '${EXTERNAL_BUILD_PATH}'."
        exit 1
    fi

    cleanup_external_test_dir() {
        if [[ -n "${EXTERNAL_TEST_DIR:-}" ]]; then
            sudo rm -rf "${EXTERNAL_TEST_DIR}" 2>/dev/null || true
        fi
    }

    if ! sudo touch "${EXTERNAL_TEST_DIR}/write-test" ||
        ! sudo ln -s write-test "${EXTERNAL_TEST_DIR}/symlink-test" ||
        ! sudo ln "${EXTERNAL_TEST_DIR}/write-test" "${EXTERNAL_TEST_DIR}/hardlink-test"; then
        cleanup_external_test_dir
        echo "ERROR: '${EXTERNAL_BUILD_PATH}' does not support the write/symlink/hardlink operations podman storage needs."
        exit 1
    fi

    sudo tee "${EXTERNAL_TEST_DIR}/exec-test.sh" > /dev/null << 'EOF'
#!/bin/sh
exit 0
EOF
    sudo chmod 755 "${EXTERNAL_TEST_DIR}/exec-test.sh"
    if ! sudo "${EXTERNAL_TEST_DIR}/exec-test.sh"; then
        cleanup_external_test_dir
        echo "ERROR: '${EXTERNAL_BUILD_PATH}' cannot execute files as mounted."
        echo "This usually means the filesystem was mounted with noexec or an incompatible security policy."
        exit 1
    fi

    PODMAN_STORAGE_DRIVER=""
    PODMAN_BUILD_SECURITY_ARGS=()
    PODMAN_DRIVER_SELECTION_NOTE=""
    EXTERNAL_DRIVER_MODE="${BAZZITE_EXTERNAL_PODMAN_DRIVER:-auto}"
    case "${EXTERNAL_DRIVER_MODE}" in
        auto|overlay|vfs)
            ;;
        *)
            cleanup_external_test_dir
            echo "ERROR: BAZZITE_EXTERNAL_PODMAN_DRIVER must be one of: auto, overlay, vfs"
            exit 1
            ;;
    esac

    if [[ "${EXTERNAL_DRIVER_MODE}" != "vfs" ]]; then
        echo "Probing external podman overlay storage..."
        if probe_external_podman_driver overlay 0; then
            PODMAN_STORAGE_DRIVER="overlay"
            PODMAN_DRIVER_SELECTION_NOTE="Using podman overlay on ${EXTERNAL_BUILD_PATH} (probe passed with SELinux labels enabled)."
        elif command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled && probe_external_podman_driver overlay 1; then
            PODMAN_STORAGE_DRIVER="overlay"
            PODMAN_BUILD_SECURITY_ARGS=(--security-opt label=disable)
            PODMAN_DRIVER_SELECTION_NOTE="Using podman overlay on ${EXTERNAL_BUILD_PATH} with SELinux label separation disabled (overlay probe required it)."
        elif [[ "${EXTERNAL_DRIVER_MODE}" == "overlay" ]]; then
            cleanup_external_test_dir
            echo "ERROR: BAZZITE_EXTERNAL_PODMAN_DRIVER=overlay was requested, but the overlay probe failed."
            if [[ -n "${PODMAN_DRIVER_PROBE_LOG}" && -f "${PODMAN_DRIVER_PROBE_LOG}" ]]; then
                echo "Probe log: ${PODMAN_DRIVER_PROBE_LOG}"
                tail -n 40 "${PODMAN_DRIVER_PROBE_LOG}" || true
            fi
            exit 1
        fi
    fi

    if [[ "${EXTERNAL_DRIVER_MODE}" == "vfs" || "${PODMAN_STORAGE_DRIVER}" != "overlay" ]]; then
        PODMAN_STORAGE_DRIVER="vfs"
        if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
            PODMAN_BUILD_SECURITY_ARGS=(--security-opt label=disable)
        fi
        if [[ "${EXTERNAL_DRIVER_MODE}" == "vfs" ]]; then
            PODMAN_DRIVER_SELECTION_NOTE="Using podman vfs because BAZZITE_EXTERNAL_PODMAN_DRIVER=vfs forced it."
        elif [[ -n "${PODMAN_DRIVER_SELECTION_NOTE}" ]]; then
            PODMAN_DRIVER_SELECTION_NOTE="${PODMAN_DRIVER_SELECTION_NOTE} Falling back to podman vfs for compatibility."
        else
            PODMAN_DRIVER_SELECTION_NOTE="Falling back to podman vfs because the external overlay probe did not pass."
        fi
    fi
    cleanup_external_test_dir

    echo "${PODMAN_DRIVER_SELECTION_NOTE}"

    # How much free space is on the external path?
    EXTERNAL_FREE_GB=$(df -BG "${EXTERNAL_BUILD_PATH}" | awk 'NR==2{gsub("G",""); print $4}')
    if [[ "${PODMAN_STORAGE_DRIVER}" == "vfs" ]]; then
        if [[ "${SKIP_WINE}" -eq 1 ]]; then
            REQUIRED_EXTERNAL_FREE_GB=220
        else
            REQUIRED_EXTERNAL_FREE_GB=420
        fi
    elif [[ "${SKIP_WINE}" -eq 1 ]]; then
        REQUIRED_EXTERNAL_FREE_GB=50
    else
        REQUIRED_EXTERNAL_FREE_GB=90
    fi
    echo "External path free space: ${EXTERNAL_FREE_GB} GB (need ~${REQUIRED_EXTERNAL_FREE_GB} GB)"
    if (( EXTERNAL_FREE_GB < REQUIRED_EXTERNAL_FREE_GB )); then
        echo "ERROR: Not enough free space on ${EXTERNAL_BUILD_PATH} (${EXTERNAL_FREE_GB} GB < ${REQUIRED_EXTERNAL_FREE_GB} GB needed)"
        exit 1
    fi

    PODMAN_EXT_ROOT="${EXTERNAL_BUILD_PATH}/podman-build"
    PODMAN_TMPDIR="${EXTERNAL_BUILD_PATH}/podman-tmp"
    if [[ -d "${PODMAN_EXT_ROOT}" ]]; then
        echo "Removing stale external build storage at ${PODMAN_EXT_ROOT}..."
        sudo rm -rf "${PODMAN_EXT_ROOT}"
    fi
    sudo mkdir -p "${PODMAN_EXT_ROOT}"
    sudo mkdir -p "${PODMAN_TMPDIR}"
    sudo chmod 1777 "${PODMAN_TMPDIR}"

    if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
        if command -v semanage >/dev/null 2>&1; then
            sudo semanage fcontext -a -e /var/lib/containers/storage "${PODMAN_EXT_ROOT}" 2>/dev/null || \
                sudo semanage fcontext -m -e /var/lib/containers/storage "${PODMAN_EXT_ROOT}" 2>/dev/null || true
        fi
        sudo restorecon -R -F "${PODMAN_EXT_ROOT}" 2>/dev/null || true
    fi

    if [[ -f "${PODMAN_STORAGE_CONF}" && -z "${PODMAN_STORAGE_CONF_BACKUP}" ]]; then
        PODMAN_STORAGE_CONF_BACKUP=$(mktemp /tmp/bazzite-storage.conf.XXXXXX)
        sudo cp -a "${PODMAN_STORAGE_CONF}" "${PODMAN_STORAGE_CONF_BACKUP}"
        sudo chown "$(id -u):$(id -g)" "${PODMAN_STORAGE_CONF_BACKUP}" 2>/dev/null || true
    fi

    # Write /etc/containers/storage.conf for root to redirect all podman storage.
    # This affects sudo podman build, sudo podman image exists, and
    # sudo skopeo copy containers-storage:... -- all use this config.
    sudo mkdir -p /etc/containers
    sudo tee /etc/containers/storage.conf > /dev/null << EOF
[storage]
driver = "${PODMAN_STORAGE_DRIVER}"
graphRoot = "${PODMAN_EXT_ROOT}"
runRoot = "/run/containers/storage"
EOF
    PODMAN_STORAGE_OVERRIDE_ACTIVE=1
    echo "Podman root storage → ${PODMAN_EXT_ROOT}"
    echo "Podman storage driver → ${PODMAN_STORAGE_DRIVER}"
    echo "Podman temp directory → ${PODMAN_TMPDIR}"
    echo "Internal disk freed from container build layers (~20 GB saved)."

    if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
        if [[ "${#PODMAN_BUILD_SECURITY_ARGS[@]}" -gt 0 ]]; then
            echo "SELinux is enabled; using podman build with SELinux label separation disabled for the external ${PODMAN_STORAGE_DRIVER} graphroot."
        else
            echo "SELinux is enabled; podman build will use normal SELinux label separation for the external ${PODMAN_STORAGE_DRIVER} graphroot."
        fi
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 2: Build Bazzite ARM image
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 2: Build Bazzite ARM image ---"
echo "This takes ~25 minutes with --skip-wine (~85 min without). Output is live."
echo ""
BUILD_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-podman-build.log"

if sudo_with_container_env podman image exists "${BAZZITE_IMAGE}" 2>/dev/null; then
    echo "Bazzite ARM image already exists; skipping build."
else
    cd "${REPO_ROOT}"
    echo "Build log: ${BUILD_LOG}"
    echo "Pruning stale Podman builder cache before the native build..."
    sudo_with_container_env podman builder prune -af 2>/dev/null || true
    if ! sudo_with_container_env podman build \
        "${PODMAN_BUILD_SECURITY_ARGS[@]}" \
        --no-cache \
        --pull=always \
        --platform linux/arm64 \
        -f Containerfile.arm \
        --build-arg BASE_IMAGE_NAME=kinoite \
        --build-arg FEDORA_VERSION=43 \
        --build-arg IMAGE_NAME="${IMAGE_NAME}" \
        --build-arg IMAGE_VENDOR=nripeshn \
        --build-arg KERNEL_VARIANT="${KERNEL_VARIANT}" \
        --build-arg IMAGE_BRANCH="${IMAGE_BRANCH}" \
        --build-arg SKIP_WINE="${SKIP_WINE}" \
        --build-arg SKIP_HEROIC="$(( BUILD_HEROIC == 1 ? 0 : 1 ))" \
        --build-arg SKIP_PROTON="$(( BUILD_PROTON == 1 ? 0 : 1 ))" \
        --build-arg VERSION_TAG=local \
        --build-arg VERSION_PRETTY="Local Build" \
        --build-arg SHA_HEAD_SHORT="${IMAGE_TAG}" \
        -t "${BAZZITE_IMAGE}" \
        . 2>&1 | tee "${BUILD_LOG}"; then
        echo ""
        echo "ERROR: Bazzite ARM image build failed."
        echo "Full build log: ${BUILD_LOG}"
        print_log_tail "${BUILD_LOG}"
        print_external_build_debug "${EXTERNAL_BUILD_PATH}"
        exit 1
    fi
    echo "Bazzite ARM image built successfully."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 3: Initialize ostree repository
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 3: Initialize ostree repository ---"
sudo mkdir -p /ostree/repo
if [[ ! -f /ostree/repo/config ]]; then
    sudo ostree init --repo=/ostree/repo --mode=bare
else
    echo "OSTree repo already initialized; skipping."
fi
ensure_ostree_repo_bare_mode
sudo ostree config --repo=/ostree/repo set sysroot.bootloader none
sudo ostree config --repo=/ostree/repo set sysroot.readonly true

ensure_boot_loader_symlink

sudo mkdir -p /ostree/deploy
if [[ ! -d /ostree/deploy/fedora ]]; then
    sudo ostree admin os-init fedora --sysroot /
else
    echo "Stateroot 'fedora' already exists; skipping os-init."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 4: Pull the atomic base image into ostree
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 4: Pull Fedora Asahi Atomic base image ---"
PULL_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-atomic-pull.log"
if ! run_logged_retry_step \
    "Pulling ${ATOMIC_BASE} (may take a few minutes)" \
    "${PULL_LOG}" \
    3 \
    sudo ostree container image pull /ostree/repo \
        "ostree-unverified-registry:${ATOMIC_BASE}"; then
    echo ""
    echo "ERROR: Failed to pull ${ATOMIC_BASE} after 3 attempts."
    echo "Full pull log: ${PULL_LOG}"
    print_log_tail "${PULL_LOG}"
    exit 1
fi
echo "Pull complete."

# ──────────────────────────────────────────────────────────────────────────────
# Step 5: Detect root UUID
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 5: Detect root partition UUID ---"
ROOT_UUID=$(grep -oP 'root=UUID=\K[^\s]+' /proc/cmdline 2>/dev/null || true)
if [[ -z "$ROOT_UUID" ]]; then
    ROOT_UUID=$(sed -n 's/.*root=UUID=\([^ ]*\).*/\1/p' /proc/cmdline 2>/dev/null || true)
fi
if [[ -z "$ROOT_UUID" ]]; then
    ROOT_UUID=$(findmnt -no UUID / 2>/dev/null || true)
fi
echo "Root UUID: ${ROOT_UUID}"
if [[ -z "$ROOT_UUID" ]]; then
    echo "ERROR: Could not detect root UUID."
    echo "  /proc/cmdline: $(cat /proc/cmdline)"
    echo "  findmnt: $(findmnt -no SOURCE,UUID / 2>/dev/null || true)"
    exit 1
fi

# Capture /boot and /boot/efi UUIDs from the RUNNING traditional system.
# The base-atomic image's fstab only has / -- it doesn't know about Asahi's
# separate /boot (ext4) and /boot/efi (vfat) partitions. Without fstab entries
# for these, the atomic system boots with /boot unmounted (read-only overlay),
# and all attempts to write to /boot (including rpm-ostreed setup) fail with
# "Read-only file system".
BOOT_UUID=$(findmnt -no UUID /boot 2>/dev/null || true)
BOOT_FSTYPE=$(findmnt -no FSTYPE /boot 2>/dev/null || echo "ext4")
EFI_UUID=$(findmnt -no UUID /boot/efi 2>/dev/null || true)
echo "Boot UUID:  ${BOOT_UUID:-NOT FOUND} (${BOOT_FSTYPE})"
echo "EFI UUID:   ${EFI_UUID:-NOT FOUND}"

# ──────────────────────────────────────────────────────────────────────────────
# Step 6: Deploy the atomic base image
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 6: Deploy atomic base image ---"

# Resolve deployable ref
REF=""
CANDIDATE="ostree-unverified-registry:${ATOMIC_BASE}"
if sudo ostree rev-parse --repo=/ostree/repo "${CANDIDATE}" &>/dev/null; then
    REF="${CANDIDATE}"
fi
if [[ -z "${REF}" ]]; then
    mapfile -t _image_refs < <(sudo ostree refs --repo=/ostree/repo \
        | grep '^ostree/container/image/' || true)
    if [[ "${#_image_refs[@]}" -eq 1 ]]; then
        REF="${_image_refs[0]}"
    elif [[ "${#_image_refs[@]}" -gt 1 ]]; then
        echo "ERROR: Multiple ostree/container/image refs found:"
        printf '  %s\n' "${_image_refs[@]}"
        exit 1
    fi
fi
if [[ -z "${REF}" ]] || ! sudo ostree rev-parse --repo=/ostree/repo "${REF}" &>/dev/null; then
    echo "ERROR: No deployable ref in /ostree/repo."
    sudo ostree refs --repo=/ostree/repo
    exit 1
fi
echo "Deploying ref: ${REF}"

TARGET_REV=$(sudo ostree rev-parse --repo=/ostree/repo "${REF}")
EXISTING_KARGS=$(cat /proc/cmdline)
DEPLOY_DIR=""
PRE_DEPLOYMENT_SNAPSHOT="$(list_stateroot_deployments)"

# Preserve rootflags (needed for btrfs subvol on Asahi)
ROOTFLAGS_KARG=()
if [[ "$EXISTING_KARGS" =~ rootflags=([^[:space:]]+) ]]; then
    ROOTFLAGS_KARG=(--karg="rootflags=${BASH_REMATCH[1]}")
    echo "Preserving rootflags=${BASH_REMATCH[1]}"
fi

_skip_deploy=0
if [[ -z "${OSTREE_FORCE_DEPLOY:-}" ]]; then
    _ostree_status="$(sudo ostree admin status --sysroot=/ 2>/dev/null || true)"
    if printf '%s\n' "${_ostree_status}" | grep -qF "${TARGET_REV:0:16}"; then
        _skip_deploy=1
    fi
fi

if [[ "${_skip_deploy}" -eq 1 ]]; then
    echo "Revision already deployed; skipping (set OSTREE_FORCE_DEPLOY=1 to force)."
    DEPLOY_DIR="$(resolve_deployment_dir_for_revision "${TARGET_REV}")" || true
else
    DEPLOY_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-atomic-deploy.log"
    if ! run_logged_step \
        "Deploying atomic base image" \
        "${DEPLOY_LOG}" \
        sudo ostree admin deploy "${REF}" \
            --sysroot / \
            --os fedora \
            --karg="root=UUID=${ROOT_UUID}" \
            --karg="ro" \
            --karg="rhgb" \
            --karg="quiet" \
            "${ROOTFLAGS_KARG[@]}"; then
        echo ""
        echo "ERROR: ostree admin deploy failed."
        echo "Full deploy log: ${DEPLOY_LOG}"
        print_log_tail "${DEPLOY_LOG}"
        exit 1
    fi
    echo "Deploy command completed. Resolving deployment directory..."
    DEPLOY_DIR="$(resolve_new_deployment_dir_from_snapshot "${PRE_DEPLOYMENT_SNAPSHOT}")" || true
    echo "Snapshot-based resolution: DEPLOY_DIR='${DEPLOY_DIR:-<empty>}'"
    if [[ -z "${DEPLOY_DIR}" || ! -d "${DEPLOY_DIR}" ]]; then
        echo "Snapshot resolution returned empty/nonexistent; trying revision-based resolution..."
        DEPLOY_DIR="$(resolve_deployment_dir_for_revision "${TARGET_REV}")" || true
        echo "Revision-based resolution: DEPLOY_DIR='${DEPLOY_DIR:-<empty>}'"
    fi
fi

if [[ -z "${DEPLOY_DIR}" || ! -d "${DEPLOY_DIR}" ]]; then
    echo "Listing all deployment directories for diagnosis:"
    find /ostree/deploy/fedora/deploy -maxdepth 2 -type d 2>/dev/null || true
    echo "TARGET_REV=${TARGET_REV}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 7: Inject user account into the new deployment
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 7: Inject user account into new deployment ---"

if [[ -z "$DEPLOY_DIR" || ! -d "$DEPLOY_DIR" ]]; then
    DEPLOY_DIR="$(resolve_deployment_dir_for_revision "${TARGET_REV}")" || true
fi

if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    unmask_deployment_sleep_targets "$DEPLOY_DIR"
    prepare_graphical_boot_in_deployment "$DEPLOY_DIR"
fi

# ── CRITICAL: Inject /boot and /boot/efi into the deployment's fstab ─────────
# The base-atomic image ships with an fstab that only has /. Without entries
# for /boot (ext4, disk0s5) and /boot/efi (vfat, disk0s4), the atomic system
# boots with those partitions unmounted. rpm-ostreed then fails with
# "Read-only file system" when it tries to write to /boot/loader.
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    FSTAB="${DEPLOY_DIR}/etc/fstab"
    sudo touch "${FSTAB}"

    if [[ -n "$BOOT_UUID" ]] && ! grep -q "UUID=${BOOT_UUID}" "${FSTAB}" 2>/dev/null; then
        echo "UUID=${BOOT_UUID}  /boot  ${BOOT_FSTYPE}  defaults  1  2" \
            | sudo tee -a "${FSTAB}" > /dev/null
        echo "Added /boot (UUID=${BOOT_UUID}) to deployment fstab."
    fi

    if [[ -n "$EFI_UUID" ]] && ! grep -q "UUID=${EFI_UUID}" "${FSTAB}" 2>/dev/null; then
        echo "UUID=${EFI_UUID}  /boot/efi  vfat  umask=0077,shortname=winnt  0  2" \
            | sudo tee -a "${FSTAB}" > /dev/null
        echo "Added /boot/efi (UUID=${EFI_UUID}) to deployment fstab."
    fi

    echo "Deployment fstab:"
    cat "${FSTAB}"
fi

# Wrap in subshell with set +e -- user errors must NEVER block the GRUB update
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    echo "Deployment directory: $DEPLOY_DIR"
    (
        set +e
        NEW_USER="${BAZZITE_USER}"
        PASS_HASH="${BAZZITE_PASS_HASH}"

        # Unlock root
        sudo sed -i "s|^root:[^:]*:|root:${PASS_HASH}:|" "${DEPLOY_DIR}/etc/shadow"
        echo "Root account unlocked."

        if ! grep -q "^${NEW_USER}:" "${DEPLOY_DIR}/etc/passwd" 2>/dev/null; then
            NEXT_UID=$(awk -F: 'BEGIN{max=999} $3>max && $3<60000{max=$3} END{print max+1}' \
                "${DEPLOY_DIR}/etc/passwd")
            printf '%s:x:%s:%s:%s:/home/%s:/bin/bash\n' \
                "${NEW_USER}" "${NEXT_UID}" "${NEXT_UID}" "${NEW_USER}" "${NEW_USER}" \
                | sudo tee -a "${DEPLOY_DIR}/etc/passwd" > /dev/null
            printf '%s:x:%s:\n' "${NEW_USER}" "${NEXT_UID}" \
                | sudo tee -a "${DEPLOY_DIR}/etc/group" > /dev/null
            printf '%s:%s:19900:0:99999:7:::\n' "${NEW_USER}" "${PASS_HASH}" \
                | sudo tee -a "${DEPLOY_DIR}/etc/shadow" > /dev/null

            # ostree persistent var lives at /ostree/deploy/fedora/var/ --
            # NOT inside the deployment dir. This is what becomes /var after boot.
            STATEROOT_VAR="/ostree/deploy/fedora/var"
            sudo mkdir -p "${STATEROOT_VAR}/home/${NEW_USER}" 2>/dev/null || true
            sudo chown "${NEXT_UID}:${NEXT_UID}" \
                "${STATEROOT_VAR}/home/${NEW_USER}" 2>/dev/null || true

            # Add to wheel for sudo (check membership first to avoid duplicates/malformation)
            if grep -q "^wheel:" "${DEPLOY_DIR}/etc/group"; then
                if ! grep -qE "^wheel:.*[:,]${NEW_USER}(,|$)" "${DEPLOY_DIR}/etc/group"; then
                    sudo sed -i "/^wheel:/ s/$/,${NEW_USER}/" "${DEPLOY_DIR}/etc/group"
                    sudo sed -i 's/:,/:/' "${DEPLOY_DIR}/etc/group"
                fi
            fi
            echo "User '${NEW_USER}' created in deployment."
        else
            sudo sed -i "s|^${NEW_USER}:[^:]*:|${NEW_USER}:${PASS_HASH}:|" \
                "${DEPLOY_DIR}/etc/shadow"
            echo "Password updated for existing user '${NEW_USER}'."
        fi
    ) || echo "WARNING: User setup had errors -- continuing to GRUB update."
else
    echo "WARNING: Could not find deployment directory. Log in as root after reboot."
fi
unset BAZZITE_PASS_HASH

# ──────────────────────────────────────────────────────────────────────────────
# Step 7b: Configure external SSD for persistent use after Bazzite boot
# ──────────────────────────────────────────────────────────────────────────────
# When --external-build is used the internal partition is typically small.
# Mount the external SSD permanently and redirect ALL heavy-storage consumers
# (podman, flatpak, Steam, games) there so the internal disk only holds the
# atomic OS image and /etc.
if [[ -n "${EXTERNAL_BUILD_PATH}" ]] && [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    EXT_DEV=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no SOURCE 2>/dev/null || true)
    EXT_DEV="${EXT_DEV%%[*}"
    EXT_FSTYPE=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no FSTYPE 2>/dev/null || true)
    EXT_FSCK_PASSNO=0
    EXT_UUID=""
    if [[ -n "${EXT_DEV}" && -b "${EXT_DEV}" ]]; then
        EXT_UUID=$(sudo blkid -s UUID -o value "${EXT_DEV}" 2>/dev/null || true)
    fi
    if [[ "${EXT_FSTYPE}" =~ ^ext[234]$ ]]; then
        EXT_FSCK_PASSNO=2
    fi
    if [[ -n "$EXT_UUID" && -n "$EXT_FSTYPE" ]]; then
        EXT_MOUNT="/var/mnt/external"
        EXT_FSTAB="${DEPLOY_DIR}/etc/fstab"
        STATEROOT_VAR_EXT="/ostree/deploy/fedora/var"

        sudo sed -i "\|[[:space:]]${EXT_MOUNT}[[:space:]]|d" "${EXT_FSTAB}"
        echo "UUID=${EXT_UUID}  ${EXT_MOUNT}  ${EXT_FSTYPE}  defaults,nofail,x-systemd.automount  0  ${EXT_FSCK_PASSNO}" \
            | sudo tee -a "${EXT_FSTAB}" > /dev/null
        echo "Added external SSD (UUID=${EXT_UUID}) → ${EXT_MOUNT} in deployment fstab."

        sudo mkdir -p "${STATEROOT_VAR_EXT}/mnt/external"

        # Pre-create directory structure on the external SSD itself
        for dir in containers/storage flatpak games steam .local/share/Steam; do
            sudo mkdir -p "${EXTERNAL_BUILD_PATH}/bazzite/${dir}"
        done
        sudo chmod -R 755 "${EXTERNAL_BUILD_PATH}/bazzite"

        # --- Podman root storage ---
        sudo mkdir -p "${DEPLOY_DIR}/etc/containers"
        sudo tee "${DEPLOY_DIR}/etc/containers/storage.conf" > /dev/null << PODMANCFG
[storage]
driver = "overlay"
graphRoot = "${EXT_MOUNT}/bazzite/containers/storage"
runRoot = "/run/containers/storage"
PODMANCFG
        echo "Configured podman root storage → ${EXT_MOUNT}/bazzite/containers/storage"

        # --- Flatpak system-wide installation ---
        sudo mkdir -p "${DEPLOY_DIR}/etc/flatpak"
        if [[ ! -f "${DEPLOY_DIR}/etc/flatpak/installations.d" ]]; then
            sudo mkdir -p "${DEPLOY_DIR}/etc/flatpak/installations.d"
        fi
        sudo tee "${DEPLOY_DIR}/etc/flatpak/installations.d/external.conf" > /dev/null << FLATPAKCFG
[Installation "external"]
Path=${EXT_MOUNT}/bazzite/flatpak
DisplayName=External SSD
StorageType=harddisk
FLATPAKCFG
        echo "Configured Flatpak external installation → ${EXT_MOUNT}/bazzite/flatpak"

        # --- First-boot setup script to create user-level symlinks ---
        # This runs once on first login to redirect Steam data and general
        # game storage to the external SSD under the user's home.
        sudo mkdir -p "${DEPLOY_DIR}/etc/profile.d"
        sudo tee "${DEPLOY_DIR}/etc/profile.d/bazzite-external-storage.sh" > /dev/null << 'EXTSH'
#!/usr/bin/bash
# Redirect heavy user-level storage to external SSD (runs once per user)
EXT="/var/mnt/external/bazzite"
MARKER="${HOME}/.bazzite-external-storage-configured"

if [[ -d "${EXT}" && ! -f "${MARKER}" ]]; then
    # Steam data directory
    if [[ ! -e "${HOME}/.local/share/Steam" ]]; then
        mkdir -p "${HOME}/.local/share"
        mkdir -p "${EXT}/steam/user-${UID}"
        ln -sf "${EXT}/steam/user-${UID}" "${HOME}/.local/share/Steam"
    fi

    # Heroic data directory
    if [[ ! -e "${HOME}/.config/heroic" ]]; then
        mkdir -p "${HOME}/.config"
        mkdir -p "${EXT}/heroic/user-${UID}"
        ln -sf "${EXT}/heroic/user-${UID}" "${HOME}/.config/heroic"
    fi

    # Games directory shortcut
    mkdir -p "${EXT}/games"
    if [[ ! -e "${HOME}/Games" ]]; then
        ln -sf "${EXT}/games" "${HOME}/Games"
    fi

    # User-level podman storage
    if [[ ! -f "${HOME}/.config/containers/storage.conf" ]]; then
        mkdir -p "${HOME}/.config/containers"
        cat > "${HOME}/.config/containers/storage.conf" << USRPOD
[storage]
driver = "overlay"
graphRoot = "${EXT}/containers/user-${UID}"
runRoot = "/run/user/${UID}/containers"
USRPOD
    fi

    touch "${MARKER}"
fi
EXTSH
        echo "Installed first-login external storage redirect script."

        # Backward-compat: also set up /var/mnt/games symlink
        sudo sed -i '\|[[:space:]]/var/mnt/games[[:space:]]|d' "${EXT_FSTAB}"
        sudo mkdir -p "${STATEROOT_VAR_EXT}/mnt/games"
        sudo ln -sf "${EXT_MOUNT}/bazzite/games" "${STATEROOT_VAR_EXT}/mnt/games" 2>/dev/null || true

        echo ""
        echo "External SSD storage layout (${EXT_MOUNT}/bazzite/):"
        echo "  containers/storage  — podman root images/containers"
        echo "  flatpak/            — Flatpak apps (use: flatpak --installation=external install ...)"
        echo "  steam/              — Steam data (symlinked from ~/.local/share/Steam)"
        echo "  heroic/             — Heroic data (symlinked from ~/.config/heroic)"
        echo "  games/              — General game storage (symlinked from ~/Games)"
        echo "  containers/user-*   — User-level podman storage"
    else
        echo "Note: could not detect external SSD UUID -- skipping persistent storage setup."
        echo "      After Bazzite boots, run: ujust setup-games-drive /dev/sda"
    fi
fi
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 8: Export Bazzite image for first-boot rebase ---"

# The ostree stateroot var (/ostree/deploy/fedora/var) becomes /var after boot.
# Export the image as an OCI archive there so the first-boot service can
# rebase directly from local storage without needing network access.
STATEROOT_VAR="/ostree/deploy/fedora/var"
OCI_DEST="${STATEROOT_VAR}/lib/bazzite-install"

sudo mkdir -p "${OCI_DEST}"
echo "Exporting Bazzite ARM image to ${OCI_DEST} (may take a few minutes)..."
EXPORT_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-oci-export.log"
echo "Export log: ${EXPORT_LOG}"
if ! sudo_with_container_env skopeo copy \
    "containers-storage:${BAZZITE_IMAGE}" \
    "oci:${OCI_DEST}:latest" 2>&1 | tee "${EXPORT_LOG}"; then
    echo ""
    echo "ERROR: Failed to export Bazzite image to ${OCI_DEST}."
    echo "Full export log: ${EXPORT_LOG}"
    print_log_tail "${EXPORT_LOG}"
    exit 1
fi
echo "Image exported successfully."

echo ""
echo "--- Cleaning up local Podman image/build cache (image now in ${OCI_DEST}) ---"
cleanup_local_podman_image
echo "Local Podman build artifacts cleaned."

# Now that the OCI archive is safely on the internal stateroot var and the
# source image has been removed from Podman, external build storage is no
# longer needed. Clean it up to free the SSD for games/data after first boot.
if [[ -n "${EXTERNAL_BUILD_PATH}" ]]; then
    echo ""
    echo "--- Cleaning up external build storage (image now in ${OCI_DEST}) ---"
    cleanup_external_podman_storage
    PODMAN_EXT_ROOT=""
    echo "External build storage cleaned. ${EXTERNAL_BUILD_PATH} is now free for other use."
fi

# Install first-boot rebase mechanism into the deployment.
# The service runs silently in the background and writes only to the journal so
# it does not overlap with the login prompt. The MOTD/status helper tells users
# exactly where to watch progress or diagnose failures.
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    cleanup_stale_first_boot_artifacts "" "${STATEROOT_VAR}"
    cleanup_stale_first_boot_artifacts "${DEPLOY_DIR}" "${STATEROOT_VAR}"

    # bazzite-rebase-status: /usr/local -> /var/usrlocal in atomic Fedora.
    sudo mkdir -p "${STATEROOT_VAR}/usrlocal/bin"
    sudo tee "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-status" > /dev/null << 'STATUS_EOF'
#!/usr/bin/bash
CURRENT_ID=""
if [[ -r /usr/lib/os-release ]]; then
    # shellcheck disable=SC1091
    source /usr/lib/os-release
    CURRENT_ID="${ID:-}"
fi
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Bazzite ARM - First Boot Rebase          ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
if [[ -f /var/lib/bazzite-rebase-done ]]; then
    echo "  Status: COMPLETE"
elif [[ -f /var/lib/bazzite-rebase-queued ]]; then
    if [[ "${CURRENT_ID}" == "bazzite" ]]; then
        echo "  Status: COMPLETE -- cleanup will finish on this boot"
    else
        echo "  Status: QUEUED -- reboot to boot into Bazzite"
        echo "  The staged deployment is finalized automatically during reboot."
        echo "  Action: sudo systemctl reboot"
    fi
elif [[ -f /var/lib/bazzite-rebase-failed ]]; then
    echo "  Status: FAILED -- inspect the log below"
    echo "  Log:    /var/log/bazzite-first-boot-rebase.log"
    echo "  Watch:  journalctl -u bazzite-first-boot-rebase -b"
    echo ""
    echo "  To retry: rm /var/lib/bazzite-rebase-failed && sudo systemctl start bazzite-first-boot-rebase"
elif systemctl is-active --quiet bazzite-first-boot-rebase.service 2>/dev/null; then
    echo "  Status: RUNNING -- rebase is in progress"
    echo "  Watch:  journalctl -f -u bazzite-first-boot-rebase"
elif systemctl is-enabled --quiet bazzite-first-boot-rebase.service 2>/dev/null; then
    echo "  Status: ARMED -- service will start automatically on boot"
    echo "  Watch:  systemctl status bazzite-first-boot-rebase.service"
elif [[ -d /var/lib/bazzite-install ]]; then
    echo "  Status: PENDING -- will start automatically"
    echo "  Watch:  journalctl -f -u bazzite-first-boot-rebase"
else
    echo "  Status: N/A -- no rebase data found"
fi
STATUS_EOF
    sudo chmod +x "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-status"

    sudo tee "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-finalize-staged" > /dev/null << 'FINALIZE_EOF'
#!/usr/bin/bash
set -euo pipefail

echo "Verifying boot partitions before staged deployment finalization..."
for mount_point in /boot /boot/efi; do
    if findmnt -T "${mount_point}" >/dev/null 2>&1; then
        echo "${mount_point} is mounted:"
        findmnt -T "${mount_point}" -no SOURCE,FSTYPE,OPTIONS
    else
        echo "${mount_point} is not mounted; attempting to mount it now."
        mount "${mount_point}" 2>/dev/null || echo "  Could not mount ${mount_point} (may not be in fstab)."
        findmnt -T "${mount_point}" -no SOURCE,FSTYPE,OPTIONS 2>/dev/null || true
    fi
done

bls_dir=/boot/loader/entries
if [[ -d "${bls_dir}" ]]; then
    echo "BLS entries before finalization: $(find "${bls_dir}" -maxdepth 1 -name '*.conf' 2>/dev/null | wc -l)"
fi

if systemctl list-unit-files ostree-finalize-staged.service >/dev/null 2>&1; then
    echo "Running ostree-finalize-staged.service explicitly..."
    systemctl start ostree-finalize-staged.service 2>/dev/null || true
    systemctl --no-pager --full status ostree-finalize-staged.service 2>/dev/null || true
else
    echo "ostree-finalize-staged.service is not available (deployment may not be staged)."
fi

if [[ -d "${bls_dir}" ]]; then
    echo "BLS entries after finalization: $(find "${bls_dir}" -maxdepth 1 -name '*.conf' 2>/dev/null | wc -l)"
    ls -1 "${bls_dir}"/*.conf 2>/dev/null || true
fi
FINALIZE_EOF
    sudo chmod +x "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-finalize-staged"

    sudo tee "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-select-next-boot" > /dev/null << 'BOOTSEL_EOF'
#!/usr/bin/bash
set -euo pipefail

echo "Selecting next boot deployment..."

if ! command -v rpm-ostree >/dev/null 2>&1; then
    echo "ERROR: rpm-ostree is not available." >&2
    exit 1
fi

rpm-ostree status 2>&1 || true
echo ""

if command -v ostree >/dev/null 2>&1; then
    echo "Setting ostree default to deployment index 0..."
    ostree admin set-default 0 2>/dev/null || true
fi

bls_dir="/boot/loader/entries"
if [[ ! -d "${bls_dir}" ]]; then
    echo "WARNING: ${bls_dir} does not exist; skipping explicit GRUB selection."
    echo "The system should still boot into the correct deployment."
    exit 0
fi

echo "BLS entries:"
ls -1 "${bls_dir}"/*.conf 2>/dev/null || true

selected_target=""
bls_path=""

for candidate in "${bls_dir}"/ostree-*.conf; do
    [[ -f "${candidate}" ]] || continue
    bls_path="${candidate}"
    selected_target="$(basename "${candidate}" .conf)"
    break
done

if [[ -z "${selected_target}" ]]; then
    echo "WARNING: No ostree BLS entries found in ${bls_dir}."
    echo "Listing all entries:"
    ls -la "${bls_dir}" 2>/dev/null || true
    echo "The system should still boot via ostree admin set-default."
    exit 0
fi

echo "Selected BLS entry: ${selected_target} (${bls_path})"

if ! command -v grub2-editenv >/dev/null 2>&1; then
    echo "WARNING: grub2-editenv not available; skipping explicit GRUB entry selection."
    exit 0
fi

mkdir -p /boot/grub2 2>/dev/null || true
if [[ ! -f /boot/grub2/grubenv ]]; then
    grub2-editenv /boot/grub2/grubenv create
fi

if command -v grub2-set-default >/dev/null 2>&1; then
    grub2-set-default "${selected_target}" 2>/dev/null || \
        grub2-set-default 0 2>/dev/null || true
    echo "Applied persistent GRUB default."
fi

if command -v grub2-reboot >/dev/null 2>&1; then
    grub2-reboot "${selected_target}" 2>/dev/null || \
        grub2-reboot 0 2>/dev/null || true
    echo "Applied one-shot GRUB next_entry."
fi

echo "Current grubenv:"
grub2-editenv list 2>/dev/null || true
BOOTSEL_EOF
    sudo chmod +x "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-select-next-boot"

    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system"

    # First-boot rebase service: runs silently in the background as root.
    #
    # Flow:
    # 1. rpm-ostree rebase stages the Bazzite deployment
    # 2. ostree admin finalize-staged immediately finalizes it (writes BLS
    #    entries, promotes it to the default deployment). We MUST do this
    #    explicitly because Fedora Asahi's shutdown-time finalization
    #    (ostree-finalize-staged.service) does not reliably run during
    #    reboot on this platform.
    # 3. Reboot → GRUB picks the new deployment via BLS version ordering.
    sudo tee "${DEPLOY_DIR}/etc/systemd/system/bazzite-first-boot-rebase.service" > /dev/null << 'SVC_EOF'
[Unit]
Description=Bazzite ARM - First Boot Rebase
ConditionPathExists=/var/lib/bazzite-install/index.json
ConditionPathExists=!/var/lib/bazzite-rebase-failed
ConditionPathExists=!/var/lib/bazzite-rebase-queued
ConditionPathExists=!/var/lib/bazzite-rebase-done
After=local-fs.target systemd-user-sessions.service dbus.service
Wants=local-fs.target

[Service]
Type=oneshot
ExecStartPre=/usr/bin/sleep 20
ExecStart=/usr/bin/bash -euxo pipefail -c '\
  rm -f /var/lib/bazzite-rebase-failed; \
  : > /var/log/bazzite-first-boot-rebase.log; \
  echo "=== Step 1: Stage Bazzite deployment ===" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  rpm-ostree rebase ostree-unverified-image:oci:/var/lib/bazzite-install:latest 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  echo "" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  echo "=== Step 2: Finalize staged deployment ===" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  ostree admin finalize-staged 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  echo "" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  echo "=== Step 3: Verify deployment ===" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  rpm-ostree status 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log || true; \
  echo "BLS entries:" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  ls -la /boot/loader/entries/*.conf 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log || true; \
  echo "" 2>&1 | tee -a /var/log/bazzite-first-boot-rebase.log; \
  touch /var/lib/bazzite-rebase-queued'
ExecStartPost=/usr/bin/bash -c 'sleep 5; systemctl --no-block reboot'
ExecStopPost=/usr/bin/bash -c 'if [[ ! -f /var/lib/bazzite-rebase-queued ]]; then touch /var/lib/bazzite-rebase-failed; fi'
TimeoutStartSec=0
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVC_EOF

    sudo tee "${DEPLOY_DIR}/etc/systemd/system/bazzite-first-boot-rebase-cleanup.service" > /dev/null << 'CLEANUP_EOF'
[Unit]
Description=Bazzite ARM - Clean First Boot Rebase Artifacts
ConditionPathExists=/var/lib/bazzite-rebase-queued
ConditionPathExists=!/var/lib/bazzite-rebase-done
ConditionPathExists=/usr/lib/bazzite
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -euxo pipefail -c 'touch /var/lib/bazzite-rebase-done; rm -rf /var/lib/bazzite-install; rm -f /etc/profile.d/bazzite-rebase.sh /etc/motd /etc/systemd/system/bazzite-firstboot-rebase.service /etc/systemd/system/bazzite-first-boot-rebase.service /etc/systemd/system/bazzite-first-boot-rebase.timer /etc/systemd/system/bazzite-first-boot-rebase-cleanup.service /etc/systemd/system/bazzite-first-boot-flatpaks.service /etc/systemd/system/multi-user.target.wants/bazzite-firstboot-rebase.service /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase.service /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase-cleanup.service /etc/systemd/system/timers.target.wants/bazzite-first-boot-rebase.timer /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-flatpaks.service /var/usrlocal/bin/bazzite-rebase-status /usr/local/bin/bazzite-rebase-status /usr/bin/bazzite-rebase-status /var/usrlocal/bin/bazzite-rebase-finalize-staged /usr/local/bin/bazzite-rebase-finalize-staged /usr/bin/bazzite-rebase-finalize-staged /var/usrlocal/bin/bazzite-rebase-select-next-boot /usr/local/bin/bazzite-rebase-select-next-boot /usr/bin/bazzite-rebase-select-next-boot /var/lib/bazzite-rebase-failed /var/lib/bazzite-rebase-queued || true'

[Install]
WantedBy=multi-user.target
CLEANUP_EOF

    # Enable the rebase and cleanup services in the deployment so systemd sees
    # them as first-class enabled units on the first atomic boot.
    if ! sudo systemctl --root="${DEPLOY_DIR}" enable \
        bazzite-first-boot-rebase.service \
        bazzite-first-boot-rebase-cleanup.service >/dev/null 2>&1; then
        sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants"
        sudo ln -sf /etc/systemd/system/bazzite-first-boot-rebase.service \
            "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase.service"
        sudo ln -sf /etc/systemd/system/bazzite-first-boot-rebase-cleanup.service \
            "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase-cleanup.service"
    fi
    echo "Installed first-boot units in deployment:"
    sudo systemctl --root="${DEPLOY_DIR}" list-unit-files 'bazzite-first-boot-*' 2>/dev/null || true

    # MOTD -- shown at login so user knows rebase is running silently
    sudo tee "${DEPLOY_DIR}/etc/motd" > /dev/null << 'MOTD_EOF'

  ╔══════════════════════════════════════════════════════════════╗
  ║  Bazzite ARM: The final rebase is scheduled for this boot.   ║
  ║  It starts automatically about 20 seconds after login/boot.  ║
  ║                                                              ║
  ║  Check progress:                                             ║
  ║    journalctl -f -u bazzite-first-boot-rebase                ║
  ║    systemctl status bazzite-first-boot-rebase.service        ║
  ║  If it fails:                                                ║
  ║    cat /var/log/bazzite-first-boot-rebase.log                ║
  ║                                                              ║
  ║  The system reboots twice:                                   ║
  ║    1st reboot: stages Bazzite deployment (~2-5 min)          ║
  ║    2nd reboot: boots into Bazzite (automatic)                ║
  ╚══════════════════════════════════════════════════════════════╝

MOTD_EOF

    echo "First-boot rebase installed (silent systemd service, output to journal only)."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 9: Back up and update GRUB
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 9: Update GRUB ---"
sudo cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.backup
GRUB_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-grub-mkconfig.log"
sudo mkdir -p /etc/default
sudo touch /etc/default/grub
if grep -q '^GRUB_DEFAULT=' /etc/default/grub 2>/dev/null; then
    sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
else
    echo 'GRUB_DEFAULT=saved' | sudo tee -a /etc/default/grub > /dev/null
fi
if grep -q '^GRUB_ENABLE_BLSCFG=' /etc/default/grub 2>/dev/null; then
    sudo sed -i 's/^GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=true/' /etc/default/grub
else
    echo 'GRUB_ENABLE_BLSCFG=true' | sudo tee -a /etc/default/grub > /dev/null
fi
sudo grub2-editenv /boot/grub2/grubenv create >/dev/null 2>&1 || true

if [[ -d /sys/firmware/efi ]] && command -v grub2-switch-to-blscfg >/dev/null 2>&1; then
    echo "Ensuring GRUB uses BLS on the EFI path..."
    sudo sed -i 's/^EFIDIR=.*/EFIDIR="fedora"/' "$(command -v grub2-switch-to-blscfg)" || true
    sudo grub2-switch-to-blscfg 2>&1 | tee -a "${GRUB_LOG}" >/dev/null || true
fi

GRUB_TARGETS=()
if [[ -d /sys/firmware/efi ]]; then
    GRUB_TARGETS+=(/etc/grub2-efi.cfg)
else
    GRUB_TARGETS+=(/etc/grub2.cfg)
fi
GRUB_TARGETS+=(/boot/grub2/grub.cfg)

for grub_target in "${GRUB_TARGETS[@]}"; do
    if ! run_logged_step \
        "Updating GRUB configuration (${grub_target})" \
        "${GRUB_LOG}" \
        sudo grub2-mkconfig -o "${grub_target}"; then
        echo "WARNING: grub2-mkconfig for ${grub_target} had errors (see ${GRUB_LOG})."
    fi
done
if ! sudo grep -Eq 'saved_entry|next_entry' /boot/grub2/grub.cfg; then
    echo "ERROR: /boot/grub2/grub.cfg does not honor saved/next GRUB entries."
    echo "GRUB selection would be ignored on reboot, so stopping here."
    exit 1
fi
echo "GRUB updated."

# ──────────────────────────────────────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "================================================="
echo "  Conversion complete!"
echo ""
echo "  On reboot:"
echo "    1. You will boot into Fedora Asahi Atomic"
echo "    2. The first-boot service starts the local rebase automatically"
echo "       about 20 seconds after the atomic boot"
echo "    3. It automatically rebases to Bazzite ARM"
echo "    4. System reboots again into full Bazzite"
echo ""
echo "  If the auto-rebase fails, run manually:"
echo "    rpm-ostree rebase ostree-unverified-image:oci:/var/lib/bazzite-install:latest"
echo "    systemctl reboot"
echo "================================================="
echo ""
read -rp "Reboot now? (y/N): " reboot_confirm
if [[ "$reboot_confirm" == [yY] ]]; then
    sudo systemctl reboot
fi
