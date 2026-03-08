#!/usr/bin/bash
set -xeuo pipefail

dnf5 install -y \
    android-tools \
    bcc \
    bpftop \
    bpftrace \
    ccache \
    flatpak-builder \
    git-subtree \
    nicstat \
    numactl \
    podman-machine \
    podman-tui \
    python3-ramalama \
    qemu-kvm \
    restic \
    rclone \
    sysprof \
    tiptop \
    usbmuxd \
    zsh

# Restore UUPD update timer and Input Remapper
sed -i 's@^NoDisplay=true@NoDisplay=false@' /usr/share/applications/input-remapper-gtk.desktop
systemctl enable input-remapper.service
systemctl enable uupd.timer

# Remove -deck specific changes to allow for login screens and session selection in settings
rm -f /etc/sddm.conf.d/steamos.conf
rm -f /etc/sddm.conf.d/virtualkbd.conf
rm -f /etc/sddm.conf.d/zz-steamos-autologin.conf
rm -f /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz
systemctl disable bazzite-autologin.service
dnf5 remove -y steamos-manager

if [[ "$IMAGE_NAME" == *gnome* ]]; then
    # Remove SDDM and re-enable GDM on GNOME builds.
    dnf5 remove -y \
        sddm

    systemctl enable gdm.service
else
    # Re-enable logout and switch user functionality in KDE
    sed -i -E \
      -e 's/^(action\/switch_user)=false/\1=true/' \
      -e 's/^(action\/start_new_session)=false/\1=true/' \
      -e 's/^(action\/lock_screen)=false/\1=true/' \
      -e 's/^(kcm_sddm\.desktop)=false/\1=true/' \
      -e 's/^(kcm_plymouth\.desktop)=false/\1=true/' \
      /etc/xdg/kdeglobals
fi


dnf5 install --enable-repo="copr:copr.fedorainfracloud.org:ublue-os:packages" -y \
    ublue-setup-services

# Adding repositories should be a LAST RESORT. Contributing to Terra or `ublue-os/packages` is much preferred
# over using random coprs. Please keep this in mind when adding external dependencies.
# If adding any dependency, make sure to always have it disabled by default and _only_ enable it on `dnf install`

dnf5 config-manager addrepo --set=baseurl="https://packages.microsoft.com/yumrepos/vscode" --id="vscode"
dnf5 config-manager setopt vscode.enabled=0
# FIXME: gpgcheck is broken for vscode due to it using `asc` for checking
# seems to be broken on newer rpm security policies.
dnf5 config-manager setopt vscode.gpgcheck=0
dnf5 install --nogpgcheck --enable-repo="vscode" -y \
    code

docker_pkgs=(
    containerd.io
    docker-buildx-plugin
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 install -y --enable-repo="docker-ce-stable" "${docker_pkgs[@]}" || {
    # Use test packages if docker pkgs is not available for f42
    if (($(lsb_release -sr) == 42)); then
        echo "::info::Missing docker packages in f42, falling back to test repos..."
        dnf5 install -y --enablerepo="docker-ce-test" "${docker_pkgs[@]}"
    fi
}

# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF
