#!/usr/bin/env bash
#
# Remove packages and configurations that conflict with NVIDIA drivers.
#
# Removes incompatible firmware and utilities, and swaps cardwire for
# switcheroo-control on non-deck images.
#
set -xeuo pipefail

echo "::group::Remove Nvidia conflicts"
trap 'echo "::endgroup::"' EXIT

# -- Remove conflicting firmware and ROCm packages --
# nvidia-gpu-firmware conflicts with NVIDIA proprietary drivers.
echo "==> Removing conflicting firmware..."
dnf5 -y remove \
    nvidia-gpu-firmware \
    rocm-opencl \
    rocm-clinfo \
    rocm-smi

# -- Replace cardwire with switcheroo-control (nvidia-lts only) --
# On nvidia-lts, cardwire doesn't work well; swap it for switcheroo-control
# and install supergfxctl from the terra repo.
if [[ "${NVIDIA_FLAVOR}" = "nvidia-lts" ]]; then
    echo "    Disabling cardwired.service..."
    systemctl disable cardwired.service

    echo "    Removing cardwire-gui..."
    dnf5 -y remove cardwire-gui

    echo "    Swapping cardwire for switcheroo-control..."
    dnf5 -y swap cardwire switcheroo-control

    echo "    Installing supergfxctl from ublue repo..."
    dnf5 -y copr enable ublue-os/staging
    dnf5 -y install supergfxctl
    dnf5 -y copr disable ublue-os/staging
fi

# -- Remove nvidia-deck configuration on non-deck images --
# The nvidia-deck.conf is only relevant for Steam Deck images.
if ! grep -q "deck" <<< "${IMAGE_NAME}"; then
    echo "    Removing nvidia-deck.conf (not a deck image)..."
    rm -f /usr/lib/modprobe.d/nvidia-deck.conf
fi
