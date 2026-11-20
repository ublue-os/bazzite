#!/usr/bin/env bash
set -xeuo pipefail

echo "::group::Install packages (DX)"
trap 'echo "::endgroup::"' EXIT

dnf5 install -y \
    android-tools \
    bcc \
    bpftop \
    bpftrace \
    ccache \
    flatpak-builder \
    git-subtree \
    google-noto-sans-fonts \
    nicstat \
    numactl \
    podman-machine \
    podman-tui \
    python3-ramalama \
    restic \
    rclone \
    sysprof \
    tiptop \
    usbmuxd \
    waypipe \
    zsh

dnf5 remove -y mesa-libOpenCL
dnf5 --setopt=install_weak_deps=False install -y \
    qemu \
    libvirt \
    qemu-kvm \
    virt-manager \
    edk2-ovmf \
    guestfs-tools

dnf5 install --enable-repo="copr:copr.fedorainfracloud.org:ublue-os:packages" -y \
    ublue-setup-services

dnf5 config-manager addrepo --from-repofile="https://packages.microsoft.com/yumrepos/vscode/config.repo"
dnf5 config-manager setopt vscode-yum.enabled=0
dnf5 install --enable-repo="vscode-yum" -y code

dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 install --enable-repo="docker-ce-stable" -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin
