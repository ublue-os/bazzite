#!/usr/bin/bash

set -eoux pipefail

export BUILDAH_PLATFORM=linux/arm64

dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 update -y --refresh

# Remove conflicting/unwanted packages from the base
dnf5 -y remove \
    tuned-ppd || true

dnf5 -y remove \
    ublue-os-update-services \
    firefox \
    firefox-langpacks \
    toolbox \
    htop || true

# Media codec support via RPM Fusion
dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils \
    libfreeaptx || true

# Gaming packages available natively on aarch64
dnf5 -y install --skip-broken --skip-unavailable \
    gamescope \
    mangohud \
    lutris

# Bazzite desktop stack (ARM-compatible packages only)
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
    pipewire-module-filter-chain-sofa \
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
    bees \
    usbip \
    stress-ng \
    gobject-introspection \
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
    cabextract \
    dbus-x11 \
    xrandr \
    evtest \
    xdg-user-dirs \
    xdg-terminal-exec

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
        uupd \
        topgrade
fi

if dnf5 -y copr enable ublue-os/bling 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        ublue-os-bling
fi

# Asahi Flatpak Mesa runtimes -- GPU acceleration for Flatpak apps
# These come from the @asahi:flatpak COPR already configured in the base image
dnf5 -y install --skip-broken --skip-unavailable \
    mesa-asahi-24.08-flatpak \
    mesa-asahi-23.08-flatpak || true

# Enable services
systemctl enable podman.socket || true
systemctl enable tailscaled.service || true
systemctl enable speakersafetyd.service || true
systemctl enable input-remapper.service || true
systemctl enable greenboot-healthcheck.service || true
systemctl enable greenboot-set-rollback-trigger.service || true
systemctl enable bazzite-flatpak-manager.service || true
systemctl enable bazzite-hardware-setup.service || true
systemctl enable --global bazzite-user-setup.service || true
systemctl enable --global bazzite-dynamic-fixes.service || true
systemctl enable --global ntfs-nag.service || true
systemctl enable --global systemd-tmpfiles-setup.service || true
systemctl disable waydroid-container.service || true
systemctl disable rpm-ostreed-automatic.timer || true
systemctl disable force-wol.service || true
systemctl mask iscsi || true
systemctl mask wpa_supplicant.service || true
systemctl disable iwd.service || true

if systemctl list-unit-files | grep -q power-profiles-daemon.service; then
    systemctl enable power-profiles-daemon || true
fi

# Bluetooth: enable userspace HID for Apple keyboards/trackpads
sed -i 's/#UserspaceHID=true/UserspaceHID=true/' /etc/bluetooth/input.conf || true

# PulseAudio shim -- some apps hardcode a check for pulseaudio binary
ln -sf /usr/bin/true /usr/bin/pulseaudio || true

# Flathub remote -- ensure it's configured system-wide
mkdir -p /etc/flatpak/remotes.d
cat > /etc/flatpak/remotes.d/flathub.flatpakrepo << 'FLATHUB_EOF'
[Flatpak Repo]
Title=Flathub
Url=https://dl.flathub.org/repo/
Homepage=https://flathub.org/
Comment=Central repository of Flatpak applications
Description=Central repository of Flatpak applications
Icon=https://dl.flathub.org/repo/logo.svg
GPGKey=mQINBFlD2sABEADsiUZUOYBg1UdDaWkEdJYkTSZD68214m8Q1fbrP5AptaUfCl8KYKFMNoAe8SB
FLATHUB_EOF

# Waydroid: patch nft/iptables detection for container networking
if [[ -f /usr/lib/waydroid/data/scripts/waydroid-net.sh ]]; then
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh || true
fi

# Remove toolbox profile.d script (conflicts with distrobox)
rm -f /etc/profile.d/toolbox.sh || true

# rpm-ostreed: disable automatic staging (Bazzite manages updates via uupd)
if [[ -f /etc/rpm-ostreed.conf ]]; then
    sed -i 's/#\?AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=none/' /etc/rpm-ostreed.conf || true
fi

# Distrobox configs
mkdir -p /etc/distrobox
curl -sL "https://raw.githubusercontent.com/ublue-os/toolboxes/main/apps/docker/Distrobox.ini" -o /etc/distrobox/docker.ini || true
curl -sL "https://raw.githubusercontent.com/ublue-os/toolboxes/main/apps/incus/Distrobox.ini" -o /etc/distrobox/incus.ini || true

# bash-preexec for shell integration
curl -sL "https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh" -o /usr/share/bash-prexec || true

# ujust system -- the ublue-os-just package is not available on aarch64,
# so we create the ujust wrapper, helper library, and root justfile here.
mkdir -p /usr/lib/ujust
cat > /usr/lib/ujust/ujust.sh << 'UJUST_LIB_EOF'
#!/usr/bin/bash
BOLD='\033[1m'
NORMAL='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'

ugum() { /usr/bin/gum "$@"; }

Chooser() {
    ugum choose "$@"
}

Choose() {
    Chooser "$@" --header "$1"
}

OPTION=""
UJUST_LIB_EOF
chmod +x /usr/lib/ujust/ujust.sh

cat > /usr/bin/ujust << 'UJUST_BIN_EOF'
#!/usr/bin/bash
JUST_DIR="/usr/share/ublue-os"
if [ $# -eq 0 ]; then
    just --unstable --justfile "$JUST_DIR/justfile" --list --list-heading $'Available commands:\n'
else
    just --unstable --justfile "$JUST_DIR/justfile" "$@"
fi
UJUST_BIN_EOF
chmod +x /usr/bin/ujust

# Generate the root justfile that imports all .just modules
JUSTFILE="/usr/share/ublue-os/justfile"
cat > "$JUSTFILE" << 'JUSTFILE_HEADER'
set shell := ["/usr/bin/bash", "-euo", "pipefail", "-c"]

default:
    @just --unstable --list --list-heading $'Available commands:\n'
JUSTFILE_HEADER

for f in /usr/share/ublue-os/just/*.just; do
    name=$(basename "$f")
    echo "import \"/usr/share/ublue-os/just/$name\"" >> "$JUSTFILE"
done

# winetricks (arch-independent shell script)
curl -sL "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o /usr/bin/winetricks && \
    chmod +x /usr/bin/winetricks || true

# Flatpak first-boot configuration
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

# Lock down COPR repos post-build -- prevent unexpected package pulls on updates.
# The Asahi COPRs must stay enabled (kernel, mesa, firmware updates).
# Only disable the ones we added for build-time package installation.
for repo in /etc/yum.repos.d/_copr*.repo; do
    if [[ -f "$repo" ]]; then
        sed -i 's/enabled=1/enabled=0/' "$repo"
    fi
done

/ctx/cleanup
