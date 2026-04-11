#!/usr/bin/bash

set -eoux pipefail

export BUILDAH_PLATFORM=linux/arm64

restore_kernel_install_tools() {
    if [[ -d /usr/lib/kernel/install.d ]]; then
        for _backup in /usr/lib/kernel/install.d/*.install.bak; do
            [[ -f "${_backup}" ]] || continue
            _original="${_backup%.bak}"
            rm -f "${_original}"
            mv "${_backup}" "${_original}"
            chmod +x "${_original}"
            echo "Restored kernel install hook: ${_original}"
        done
    fi

    if [[ -f /usr/bin/dracut.real ]]; then
        rm -f /usr/bin/dracut
        mv /usr/bin/dracut.real /usr/bin/dracut
        chmod +x /usr/bin/dracut
        echo "Restored: /usr/bin/dracut"
    fi
}

trap restore_kernel_install_tools EXIT

remove_installed_packages() {
    local installed_package
    local package
    local query_output
    local -A installed_packages=()

    for package in "$@"; do
        if query_output="$(rpm -q --whatprovides --qf '%{NAME}\n' "${package}" 2>/dev/null)"; then
            while IFS= read -r installed_package; do
                [[ -n "${installed_package}" ]] || continue
                installed_packages["${installed_package}"]=1
            done <<< "${query_output}"
        fi
    done

    if (( ${#installed_packages[@]} > 0 )); then
        dnf5 -y remove "${!installed_packages[@]}"
    fi
}

# ── Suppress dracut + kernel-install triggers ─────────────────────────────────
# When kernel or kernel-module packages are installed/updated inside a
# container, their RPM post-install scriptlets run dracut and Asahi-specific
# hooks (15-update-m1n1, 50-dracut, 90-loaderentry, etc.) to rebuild the
# initramfs and update the bootloader. All of these fail in containers
# (no live kernel, no ESP, missing tools) and abort the entire dnf transaction.
# Shim ALL scripts in /usr/lib/kernel/install.d/ with no-ops for the build.
# Also shim dracut itself. The finalize script wipes /boot/* at the end anyway.
if [[ -d /usr/lib/kernel/install.d ]]; then
    for _shim in /usr/lib/kernel/install.d/*.install; do
        [[ -f "${_shim}" ]] || continue
        mv "${_shim}" "${_shim}.bak"
        printf '#!/bin/sh\nexit 0\n' > "${_shim}"
        chmod +x "${_shim}"
        echo "Shimmed kernel install hook: ${_shim}"
    done
fi
# Also shim dracut itself in case scriptlets call it directly
if [[ -x /usr/bin/dracut ]]; then
    mv /usr/bin/dracut /usr/bin/dracut.real
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/dracut
    chmod +x /usr/bin/dracut
    echo "Shimmed: /usr/bin/dracut"
fi
# ─────────────────────────────────────────────────────────────────────────────

# KERNEL_VARIANT is passed in via ENV from Containerfile.arm
# stable    = default Asahi kernel (production)
# fairydust = experimental branch with Thunderbolt/USB4/DisplayPort-Alt-Mode
KERNEL_VARIANT="${KERNEL_VARIANT:-stable}"
echo "Building Bazzite ARM with KERNEL_VARIANT=${KERNEL_VARIANT}"

FEDORA_VER=$(rpm -E %fedora)
# Required package transactions must not skip Fedora/RPM Fusion repos. If a
# mirror/metalink is unavailable, failing here gives a clear root cause instead
# of producing a later depsolve wall during the Wine build.
DNF5_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=0"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)
CURL_COMMON_ARGS=(
    -fsSL
    --retry 5
    --retry-all-errors
    --retry-delay 2
    --connect-timeout 20
)

dnf5_install() {
    dnf5 -y install "${DNF5_STRICT_REPO_ARGS[@]}" "$@"
}

refresh_dnf_metadata() {
    dnf5 clean all >/dev/null 2>&1 || true
    rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

dnf5_update_required() {
    if dnf5 update -y --refresh \
        "${DNF5_STRICT_REPO_ARGS[@]}" \
        --exclude='kernel*' --exclude='asahi-kernel*'; then
        return 0
    fi

    echo "dnf5 update failed; cleaning metadata and retrying once." >&2
    refresh_dnf_metadata
    dnf5 update -y --refresh \
        "${DNF5_STRICT_REPO_ARGS[@]}" \
        --exclude='kernel*' --exclude='asahi-kernel*'
}

vendor_enable_system_unit() {
    local unit="$1"
    local install_target
    local target_dir

    shift
    [[ -f "/usr/lib/systemd/system/${unit}" ]] || return 0

    for install_target in "$@"; do
        target_dir="/usr/lib/systemd/system/${install_target}"
        mkdir -p "${target_dir}"
        ln -sf "../${unit}" "${target_dir}/${unit}"
        rm -f "/etc/systemd/system/${install_target}/${unit}"
    done
}

vendor_enable_user_unit() {
    local unit="$1"
    local install_target
    local target_dir

    shift
    [[ -f "/usr/lib/systemd/user/${unit}" ]] || return 0

    for install_target in "$@"; do
        target_dir="/usr/lib/systemd/user/${install_target}"
        mkdir -p "${target_dir}"
        ln -sf "../${unit}" "${target_dir}/${unit}"
        rm -f "/etc/systemd/user/${install_target}/${unit}"
    done
}

# ── Disable broken repos + fix GPG for COPR repos ────────────────────────────
# The Asahi hotfixes repo returns 403 (retired upstream).
dnf5 config-manager setopt 'fedora-asahi-remix-hotfixes*.enabled=0' 2>/dev/null || \
    sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/*hotfixes*.repo 2>/dev/null || true

# COPR repos ship packages signed with COPR project-specific GPG keys that
# may not be pre-imported in the base image's RPM keyring, causing
# "Signature verification failed" when dnf tries to install from them.
# Import all available COPR GPG keys, then set gpgcheck=0 on COPR repos
# as a fallback — this is standard practice for OCI container builds where
# packages come from a known-trusted source (the base image's configured repos).
for gpg_key in /etc/pki/rpm-gpg/RPM-GPG-KEY-*; do
    [[ -f "$gpg_key" ]] && rpm --import "$gpg_key" 2>/dev/null || true
done
for copr_repo in /etc/yum.repos.d/_copr*.repo; do
    [[ -f "$copr_repo" ]] || continue
    sed -i 's/^gpgcheck=1/gpgcheck=0/' "$copr_repo"
done

dnf5_install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

dnf5_update_required

# Remove conflicting/unwanted packages from the base
remove_installed_packages \
    tuned-ppd

remove_installed_packages \
    ublue-os-update-services \
    toolbox \
    htop

# Keep Firefox RPM -- users need a browser immediately out of the box.
# The Flatpak version will install via first-boot service and users can
# switch later. On ARM we don't remove the RPM like x86 Bazzite does.

# Media codec support via RPM Fusion
media_repo_args=(--enable-repo="*rpmfusion*")
if dnf5 repolist --all | grep -q '^fedora-multimedia '; then
    media_repo_args+=(--disable-repo="*fedora-multimedia*")
fi

dnf5_install "${media_repo_args[@]}" \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils \
    libfreeaptx || true

# Gaming packages available natively on aarch64
dnf5_install --skip-broken --skip-unavailable \
    gamescope \
    mangohud \
    lutris

# Bazzite desktop stack (ARM-compatible packages only)
dnf5_install --skip-broken --skip-unavailable \
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
    pipewire-module-filter-chain-sofa \
    python3-icoextract \
    tailscale \
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
    dnf5_install --skip-broken --skip-unavailable \
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
    remove_installed_packages \
        plasma-drkonqi \
        plasma-welcome \
        plasma-welcome-fedora \
        plasma-discover-kns \
        kcharselect \
        kde-partitionmanager \
        plasma-discover
else
    dnf5_install --skip-broken --skip-unavailable \
        gnome-tweaks \
        gnome-extensions-app \
        dconf-editor \
        ptyxis
fi

# Enable COPRs that have aarch64 builds
dnf5_install dnf5-plugins || true
if dnf5 -y copr enable ublue-os/staging 2>/dev/null; then
    dnf5_install --skip-broken --skip-unavailable \
        topgrade
fi

if dnf5 -y copr enable ublue-os/packages 2>/dev/null; then
    dnf5_install --skip-broken --skip-unavailable \
        uupd

    if [[ -f /usr/lib/systemd/system/uupd.service ]]; then
        sed -i '/^ExecStart=/s|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service
    fi

    if [[ -f /usr/lib/systemd/system/uupd.timer ]]; then
        vendor_enable_system_unit uupd.timer timers.target.wants
    fi
fi

if dnf5 -y copr enable ublue-os/bling 2>/dev/null; then
    dnf5_install --skip-broken --skip-unavailable \
        ublue-os-bling
fi

# Thunderbolt / USB4 userspace stack
# bolt: Thunderbolt device manager -- authorises devices, works with any
# kernel that has CONFIG_USB4/CONFIG_THUNDERBOLT. Installed on ALL variants.
# With the fairydust kernel, this unlocks your dock + peripherals + 4K display.
dnf5_install --skip-broken --skip-unavailable \
    bolt \
    usbutils \
    pciutils

# bolt is D-Bus activated by org.freedesktop.bolt, and its unit is static, so
# there is no install target to enable at image build time.

# fairydust-specific setup
# The fairydust kernel RPM is not yet packaged in any COPR so we cannot swap
# the kernel at image build time. Instead we write a marker file and pre-install
# the full kernel build toolchain so ujust install-fairydust-kernel works
# immediately without any extra package installation steps.
if [[ "${KERNEL_VARIANT}" == "fairydust" ]]; then
    echo "fairydust" > /usr/share/ublue-os/kernel-variant

    # Kernel build toolchain -- everything needed to compile Linux from source
    # on native aarch64. Note: gcc-aarch64-linux-gnu is a CROSS-compiler (wrong
    # here); on native ARM64 we just use plain gcc.
    dnf5_install --skip-broken --skip-unavailable \
        gcc \
        gcc-c++ \
        make \
        bc \
        bison \
        flex \
        git \
        openssl-devel \
        dwarves \
        elfutils-libelf-devel \
        perl \
        perl-Carp \
        perl-generators \
        rpm-build \
        ncurses-devel \
        python3 \
        rsync \
        cpio \
        binutils \
        openssl \
        diffutils \
        hostname \
        kmod \
        dracut \
        grubby \
        usbredir \
        nftables

    echo "fairydust kernel build toolchain installed."
else
    echo "stable" > /usr/share/ublue-os/kernel-variant
fi

# Asahi Flatpak Mesa runtimes -- GPU acceleration for Flatpak apps
# These come from the @asahi:flatpak COPR already configured in the base image
dnf5_install --skip-broken --skip-unavailable \
    mesa-asahi-24.08-flatpak \
    mesa-asahi-23.08-flatpak || true

# Enable services with vendor symlinks in /usr/lib so image-owned enablement
# does not persist as mutable /etc/systemd state across rebases.
vendor_enable_system_unit podman.socket sockets.target.wants || true
vendor_enable_system_unit tailscaled.service multi-user.target.wants || true
vendor_enable_system_unit speakersafetyd.service multi-user.target.wants || true
vendor_enable_system_unit input-remapper.service default.target.wants || true
vendor_enable_system_unit \
    greenboot-healthcheck.service \
    boot-complete.target.requires \
    multi-user.target.wants || true
vendor_enable_system_unit \
    greenboot-set-rollback-trigger.service \
    greenboot-healthcheck.service.wants \
    systemd-update-done.service.wants || true
vendor_enable_system_unit greenboot-success.target multi-user.target.wants || true
vendor_enable_user_unit ntfs-nag.service xdg-desktop-autostart.target.wants || true
vendor_enable_user_unit systemd-tmpfiles-setup.service basic.target.wants || true
systemctl disable waydroid-container.service || true
systemctl disable rpm-ostreed-automatic.timer || true
systemctl disable force-wol.service || true
systemctl mask iscsi || true
# Do NOT mask wpa_supplicant on ARM -- Apple Silicon uses NM + wpa_supplicant
# for the Broadcom WiFi chip. Masking it breaks WiFi entirely.
systemctl disable iwd.service || true

if [[ -f /usr/lib/systemd/system/power-profiles-daemon.service ]]; then
    vendor_enable_system_unit power-profiles-daemon.service graphical.target.wants || true
fi

# Bluetooth: enable userspace HID for Apple keyboards/trackpads
sed -i 's/#UserspaceHID=true/UserspaceHID=true/' /etc/bluetooth/input.conf || true

# Force NetworkManager to use wpa_supplicant backend for WiFi on Apple Silicon.
# Without this, NM may try the iwd backend which doesn't reliably work with
# the Broadcom WiFi chip on M-series Macs, causing WiFi to disconnect or not appear.
mkdir -p /etc/NetworkManager/conf.d
printf '[device]\nwifi.backend=wpa_supplicant\n' \
    > /etc/NetworkManager/conf.d/wifi_backend.conf

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
curl "${CURL_COMMON_ARGS[@]}" "https://raw.githubusercontent.com/ublue-os/toolboxes/main/apps/docker/distrobox.ini" -o /etc/distrobox/docker.ini || true
curl "${CURL_COMMON_ARGS[@]}" "https://raw.githubusercontent.com/ublue-os/toolboxes/main/apps/incus/distrobox.ini" -o /etc/distrobox/incus.ini || true

# bash-preexec for shell integration
curl "${CURL_COMMON_ARGS[@]}" "https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh" -o /usr/share/bash-prexec || true

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
    [[ -f "$f" ]] || continue
    name=$(basename "$f")
    echo "import \"/usr/share/ublue-os/just/$name\"" >> "$JUSTFILE"
done

# winetricks (arch-independent shell script)
if curl "${CURL_COMMON_ARGS[@]}" "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o /usr/bin/winetricks; then
    chmod +x /usr/bin/winetricks
fi

# Flatpak first-boot configuration
mkdir -p /usr/lib/bazzite/scripts
cat > /usr/lib/bazzite/scripts/install-flatpaks.sh << 'FLATPAK_EOF'
#!/usr/bin/bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Firefox first -- users need a browser before anything else
flatpak install -y --noninteractive flathub org.mozilla.firefox || true
flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal || true
flatpak install -y --noninteractive flathub com.mattjakeman.ExtensionManager || true
flatpak install -y --noninteractive flathub com.discordapp.Discord || true
flatpak install -y --noninteractive flathub com.spotify.Client || true
FLATPAK_EOF
chmod +x /usr/lib/bazzite/scripts/install-flatpaks.sh

mkdir -p /usr/lib/systemd/system /usr/lib/systemd/system/multi-user.target.wants
cat > /usr/lib/systemd/system/bazzite-first-boot-flatpaks.service << 'SVC_EOF'
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
rm -f /etc/systemd/system/bazzite-first-boot-flatpaks.service \
      /etc/systemd/system/multi-user.target.wants/bazzite-first-boot-flatpaks.service
ln -sf ../bazzite-first-boot-flatpaks.service \
    /usr/lib/systemd/system/multi-user.target.wants/bazzite-first-boot-flatpaks.service

# Keep Bazzite-owned service enablement in /usr/lib so rebases do not retain
# stale /etc systemd state from earlier image revisions.
mkdir -p /usr/lib/systemd/user/default.target.wants
rm -f /etc/systemd/system/bazzite-flatpak-manager.service \
      /etc/systemd/system/bazzite-hardware-setup.service \
      /etc/systemd/system/multi-user.target.wants/bazzite-flatpak-manager.service \
      /etc/systemd/system/multi-user.target.wants/bazzite-hardware-setup.service \
      /etc/systemd/user/bazzite-user-setup.service \
      /etc/systemd/user/bazzite-dynamic-fixes.service \
      /etc/systemd/user/default.target.wants/bazzite-user-setup.service \
      /etc/systemd/user/default.target.wants/bazzite-dynamic-fixes.service
ln -sf ../bazzite-flatpak-manager.service \
    /usr/lib/systemd/system/multi-user.target.wants/bazzite-flatpak-manager.service
ln -sf ../bazzite-hardware-setup.service \
    /usr/lib/systemd/system/multi-user.target.wants/bazzite-hardware-setup.service
ln -sf ../bazzite-user-setup.service \
    /usr/lib/systemd/user/default.target.wants/bazzite-user-setup.service
ln -sf ../bazzite-dynamic-fixes.service \
    /usr/lib/systemd/user/default.target.wants/bazzite-dynamic-fixes.service

# Lock down COPR repos post-build -- prevent unexpected package pulls on updates.
# The Asahi COPRs must stay enabled (kernel, mesa, firmware updates).
# Only disable the ublue-os COPRs we added for build-time package installation.
for repo in /etc/yum.repos.d/_copr*ublue-os*.repo; do
    if [[ -f "$repo" ]]; then
        sed -i 's/enabled=1/enabled=0/' "$repo"
    fi
done

restore_kernel_install_tools
trap - EXIT

/ctx/cleanup
