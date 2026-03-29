#!/usr/bin/bash
set -euo pipefail

# Bazzite ARM setup script for Fedora Asahi Remix (traditional install).
# Installs the complete Bazzite gaming and desktop stack directly onto
# an existing Fedora Asahi Remix system.

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Error: This script must be run on an aarch64 system."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script needs root. Re-running with sudo..."
    exec sudo bash "$0" "$@"
fi

echo "============================================="
echo "  Bazzite ARM Setup for Fedora Asahi Remix"
echo "============================================="
echo ""
echo "This will install the full Bazzite gaming and"
echo "desktop stack onto your Asahi Linux system."
echo ""
read -rp "Continue? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "=== Installing RPM Fusion ==="
dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo ""
echo "=== Updating system ==="
dnf5 update -y --refresh

echo ""
echo "=== Installing x86 emulation stack ==="
dnf5 -y install \
    fex-emu \
    box64 \
    muvm \
    libkrun \
    libkrunfw \
    qemu-user-static \
    qemu-user-binfmt

echo ""
echo "=== Installing Steam ==="
dnf5 -y install steam

echo ""
echo "=== Installing gaming packages ==="
dnf5 -y install --skip-broken --skip-unavailable \
    gamescope \
    mangohud \
    lutris

echo ""
echo "=== Installing media codecs ==="
dnf5 -y install --enable-repo="*rpmfusion*" --skip-broken --skip-unavailable \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils \
    libfreeaptx

echo ""
echo "=== Installing Bazzite desktop packages ==="
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
    compsize \
    ddcutil \
    input-remapper \
    libinput-utils \
    i2c-tools \
    lm_sensors \
    iio-sensor-proxy \
    ladspa-caps-plugins \
    ladspa-noise-suppression-for-voice \
    pipewire-module-filter-chain-sofa \
    tailscale \
    btop \
    duf \
    fish \
    lshw \
    libcec \
    v4l-utils \
    pulseaudio-utils \
    p7zip \
    p7zip-plugins \
    libxcrypt-compat \
    vulkan-tools \
    fastfetch \
    glow \
    gum \
    vim \
    tmux \
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
    ydotool \
    snapper \
    waydroid \
    cage \
    wlr-randr \
    cabextract \
    dbus-x11 \
    evtest \
    xdg-user-dirs

echo ""
echo "=== Installing KDE extras ==="
dnf5 -y install --skip-broken --skip-unavailable \
    krdp \
    kdeconnectd \
    kdeplasma-addons \
    fcitx5-mozc \
    fcitx5-chinese-addons \
    fcitx5-hangul \
    kcm-fcitx5 \
    gnome-disk-utility \
    kio-extras \
    krdc

echo ""
echo "=== Enabling services ==="
systemctl enable podman.socket || true
systemctl enable tailscaled.service || true
systemctl enable speakersafetyd.service || true
systemctl enable input-remapper.service || true
systemctl enable greenboot-healthcheck.service || true

if systemctl list-unit-files | grep -q power-profiles-daemon.service; then
    systemctl enable power-profiles-daemon || true
fi

echo ""
echo "=== Configuring Bluetooth for Apple hardware ==="
sed -i 's/#UserspaceHID=true/UserspaceHID=true/' /etc/bluetooth/input.conf || true

echo ""
echo "=== Installing winetricks ==="
if curl -sL "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o /usr/bin/winetricks; then
    chmod +x /usr/bin/winetricks
fi

echo ""
echo "=== Setting up Flathub ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

echo ""
echo "=== Installing Flatpak apps ==="
flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal || true
flatpak install -y --noninteractive flathub org.mozilla.firefox || true

echo ""
echo "=== Setting up ujust ==="
mkdir -p /usr/lib/ujust
cat > /usr/lib/ujust/ujust.sh << 'UJUST_LIB'
#!/usr/bin/bash
BOLD='\033[1m'
NORMAL='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ugum() { /usr/bin/gum "$@"; }
Chooser() { ugum choose "$@"; }
Choose() { Chooser "$@" --header "$1"; }
OPTION=""
UJUST_LIB
chmod +x /usr/lib/ujust/ujust.sh

echo ""
echo "============================================="
echo "  Setup complete!"
echo "============================================="
echo ""
echo "Installed:"
echo "  - FEX-Emu + Box64 (x86 emulation)"
echo "  - Steam (Asahi native package)"
echo "  - gamescope, mangohud, lutris"
echo "  - Full Bazzite desktop stack"
echo ""
echo "Launch Steam from your application menu."
echo "Reboot recommended: sudo systemctl reboot"
