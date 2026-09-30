#
#     %%%%%%====%%%%%%%%%%
#   %%%%%%%%    %%%%%%%%%%%%%%
#  %%%%%%%%%    %%%%%%%%%%%%%%%%
#  %%%%%%%%%    %%%%%%%%%%%%%%%###
#  %%%%%%%%%    %%%%%%%%%%%%%######
#  ==                  =======######
#  ==                  =========#####
#  %%%%%%%%%    %%%%%%%####======#####
#  %%%%%%%%%    %%%%%#######=====#####
#  %%%%%%%%%    %%%#########=====#####
#  %%%%%%%%%    %%##########=====#####
#  %%%%%%%%%====###########=====######
#   %%%%%%%%====#########======######
#    %%%%%%%=====#####========######
#     %%%%###===============#######
#      %#######==========#########
#        #######################
#          ###################
#              ###########
#
# Welcome to Bazzite! If you're looking to
# build your own, we highly recommend you
# use our custom image template. Forking
# the main repo provides more control, but
# is often unnecessary.
#
# https://github.com/ublue-os/image-template

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-44}"
ARG ARCH="${ARCH:-x86_64}"

ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-ogc}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-7.0.9-ogc3.2.fc${FEDORA_VERSION}.${ARCH}}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia-open}"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-nvidia
FROM ghcr.io/ublue-os/brew:latest@sha256:bc6f5a9fc4f28cded2fe567b31f74825c1f4481d5e43c537c3fcc0d3df6d22ab AS brew

FROM scratch AS ctx
COPY build_files /

################
# DESKTOP BUILDS
################

FROM ${BASE_IMAGE} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-44}"
ARG LINUX_FIRMWARE_VERSION="${LINUX_FIRMWARE_VERSION:-20260810-1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared/ system_files/desktop/${BASE_IMAGE_NAME}/ /
RUN find /usr/share/ublue-os/docs -type f -exec setfattr -n user.component -v "ublue-docs" {} +

# Pin linux-firmware to a known-good version
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/pin-linux-firmware

# Install needed firmware blobs
RUN --mount=type=bind,src=firmware,dst=/ctx/firmware \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/install-nonfree-firmware-blobs

# Copy Homebrew files from the brew image
COPY --from=brew /system_files/ /tmp/brew_files/
RUN /ctx/bazzite/copy-brew-files

# Install kernel
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms/common,dst=/tmp/rpms/common \
    --mount=type=bind,from=akmods,src=/rpms/kmods,dst=/tmp/rpms/kmods \
    --mount=type=bind,from=akmods-extra,src=/rpms/extra,dst=/tmp/rpms/extra \
    --mount=type=bind,from=akmods-extra,src=/rpms/kmods,dst=/tmp/rpms/kmods-extra \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-kernel-akmods && \
    /ctx/cleanup

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/setup-copr-repos

# Install Valve's patched Mesa, Bluez, and Xwayland
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/valve-patches

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/global-remove

# Install new packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/install-packages

# Install Steam & Lutris, plus supporting packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/install-steam-lutris

# Install ujust-picker from GitHub releases
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/install-ujust-picker

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/configure-desktops

# ublue-os-media-automount-udev, mount non-removable device partitions automatically under /media/media-automount/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite/ublue-os-media-automount-udev

# Cleanup & Finalize
COPY system_files/overrides /

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/cleanup-finalize

RUN --mount=type=tmpfs,target=/run --network=none bootc container lint

################
# DECK BUILDS
################

FROM bazzite AS bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-deck}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/deck/shared system_files/deck/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y copr enable ublue-os/packages && \
    dnf5 -y copr enable ublue-os/bazzite && \
    dnf5 -y copr enable ublue-os/bazzite-multilib && \
    dnf5 -y copr enable ycollet/audinux && \
    dnf5 config-manager unsetopt skip_if_unavailable && \
    /ctx/cleanup

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install \
        sddm && \
    dnf5 -y remove \
        jupiter-sd-mounting-btrfs \
        ds-inhibit \
        plasma-login-manager && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y remove \
            steamdeck-kde-presets-desktop && \
       dnf5 -y install \
            steamdeck-kde-presets \
    ; else \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default.jxl && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default-dark.jxl && \
        rm -f /usr/share/backgrounds/default.xml && \
        dnf5 -y remove \
            malcontent-control \
    ; fi && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl disable gdm.service \
    ; fi && \
    systemctl enable sddm.service && \
    /ctx/cleanup

# Install new packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install --enable-repo=terra \
        jupiter-fan-control \
        jupiter-hw-support-btrfs \
        galileo-mura \
        steamdeck-dsp \
        powerbuttond \
        inputplumber \
        hid-replay \
        gamescope-session-ogui-steam \
        steamos-manager-powerstation \
        gamemode-news-hook \
        vpower \
        steam-notif-daemon \
        acpica-tools \
        sdgyrodsu \
        ibus-pinyin \
        ibus-table-chinese-cangjie \
        ibus-table-chinese-quick \
        socat \
        zstd \
        zenity \
        newt \
        qt6-qtvirtualkeyboard \
        xorg-x11-server-Xvfb \
        python-vdf \
        python-crcmod \
        acpid && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y install --enable-repo=terra \
            plasma-applet-tdp-control \
    ; fi && \
    chmod +x /usr/share/gamescope-session-plus/gamescope-session-plus && \
    sed -i \
        -e 's|^export GAMESCOPE_SESSION_STEAM_BOOTSTRAP_ARCHIVE=.*$|export GAMESCOPE_SESSION_STEAM_BOOTSTRAP_ARCHIVE="/usr/share/gamescope-session-plus/bootstrap_steam.tar.gz"|' \
        -e 's|^export GAMESCOPE_SESSION_STEAM_BOOTSTRAP_DIR=.*$|export GAMESCOPE_SESSION_STEAM_BOOTSTRAP_DIR="${HOME}/.local/share"|' \
        /usr/share/gamescope-session-plus/sessions.d/steam && \
    sed -i 's|^CLIENTCMD="opengamepadui --overlay-mode|/usr/libexec/hwsupport/non-valve-handheld-hardware \&\& CLIENTCMD="opengamepadui --accessibility disabled --overlay-mode --steam-input --steamos-manager --skip-update-pack|' /usr/share/gamescope-session-plus/sessions.d/ogui-steam && \
    git clone https://gitlab.com/evlaV/jupiter-dock-updater-bin.git \
        --depth 1 \
        /tmp/jupiter-dock-updater-bin && \
    mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/libexec/jupiter-dock-updater && \
    setfattr -n user.component -v "jupiter-dock-updater" /usr/libexec/jupiter-dock-updater/* && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning && \
    /ctx/cleanup

# Install Steam Deck patched UPower
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y swap \
    --repo copr:copr.fedorainfracloud.org:ublue-os:bazzite \
        upower upower && \
    dnf5 versionlock add \
        upower \
        upower-libs && \
    /ctx/cleanup

# Install Gamescope Session Supporting changes
# Add bootstrap_steam.tar.gz used by gamescope-session (Thanks GE & Nobara Project!)
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    mkdir -p /usr/share/gamescope-session-plus/ && \
    curl --retry 3 -Lo /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz && \
    setfattr -n user.component -v "steam-bootstrap" /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz && \
    setfattr -n user.update-interval -v "yearly" /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz && \
    /ctx/cleanup

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p "/etc/xdg/autostart" && \
    mv "/etc/skel/.config/autostart/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop && \
    sed -i 's|/usr/lib/|/usr/libexec/|g' /usr/share/steamos-manager/platform.toml && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i 's|Exec=.*|Exec=/usr/bin/return-to-gamemode|' /etc/skel/Desktop/Return.desktop && \
        printf "\n[session]\ndesktop = \"plasma.desktop\"\n" >> /usr/share/steamos-manager/platform.toml \
    ; else \
        printf "\n[session]\ndesktop = \"gnome.desktop\"\n" >> /usr/share/steamos-manager/platform.toml \
    ; fi && \
    printf "[scx]\nscx_service = \"scx_loader.service\"\n" >> /usr/share/steamos-manager/platform.toml && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/input-remapper-gtk.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /etc/xdg/autostart/input-remapper-autoload.desktop && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    for copr in \
        ublue-os/staging \
        ublue-os/packages \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ycollet/audinux; \
    do \
        dnf5 -y copr disable -y $copr; \
    done && unset -v copr && \
    { rm -v /usr/share/applications/bazzite-steam-bpm.desktop || true; } && \
    news_branch="${IMAGE_BRANCH}" && \
    case "${news_branch}" in \
        testing|unstable) ;; \
        *) news_branch="stable" ;; \
    esac && \
    sed -i "s|^github = .*|github = https://raw.githubusercontent.com/ublue-os/bazzite-gamemode-news/refs/heads/${news_branch}/announcements.json|" /etc/gamemode-news-hook.conf && \
    mkdir -p /usr/lib/systemd/user/gamescope-session-plus@ogui-steam.service.wants && \
    ln -s /usr/lib/systemd/user/steamos-powerbuttond.service /usr/lib/systemd/user/gamescope-session-plus@ogui-steam.service.wants/ && \
    sed -i 's/@steam/@ogui-steam/g' /usr/lib/systemd/user/gamemode-news-hook.service && \
    sed -i '/^\[Service\]$/a KillSignal=SIGKILL\nTimeoutStopSec=2s\nTimeoutStopFailureMode=kill' /usr/lib/systemd/user/gamemode-news-hook.service && \
    systemctl enable --global steamos-manager.service && \
    systemctl enable --global steamos-manager-session-cleanup.service && \
    systemctl enable --global steamos-manager-configure-cecd.service && \
    systemctl enable steamos-manager.service && \
    systemctl enable inputplumber.service && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable wireplumber-workaround.service && \
    systemctl enable wireplumber-sysconf.service && \
    systemctl enable pipewire-workaround.service && \
    systemctl enable pipewire-sysconf.service && \
    systemctl --global enable gamemode-news-hook.service && \
    systemctl --global disable sdgyrodsu.service && \
    systemctl --global enable steamos-powerbuttond.service && \
    systemctl disable powerstation.service && \
    systemctl disable input-remapper.service && \
    systemctl disable uupd.timer && \
    systemctl disable jupiter-fan-control.service && \
    systemctl disable vpower.service && \
    systemctl disable jupiter-biosupdate.service && \
    systemctl disable jupiter-controller-update.service && \
    systemctl disable acpid.service && \
    find /etc/acpi/events -mindepth 1 -delete && \
    dnf5 config-manager setopt skip_if_unavailable=1 && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN --mount=type=tmpfs,target=/run --network=none bootc container lint

################
# NVIDIA BUILDS
################

FROM ${NVIDIA_BASE} AS bazzite-nvidia

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-nvidia}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia-open}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

# Fetch NVIDIA driver
COPY system_files/nvidia/shared system_files/nvidia/${BASE_IMAGE_NAME} /

# Remove everything that doesn't work well with NVIDIA, unset skip_if_unavailable option if was set beforehand
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 config-manager unsetopt skip_if_unavailable && \
    dnf5 -y remove \
        nvidia-gpu-firmware && \
    if [ "${NVIDIA_FLAVOR}" = "nvidia-lts" ]; then \
        systemctl disable cardwired.service && \
        dnf5 -y remove \
            cardwire-gui && \
        dnf5 -y swap \
            cardwire switcheroo-control && \
        dnf5 -y install --enable-repo=terra \
            supergfxctl \
    ; fi && \
    if ! grep -q "deck" <<< "${IMAGE_NAME}"; then \
        rm -f /usr/lib/modprobe.d/nvidia-deck.conf \
    ; fi && \
    /ctx/cleanup

# Install NVIDIA driver
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/nvidia \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    dnf5 config-manager setopt "terra-mesa".enabled=1 && \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y install \
        egl-wayland.x86_64 \
        egl-wayland.i686 \
        egl-wayland2.x86_64 \
        egl-wayland2.i686 && \
    IMAGE_NAME="SKIP_PACKAGE_INSTALL" AKMODNV_PATH="/tmp/rpms/nvidia" MULTILIB=1 /tmp/rpms/nvidia/ublue-os/nvidia-install.sh && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
    dnf5 config-manager setopt "terra-mesa".enabled=0 && \
    dnf5 -y copr disable ublue-os/staging && \
    dnf5 -y swap \
        --repo terra-extras \
            waydroid waydroid-nvidia && \
    /ctx/cleanup

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    echo "import \"/usr/share/ublue-os/just/95-bazzite-nvidia.just\"" >> /usr/share/ublue-os/justfile && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        mkdir -p "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
        cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
        dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" && \
        rm "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" \
    ; fi && \
    sed -i 's/ nvidia_peermem\b//' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf && \
    systemctl enable nvidia-powerd.service && \
    systemctl disable nvidia-persistenced.service && \
    systemctl enable ublue-nvidia-flatpak-runtime-sync && \
    systemctl enable ublue-nvidia-flatpak-runtime-verify && \
    dnf5 config-manager setopt skip_if_unavailable=1 && \
    if [ -f /etc/modprobe.d/nvidia-modeset.conf ]; then \
      cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf \
    ; fi && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN --mount=type=tmpfs,target=/run --network=none bootc container lint
