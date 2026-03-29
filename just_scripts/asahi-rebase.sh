#!/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

IMAGE="localhost/bazzite-arm:latest"

echo "=== Building Bazzite ARM image ==="
sudo podman build \
  --platform linux/arm64 \
  -f Containerfile.arm \
  --build-arg BASE_IMAGE_NAME=kinoite \
  --build-arg FEDORA_VERSION=42 \
  --build-arg IMAGE_NAME=bazzite-arm \
  --build-arg IMAGE_VENDOR=ublue-os \
  --build-arg IMAGE_BRANCH=apple-silicon \
  --build-arg VERSION_TAG=local \
  --build-arg VERSION_PRETTY="Local Build" \
  --build-arg SHA_HEAD_SHORT=local \
  -t "$IMAGE" \
  .

echo ""
echo "=== Converting system to Bazzite ARM ==="
echo "This will reinitialize /boot and convert this installation."
echo "macOS is NOT affected."
read -rp "Continue? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
  echo "Aborted."
  exit 0
fi

sudo podman run --rm --privileged \
  -v /dev:/dev \
  -v /var/lib/containers:/var/lib/containers \
  -v /:/target \
  --pid=host \
  --security-opt label=type:unconfined_t \
  -e LANG=C.UTF-8 \
  -e LC_ALL=C.UTF-8 \
  "$IMAGE" \
  bootc install to-existing-root

echo ""
echo "=== Done! Rebooting into Bazzite ARM ==="
echo "After reboot, verify with: ujust check-x86-emulation"
systemctl reboot
