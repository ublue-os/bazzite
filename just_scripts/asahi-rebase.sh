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
BAZZITE_IMAGE="localhost/bazzite-arm:latest"
ATOMIC_BASE="quay.io/fedora-asahi-remix-atomic-desktops/base-atomic:42"
BAZZITE_FINAL="ghcr.io/nripeshn/bazzite-arm:latest"

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
sudo dnf install -y podman git rpm-ostree ostree rsync

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
        --build-arg FEDORA_VERSION=42 \
        --build-arg IMAGE_NAME=bazzite-arm \
        --build-arg IMAGE_VENDOR=nripeshn \
        --build-arg IMAGE_BRANCH=apple-silicon \
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

            # ostree: /home -> /var/home; create in /var/home so it persists
            sudo mkdir -p "/var/home/${NEW_USER}" 2>/dev/null || true
            sudo chown "${NEXT_UID}:${NEXT_UID}" "/var/home/${NEW_USER}" 2>/dev/null || true

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
# Step 8: Copy Bazzite image into ostree repo for first-boot rebase
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "--- Step 8: Prepare Bazzite image for first-boot rebase ---"
echo "Copying Bazzite ARM image into /ostree/repo (this may take a few minutes)..."
sudo skopeo copy \
    "containers-storage:${BAZZITE_IMAGE}" \
    "ostree-unverified-registry:localhost/bazzite-arm:latest" \
    --dest-ostree-tmp-dir /ostree/repo/tmp \
    --dest-ostree-repo /ostree/repo 2>/dev/null || true

# Install a first-boot service into the deployment that rebases to Bazzite
# once the system is up. This avoids having to manually run rpm-ostree rebase.
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system"

    sudo tee "${DEPLOY_DIR}/etc/systemd/system/bazzite-firstboot-rebase.service" > /dev/null << 'SVC_EOF'
[Unit]
Description=Rebase to Bazzite ARM on first boot
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/bazzite-rebase-done

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'rpm-ostree rebase ostree-unverified-registry:ghcr.io/nripeshn/bazzite-arm:latest && touch /var/lib/bazzite-rebase-done && systemctl reboot'
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
SVC_EOF

    # Enable the service via symlink in the deployment
    sudo mkdir -p "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants"
    sudo ln -sf \
        /etc/systemd/system/bazzite-firstboot-rebase.service \
        "${DEPLOY_DIR}/etc/systemd/system/multi-user.target.wants/bazzite-firstboot-rebase.service"

    echo "First-boot rebase service installed."
    echo "After rebooting to atomic Fedora, it will automatically rebase to Bazzite ARM."
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
echo "    rpm-ostree rebase ostree-unverified-registry:${BAZZITE_FINAL}"
echo "    systemctl reboot"
echo "================================================="
echo ""
read -rp "Reboot now? (y/N): " reboot_confirm
if [[ "$reboot_confirm" == [yY] ]]; then
    systemctl reboot
fi
