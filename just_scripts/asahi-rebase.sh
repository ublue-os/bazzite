#!/usr/bin/bash
set -euo pipefail

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
# --skip-wine            : skip native Wine aarch64 compilation (~40-60 min)
#                          x86 Wine still runs via FEX-Emu/Box64 emulation.
#                          Use this for faster first installs; rerun this
#                          script later without --skip-wine to build and
#                          deploy the native-Wine image variant.
KERNEL_VARIANT="stable"
EXTERNAL_BUILD_PATH=""
SKIP_WINE=0
for arg in "$@"; do
    case "$arg" in
        --fairydust)           KERNEL_VARIANT="fairydust" ;;
        --external-build=*)    EXTERNAL_BUILD_PATH="${arg#--external-build=}" ;;
        --skip-wine)           SKIP_WINE=1 ;;
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
echo "Local image:        ${BAZZITE_IMAGE}"

cleanup_host_overrides() {
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
        sudo podman system prune -af 2>/dev/null || true
        sudo rm -rf "${PODMAN_EXT_ROOT}" 2>/dev/null || true
    fi
}

cleanup_local_podman_image() {
    sudo podman image rm -f "${BAZZITE_IMAGE}" 2>/dev/null || true
    sudo podman builder prune -af 2>/dev/null || true
    sudo podman image prune -f 2>/dev/null || true
}

trap cleanup_host_overrides EXIT

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
echo "     - external build storage: needs ~20 GB free on / plus ~45 GB on the external drive"
echo "       (or ~25 GB on the external drive when using --skip-wine)"
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
        echo "Active podman storage.conf:"
        sudo cat /etc/containers/storage.conf 2>/dev/null || true
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
        pattern='(^|[^[:alpha:]])(error|failed|failure|cannot|could not|no match|no space left|permission denied|curl error|status code: [45][0-9][0-9]|transaction failed|depsolve|conflicting requests|nothing provides)([^[:alpha:]]|$)'
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
        "${systemd_system_root}/bazzite-first-boot-flatpaks.service" \
        "${systemd_system_root}/bazzite-flatpak-manager.service" \
        "${systemd_system_root}/bazzite-flatpak-manager.service.d" \
        "${systemd_system_root}/bazzite-hardware-setup.service" \
        "${systemd_system_root}/bazzite-hardware-setup.service.d" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-firstboot-rebase.service" \
        "${systemd_system_root}/multi-user.target.wants/bazzite-first-boot-rebase.service" \
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
        "${root_prefix}/var/usrlocal/bin/bazzite-rebase-status" 2>/dev/null || true

    if [[ -n "${stateroot_var}" ]]; then
        sudo rm -f \
            "${stateroot_var}/usrlocal/bin/bazzite-rebase-status" 2>/dev/null || true
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
    openssl
require_commands podman git rpm-ostree ostree rsync skopeo openssl

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
    ROOT_SOURCE=$(findmnt -no SOURCE / 2>/dev/null || true)

    if [[ -z "${EXTERNAL_SOURCE}" || -z "${EXTERNAL_TARGET}" || -z "${EXTERNAL_FSTYPE}" || -z "${EXTERNAL_OPTIONS}" ]]; then
        echo "ERROR: Could not resolve the filesystem backing '${EXTERNAL_BUILD_PATH}'."
        exit 1
    fi

    EXTERNAL_BLOCK_SOURCE="${EXTERNAL_SOURCE%%[*}"
    ROOT_BLOCK_SOURCE="${ROOT_SOURCE%%[*}"
    if [[ "${EXTERNAL_TARGET}" == "/" || "${EXTERNAL_BLOCK_SOURCE}" == "${ROOT_BLOCK_SOURCE}" ]]; then

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
    cleanup_external_test_dir

    # How much free space is on the external path?
    EXTERNAL_FREE_GB=$(df -BG "${EXTERNAL_BUILD_PATH}" | awk 'NR==2{gsub("G",""); print $4}')
    if [[ "${SKIP_WINE}" -eq 1 ]]; then
        REQUIRED_EXTERNAL_FREE_GB=25
    else
        REQUIRED_EXTERNAL_FREE_GB=45
    fi
    echo "External path free space: ${EXTERNAL_FREE_GB} GB (need ~${REQUIRED_EXTERNAL_FREE_GB} GB)"
    if (( EXTERNAL_FREE_GB < REQUIRED_EXTERNAL_FREE_GB )); then
        echo "ERROR: Not enough free space on ${EXTERNAL_BUILD_PATH} (${EXTERNAL_FREE_GB} GB < ${REQUIRED_EXTERNAL_FREE_GB} GB needed)"
        exit 1
    fi

    PODMAN_EXT_ROOT="${EXTERNAL_BUILD_PATH}/podman-build"
    if [[ -d "${PODMAN_EXT_ROOT}" ]]; then
        echo "Removing stale external build storage at ${PODMAN_EXT_ROOT}..."
        sudo rm -rf "${PODMAN_EXT_ROOT}"
    fi
    sudo mkdir -p "${PODMAN_EXT_ROOT}"

    FUSE_OVERLAYFS_BIN=$(command -v fuse-overlayfs || true)
    if [[ -z "${FUSE_OVERLAYFS_BIN}" && -x /usr/sbin/fuse-overlayfs ]]; then
        FUSE_OVERLAYFS_BIN="/usr/sbin/fuse-overlayfs"
    fi
    if [[ -z "${FUSE_OVERLAYFS_BIN}" ]]; then
        echo "ERROR: fuse-overlayfs was not found after installing podman."
        exit 1
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
driver = "overlay"
graphRoot = "${PODMAN_EXT_ROOT}"
runRoot = "/run/containers/storage"

[storage.options.overlay]
mount_program = "${FUSE_OVERLAYFS_BIN}"
EOF
    PODMAN_STORAGE_OVERRIDE_ACTIVE=1
    echo "Podman root storage → ${PODMAN_EXT_ROOT}"
    echo "Internal disk freed from container build layers (~20 GB saved)."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 2: Build Bazzite ARM image
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 2: Build Bazzite ARM image ---"
echo "This takes ~25 minutes with --skip-wine (~85 min without). Output is live."
echo ""
BUILD_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-podman-build.log"

if sudo podman image exists "${BAZZITE_IMAGE}" 2>/dev/null; then
    echo "Bazzite ARM image already exists; skipping build."
else
    cd "${REPO_ROOT}"
    echo "Build log: ${BUILD_LOG}"
    echo "Pruning stale Podman builder cache before the native build..."
    sudo podman builder prune -af 2>/dev/null || true
    if ! sudo podman build \
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
sudo ostree config --repo=/ostree/repo set sysroot.bootloader grub2
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
run_logged_retry_step \
    "Pulling ${ATOMIC_BASE} (may take a few minutes)" \
    "${PULL_LOG}" \
    3 \
    sudo ostree container image pull /ostree/repo \
        "ostree-unverified-registry:${ATOMIC_BASE}"
echo "Pull complete."

# ──────────────────────────────────────────────────────────────────────────────
# Step 5: Detect root UUID
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 5: Detect root partition UUID ---"
ROOT_UUID=$(grep -oP 'root=UUID=\K[^\s]+' /proc/cmdline || true)
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

# Preserve rootflags (needed for btrfs subvol on Asahi)
ROOTFLAGS_KARG=()
if [[ "$EXISTING_KARGS" =~ rootflags=([^[:space:]]+) ]]; then
    ROOTFLAGS_KARG=(--karg="rootflags=${BASH_REMATCH[1]}")
    echo "Preserving rootflags=${BASH_REMATCH[1]}"
fi

_skip_deploy=0
if [[ -z "${OSTREE_FORCE_DEPLOY:-}" ]] && \
   sudo ostree admin status --sysroot=/ 2>/dev/null | grep -qF "${TARGET_REV:0:16}"; then
    _skip_deploy=1
fi

if [[ "${_skip_deploy}" -eq 1 ]]; then
    echo "Revision already deployed; skipping (set OSTREE_FORCE_DEPLOY=1 to force)."
else
    DEPLOY_LOG="/var/tmp/${IMAGE_NAME}-${IMAGE_TAG}-atomic-deploy.log"
    run_logged_step \
        "Deploying atomic base image" \
        "${DEPLOY_LOG}" \
        sudo ostree admin deploy "${REF}" \
            --sysroot / \
            --os fedora \
            --karg="root=UUID=${ROOT_UUID}" \
            --karg="ro" \
            --karg="rhgb" \
            --karg="quiet" \
            "${ROOTFLAGS_KARG[@]}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 7: Inject user account into the new deployment
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 7: Inject user account into new deployment ---"

DEPLOY_DIR=$(sudo ostree admin --sysroot=/ --print-current-dir 2>/dev/null || true)
if [[ -z "$DEPLOY_DIR" || ! -d "$DEPLOY_DIR" ]]; then
    DEPLOY_DIR=$(find /ostree/deploy/fedora/deploy \
        -maxdepth 1 -type d -not -name deploy \
        -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | head -1 | cut -d' ' -f2)
fi

if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    unmask_deployment_sleep_targets "$DEPLOY_DIR"
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
# Step 7b: Inject external SSD fstab entry for auto-mount in Bazzite
# ──────────────────────────────────────────────────────────────────────────────
# If --external-build was used, the external SSD (e.g. /dev/sda) will be
# present but unmounted after Bazzite boots. Inject an fstab entry so it
# auto-mounts at /var/mnt/games on every boot. The user can then use it
# for game storage without manual mounting.
if [[ -n "${EXTERNAL_BUILD_PATH}" ]] && [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    EXT_DEV=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no SOURCE 2>/dev/null || true)
    EXT_DEV="${EXT_DEV%%[*}"
    EXT_FSTYPE=$(findmnt -T "${EXTERNAL_BUILD_PATH}" -no FSTYPE 2>/dev/null || true)
    GAMES_FSCK_PASSNO=0
    EXT_UUID=""
    if [[ -n "${EXT_DEV}" && -b "${EXT_DEV}" ]]; then
        EXT_UUID=$(sudo blkid -s UUID -o value "${EXT_DEV}" 2>/dev/null || true)
    fi
    if [[ "${EXT_FSTYPE}" =~ ^ext[234]$ ]]; then
        GAMES_FSCK_PASSNO=2
    fi
    if [[ -n "$EXT_UUID" && -n "$EXT_FSTYPE" ]]; then
        GAMES_FSTAB="${DEPLOY_DIR}/etc/fstab"
        sudo sed -i '\|[[:space:]]/var/mnt/games[[:space:]]|d' "${GAMES_FSTAB}"
        echo "UUID=${EXT_UUID}  /var/mnt/games  ${EXT_FSTYPE}  defaults,nofail,x-systemd.automount  0  ${GAMES_FSCK_PASSNO}" \
            | sudo tee -a "${GAMES_FSTAB}" > /dev/null
        echo "Added external SSD (UUID=${EXT_UUID}, fstype=${EXT_FSTYPE}) → /var/mnt/games in deployment fstab."
        # Create the mount point in the stateroot var (becomes /var/mnt/games after boot)
        sudo mkdir -p "/ostree/deploy/fedora/var/mnt/games"
    else
        echo "Note: could not detect external SSD UUID -- skipping auto-mount setup."
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
if ! sudo skopeo copy \
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
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Bazzite ARM - First Boot Rebase          ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
if [[ -f /var/lib/bazzite-rebase-done ]]; then
    echo "  Status: COMPLETE -- run: sudo systemctl reboot"
elif [[ -f /var/lib/bazzite-rebase-failed ]]; then
    echo "  Status: FAILED -- inspect the log below"
    echo "  Log:    /var/log/bazzite-first-boot-rebase.log"
    echo "  Watch:  journalctl -u bazzite-first-boot-rebase -b"
elif systemctl is-active --quiet bazzite-first-boot-rebase.service 2>/dev/null; then
    echo "  Status: RUNNING -- rebase is in progress"
    echo "  Watch:  journalctl -f -u bazzite-first-boot-rebase"
elif [[ -d /var/lib/bazzite-install ]]; then
    echo "  Status: PENDING -- will start automatically"
    echo "  Watch:  journalctl -f -u bazzite-first-boot-rebase"
else
    echo "  Status: N/A -- no rebase data found"
fi
STATUS_EOF
    sudo chmod +x "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-status"

    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system"

    # First-boot rebase service: runs silently in the background as root.
    # Output goes only to the journal (not the console) so it never overlaps
    # with the login prompt. The MOTD tells users to check journalctl.
    # After=multi-user.target ensures the system is fully booted before
    # the rebase starts.
    sudo tee "${DEPLOY_DIR}/etc/systemd/system/bazzite-first-boot-rebase.service" > /dev/null << 'SVC_EOF'
[Unit]
Description=Bazzite ARM - First Boot Rebase
ConditionPathExists=/var/lib/bazzite-install
ConditionPathExists=!/var/lib/bazzite-rebase-done
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -euxo pipefail -c 'rm -f /var/lib/bazzite-rebase-failed; rpm-ostree rebase ostree-unverified-image:oci:/var/lib/bazzite-install:latest 2>&1 | tee /var/log/bazzite-first-boot-rebase.log; touch /var/lib/bazzite-rebase-done; rm -f /etc/profile.d/bazzite-rebase.sh /etc/systemd/system/bazzite-firstboot-rebase.service /etc/systemd/system/bazzite-first-boot-rebase.service /etc/systemd/system/bazzite-first-boot-flatpaks.service /etc/systemd/system/multi-user.target.wants/bazzite-firstboot-rebase.service /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase.service /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-flatpaks.service /var/usrlocal/bin/bazzite-rebase-status /usr/local/bin/bazzite-rebase-status /usr/bin/bazzite-rebase-status || true; rm -rf /var/lib/bazzite-install || true; sleep 5; systemctl reboot'
ExecStopPost=/usr/bin/bash -c 'if [[ ! -f /var/lib/bazzite-rebase-done ]]; then touch /var/lib/bazzite-rebase-failed; fi'
TimeoutStartSec=0
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVC_EOF

    # Enable the service in the deployment
    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants"
    sudo ln -sf /etc/systemd/system/bazzite-first-boot-rebase.service \
        "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants/bazzite-first-boot-rebase.service"

    # MOTD -- shown at login so user knows rebase is running silently
    sudo tee "${DEPLOY_DIR}/etc/motd" > /dev/null << 'MOTD_EOF'

  ╔══════════════════════════════════════════════════════════════╗
  ║  Bazzite ARM: The final rebase is running in the background. ║
  ║  It runs silently -- no output will appear on screen.        ║
  ║                                                              ║
  ║  Check progress:                                             ║
  ║    journalctl -f -u bazzite-first-boot-rebase                ║
  ║  If it fails:                                                ║
  ║    cat /var/log/bazzite-first-boot-rebase.log                ║
  ║                                                              ║
  ║  The system reboots automatically when done (~2-5 min).      ║
  ║  DO NOT reboot manually -- just wait.                        ║
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
run_logged_step \
    "Updating GRUB configuration" \
    "${GRUB_LOG}" \
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
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
echo "    2. Log in (the first-boot service will run)"
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
