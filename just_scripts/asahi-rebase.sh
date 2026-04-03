#!/usr/bin/bash
set -euo pipefail

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

# Parse flags
# --fairydust            : use experimental Thunderbolt/USB4 kernel variant
# --external-build=PATH  : redirect podman container build storage to PATH
#                          (use this when internal disk is small, e.g. 20-25 GB)
#                          PATH must already be a mounted writable directory,
#                          e.g. /mnt/external (your external SSD).
#                          After the script finishes you can wipe PATH freely.
KERNEL_VARIANT="stable"
EXTERNAL_BUILD_PATH=""
for arg in "$@"; do
    case "$arg" in
        --fairydust)           KERNEL_VARIANT="fairydust" ;;
        --external-build=*)    EXTERNAL_BUILD_PATH="${arg#--external-build=}" ;;
    esac
done

IMAGE_NAME="bazzite-arm"
if [[ "${KERNEL_VARIANT}" == "fairydust" ]]; then
    IMAGE_NAME="${IMAGE_NAME}-fairydust"
fi

BAZZITE_IMAGE="localhost/${IMAGE_NAME}:latest"
IMAGE_BRANCH=$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "experimental")

echo "Kernel variant:     ${KERNEL_VARIANT}"
echo "External build dir: ${EXTERNAL_BUILD_PATH:-<none, using internal /var/lib/containers>}"

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

# ──────────────────────────────────────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────────────────────────────────────
echo "================================================="
echo "  Bazzite ARM: Full Asahi -> Bazzite Conversion"
echo "================================================="
echo ""
echo "This script will:"
echo "  1. Build the Bazzite ARM image locally (~30 min, needs ~20 GB free)"
echo "  2. Convert this Fedora install to atomic/ostree"
echo "  3. Set up your user account"
echo "  4. Reboot into atomic Fedora which auto-rebases to Bazzite ARM"
echo ""
echo "The Asahi boot chain (m1n1/U-Boot/GRUB) will NOT be touched."
echo ""
df -h / | tail -1
echo ""
read -rp "Continue? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 1: Install prerequisites
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 1: Install prerequisites ---"
sudo dnf upgrade -y
sudo dnf install -y podman git rpm-ostree ostree rsync

# Prevent the system from sleeping during the 60-90 minute build.
# The build will be killed if the system suspends mid-way.
echo "Disabling sleep/suspend for the duration of this script..."
sudo systemctl mask --now \
    sleep.target suspend.target hibernate.target \
    hybrid-sleep.target 2>/dev/null || true

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

    # How much free space is on the external path?
    EXTERNAL_FREE_GB=$(df -BG "${EXTERNAL_BUILD_PATH}" | awk 'NR==2{gsub("G",""); print $4}')
    echo "External path free space: ${EXTERNAL_FREE_GB} GB (need ~25 GB)"
    if (( EXTERNAL_FREE_GB < 20 )); then
        echo "ERROR: Not enough free space on ${EXTERNAL_BUILD_PATH} (${EXTERNAL_FREE_GB} GB < 20 GB needed)"
        exit 1
    fi

    PODMAN_EXT_ROOT="${EXTERNAL_BUILD_PATH}/podman-build"
    sudo mkdir -p "${PODMAN_EXT_ROOT}"

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
mount_program = "/usr/bin/fuse-overlayfs"
EOF
    echo "Podman root storage → ${PODMAN_EXT_ROOT}"
    echo "Internal disk freed from container build layers (~20 GB saved)."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 2: Clone repo and build Bazzite ARM image
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 2: Build Bazzite ARM image ---"
echo "This takes ~30 minutes. Progress will be shown."
echo ""

if ! sudo podman image exists "${BAZZITE_IMAGE}" 2>/dev/null; then
    cd "${REPO_ROOT}"
    sudo podman build \
        --platform linux/arm64 \
        -f Containerfile.arm \
        --build-arg BASE_IMAGE_NAME=kinoite \
        --build-arg FEDORA_VERSION=43 \
        --build-arg IMAGE_NAME="${IMAGE_NAME}" \
        --build-arg IMAGE_VENDOR=nripeshn \
        --build-arg KERNEL_VARIANT="${KERNEL_VARIANT}" \
        --build-arg IMAGE_BRANCH="${IMAGE_BRANCH}" \
        --build-arg VERSION_TAG=local \
        --build-arg VERSION_PRETTY="Local Build" \
        --build-arg SHA_HEAD_SHORT=local \
        -t "${BAZZITE_IMAGE}" \
        .
    echo "Bazzite ARM image built successfully."
else
    echo "Bazzite ARM image already exists; skipping build."
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
echo "Pulling ${ATOMIC_BASE} (may take a few minutes)..."
sudo ostree container image pull /ostree/repo \
    "ostree-unverified-registry:${ATOMIC_BASE}"

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
EFI_UUID=$(findmnt -no UUID /boot/efi 2>/dev/null || true)
echo "Boot UUID:  ${BOOT_UUID:-NOT FOUND}"
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
        -maxdepth 1 -name "*.0" -type d \
        -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | head -1 | cut -d' ' -f2)
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
        echo "UUID=${BOOT_UUID}  /boot  ext4  defaults  1  2" \
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
        read -rp "Enter username for the new system: " NEW_USER
        read -srp "Enter password: " NEW_PASS
        echo ""

        PASS_HASH=$(openssl passwd -6 "${NEW_PASS}")

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

            # Add to wheel for sudo
            if grep -q "^wheel:" "${DEPLOY_DIR}/etc/group"; then
                sudo sed -i "/^wheel:/ s/$/,${NEW_USER}/" "${DEPLOY_DIR}/etc/group"
                sudo sed -i "s/,${NEW_USER},${NEW_USER}/,${NEW_USER}/g" "${DEPLOY_DIR}/etc/group"
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

# ──────────────────────────────────────────────────────────────────────────────
# Step 7b: Inject external SSD fstab entry for auto-mount in Bazzite
# ──────────────────────────────────────────────────────────────────────────────
# If --external-build was used, the external SSD (e.g. /dev/sda) will be
# present but unmounted after Bazzite boots. Inject an fstab entry so it
# auto-mounts at /var/mnt/games on every boot. The user can then use it
# for game storage without manual mounting.
if [[ -n "${EXTERNAL_BUILD_PATH}" ]] && [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    EXT_DEV=$(findmnt -no SOURCE "${EXTERNAL_BUILD_PATH}" 2>/dev/null || true)
    EXT_UUID=$(blkid -s UUID -o value "${EXT_DEV}" 2>/dev/null || true)
    if [[ -n "$EXT_UUID" ]]; then
        GAMES_FSTAB="${DEPLOY_DIR}/etc/fstab"
        if ! grep -q "UUID=${EXT_UUID}" "${GAMES_FSTAB}" 2>/dev/null; then
            echo "UUID=${EXT_UUID}  /var/mnt/games  ext4  defaults,nofail,x-systemd.automount  0  2" \
                | sudo tee -a "${GAMES_FSTAB}" > /dev/null
            echo "Added external SSD (UUID=${EXT_UUID}) → /var/mnt/games in deployment fstab."
        fi
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
sudo skopeo copy \
    "containers-storage:${BAZZITE_IMAGE}" \
    "oci:${OCI_DEST}:latest"
echo "Image exported successfully."

# Now that the OCI archive is safely on the internal stateroot var,
# the podman build storage on the external SSD is no longer needed.
# Clean it up to free the external SSD for games/data after first boot.
if [[ -n "${EXTERNAL_BUILD_PATH}" ]]; then
    echo ""
    echo "--- Cleaning up external build storage (image now in ${OCI_DEST}) ---"
    sudo podman system prune -af 2>/dev/null || true
    sudo rm -rf "${PODMAN_EXT_ROOT:?}" 2>/dev/null || true
    # Remove the storage.conf redirect so future podman operations use defaults
    sudo rm -f /etc/containers/storage.conf
    echo "External build storage cleaned. ${EXTERNAL_BUILD_PATH} is now free for other use."
fi

# Install first-boot rebase mechanism into the deployment.
# Profile.d only -- no systemd service. The service caused output to overlap
# with the TTY login prompt since systemd started it in parallel with login.
# Profile.d runs AFTER the user has fully logged in, so output is clean.
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then

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
else
    echo "  Status: Ready -- will start automatically at login"
    echo "  Or run now:"
    echo "    sudo rpm-ostree rebase ostree-unverified-image:oci:/var/lib/bazzite-install:latest"
fi
STATUS_EOF
    sudo chmod +x "${STATEROOT_VAR}/usrlocal/bin/bazzite-rebase-status"

    # MOTD -- shown at login
    sudo tee "${DEPLOY_DIR}/etc/motd" > /dev/null << 'MOTD_EOF'
  ╔══════════════════════════════════════════════════════╗
  ║  Bazzite ARM: Log in to start the final rebase.      ║
  ║  Rebase runs automatically after login (~2-5 min).   ║
  ╚══════════════════════════════════════════════════════╝
MOTD_EOF

    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system"

    # Profile.d: runs after login, output is clean (no overlap with login prompt)
    sudo mkdir -p "${DEPLOY_DIR}/etc/profile.d"
    sudo tee "${DEPLOY_DIR}/etc/profile.d/bazzite-rebase.sh" > /dev/null << 'PROF_EOF'
#!/usr/bin/bash
# Auto-rebase to Bazzite ARM after login (profile.d -- runs once shell is ready)
if [[ ! -f /var/lib/bazzite-rebase-done ]] && [[ -d /var/lib/bazzite-install ]]; then
    # Small pause to ensure the shell prompt has fully initialized
    sleep 1
    clear
    echo ""
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo "  ║         Bazzite ARM - Final Installation          ║"
    echo "  ║                                                   ║"
    echo "  ║  Rebasing to Bazzite ARM. This takes ~2-5 min.    ║"
    echo "  ║  The system reboots automatically when done.      ║"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "  [sudo] password for $(whoami):"

    if sudo rpm-ostree rebase \
            "ostree-unverified-image:oci:/var/lib/bazzite-install:latest"; then
        sudo touch /var/lib/bazzite-rebase-done
        echo ""
        echo "  ✓ Rebase complete! Rebooting into Bazzite ARM in 5 seconds..."
        sleep 5
        sudo systemctl reboot
    else
        echo ""
        echo "  ✗ Rebase failed. Run manually:"
        echo "    sudo rpm-ostree rebase ostree-unverified-image:oci:/var/lib/bazzite-install:latest"
    fi
fi
PROF_EOF

    echo "First-boot rebase installed (profile.d only -- no systemd service overlap)."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 9: Back up and update GRUB
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 9: Update GRUB ---"
sudo cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.backup
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
    systemctl reboot
fi
