#!/usr/bin/env bash
#
set -exo pipefail

# Swap kernel with vanilla and rebuild initramfs.
#
# This is done because we want the initramfs to use a signed
# kernel for secureboot.
kernel_pkgs=(
    kernel
    kernel-core
    kernel-devel
    kernel-devel-matched
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
)
dnf -y versionlock delete "${kernel_pkgs[@]}"
rpm --erase -v --nodeps "${kernel_pkgs[@]}"
dnf -yq install "${kernel_pkgs[@]}"

imageref="$(podman images --format '{{ index .Names 0 }}\n' 'bazzite*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"

# Include nvidia-gpu-firmware package.
if [[ $imageref == *-nvidia* ]]; then
    dnf install -yq nvidia-gpu-firmware
fi
