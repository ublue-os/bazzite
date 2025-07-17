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

# Hide grub by default and set timeout to 5 seconds
mkdir -p /boot/grub2
cat >>/boot/grub2/grub.cfg <<'EOF'

# Setup for liveisos
set menu_auto_hide=2
set timeout_style=hidden
set timeout=5
EOF

sed -i 's|GRUB_TIMEOUT=[0-9]*$|GRUB_TIMEOUT=5|' /etc/default/grub
