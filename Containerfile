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
ARG BASE_IMAGE_FLAVOR="${BASE_IMAGE_FLAVOR:-main}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.12.5-204.bazzite.fc41.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$BASE_IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20241205.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra

FROM scratch AS ctx
COPY build_files /

################
# DESKTOP BUILDS
################

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.12.5-204.bazzite.fc41.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20241205.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared system_files/desktop/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/unwrap && \
    dnf5 -y install dnf5-plugins && \
    for copr in \
        kylegospo/bazzite \
        kylegospo/bazzite-multilib \
        ublue-os/staging \
        kylegospo/LatencyFleX \
        kylegospo/obs-vkcapture \
        kylegospo/wallpaper-engine-kde-plugin \
        ycollet/audinux \
        kylegospo/rom-properties \
        kylegospo/webapp-manager \
        hhd-dev/hhd \
        che/nerd-fonts \
        hikariknight/looking-glass-kvmfr \
        mavit/discover-overlay \
        lizardbyte/beta \
        rok/cdemu \
        rodoma92/kde-cdemu-manager \
        rodoma92/rmlint \
        ilyaz/LACT; \
    do \
        dnf5 -y copr enable $copr; \
        dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98 ;\
    done && unset -v copr && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 -y config-manager setopt "*bazzite*".priority=1 && \
    dnf5 -y config-manager setopt "*akmods*".priority=2 && \
    dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade" && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')" && \
    dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" && \
    dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*" && \
    /ctx/cleanup

# Install kernel
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-kernel-akmods && \
    dnf5 -y config-manager setopt "*rpmfusion*".enabled=0 && \
    dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install \
        scx-scheds && \
    dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
    for toswap in rpm-ostree bootc; do \
        dnf5 -y swap --repo copr:copr.fedorainfracloud.org:kylegospo:bazzite $toswap $toswap; \
    done && unset -v toswap && \
    /ctx/cleanup

# Setup firmware
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    if [[ "${IMAGE_FLAVOR}" =~ "asus" ]]; then \
        dnf5 -y copr enable lukenukem/asus-linux && \
        dnf5 -y install \
            asusctl \
            asusctl-rog-gui && \
        dnf5 copr disable -y lukenukem/asus-linux \
    ; elif [[ "${IMAGE_FLAVOR}" == "surface" ]]; then \
        dnf5 -y config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo && \
        dnf5 -y swap \
            --allowerasing \
            libwacom-data libwacom-surface-data && \
        dnf5 -y install \
            iptsd \
            libcamera \
            libcamera-tools \
            libcamera-gstreamer \
            libcamera-ipa \
            pipewire-plugin-libcamera && \
        dnf5 -y config-manager setopt "linux-surface".enabled=0 \
    ; fi && \
    /ctx/install-firmware && \
    /ctx/cleanup

# Install patched fwupd
# Install Valve's patched Mesa, Pipewire, Bluez, and Xwayland
# Install patched switcheroo control with proper discrete GPU support
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    declare -A toswap=( \
        ["copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib"]="pipewire bluez xorg-x11-server-Xwayland" \
        ["terra-extras"]="switcheroo-control mesa-filesystem" \
        ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd" \
    ) && \
    for repo in "${!toswap[@]}"; do \
        for package in ${toswap[$repo]}; do dnf5 -y swap --repo=$repo $package $package; done; \
    done && unset -v toswap repo package && \
    dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
        libaacs \
        libbdplus \
        libbluray \
        libbluray-utils && \
    /ctx/cleanup

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        ublue-os-update-services \
        firefox \
        firefox-langpacks \
        htop && \
    /ctx/cleanup

# Install new packages
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install \
        twitter-twemoji-fonts \
        google-noto-sans-cjk-fonts \
        lato-fonts \
        fira-code-fonts \
        nerd-fonts \
        discover-overlay \
        sunshine \
        python3-pip \
        libadwaita \
        duperemove \
        cpulimit \
        sqlite \
        xwininfo \
        xrandr \
        compsize \
        ryzenadj \
        input-remapper \
        i2c-tools \
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
        yad \
        f3 \
        pulseaudio-utils \
        lzip \
        rar \
        libxcrypt-compat \
        vulkan-tools \
        extest.i686 \
        xwiimote-ng \
        fastfetch \
        glow \
        gum \
        vim \
        cockpit-networkmanager \
        cockpit-podman \
        cockpit-selinux \
        cockpit-system \
        cockpit-navigator \
        cockpit-storaged \
        topgrade \
        ydotool \
        yafti \
        stress-ng \
        snapper \
        btrfs-assistant \
        podman-compose \
        edk2-ovmf \
        qemu \
        libvirt \
        lsb_release \
        ublue-update \
        waydroid \
        cage \
        wlr-randr && \
    dnf5 -y --setopt=install_weak_deps=False install \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo && \
    mkdir -p /etc/xdg/autostart && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    sed -i '1s/^/[include]\npaths = ["\/etc\/ublue-os\/topgrade.toml"]\n\n/' /usr/share/ublue-update/topgrade-user.toml && \
    sed -i 's/min_battery_percent.*/min_battery_percent = 20.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_cpu_load_percent.*/max_cpu_load_percent = 100.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_mem_percent.*/max_mem_percent = 90.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/dbus_notify.*/dbus_notify = false/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher && \
    curl -Lo /usr/bin/installcab https://raw.githubusercontent.com/KyleGospo/steam-proton-mf-wmv/master/installcab.py && \
    chmod +x /usr/bin/installcab && \
    curl -Lo /usr/bin/install-mf-wmv https://github.com/KyleGospo/steam-proton-mf-wmv/blob/master/install-mf-wmv.sh && \
    chmod +x /usr/bin/install-mf-wmv && \
    curl -Lo /tmp/ls-iommu.tar.gz $(curl https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest | jq -r '.assets[] | select(.name| test(".*x86_64.tar.gz$")).browser_download_url') && \
    mkdir -p /tmp/ls-iommu && \
    tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu && \
    rm -f /tmp/ls-iommu.tar.gz && \
    cp -r /tmp/ls-iommu/ls-iommu /usr/bin/ && \
    /ctx/cleanup

# Install Steam & Lutris, plus supporting packages
# Downgrade ibus to fix an issue with the Steam keyboard
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y swap \
    --repo copr:copr.fedorainfracloud.org:kylegospo:bazzite \
        ibus ibus && \
    dnf5 -y install \
        gamescope.x86_64 \
        gamescope-libs.x86_64 \
        gamescope-libs.i686 \
        gamescope-shaders \
        jupiter-sd-mounting-btrfs \
        umu-launcher \
        dbus-x11 \
        xdg-user-dirs \
        gobject-introspection \
        libFAudio.x86_64 \
        libFAudio.i686 \
        latencyflex-vulkan-layer \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        libobs_vkcapture.x86_64 \
        libobs_glcapture.x86_64 \
        libobs_vkcapture.i686 \
        libobs_glcapture.i686 && \
    dnf5 -y --setopt=install_weak_deps=False install \
        steam \
        lutris && \
    dnf5 -y remove \
        gamemode && \
    curl -Lo /tmp/latencyflex.tar.xz $(curl https://api.github.com/repos/ishitatsuyuki/LatencyFleX/releases/latest | jq -r '.assets[] | select(.name| test(".*.tar.xz$")).browser_download_url') && \
    mkdir -p /tmp/latencyflex && \
    tar --no-same-owner --no-same-permissions --no-overwrite-dir --strip-components 1 -xvf /tmp/latencyflex.tar.xz -C /tmp/latencyflex && \
    rm -f /tmp/latencyflex.tar.xz && \
    mkdir -p /usr/lib64/latencyflex && \
    cp -r /tmp/latencyflex/wine/usr/lib/wine/* /usr/lib64/latencyflex/ && \
    curl -Lo /usr/bin/latencyflex https://raw.githubusercontent.com/KyleGospo/LatencyFleX-Installer/main/install.sh && \
    chmod +x /usr/bin/latencyflex && \
    curl -Lo /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/bin/winetricks && \
    /ctx/cleanup

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y install \
            qt \
            krdp \
            steamdeck-kde-presets-desktop \
            wallpaper-engine-kde-plugin \
            kdeconnectd \
            kdeplasma-addons \
            rom-properties-kf6 \
            fcitx5-mozc \
            fcitx5-chinese-addons \
            fcitx5-hangul \
            kcm-fcitx5 \
            ptyxis && \
        dnf5 -y swap \
        --repo terra-extras \
            kf6-kio-core kf6-kio-core && \
        dnf5 -y remove \
            plasma-welcome \
            plasma-welcome-fedora \
            konsole && \
        git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 --branch main /tmp/wallpaper-engine-kde-plugin && \
        kpackagetool6 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin && \
        sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:steam.desktop,applications:net.lutris.Lutris.desktop,applications:org.gnome.Ptyxis.desktop,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
        sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,steam.desktop,net.lutris.Lutris.desktop,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,org.gnome.Ptyxis.desktop,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
        sed -i 's@\[Desktop Action new-window\]@\[Desktop Action new-window\]\nX-KDE-Shortcuts=Ctrl+Alt+T@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i '/^Comment/d' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Exec=ptyxis@Exec=kde-ptyxis@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Keywords=@Keywords=konsole;console;@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        cp /usr/share/applications/org.gnome.Ptyxis.desktop /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
        setcap 'cap_net_raw+ep' /usr/libexec/ksysguard/ksgrd_network_helper \
    ; else \
        dnf5 -y swap \
        --repo terra-extras \
            gnome-shell gnome-shell && \
        dnf5 -y install \
            nautilus-gsconnect \
            steamdeck-backgrounds \
            gnome-randr-rust \
            gnome-shell-extension-appindicator \
            gnome-shell-extension-user-theme \
            gnome-shell-extension-gsconnect \
            gnome-shell-extension-compiz-windows-effect \
            gnome-shell-extension-compiz-alike-magic-lamp-effect \
            gnome-shell-extension-coverflow-alt-tab \
            gnome-shell-extension-just-perfection \
            gnome-shell-extension-blur-my-shell \
            gnome-shell-extension-hanabi \
            gnome-shell-extension-bazzite-menu \
            gnome-shell-extension-hotedge \
            gnome-shell-extension-caffeine \
            rom-properties-gtk3 \
            ibus-mozc \
            openssh-askpass \
            firewall-config && \
        dnf5 -y remove \
            gnome-classic-session \
            gnome-tour \
            gnome-extensions-app \
            gnome-system-monitor \
            gnome-initial-setup \
            gnome-shell-extension-background-logo \
            gnome-shell-extension-apps-menu && \
        mkdir -p /tmp/tilingshell && \
        curl -s https://api.github.com/repos/domferr/tilingshell/releases/latest | \
            jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("^tilingshell@.*zip$")) | .browser_download_url' | \
            wget -qi - -O /tmp/tilingshell/tilingshell@ferrarodomenico.com.zip && \
        curl -Lo /usr/share/thumbnailers/exe-thumbnailer.thumbnailer https://raw.githubusercontent.com/jlu5/icoextract/master/exe-thumbnailer.thumbnailer && \
        unzip /tmp/tilingshell/tilingshell@ferrarodomenico.com.zip -d /usr/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com && \
        systemctl enable dconf-update.service \
    ; fi && \
    /ctx/cleanup

# Homebrew & Bash Prexec
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    touch /.dockerenv && \
    mkdir -p /var/home && \
    mkdir -p /var/roothome && \
    curl -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh && \
    chmod +x /tmp/brew-install && \
    /tmp/brew-install && \
    tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew && \
    curl -Lo /usr/share/bash-prexec https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh &&\
    /ctx/cleanup

# Cleanup & Finalize
COPY system_files/overrides /
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    rm -f /etc/profile.d/toolbox.sh && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so && \
    cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so && \
    sed -i 's@/usr/bin/steam@/usr/bin/bazzite-steam@g' /usr/share/applications/steam.desktop && \
    sed -i 's@Exec=steam steam://open/bigpicture@Exec=/usr/bin/bazzite-steam-bpm@g' /usr/share/applications/steam.desktop && \
    mkdir -p /etc/skel/.config/autostart/ && \
    cp "/usr/share/applications/steam.desktop" "/etc/skel/.config/autostart/steam.desktop" && \
    sed -i 's@/usr/bin/bazzite-steam %U@/usr/bin/bazzite-steam -silent %U@g' /etc/skel/.config/autostart/steam.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/fish.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop && \
    sed -i 's/#UserspaceHID.*/UserspaceHID=true/' /etc/bluetooth/input.conf && \
    sed -i "s/^SCX_SCHEDULER=.*/SCX_SCHEDULER=scx_lavd/" /etc/default/scx && \
    rm -f /usr/share/vulkan/icd.d/lvp_icd.*.json && \
    mkdir -p "/etc/profile.d/" && \
    ln -s "/usr/share/ublue-os/firstboot/launcher/login-profile.sh" \
    "/etc/profile.d/ublue-firstboot.sh" && \
    mkdir -p "/etc/xdg/autostart" && \
    cp "/usr/share/applications/discover_overlay.desktop" "/etc/xdg/autostart/discover_overlay.desktop" && \
    sed -i 's@Exec=discover-overlay@Exec=/usr/bin/bazzite-discover-overlay@g' /etc/xdg/autostart/discover_overlay.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/discover_overlay.desktop && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/etc/yafti.yml" && \
    echo "import \"/usr/share/ublue-os/just/80-bazzite.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/81-bazzite-fixes.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-apps.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-cdemu.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-sunshine.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-rmlint.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-waydroid.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/83-bazzite-audio.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/84-bazzite-virt.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/85-bazzite-image.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/86-bazzite-windows.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/87-bazzite-framegen.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-de.just\"" >> /usr/share/ublue-os/justfile && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
      systemctl enable usr-share-sddm-themes.mount && \
      mkdir -p "/usr/share/ublue-os/dconfs/desktop-kinoite/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" "/usr/share/ublue-os/dconfs/desktop-kinoite/" && \
      find "/etc/dconf/db/distro.d/" -maxdepth 1 -type f -exec cp {} "/usr/share/ublue-os/dconfs/desktop-kinoite/" \; && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/desktop-kinoite/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" && \
      rm "/usr/share/ublue-os/dconfs/desktop-kinoite/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" \
    ; else \
      mkdir -p "/usr/share/ublue-os/dconfs/desktop-silverblue/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/desktop-silverblue/" && \
      find "/etc/dconf/db/distro.d/" -maxdepth 1 -type f -exec cp {} "/usr/share/ublue-os/dconfs/desktop-silverblue/" \; && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" && \
      sed -i 's/\[org.gtk.Settings.FileChooser\]/\[org\/gtk\/settings\/file-chooser\]/g; s/\[org.gtk.gtk4.Settings.FileChooser\]/\[org\/gtk\/gtk4\/settings\/file-chooser\]/g' "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-00-bazzite-desktop-silverblue-global" && \
      rm "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" \
    ; fi && \
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    for copr in \
        kylegospo/bazzite \
        kylegospo/bazzite-multilib \
        ublue-os/staging \
        kylegospo/LatencyFleX \
        kylegospo/obs-vkcapture \
        kylegospo/wallpaper-engine-kde-plugin \
        ycollet/audinux \
        kylegospo/rom-properties \
        kylegospo/webapp-manager \
        hhd-dev/hhd \
        che/nerd-fonts \
        mavit/discover-overlay \
        lizardbyte/beta \
        hikariknight/looking-glass-kvmfr; \
    do \
        dnf5 -y copr disable $copr; \
    done && unset -v copr && \
    dnf5 config-manager setopt "*tailscale*".enabled=0 && \
    dnf5 config-manager setopt "*charm*".enabled=0 && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' enabled=0)" && \
    sed -i 's#/var/lib/selinux#/etc/selinux#g' /usr/lib/python3.*/site-packages/setroubleshoot/util.py && \
    mkdir -p /etc/flatpak/remotes.d && \
    curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
    systemctl enable brew-dir-fix.service && \
    systemctl enable brew-setup.service && \
    systemctl disable brew-upgrade.timer && \
    systemctl disable brew-update.timer && \
    systemctl disable displaylink.service && \
    systemctl enable input-remapper.service && \
    systemctl enable bazzite-flatpak-manager.service && \
    systemctl disable rpm-ostreed-automatic.timer && \
    systemctl enable ublue-update.timer && \
    systemctl enable incus-workaround.service && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl disable tailscaled.service && \
    systemctl enable dev-hugepages1G.mount && \
    systemctl --global enable bazzite-user-setup.service && \
    systemctl --global enable podman.socket && \
    systemctl --global enable systemd-tmpfiles-setup.service && \
    systemctl --global disable sunshine.service && \
    systemctl disable waydroid-container.service && \
    curl -Lo /etc/dxvk-example.conf https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf && \
    curl -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh && \
    chmod +x /usr/bin/waydroid-choose-gpu && \
    curl -Lo /usr/lib/sysctl.d/99-bore-scheduler.conf https://github.com/CachyOS/CachyOS-Settings/raw/master/usr/lib/sysctl.d/99-bore-scheduler.conf && \
    curl -Lo /etc/distrobox/docker.ini https://github.com/ublue-os/toolboxes/raw/refs/heads/main/apps/docker/distrobox.ini && \
    curl -Lo /etc/distrobox/incus.ini https://github.com/ublue-os/toolboxes/raw/refs/heads/main/apps/incus/distrobox.ini && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

################
# DECK BUILDS
################

FROM bazzite AS bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-deck}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.12.5-204.bazzite.fc41.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/deck/shared system_files/deck/${BASE_IMAGE_NAME} /

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    dnf5 -y copr enable kylegospo/bazzite && \
    dnf5 -y copr enable kylegospo/bazzite-multilib && \
    dnf5 -y copr enable kylegospo/LatencyFleX && \
    dnf5 -y copr enable kylegospo/obs-vkcapture && \
    dnf5 -y copr enable kylegospo/wallpaper-engine-kde-plugin && \
    dnf5 -y copr enable hhd-dev/hhd && \
    dnf5 -y copr enable ycollet/audinux && \
    /ctx/cleanup

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        jupiter-sd-mounting-btrfs && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y remove \
            steamdeck-kde-presets-desktop && \
       dnf5 -y install \
            steamdeck-kde-presets \
    ; else \
        dnf5 -y install \
            steamdeck-gnome-presets \
            gnome-shell-extension-caribou-blocker \
            sddm \
    ; fi && \
    /ctx/cleanup

# Install new packages
# Dock updater - done manually due to proprietary parts preventing it from being on Copr
# Neptune firmware - done manually due to "TBD" license on needed audio firmware
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install \
        jupiter-fan-control \
        jupiter-hw-support-btrfs \
        galileo-mura \
        steamdeck-dsp \
        powerbuttond \
        hhd \
        hhd-ui \
        adjustor \
        acpica-tools \
        vpower \
        ds-inhibit \
        steam_notif_daemon \
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
        python-crcmod && \
    git clone https://gitlab.com/evlaV/jupiter-dock-updater-bin.git \
        --depth 1 \
        /tmp/jupiter-dock-updater-bin && \
    mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/libexec/jupiter-dock-updater && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning && \
    /ctx/cleanup

# Install Steam Deck patched UPower, remove Tuned GUI
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y swap \
    --repo copr:copr.fedorainfracloud.org:kylegospo:bazzite \
        upower upower && \
    /ctx/cleanup

# Install Gamescope Session & Supporting changes
# Add bootstrap_steam.tar.gz used by gamescope-session (Thanks GE & Nobara Project!)
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p /usr/share/gamescope-session-plus/ && \
    curl -Lo /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz && \
    dnf5 -y install \
    --repo copr:copr.fedorainfracloud.org:kylegospo:bazzite \
        gamescope-session-plus \
        gamescope-session-steam && \
    /ctx/cleanup

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/image-info && \
    mkdir -p "/etc/xdg/autostart" && \
    mv "/etc/skel/.config/autostart/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i 's/Exec=.*/Exec=systemctl start return-to-gamemode.service/' /etc/skel/Desktop/Return.desktop && \
        mkdir -p /usr/share/ublue-os/backup && \
        mv /usr/share/applications/com.github.maliit.keyboard.desktop /usr/share/ublue-os/backup/com.github.maliit.keyboard.desktop \
    ; fi && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/input-remapper-gtk.desktop && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/etc/yafti.yml" && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    for copr in \
        kylegospo/bazzite \
        kylegospo/bazzite-multilib \
        kylegospo/LatencyFleX \
        kylegospo/obs-vkcapture \
        kylegospo/wallpaper-engine-kde-plugin \
        hhd-dev/hhd \
        ycollet/audinux; \
    do \
        dnf5 -y copr disable -y $copr; \
    done && unset -v copr && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl disable gdm.service && \
        systemctl enable sddm.service \
    ; fi && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
      mkdir -p "/usr/share/ublue-os/dconfs/deck-silverblue/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-deck-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/deck-silverblue/" && \
      find "/etc/dconf/db/distro.d/" -maxdepth 1 -type f -exec cp {} "/usr/share/ublue-os/dconfs/deck-silverblue/" \; && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/deck-silverblue/zz0-"*"-bazzite-deck-silverblue-"*".gschema.override" && \
      rm "/usr/share/ublue-os/dconfs/deck-silverblue/zz0-"*"-bazzite-deck-silverblue-"*".gschema.override" \
    ; else \
      systemctl disable usr-share-sddm-themes.mount \
    ; fi && \
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    { rm -v /usr/share/applications/bazzite-steam-bpm.desktop || true; } && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable wireplumber-workaround.service && \
    systemctl enable wireplumber-sysconf.service && \
    systemctl enable pipewire-workaround.service && \
    systemctl enable pipewire-sysconf.service && \
    systemctl enable ds-inhibit.service && \
    systemctl enable cec-onboot.service && \
    systemctl enable cec-onpoweroff.service && \
    systemctl enable cec-onsleep.service && \
    systemctl enable bazzite-tdpfix.service && \
    systemctl enable bazzite-grub-boot-success.timer && \
    systemctl enable bazzite-grub-boot-success.service && \
    systemctl --global disable sdgyrodsu.service && \
    systemctl --global disable grub-boot-success.timer && \
    systemctl disable grub-boot-indeterminate.service && \
    systemctl disable input-remapper.service && \
    systemctl disable ublue-update.timer && \
    systemctl disable jupiter-fan-control.service && \
    systemctl disable vpower.service && \
    systemctl disable jupiter-biosupdate.service && \
    systemctl disable jupiter-controller-update.service && \
    systemctl disable batterylimit.service && \
    /ctx/finalize

FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS nvidia-akmods

################
# NVIDIA BUILDS
################

FROM ${NVIDIA_BASE} AS bazzite-nvidia

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-nvidia}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-nvidia}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.12.5-204.bazzite.fc41.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

# Fetch NVIDIA driver
COPY system_files/nvidia/shared system_files/nvidia/${BASE_IMAGE_NAME} /

# Remove everything that doesn't work well with NVIDIA
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo && \
    /ctx/cleanup

# Install NVIDIA driver
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=nvidia-akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y install \
        mesa-vdpau-drivers.x86_64 \
        mesa-vdpau-drivers.i686 && \
    curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/b3a3dbddf4af81cfbfa7526c1918c9b9f014f86b/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    IMAGE_NAME="${BASE_IMAGE_NAME}" /tmp/nvidia-install.sh && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
    dnf5 -y copr disable ublue-os/staging && \
    /ctx/cleanup

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    echo "import \"/usr/share/ublue-os/just/95-bazzite-nvidia.just\"" >> /usr/share/ublue-os/justfile && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
      mkdir -p "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" && \
      rm "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" \
    ; fi && \
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize
