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

IMAGE="quay.io/fedora-asahi-remix-atomic-desktops/kinoite:42"

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
sudo ostree init --repo=/ostree/repo --mode=bare
sudo ostree config --repo=/ostree/repo set sysroot.bootloader none
sudo ostree config --repo=/ostree/repo set sysroot.readonly true
sudo mkdir -p /ostree/deploy
sudo ostree admin os-init fedora --sysroot /

echo ""
echo "--- Step 3: Back up GRUB config ---"
sudo cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg.backup

echo ""
echo "--- Step 4: Pull the Fedora Asahi Atomic base image ---"
echo "This may take several minutes with no progress shown..."
sudo ostree container image pull /ostree/repo \
    ostree-unverified-registry:${IMAGE}

echo ""
echo "--- Step 5: Get root partition UUID ---"
ROOT_UUID=$(cat /proc/cmdline | grep -oP 'root=UUID=\K[^\s]+')
echo "Root UUID: $ROOT_UUID"

if [[ -z "$ROOT_UUID" ]]; then
    echo "ERROR: Could not detect root UUID from /proc/cmdline"
    echo "Please check: cat /proc/cmdline"
    echo "And provide the UUID manually."
    exit 1
fi

echo ""
echo "--- Step 6: Deploy the atomic image ---"
REF=$(sudo ostree refs --repo=/ostree/repo | head -1)
echo "Deploying ref: $REF"

sudo ostree admin deploy "$REF" \
    --sysroot / \
    --os fedora \
    --karg="root=UUID=${ROOT_UUID}" \
    --karg="ro" \
    --karg="rhgb" \
    --karg="quiet"

echo ""
echo "--- Step 7: Update GRUB to boot the new deployment ---"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo ""
echo "============================================"
echo "  Atomic conversion complete!"
echo ""
echo "  After reboot, you will be on Fedora Asahi"
echo "  Atomic (Kinoite). Then run:"
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
