ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG IMAGE_VENDOR="ublue-os"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY system_files/desktop/shared /
COPY system_files/desktop/${BASE_IMAGE_NAME} /

# Add ublue packages, add needed negativo17 repo and then immediately disable due to incompatibility with RPMFusion
COPY --from=ghcr.io/ublue-os/akmods:${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
COPY --from=ghcr.io/ublue-os/ublue-update:latest /rpms/ublue-update.noarch.rpm /tmp/rpms/ublue-update.noarch.rpm
COPY --from=ghcr.io/ublue-os/bling:latest /rpms/ublue-os-wallpapers-*.noarch.rpm /tmp/rpms/ublue-os-wallpapers.rpm
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    wget https://negativo17.org/repos/fedora-multimedia.repo -O /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    rpm-ostree install \
        /tmp/akmods-rpms/kmods/*gcadapter_oc*.rpm \
        /tmp/akmods-rpms/kmods/*openrgb*.rpm \
        /tmp/akmods-rpms/kmods/*evdi*.rpm \
        /tmp/akmods-rpms/kmods/*wl*.rpm \
        /tmp/rpms/ublue-update.noarch.rpm \
        /tmp/rpms/ublue-os-wallpapers.rpm && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# Setup Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-multilib-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    wget https://copr.fedorainfracloud.org/coprs/ublue-os/distrobox-git/repo/fedora-$(rpm -E %fedora)/ublue-os-distrobox-git-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-distrobox-git.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/repo/fedora-$(rpm -E %fedora)/kylegospo-hl2linux-selinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/repo/fedora-$(rpm -E %fedora)/kylegospo-obs-vkcapture-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-$(rpm -E %fedora)/kylegospo-wallpaper-engine-kde-plugin-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/ycollet/audinux/repo/fedora-$(rpm -E %fedora)/ycollet-audinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    wget https://copr.fedorainfracloud.org/coprs/lyessaadi/gradience/repo/fedora-$(rpm -E %fedora)/lyessaadi-gradience-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_lyessaadi-gradience.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-$(rpm -E %fedora)/kylegospo-rom-properties-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo

# Remove unneeded packages
RUN rpm-ostree override remove \
    ublue-os-update-services \
    firefox \
    firefox-langpacks \
    htop \
    google-noto-sans-cjk-vf-fonts

# Install new packages
RUN rpm-ostree install \
    extest.i686 \
    python3-pip \
    libadwaita \
    duperemove \
    xwininfo \
    xrandr \
    rmlint \
    compsize \
    ddccontrol \
    ddccontrol-gtk \
    ddccontrol-db \
    input-remapper \
    system76-scheduler \
    hl2linux-selinux \
    libobs_glcapture \
    libobs_vkcapture \
    obs-vkcapture \
    ladspa-caps-plugins \
    ladspa-noise-suppression-for-voice \
    btop \
    fish \
    xdotool \
    wmctrl \
    yad \
    f3 \
    google-noto-sans-cjk-fonts \
    twitter-twemoji-fonts \
    lato-fonts \
    fira-code-fonts && \
    wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/main/files/usr/lib/systemd/system/btrfs-dedup@.service -O /usr/lib/systemd/system/btrfs-dedup@.service && \
    wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/main/files/usr/lib/systemd/system/btrfs-dedup@.timer -O /usr/lib/systemd/system/btrfs-dedup@.timer

# Configure KDE & GNOME
RUN if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
    rpm-ostree override remove \
        plasma-welcome \
        qt5-qdbusviewer && \
    rpm-ostree install \
        steamdeck-kde-presets-desktop \
        wallpaper-engine-kde-plugin \
        kdeconnectd \
        rom-properties-kf5 && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr \
        xorg-x11-server-Xwayland && \
    git clone https://github.com/maxiberta/kwin-system76-scheduler-integration.git --depth 1 /tmp/kwin-system76-scheduler-integration && \
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 /tmp/wallpaper-engine-kde-plugin && \
    kpackagetool5 --type=KWin/Script --global --install /tmp/kwin-system76-scheduler-integration && \
    kpackagetool5 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin && \
    rm -rf /tmp/kwin-system76-scheduler-integration && \
    rm -rf /tmp/wallpaper-engine-kde-plugin && \
    sed -i 's@After=plasma-core.target@After=plasma-core.target\nAfter=xdg-desktop-portal.service@g' /usr/lib/systemd/user/plasma-xdg-desktop-portal-kde.service \
; else \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr \
        mutter \
        mutter-common \
        gnome-control-center \
        gnome-control-center-filesystem \
        xorg-x11-server-Xwayland && \
    rpm-ostree install \
        steamdeck-backgrounds \
        gradience \
        gnome-shell-extension-user-theme \
        gnome-shell-extension-gsconnect \
        gnome-shell-extension-system76-scheduler \
        gnome-shell-extension-caribou-blocker \
        gnome-shell-extension-compiz-windows-effect \
        gnome-shell-extension-just-perfection \
        gnome-shell-extension-blur-my-shell \
        gnome-shell-extension-hanabi \
        rom-properties-gtk3 \
        openssh-askpass && \
    rpm-ostree override remove \
        gnome-classic-session \
        gnome-tour \
        gnome-extensions-app \
; fi

# Install ROCM and Waydroid on non-Nvidia images
# Install distrobox-git on Nvidia images (while needed)
RUN if grep -qv "nvidia" <<< "${IMAGE_NAME}"; then \
    rpm-ostree install \
        rocm-hip \
        rocm-opencl \
        waydroid \
        lzip \
        weston \
; else \
    rpm-ostree override remove \
        distrobox && \
    rpm-ostree install \
        distrobox-git \
; fi

# Cleanup & Finalize
RUN rm /usr/share/applications/shredder.desktop && \
    rm /usr/share/vulkan/icd.d/lvp_icd.*.json && \
    mkdir -p "/usr/etc/profile.d/" && \
    ln -s "/usr/share/ublue-os/firstboot/launcher/login-profile.sh" \
    "/usr/etc/profile.d/ublue-firstboot.sh" && \
    ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" \
    "/usr/share/fonts/noto-cjk" && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/etc/yafti.yml" && \
    pip install --prefix=/usr yafti && \
    pip install --prefix=/usr hyfetch && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-distrobox-git.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_lyessaadi-gradience.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    mkdir -p /usr/etc/flatpak/remotes.d && \
    wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d && \
    systemctl enable com.system76.Scheduler.service && \
    systemctl enable displaylink.service && \
    systemctl enable btrfs-dedup@var-home.timer && \
    systemctl enable input-remapper.service && \
    systemctl unmask bazzite-flatpak-manager.service && \
    systemctl enable bazzite-flatpak-manager.service && \
    systemctl disable rpm-ostreed-automatic.timer && \
    systemctl --global enable ublue-update.timer && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl --global enable bazzite-user-setup.service && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i '/^PRETTY_NAME/s/Kinoite/Bazzite/' /usr/lib/os-release && \
        systemctl --global enable com.system76.Scheduler.dbusproxy.service \
    ; else \
        rm /usr/share/applications/yad-icon-browser.desktop && \
        rm /usr/share/applications/com.github.rafostar.Clapper.desktop && \
        sed -i '/^PRETTY_NAME/s/Silverblue/Bazzite GNOME/' /usr/lib/os-release \
    ; fi && \
    if grep -qv "nvidia" <<< "${IMAGE_NAME}"; then \
        systemctl disable waydroid-container.service && \
        rm /usr/share/wayland-sessions/weston.desktop \
    ; fi && \
    mkdir -p /usr/etc/default && \
    echo -e "IMAGE_NAME=${IMAGE_NAME}\nIMAGE_VENDOR=${IMAGE_VENDOR}\nBASE_IMAGE_NAME=${BASE_IMAGE_NAME}\nIMAGE_FLAVOR=${IMAGE_FLAVOR}\nFEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION}" >> /usr/etc/default/bazzite && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    ostree container commit

FROM bazzite as bazzite-surface

# Add Linux Surface repo
RUN wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -P /etc/yum.repos.d

# Install Surface kernel
RUN wget https://github.com/linux-surface/linux-surface/releases/download/silverblue-20201215-1/kernel-20201215-1.x86_64.rpm -O \
    /tmp/surface-kernel.rpm && \
    rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override replace /tmp/surface-kernel.rpm \
        --remove kernel-core \
        --remove kernel-devel-matched \
        --remove kernel-modules \
        --remove kernel-modules-extra \
        --remove libwacom \
        --remove libwacom-data \
        --install kernel-surface \
        --install iptsd \
        --install libwacom-surface \
        --install libwacom-surface-data

# Cleanup & Finalize
RUN rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    ostree container commit

FROM bazzite as bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG IMAGE_VENDOR="ublue-os"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY system_files/deck/shared /
COPY system_files/deck/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo

# Install Valve's Steam Deck drivers as kmods
COPY --from=ghcr.io/ublue-os/akmods:${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
RUN rpm-ostree install \
    /tmp/akmods-rpms/kmods/*steamdeck*.rpm

# Install gamescope-limiter patched Mesa and patched udisks2 (Needed for SteamOS SD card mounting)
RUN rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
        mesa-filesystem \
        mesa-dri-drivers \
        mesa-libEGL \
        mesa-libEGL-devel \
        mesa-libgbm \
        mesa-libGL \
        mesa-libglapi \
        mesa-vulkan-drivers && \
    if [ ${FEDORA_MAJOR_VERSION} -lt 39 ]; then \
        rpm-ostree override replace \
        --experimental \
        --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
            udisks2 \
            libudisks2 \
            udisks2-btrfs \
    ; fi

# Configure KDE & GNOME
RUN if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
    rpm-ostree override remove \
        steamdeck-kde-presets-desktop && \
    rpm-ostree install \
        steamdeck-kde-presets \
; else \
    rpm-ostree install \
        gnome-shell-extension-bazzite-menu \
        gnome-shell-extension-search-light \
        sddm && \
    wget https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf -O /usr/etc/dxvk-example.conf \
; fi

# Install new packages
# Dock updater - done manually due to proprietary parts preventing it from being on Copr
# Neptune firmware - done manually due to "TBD" license on needed audio firmware
RUN rpm-ostree install \
    mesa-va-drivers \
    vulkan-tools \
    jupiter-fan-control \
    jupiter-hw-support-btrfs \
    powerbuttond \
    vpower \
    ds-inhibit \
    steam_notif_daemon \
    ryzenadj \
    latencyflex-vulkan-layer \
    vkBasalt \
    mangohud \
    sdgyrodsu \
    sddm-sugar-steamOS \
    ibus-pinyin \
    ibus-table-chinese-cangjie \
    ibus-table-chinese-quick \
    socat \
    zstd \
    python-vdf \
    python-crcmod && \
    git clone https://gitlab.com/evlaV/jupiter-dock-updater-bin.git \
        --depth 1 \
        /tmp/jupiter-dock-updater-bin && \
    mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater && \
    rm -rf /tmp/jupiter-dock-updater-bin && \
    mkdir -p /tmp/linux-firmware-neptune && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter/cs35l41-dsp1-spk-cali.bin -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.bin && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter/cs35l41-dsp1-spk-cali.wmfw -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.wmfw && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter/cs35l41-dsp1-spk-prot.bin -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.bin && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter/cs35l41-dsp1-spk-prot.wmfw -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.wmfw && \
    xz --check=crc32 /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-{cali.bin,cali.wmfw,prot.bin,prot.wmfw} && \
    mv -vf /tmp/linux-firmware-neptune/* /usr/lib/firmware/cirrus/ && \
    rm -rf /tmp/linux-firmware-neptune

# Install Steam and Lutris into their own OCI layer
# Add bootstraplinux_ubuntu12_32.tar.xz used by gamescope-session (Thanks ChimeraOS! - https://chimeraos.org/)
RUN rpm-ostree install \
        steam \
        lutris \
        libFAudio \
        gamescope \
        gamescope-session \
        wine-core \
        winetricks \
        protontricks && \
    wget https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steam-jupiter-stable-1.0.0.76-1-x86_64.pkg.tar.zst -O /tmp/steam-jupiter.pkg.tar.zst && \
    mkdir -p /usr/etc/first-boot && \
    tar -I zstd -xvf /tmp/steam-jupiter.pkg.tar.zst usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz -O > /usr/etc/first-boot/bootstraplinux_ubuntu12_32.tar.xz && \
    rm -f /tmp/steam-jupiter.pkg.tar.zst && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        rpm-ostree override remove \
            gamemode \
    ; else \
        rpm-ostree override remove \
            gamemode \
            gnome-shell-extension-gamemode \
            gnome-shell-extension-appindicator \
    ; fi

# Cleanup & Finalize
RUN rm /usr/share/applications/wine*.desktop && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning && \
    sed -i 's/870/817/' /usr/share/alsa/ucm2/AMD/acp5x/acp5x.conf && \
    sed -i 's/252/207/' /usr/share/alsa/ucm2/AMD/acp5x/acp5x.conf && \
    sed -i 's/192/207/' /usr/share/alsa/ucm2/AMD/acp5x/acp5x.conf && \
    sed -i 's@/usr/bin/steam@/usr/bin/bazzite-steam@g' /usr/share/applications/steam.desktop && \
    mkdir -p "/usr/etc/xdg/autostart" && \
    cp "/usr/share/applications/steam.desktop" "/usr/etc/xdg/autostart/steam.desktop" && \
    sed -i 's@/usr/bin/bazzite-steam %U@/usr/bin/bazzite-steam -silent %U@g' /usr/etc/xdg/autostart/steam.desktop && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/usr/etc/yafti.yml" && \
    sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' /etc/systemd/logind.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl mask power-profiles-daemon.service && \
        systemctl disable gdm.service && \
        systemctl enable sddm.service \
    ; fi && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable jupiter-fan-control.service && \
    systemctl enable btrfs-dedup@run-media-mmcblk0p1.timer && \
    systemctl enable vpower.service && \
    systemctl enable ds-inhibit.service && \
    systemctl --global enable steam-web-debug-portforward.service && \
    systemctl --global enable sdgyrodsu.service && \
    systemctl disable input-remapper.service && \
    systemctl --global disable ublue-update.timer && \
    rm -f /usr/etc/sddm.conf && \
    rm -f /usr/etc/default/bazzite && \
    echo -e "IMAGE_NAME=${IMAGE_NAME}\nIMAGE_VENDOR=${IMAGE_VENDOR}\nBASE_IMAGE_NAME=${BASE_IMAGE_NAME}\nIMAGE_FLAVOR=${IMAGE_FLAVOR}\nFEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION}" >> /usr/etc/default/bazzite && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/bluetooth && \
    ostree container commit
