#!/usr/bin/bash
set -euo pipefail

# Bazzite ARM: Convert Fedora Asahi Remix to atomic Bazzite
# Based on https://gist.github.com/davidvfx07/fec3d92f6075ece27f7dd875b5dc459b
#
# This script converts a traditional Fedora Asahi Remix installation
# into an atomic/ostree system running Bazzite ARM, WITHOUT touching
# the Asahi boot chain (m1n1 -> U-Boot -> GRUB).
#
# Prerequisites:
#   - Fresh Fedora Asahi Remix Minimal installation
#   - Run: sudo dnf upgrade -y && reboot (before running this script)
# Safe to re-run after failures: skips init/os-init/deploy when already done.
# Force another deployment: OSTREE_FORCE_DEPLOY=1 ./just_scripts/asahi-rebase.sh

IMAGE="quay.io/fedora-asahi-remix-atomic-desktops/base-atomic:42"

# ostree only accepts /boot/loader -> loader.0 or loader.1 (see read_current_bootversion in
# ostree-sysroot.c). Symlinks like ../efi/EFI/fedora fail with "Invalid target in boot/loader".
# BLS entries must live under /boot/loader.0/entries (or loader.1).
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

    # Populate loader.0 from a plain /boot/loader directory (common on Asahi).
    if [[ -d /boot/loader && ! -L /boot/loader ]]; then
        echo "Migrating /boot/loader directory -> /boot/loader.0 ..."
        sudo rsync -a /boot/loader/ /boot/loader.0/
        sudo rm -rf /boot/loader
    fi

    # If BLS entries are still only on the ESP (or after a previous bad migration).
    if [[ ! -d /boot/loader.0/entries ]] || [[ -z "$(find /boot/loader.0/entries -name '*.conf' 2>/dev/null | head -1)" ]]; then
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
        echo "ERROR: /boot/loader exists but is not a symlink (unexpected). Fix manually, then re-run."
        exit 1
    fi
}

echo "=== Bazzite ARM: Asahi Atomic Conversion ==="
echo ""
echo "This will convert your Fedora Asahi Remix into an atomic (ostree)"
echo "system, then rebase to Bazzite ARM."
echo ""
echo "Your Asahi boot chain (m1n1/U-Boot/GRUB) will NOT be touched."
echo ""
read -rp "Continue? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "--- Step 1: Install prerequisites ---"
sudo dnf install -y rpm-ostree ostree skopeo podman

echo ""
echo "--- Step 2: Initialize ostree repository ---"
sudo mkdir -p /ostree/repo
if [[ ! -f /ostree/repo/config ]]; then
    sudo ostree init --repo=/ostree/repo --mode=bare
else
    echo "OSTree repo already initialized at /ostree/repo; skipping ostree init."
fi
sudo ostree config --repo=/ostree/repo set sysroot.bootloader none
sudo ostree config --repo=/ostree/repo set sysroot.readonly true

# See https://bugzilla.redhat.com/show_bug.cgi?id=1648672
ensure_boot_loader_symlink

sudo mkdir -p /ostree/deploy

if [[ ! -d /ostree/deploy/fedora ]]; then
    sudo ostree admin os-init fedora --sysroot /
else
    echo "Stateroot 'fedora' already exists under /ostree/deploy/fedora; skipping os-init."
fi

echo ""
echo "--- Step 3: Back up GRUB config ---"
sudo cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.backup

echo ""
echo "--- Step 4: Pull the Fedora Asahi Atomic base image ---"
echo "This may take several minutes with no visible progress..."
sudo ostree container image pull /ostree/repo \
    ostree-unverified-registry:${IMAGE}

echo ""
echo "--- Step 5: Get root partition UUID ---"
# Try /proc/cmdline first, fall back to findmnt
ROOT_UUID=$(cat /proc/cmdline | grep -oP 'root=UUID=\K[^\s]+' || true)
if [[ -z "$ROOT_UUID" ]]; then
    ROOT_UUID=$(findmnt -no UUID /)
fi
echo "Root UUID: $ROOT_UUID"

if [[ -z "$ROOT_UUID" ]]; then
    echo "ERROR: Could not detect root UUID."
    echo "  /proc/cmdline: $(cat /proc/cmdline)"
    echo "  findmnt /: $(findmnt -no SOURCE,UUID /)"
    echo ""
    echo "Please provide the UUID manually and re-run."
    exit 1
fi

echo ""
echo "--- Step 6: Deploy the atomic image ---"
# Layer blobs (ostree/container/blob/...) are not root filesystems (no kernel). Do not use
# ostree refs | head -1. Prefer ostree-unverified-registry:<image>; newer ostree may only
# record ostree/container/image/... for the pulled image.
REF=""
if [[ -n "${IMAGE:-}" ]]; then
    candidate="ostree-unverified-registry:${IMAGE}"
    if sudo ostree rev-parse --repo=/ostree/repo "${candidate}" &>/dev/null; then
        REF="${candidate}"
    fi
fi
if [[ -z "${REF}" ]]; then
    mapfile -t _image_refs < <(sudo ostree refs --repo=/ostree/repo | grep '^ostree/container/image/' || true)
    if [[ "${#_image_refs[@]}" -eq 1 ]]; then
        REF="${_image_refs[0]}"
    elif [[ "${#_image_refs[@]}" -gt 1 ]]; then
        echo "ERROR: Multiple ostree/container/image refs; cannot pick automatically:"
        printf '%s\n' "${_image_refs[@]}"
        exit 1
    fi
fi
if [[ -z "${REF}" ]] || ! sudo ostree rev-parse --repo=/ostree/repo "${REF}" &>/dev/null; then
    echo "ERROR: No deployable image ref in /ostree/repo."
    echo "  Set IMAGE at the top of this script, or ensure a single ostree/container/image/ ref exists."
    sudo ostree refs --repo=/ostree/repo
    exit 1
fi
echo "Deploying ref: $REF"

TARGET_REV=$(sudo ostree rev-parse --repo=/ostree/repo "${REF}")
EXISTING_KARGS=$(cat /proc/cmdline)
echo "Existing kernel args: $EXISTING_KARGS"

# btrfs (e.g. Asahi) needs rootflags from the running system (e.g. subvol=root)
ROOTFLAGS_KARG=()
if [[ "$EXISTING_KARGS" =~ rootflags=([^[:space:]]+) ]]; then
    ROOTFLAGS_KARG=(--karg="rootflags=${BASH_REMATCH[1]}")
    echo "Preserving rootflags=${BASH_REMATCH[1]}"
fi

# Re-runs: avoid stacking duplicate deployments if this tree is already present.
# Match on a prefix of the commit (ostree admin status may shorten the hash).
_skip_deploy=0
if [[ -z "${OSTREE_FORCE_DEPLOY:-}" ]] \
    && sudo ostree admin status --sysroot=/ 2>/dev/null | grep -qF "${TARGET_REV:0:16}"; then
    _skip_deploy=1
fi
if [[ "${_skip_deploy}" -eq 1 ]]; then
    echo "Skipping ostree admin deploy: revision ${TARGET_REV:0:12}... is already deployed (set OSTREE_FORCE_DEPLOY=1 to force a new deployment)."
else
    sudo ostree admin deploy "$REF" \
        --sysroot / \
        --os fedora \
        --karg="root=UUID=${ROOT_UUID}" \
        --karg="ro" \
        --karg="rhgb" \
        --karg="quiet" \
        "${ROOTFLAGS_KARG[@]}"
fi

echo ""
echo "--- Step 7: Copy kernel and initramfs to /boot ---"
# Ensure the deployed kernel is accessible to GRUB
DEPLOY_DIR=$(sudo ostree admin --sysroot=/ --print-current-dir 2>/dev/null || true)
if [[ -n "$DEPLOY_DIR" && -d "$DEPLOY_DIR" ]]; then
    echo "Deployment directory: $DEPLOY_DIR"
fi

echo ""
echo "--- Step 8: Update GRUB to boot the new deployment ---"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo ""
echo "============================================"
echo "  Atomic conversion complete!"
echo ""
echo "  After reboot you will be on Fedora Asahi"
echo "  Atomic. Then run:"
echo ""
echo "    rpm-ostree rebase ostree-unverified-registry:ghcr.io/nripeshn/bazzite-arm:latest"
echo "    systemctl reboot"
echo ""
echo "  That second reboot puts you on Bazzite ARM."
echo "============================================"
echo ""
read -rp "Reboot now? (y/N): " reboot_confirm
if [[ "$reboot_confirm" == [yY] ]]; then
    systemctl reboot
fi
