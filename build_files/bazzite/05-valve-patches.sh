#!/usr/bin/env bash
#
# Install Valve's patched Mesa and Xwayland
# Removes conflicting packages, swaps in patched versions, locks them, and
# installs additional multimedia dependencies.
#
set -xeuo pipefail

echo "::group::Install Valve patches"
trap 'echo "::endgroup::"' EXIT

# -- Remove conflicting packages --
# pipewire-config-raop conflicts with Valve's patched audio stack;
# mesa-va-drivers conflicts with the patched Mesa from terra-mesa.
echo "==> Removing conflicting packages..."
dnf5 -y remove pipewire-config-raop mesa-va-drivers

# -- Swap in Valve's patched packages --
# Xwayland and wireplumber from Terra extras; mesa-filesystem from terra-mesa.
echo "==> Swapping in Valve's patched packages..."
dnf5 -y swap --from-repo=terra-mesa mesa-filesystem mesa-filesystem

echo "    Swapping Xwayland → terra-xorg-x11-server-Xwayland..."
dnf5 -y swap --allowerasing \
    --repo terra-extras \
    xorg-x11-server-Xwayland terra-xorg-x11-server-Xwayland

# Swap wireplumber for terra's patched version
echo "    Swapping wireplumber → terra-wireplumber..."
dnf5 -y swap --allowerasing --repo terra-extras wireplumber terra-wireplumber

echo "==> Installing Terra BlueZ packages..."
dnf5 -y install \
    --allowerasing \
    --repo terra-extras \
    terra-bluez \
    terra-bluez-libs \
    terra-bluez-obexd \
    terra-bluez-cups

# -- Version-lock patched packages --
# Prevent dnf from overwriting Valve's patched Mesa and Xwayland.
echo "==> Locking package versions..."
dnf5 versionlock add \
    terra-xorg-x11-server-Xwayland \
    terra-bluez \
    mesa-dri-drivers \
    mesa-filesystem \
    mesa-libEGL \
    mesa-libGL \
    mesa-libgbm \
    mesa-vulkan-drivers

# -- Install Mesa OpenCL & 32-bit EGL --
# intel-opencl and clinfo for OpenCL support; mesa-libEGL.i686 for 32-bit compat.
echo "==> Installing Mesa OpenCL and 32-bit EGL..."
dnf5 -y install \
    mesa-libEGL.i686 \
    intel-opencl \
    clinfo

# -- Install audio codec support --
# libfreeaptx for A2DP aptX audio codec support.
echo "==> Installing libfreeaptx..."
dnf5 -y install libfreeaptx

# -- Install multimedia codecs --
# OpenH264 (both arches) and libbluray from fedora-multimedia.
echo "==> Installing OpenH264 and libbluray..."
dnf5 -y install --allowerasing \
    openh264.x86_64 \
    openh264.i686

dnf5 -y install \
    libbluray \
    libbluray-utils
