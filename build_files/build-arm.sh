#!/usr/bin/bash

set -eoux pipefail

export BUILDAH_PLATFORM=linux/arm64

dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 update -y --refresh

# Asahi-specific hardware support is already in the base image:
#   - asahi-audio, asahi-scripts, apple firmware
#   - Asahi Mesa (AGX GPU driver)
#   - Asahi kernel with Apple Silicon DT/driver support

# Remove conflicting packages
dnf5 -y remove \
    tuned-ppd || true

dnf5 -y remove \
    ublue-os-update-services \
    firefox \
    firefox-langpacks \
    toolbox \
    htop || true

# Install base desktop packages (ARM-native, no i686/multilib)
dnf5 -y install \
    bluez \
    bluez-libs \
    xorg-x11-server-Xwayland \
    mesa-dri-drivers \
    mesa-filesystem \
    mesa-libEGL \
    mesa-libGL \
    mesa-libgbm \
    mesa-vulkan-drivers \
    fwupd \
    NetworkManager \
    NetworkManager-wifi \
    NetworkManager-bluetooth \
    libfreeaptx

dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils || true

# Install Bazzite desktop stack (ARM-compatible subset)
dnf5 -y install --skip-broken --skip-unavailable \
    iwd \
    greenboot \
    greenboot-default-health-checks \
    twitter-twemoji-fonts \
    google-noto-sans-cjk-fonts \
    lato-fonts \
    fira-code-fonts \
    python3-pip \
    libadwaita \
    xwininfo \
    compsize \
    ddcutil \
    input-remapper \
    libinput-utils \
    i2c-tools \
    lm_sensors \
    iio-sensor-proxy \
    udica \
    ladspa-caps-plugins \
    ladspa-noise-suppression-for-voice \
    python3-icoextract \
    tailscale \
    webapp-manager \
    btop \
    duf \
    fish \
    lshw \
    xdotool \
    wmctrl \
    libcec \
    v4l-utils \
    yad \
    f3 \
    pulseaudio-utils \
    lzip \
    p7zip \
    p7zip-plugins \
    libxcrypt-compat \
    vulkan-tools \
    fastfetch \
    glow \
    gum \
    vim \
    tmux \
    git \
    powertop \
    power-profiles-daemon \
    distrobox \
    podman \
    just \
    jq \
    cockpit-networkmanager \
    cockpit-podman \
    cockpit-selinux \
    cockpit-system \
    cockpit-files \
    cockpit-storaged \
    topgrade \
    ydotool \
    snapper \
    lsb_release \
    waydroid \
    cage \
    wlr-randr \
    cabextract

# DE-specific packages
if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then
    dnf5 -y install --skip-broken --skip-unavailable \
        qt \
        krdp \
        kdeconnectd \
        kdeplasma-addons \
        fcitx5-mozc \
        fcitx5-chinese-addons \
        fcitx5-hangul \
        kcm-fcitx5 \
        gnome-disk-utility \
        kio-extras \
        krdc \
        ptyxis
    dnf5 -y remove \
        plasma-drkonqi \
        plasma-welcome \
        plasma-welcome-fedora \
        plasma-discover-kns \
        kcharselect \
        kde-partitionmanager \
        plasma-discover || true
else
    dnf5 -y install --skip-broken --skip-unavailable \
        gnome-tweaks \
        gnome-extensions-app \
        dconf-editor \
        ptyxis
fi

# Enable COPRs that have aarch64 builds
if dnf5 -y copr enable ublue-os/staging 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        ublue-update \
        uupd
fi

if dnf5 -y copr enable ublue-os/bling 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        ublue-os-bling
fi

# Enable services
systemctl enable podman.socket || true
systemctl enable tailscaled.service || true
systemctl mask iscsi || true
systemctl mask wpa_supplicant.service || true
systemctl disable iwd.service || true

if systemctl list-unit-files | grep -q power-profiles-daemon.service; then
    systemctl enable power-profiles-daemon || true
fi

# Install winetricks (arch-independent shell script)
curl -sL "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o /usr/bin/winetricks && \
    chmod +x /usr/bin/winetricks || true

# Flatpak configuration for first-boot
mkdir -p /usr/lib/bazzite/scripts
cat > /usr/lib/bazzite/scripts/install-flatpaks.sh << 'FLATPAK_EOF'
#!/usr/bin/bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal || true
flatpak install -y --noninteractive flathub org.mozilla.firefox || true
flatpak install -y --noninteractive flathub com.mattjakeman.ExtensionManager || true
FLATPAK_EOF
chmod +x /usr/lib/bazzite/scripts/install-flatpaks.sh

mkdir -p /etc/systemd/system
cat > /etc/systemd/system/bazzite-first-boot-flatpaks.service << 'SVC_EOF'
[Unit]
Description=Install essential Flatpaks on first boot
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/bazzite/flatpaks-installed

[Service]
Type=oneshot
ExecStart=/usr/lib/bazzite/scripts/install-flatpaks.sh
ExecStartPost=/usr/bin/mkdir -p /var/lib/bazzite
ExecStartPost=/usr/bin/touch /var/lib/bazzite/flatpaks-installed

[Install]
WantedBy=multi-user.target
SVC_EOF
systemctl enable bazzite-first-boot-flatpaks.service || true

/ctx/cleanup
