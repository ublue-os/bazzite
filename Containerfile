ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG BASE_IMAGE_FLAVOR="${BASE_IMAGE_FLAVOR:-main}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG AKMODS_FLAVOR="${AKMODS_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$BASE_IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG AKMODS_FLAVOR="${AKMODS_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

COPY system_files/desktop/shared system_files/desktop/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-multilib-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    wget https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_ublue-os-staging.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/repo/fedora-$(rpm -E %fedora)/kylegospo-hl2linux-selinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/repo/fedora-$(rpm -E %fedora)/kylegospo-obs-vkcapture-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-$(rpm -E %fedora)/kylegospo-wallpaper-engine-kde-plugin-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/vk_hdr_layer/repo/fedora-$(rpm -E %fedora)/kylegospo-vk_hdr_layer-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-vk_hdr_layer.repo && \
    wget https://copr.fedorainfracloud.org/coprs/ycollet/audinux/repo/fedora-$(rpm -E %fedora)/ycollet-audinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-$(rpm -E %fedora)/kylegospo-rom-properties-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-$(rpm -E %fedora)/kylegospo-prompt-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-prompt.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/joycond/repo/fedora-$(rpm -E %fedora)/kylegospo-joycond-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-joycond.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/VTFLib/repo/fedora-$(rpm -E %fedora)/kylegospo-VTFLib-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-VTFLib.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-$(rpm -E %fedora)/kylegospo-webapp-manager-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo && \
    wget https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/repo/fedora-$(rpm -E %fedora)/hhd-dev-hhd-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_hhd-dev-hhd.repo && \
    wget https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-$(rpm -E %fedora)/che-nerd-fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_che-nerd-fonts.repo && \
    wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -O /etc/yum.repos.d/tailscale.repo && \
    sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/tailscale.repo

# Install kernel-fsync
RUN wget https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/repo/fedora-$(rpm -E %fedora)/sentry-kernel-fsync-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_sentry-kernel-fsync.repo && \
    rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:sentry:kernel-fsync \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra \
        kernel-uki-virt

# Setup firmware and asusctl for ASUS devices
RUN if [[ "${IMAGE_FLAVOR}" =~ "asus" ]]; then \
        wget https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-$(rpm -E %fedora)/lukenukem-asus-linux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_lukenukem-asus-linux.repo && \
        rpm-ostree install \
            asusctl \
            asusctl-rog-gui && \
        git clone https://gitlab.com/asus-linux/firmware.git --depth 1 /tmp/asus-firmware && \
        cp -rf /tmp/asus-firmware/* /usr/lib/firmware/ && \
        rm -rf /tmp/asus-firmware \
    ; fi

# Setup Surface devices
RUN if [[ "${IMAGE_FLAVOR}" =~ "surface" ]]; then \
        wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -P /etc/yum.repos.d && \
        rpm-ostree override remove \
            libwacom \
            libwacom-data && \
        rpm-ostree install \
            iptsd \
            libwacom-surface \
            libwacom-surface-data \
    ; fi

# Add ublue packages, add needed negativo17 repo and then immediately disable due to incompatibility with RPMFusion
COPY --from=ghcr.io/ublue-os/akmods:${AKMODS_FLAVOR}-${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    wget https://negativo17.org/repos/fedora-multimedia.repo -O /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    rpm-ostree install \
        /tmp/akmods-rpms/kmods/*xone*.rpm \
        /tmp/akmods-rpms/kmods/*openrazer*.rpm \
        /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
        /tmp/akmods-rpms/kmods/*wl*.rpm \
        /tmp/akmods-rpms/kmods/*gcadapter_oc*.rpm \
        /tmp/akmods-rpms/kmods/*nct6687*.rpm \
        /tmp/akmods-rpms/kmods/*evdi*.rpm \
        /tmp/akmods-rpms/kmods/*zenergy*.rpm \
        /tmp/akmods-rpms/kmods/*ayn-platform*.rpm \
        /tmp/akmods-rpms/kmods/*bmi260*.rpm \
        /tmp/akmods-rpms/kmods/*bmi323*.rpm \
        /tmp/akmods-rpms/kmods/*rtl8814au*.rpm \
        /tmp/akmods-rpms/kmods/*ryzen-smu*.rpm && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# Update packages that commonly cause build issues
RUN rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        vulkan-loader \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gnutls \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        glib2 \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gtk3 \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        atk \
        at-spi2-atk \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libaom \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gstreamer1 \
        gstreamer1-plugins-base \
        gstreamer1-plugins-bad-free-libs \
        gstreamer1-plugins-good-qt \
        gstreamer1-plugins-good \
        gstreamer1-plugins-bad-free \
        gstreamer1-plugin-libav \
        gstreamer1-plugins-ugly-free \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        python3 \
        python3-libs \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libdecor \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libtirpc \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libuuid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libblkid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libmount \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates-archive \
        glibc-headers \
        glibc-devel \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        glibc \
        glibc-common \
        glibc-all-langpacks \
        glibc-gconv-extra \
        || true && \
    rpm-ostree override remove \
        glibc32 \
        || true

# Install Valve's patched Mesa, Pipewire and Bluez
RUN rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
        mesa-filesystem \
        mesa-dri-drivers \
        mesa-libEGL \
        mesa-libgbm \
        mesa-libGL \
        mesa-libglapi \
        mesa-vulkan-drivers \
        mesa-libOSMesa \
        pipewire \
        pipewire-alsa \
        pipewire-gstreamer \
        pipewire-jack-audio-connection-kit \
        pipewire-jack-audio-connection-kit-libs \
        pipewire-libs \
        pipewire-pulseaudio \
        pipewire-utils \
        bluez \
        bluez-cups \
        bluez-libs \
        bluez-obexd \
        xorg-x11-server-Xwayland && \
    rpm-ostree install \
        mesa-vdpau-drivers-freeworld.x86_64

# Remove unneeded packages
RUN rpm-ostree override remove \
        ublue-os-update-services \
        firefox \
        firefox-langpacks \
        htop && \
    rpm-ostree override remove \
        power-profiles-daemon \
        || true && \
    rpm-ostree override remove \
        tlp \
        tlp-rdw \
        || true

# Install new packages
RUN rpm-ostree install \
        discover-overlay \
        python3-pip \
        libadwaita \
        duperemove \
        xwininfo \
        xrandr \
        rmlint \
        compsize \
        input-remapper \
        system76-scheduler \
        tuned \
        tuned-ppd \
        tuned-utils \
        tuned-utils-systemtap \
        tuned-gtk \
        tuned-profiles-atomic \
        tuned-profiles-cpu-partitioning \
        powertop \
        hl2linux-selinux \
        joycond \
        ladspa-caps-plugins \
        ladspa-noise-suppression-for-voice \
        python3-icoextract \
        tailscale \
        webapp-manager \
        btop \
        fish \
        lshw \
        xdotool \
        wmctrl \
        libcec \
        yad \
        f3 \
        pulseaudio-utils \
        playerctl \
        unrar \
        lzip \
        libxcrypt-compat \
        mesa-libGLU \
        vulkan-tools \
        glibc.i686 \
        extest.i686 \
        xwiimote-ng \
        twitter-twemoji-fonts \
        google-noto-sans-cjk-fonts \
        lato-fonts \
        fira-code-fonts \
        nerd-fonts \
        glow \
        gum \
        setools \
        redhat-lsb-core \
        cockpit-networkmanager \
        cockpit-podman \
        cockpit-selinux \
        cockpit-system \
        cockpit-navigator \
        cockpit-storaged && \
    pip install --prefix=/usr topgrade && \
    rpm-ostree install \
        ublue-update && \
    sed -i '1s/^/[include]\npaths = ["\/etc\/ublue-os\/topgrade.toml"]\n\n/' /usr/etc/ublue-update/topgrade-user.toml && \
    sed -i 's/min_battery_percent.*/min_battery_percent = 20.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_cpu_load_percent.*/max_cpu_load_percent = 100.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_mem_percent.*/max_mem_percent = 90.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/dbus_notify.*/dbus_notify = false/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's@Name=tuned-gui@Name=TuneD Manager@g' /usr/share/applications/tuned-gui.desktop && \
    wget https://raw.githubusercontent.com/KyleGospo/steam-proton-mf-wmv/master/installcab.py -O /usr/bin/installcab && \
    wget https://github.com/KyleGospo/steam-proton-mf-wmv/blob/master/install-mf-wmv.sh -O /usr/bin/install-mf-wmv && \
    wget https://raw.githubusercontent.com/jlu5/icoextract/master/exe-thumbnailer.thumbnailer -O /usr/share/thumbnailers/exe-thumbnailer.thumbnailer

# Install Steam & Lutris, plus supporting packages
RUN rpm-ostree install \
        at-spi2-core.i686 \
        atk.i686 \
        vulkan-loader.i686 \
        alsa-lib.i686 \
        fontconfig.i686 \
        gtk2.i686 \
        libICE.i686 \
        libnsl.i686 \
        libxcrypt-compat.i686 \
        libpng12.i686 \
        libXext.i686 \
        libXinerama.i686 \
        libXtst.i686 \
        libXScrnSaver.i686 \
        NetworkManager-libnm.i686 \
        nss.i686 \
        pulseaudio-libs.i686 \
        libcurl.i686 \
        systemd-libs.i686 \
        libva.i686 \
        libvdpau.i686 \
        libdbusmenu-gtk3.i686 \
        libatomic.i686 \
        pipewire-alsa.i686 \
        clinfo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/fedora-updates.repo && \
    rpm-ostree install \
        mesa-vulkan-drivers.i686 \
        mesa-va-drivers-freeworld.i686 \
        mesa-vdpau-drivers-freeworld.i686 && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree.repo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo && \
    rpm-ostree install \
        steam && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/fedora-updates.repo && \
    rpm-ostree install \
        lutris \
        wxGTK \
        libFAudio \
        wine-core.x86_64 \
        wine-core.i686 \
        wine-pulseaudio.x86_64 \
        wine-pulseaudio.i686 \
        winetricks \
        protontricks \
        latencyflex-vulkan-layer \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        vk_hdr_layer.x86_64 \
        vk_hdr_layer.i686 \
        gperftools-libs.i686 \
        goverlay && \
    if [[ ! "${IMAGE_FLAVOR}" =~ "surface" ]]; then \
        rpm-ostree install \
            obs-vkcapture.x86_64 \
            obs-vkcapture.i686 \
    ; fi && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/winetricks.desktop && \
    ln -s /usr/bin/wine64 /usr/bin/wine && \
    wget $(curl https://api.github.com/repos/ishitatsuyuki/LatencyFleX/releases/latest | jq -r '.assets[] | select(.name| test(".*.tar.xz$")).browser_download_url') -O /tmp/latencyflex.tar.xz && \
    mkdir -p /tmp/latencyflex && \
    tar --strip-components 1 -xvf /tmp/latencyflex.tar.xz -C /tmp/latencyflex && \
    rm -f /tmp/latencyflex.tar.xz && \
    cp -r /tmp/latencyflex/wine/usr/lib/wine/* /usr/lib64/wine/ && \
    rm -rf /tmp/latencyflex && \
    wget https://raw.githubusercontent.com/KyleGospo/LatencyFleX-Installer/main/install.sh -O /usr/bin/latencyflex && \
    sed -i 's@/usr/lib/wine/@/usr/lib64/wine/@g' /usr/bin/latencyflex && \
    sed -i 's@"dxvk.conf"@"/usr/share/latencyflex/dxvk.conf"@g' /usr/bin/latencyflex && \
    chmod +x /usr/bin/latencyflex

# Configure KDE & GNOME
RUN if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
    rpm-ostree override remove \
        plasma-welcome \
        qt5-qdbusviewer && \
    rpm-ostree install \
        steamdeck-kde-presets-desktop \
        wallpaper-engine-kde-plugin \
        kdeconnectd \
        kdeplasma-addons \
        rom-properties-kf5 \
        qvtf \
        prompt && \
    git clone https://github.com/maxiberta/kwin-system76-scheduler-integration.git --depth 1 /tmp/kwin-system76-scheduler-integration && \
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 /tmp/wallpaper-engine-kde-plugin && \
    kpackagetool5 --type=KWin/Script --global --install /tmp/kwin-system76-scheduler-integration && \
    kpackagetool5 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin && \
    rm -rf /tmp/kwin-system76-scheduler-integration && \
    rm -rf /tmp/wallpaper-engine-kde-plugin && \
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:steam.desktop,applications:net.lutris.Lutris.desktop,applications:org.gnome.Prompt.desktop,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,steam.desktop,net.lutris.Lutris.desktop,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,org.gnome.Prompt.desktop,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
    sed -i 's@\[Desktop Action new-window\]@\[Desktop Action new-window\]\nX-KDE-Shortcuts=Ctrl+Alt+T@g' /usr/share/applications/org.gnome.Prompt.desktop && \
    sed -i 's@Exec=prompt@Exec=kde-prompt@g' /usr/share/applications/org.gnome.Prompt.desktop && \
    cp /usr/share/applications/org.gnome.Prompt.desktop /usr/share/kglobalaccel/org.gnome.Prompt.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.konsole.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop && \
    rm -f /usr/share/kglobalaccel/org.kde.konsole.desktop && \
    systemctl enable kde-sysmonitor-workaround.service \
; else \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr \
        mutter \
        mutter-common \
        gnome-control-center \
        gnome-control-center-filesystem && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
        vte291 \
        vte-profile && \
    rpm-ostree install \
        prompt \
        nautilus-open-any-terminal \
        nautilus-gsconnect \
        steamdeck-backgrounds \
        gnome-randr-rust \
        gnome-shell-extension-user-theme \
        gnome-shell-extension-gsconnect \
        gnome-shell-extension-system76-scheduler \
        gnome-shell-extension-compiz-windows-effect \
        gnome-shell-extension-just-perfection \
        gnome-shell-extension-blur-my-shell \
        gnome-shell-extension-hanabi \
        gnome-shell-extension-gamerzilla \
        gnome-shell-extension-bazzite-menu \
        gnome-shell-extension-hotedge \
        gnome-shell-extension-tailscale-gnome-qs \
        rom-properties-gtk3 \
        pixbufloader-vtf \
        openssh-askpass && \
    rpm-ostree override remove \
        gnome-software-rpm-ostree \
        gnome-classic-session \
        gnome-tour \
        gnome-extensions-app \
        gnome-terminal-nautilus \
        gnome-initial-setup && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/gnome-system-monitor.desktop && \
    systemctl enable dconf-update.service \
; fi

# Install Gamescope, ROCM, and Waydroid on non-Nvidia images
RUN rpm-ostree install \
        gamescope.x86_64 \
        gamescope-libs.i686 \
        gamescope-shaders \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        waydroid \
        cage \
        wlr-randr && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh

# Cleanup & Finalize
COPY system_files/shared /
RUN /tmp/image-info.sh && \
    rm -f /etc/profile.d/toolbox.sh && \
    sed -i 's@/usr/bin/steam@/usr/bin/bazzite-steam@g' /usr/share/applications/steam.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/shredder.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/fish.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop && \
    rm -f /usr/share/vulkan/icd.d/lvp_icd.*.json && \
    mkdir -p "/usr/etc/profile.d/" && \
    ln -s "/usr/share/ublue-os/firstboot/launcher/login-profile.sh" \
    "/usr/etc/profile.d/ublue-firstboot.sh" && \
    mkdir -p "/usr/etc/xdg/autostart" && \
    cp "/usr/share/applications/discover_overlay.desktop" "/usr/etc/xdg/autostart/discover_overlay.desktop" && \
    sed -i 's@Exec=discover-overlay@Exec=/usr/bin/bazzite-discover-overlay@g' /usr/etc/xdg/autostart/discover_overlay.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/discover_overlay.desktop && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/etc/yafti.yml" && \
    echo "import \"/usr/share/ublue-os/just/80-bazzite.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/85-bazzite-image.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-de.just\"" >> /usr/share/ublue-os/justfile && \
    pip install --prefix=/usr yafti && \
    pip install --prefix=/usr hyfetch && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-vk_hdr_layer.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-prompt.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-joycond.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-VTFLib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_hhd-dev-hhd.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_che-nerd-fonts.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    mkdir -p /usr/etc/flatpak/remotes.d && \
    wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d && \
    systemctl enable com.system76.Scheduler.service && \
    systemctl enable tuned.service && \
    systemctl enable btrfs-dedup@var-home.timer && \
    systemctl enable displaylink.service && \
    systemctl enable input-remapper.service && \
    systemctl unmask bazzite-flatpak-manager.service && \
    systemctl enable bazzite-flatpak-manager.service && \
    systemctl disable rpm-ostreed-automatic.timer && \
    systemctl enable ublue-update.timer && \
    systemctl enable gamescope-workaround.service && \
    systemctl enable waydroid-workaround.service && \
    systemctl enable incus-workaround.service && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl enable tailscaled.service && \
    systemctl enable dev-hugepages1G.mount && \
    systemctl enable joycond && \
    systemctl --global enable bazzite-user-setup.service && \
    systemctl --global enable podman.socket && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i '/^PRETTY_NAME/s/Kinoite/Bazzite/' /usr/lib/os-release && \
        systemctl --global enable com.system76.Scheduler.dbusproxy.service \
    ; else \
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop && \
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/com.github.rafostar.Clapper.desktop && \
        sed -i '/^PRETTY_NAME/s/Silverblue/Bazzite GNOME/' /usr/lib/os-release \
    ; fi && \
    systemctl disable waydroid-container.service && \
    sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop && \
    wget https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh -O /usr/bin/waydroid-choose-gpu && \
    chmod +x /usr/bin/waydroid-choose-gpu && \
    mkdir -p /usr/etc/default && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/bluetooth && \
    chmod -R 755 /var/lib/bluetooth && \
    ostree container commit

FROM bazzite as bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-deck}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

COPY system_files/deck/shared system_files/deck/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_hhd-dev-hhd.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo

# Configure KDE & GNOME
RUN if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
    rpm-ostree override remove \
        steamdeck-kde-presets-desktop && \
    rpm-ostree install \
        steamdeck-kde-presets \
; else \
    rpm-ostree install \
        steamdeck-gnome-presets \
        gnome-shell-extension-caribou-blocker \
        sddm && \
    wget https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf -O /usr/etc/dxvk-example.conf \
; fi

# Install new packages
# Dock updater - done manually due to proprietary parts preventing it from being on Copr
# Neptune firmware - done manually due to "TBD" license on needed audio firmware
RUN rpm-ostree install \
    jupiter-fan-control \
    jupiter-hw-support-btrfs \
    galileo-mura \
    powerbuttond \
    HandyGCCS \
    hhd \
    vpower \
    ds-inhibit \
    steam_notif_daemon \
    ryzenadj \
    sdgyrodsu \
    ibus-pinyin \
    ibus-table-chinese-cangjie \
    ibus-table-chinese-quick \
    socat \
    zstd \
    zenity \
    newt \
    qt5-qtvirtualkeyboard \
    xorg-x11-server-Xvfb \
    python-vdf \
    python-crcmod && \
    git clone https://gitlab.com/evlaV/jupiter-dock-updater-bin.git \
        --depth 1 \
        /tmp/jupiter-dock-updater-bin && \
    mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater && \
    rm -rf /tmp/jupiter-dock-updater-bin && \
    mkdir -p /tmp/linux-firmware-neptune && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/cs35l41-dsp1-spk-cali.bin -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.bin && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/cs35l41-dsp1-spk-cali.wmfw -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.wmfw && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/cs35l41-dsp1-spk-prot.bin -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.bin && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/cs35l41-dsp1-spk-prot.wmfw -O /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.wmfw && \
    xz --check=crc32 /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-{cali.bin,cali.wmfw,prot.bin,prot.wmfw} && \
    mv -vf /tmp/linux-firmware-neptune/* /usr/lib/firmware/cirrus/ && \
    rm -rf /tmp/linux-firmware-neptune && \
    mkdir -p /tmp/linux-firmware-galileo && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/archive/jupiter-20231113.1/linux-firmware-neptune-jupiter-20231113.1.tar.gz?path=ath11k/QCA206X -O /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    tar --strip-components 1 -xvf /tmp/linux-firmware-galileo/ath11k.tar.gz -C /tmp/linux-firmware-galileo && \
    xz --check=crc32 /tmp/linux-firmware-galileo/ath11k/QCA206X/hw2.1/* && \
    mv -vf /tmp/linux-firmware-galileo/ath11k/QCA206X /usr/lib/firmware/ath11k/QCA206X && \
    rm -rf /tmp/linux-firmware-galileo/ath11k && \
    rm -rf /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/qca/hpbtfw21.tlv -O /tmp/linux-firmware-galileo/hpbtfw21.tlv && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/qca/hpnv21.309 -O /tmp/linux-firmware-galileo/hpnv21.309 && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/qca/hpnv21.bin -O /tmp/linux-firmware-galileo/hpnv21.bin && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/qca/hpnv21g.309 -O /tmp/linux-firmware-galileo/hpnv21g.309 && \
    wget https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/jupiter-20231113.1/qca/hpnv21g.bin -O /tmp/linux-firmware-galileo/hpnv21g.bin && \
    xz --check=crc32 /tmp/linux-firmware-galileo/* && \
    mv -vf /tmp/linux-firmware-galileo/* /usr/lib/firmware/qca/ && \
    rm -rf /tmp/linux-firmware-galileo && \
    rm -rf /usr/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf

# Install Steam Deck patched Wireplumber & UPower
RUN rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
        wireplumber \
        wireplumber-libs \
        upower \
        upower-libs

# Install Gamescope Session & Supporting changes
# Add bootstraplinux_ubuntu12_32.tar.xz used by gamescope-session (Thanks ChimeraOS! - https://chimeraos.org/)
# Remove Feral gamemode, System76-Scheduler supersedes this
RUN wget https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steam-jupiter-stable-1.0.0.78-1.2-x86_64.pkg.tar.zst -O /tmp/steam-jupiter.pkg.tar.zst && \
    mkdir -p /usr/etc/first-boot && \
    tar -I zstd -xvf /tmp/steam-jupiter.pkg.tar.zst usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz -O > /usr/etc/first-boot/bootstraplinux_ubuntu12_32.tar.xz && \
    rm -f /tmp/steam-jupiter.pkg.tar.zst && \
    rpm-ostree install \
        gamescope-session-plus \
        gamescope-session-steam && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        rpm-ostree override remove \
            gamemode \
    ; else \
        rpm-ostree override remove \
            gamemode \
            gnome-shell-extension-gamemode \
    ; fi

# Cleanup & Finalize
COPY system_files/shared /
RUN /tmp/image-info.sh && \
    mkdir -p "/usr/etc/xdg/autostart" && \
    cp "/usr/share/applications/steam.desktop" "/usr/etc/xdg/autostart/steam.desktop" && \
    sed -i 's@/usr/bin/bazzite-steam %U@/usr/bin/bazzite-steam -silent %U@g' /usr/etc/xdg/autostart/steam.desktop && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i 's/Exec=.*/Exec=systemctl start return-to-gamemode.service/' /etc/skel/Desktop/Return.desktop && \
        rm -f /usr/share/applications/com.github.maliit.keyboard.desktop \
    ; fi && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/input-remapper-gtk.desktop && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/usr/etc/yafti.yml" && \
    sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' /etc/systemd/logind.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_hhd-dev-hhd.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl disable gdm.service && \
        systemctl enable sddm.service \
    ; fi && \
    systemctl enable wireplumber-workaround.service && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable wireplumber-sysconf.service && \
    systemctl enable btrfs-dedup@run-media-mmcblk0p1.timer && \
    systemctl enable ds-inhibit.service && \
    systemctl enable cec-onboot.service && \
    systemctl enable cec-onpoweroff.service && \
    systemctl enable cec-onsleep.service && \
    systemctl --global enable steam-web-debug-portforward.service && \
    systemctl --global disable sdgyrodsu.service && \
    systemctl disable input-remapper.service && \
    systemctl disable ublue-update.timer && \
    systemctl disable handycon.service && \
    systemctl disable jupiter-fan-control.service && \
    systemctl disable vpower.service && \
    systemctl disable jupiter-biosupdate.service && \
    systemctl disable jupiter-controller-update.service && \
    systemctl disable ryzenadj.service && \
    systemctl disable batterylimit.service && \
    rm -f /usr/etc/sddm.conf && \
    rm -f /usr/etc/default/bazzite && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/bluetooth && \
    chmod -R 755 /var/lib/bluetooth && \
    ostree container commit

FROM bazzite as bazzite-nvidia

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-nvidia}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-nvidia}"
ARG AKMODS_FLAVOR="${AKMODS_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"
ARG NVIDIA_MAJOR_VERSION="545"

# Fetch NVIDIA driver
COPY --from=ghcr.io/ublue-os/akmods-nvidia:${AKMODS_FLAVOR}-${FEDORA_MAJOR_VERSION}-${NVIDIA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
COPY system_files/nvidia/shared system_files/nvidia/${BASE_IMAGE_NAME} /

# Remove everything that doesn't work well with NVIDIA
RUN rm -f /usr/bin/waydroid-choose-gpu && \
    rpm-ostree override remove \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo && \
    if [[ "${BASE_IMAGE_NAME}" == "kinoite" ]]; then \
        rpm-ostree override remove \
            colord-kde \
    ; fi

# Install NVIDIA driver
RUN wget https://raw.githubusercontent.com/ublue-os/nvidia/main/install.sh -O /tmp/nvidia-install.sh && \
    wget https://raw.githubusercontent.com/ublue-os/nvidia/main/post-install.sh -O /tmp/nvidia-post-install.sh && \
    chmod +x /tmp/nvidia-install.sh && IMAGE_NAME="${BASE_IMAGE_NAME}" /tmp/nvidia-install.sh && \
    chmod +x /tmp/nvidia-post-install.sh && IMAGE_NAME="${BASE_IMAGE_NAME}" /tmp/nvidia-post-install.sh

# Cleanup & Finalize
RUN rm -rf \
        /tmp/* \
        /var/* && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    echo "import \"/usr/share/ublue-os/just/95-bazzite-nvidia.just\"" >> /usr/share/ublue-os/justfile && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/bluetooth && \
    chmod -R 755 /var/lib/bluetooth && \
    ostree container commit
