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
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.19.11-ogc1.1.fc44.x86_64}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia-open}"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-nvidia

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
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared/ system_files/desktop/${BASE_IMAGE_NAME}/ /
RUN find /usr/share/ublue-os/docs -type f -exec setfattr -n user.component -v "ublue-docs" {} +

# Install needed firmware blobs
RUN --mount=type=bind,src=firmware,dst=/ctx/firmware \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    cp -a /ctx/firmware/. /tmp/firmware && \
    find /tmp/firmware -type f -exec setfattr -n user.component -v "bazzite-nonfree" {} + && \
    rm -rf /tmp/firmware/.git && \
    cp -a /tmp/firmware/. / && \
    rm -rf /tmp/firmware

# Copy Homebrew files from the brew image
ARG BREW_IMAGE=ghcr.io/ublue-os/brew:latest@sha256:ca91068f51ce663d495ccfc829352d6621ec95f6c7db447ade55023b222f9762
COPY --from=${BREW_IMAGE} /system_files/ /tmp/brew_files/
RUN find /tmp/brew_files -type f -printf '/%P\0' > /tmp/brew_list.txt && \
    cp -a /tmp/brew_files/. / && \
    xargs -0 -a /tmp/brew_list.txt setfattr -h -n user.component -v "homebrew" && \
    rm -rf /tmp/brew_files /tmp/brew_list.txt

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
    mkdir -p /var/roothome && \
    dnf5 config-manager setopt keepcache=1 && \
    for copr in \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        ycollet/audinux \
        che/nerd-fonts; \
    do \
        echo "Enabling copr: $copr"; \
        dnf5 -y copr enable $copr; \
        dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98 ;\
    done && unset -v copr && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa} && \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 -y config-manager setopt "*terra*".priority=1 "*terra*".exclude="nerd-fonts topgrade scx-tools scx-scheds python3-protobuf zlib-devel" && \
    dnf5 -y config-manager setopt "terra-mesa".enabled=false && \
    dnf5 -y config-manager setopt "*bazzite*".priority=2 && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')" && \
    dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    dnf5 -y config-manager setopt "*audinux*".exclude="kernel*" && \
    dnf5 -y config-manager setopt "*staging*".exclude="scx-tools scx-scheds kf6-* mesa* mutter*" && \
    /ctx/cleanup

# Install patched fwupd
# Install Valve's patched Mesa, Bluez, and Xwayland
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        pipewire-config-raop \
        mesa-va-drivers && \
    declare -A toswap=( \
        ["copr:copr.fedorainfracloud.org:ublue-os:bazzite"]="wireplumber" \
        ["copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib"]="bluez xorg-x11-server-Xwayland" \
        ["terra-mesa"]="mesa-filesystem" \
        ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd" \
    ) && \
    for repo in "${!toswap[@]}"; do \
        for package in ${toswap[$repo]}; do dnf5 -y swap --from-repo=$repo $package $package; done; \
    done && unset -v toswap repo package && \
    dnf5 versionlock add \
        wireplumber \
        wireplumber-libs \
        bluez \
        bluez-cups \
        bluez-libs \
        bluez-obexd \
        xorg-x11-server-Xwayland \
        mesa-dri-drivers \
        mesa-filesystem \
        mesa-libEGL \
        mesa-libGL \
        mesa-libgbm \
        mesa-vulkan-drivers \
        fwupd \
        fwupd-plugin-flashrom \
        fwupd-plugin-modem-manager \
        fwupd-plugin-uefi-capsule-data \
        NetworkManager \
        NetworkManager-wifi \
        NetworkManager-libnm && \
    dnf5 --enable-repo=terra-mesa -y install \
        mesa-libOpenCL \
        intel-opencl \
        clinfo && \
    dnf5 -y install \
        libfreeaptx && \
    dnf5 -y install --enable-repo="*fedora-multimedia*" \
        libbluray \
        libbluray-utils \
        makemkv && \
    desktop-file-edit --set-key=Hidden --set-value=true /usr/share/applications/makemkv.desktop && \
    ln -sf /usr/lib64/libmmbd.so.0 /usr/lib64/libaacs.so.0 && \
    ln -sf /usr/lib64/libmmbd.so.0 /usr/lib64/libaacs.so.0.7.2 && \
    ln -sf /usr/lib64/libmmbd.so.0 /usr/lib64/libbdplus.so.0 && \
    ln -sf /usr/lib64/libmmbd.so.0 /usr/lib64/libbdplus.so.0.2.0 && \
    /ctx/cleanup

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        ublue-os-update-services \
        firefox \
        firefox-langpacks \
        htop && \
    /ctx/cleanup

# Install new packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    dnf5 -y install \
        $(/ctx/ghcurl https://api.github.com/repos/ublue-os/cicpoffs/releases/latest | jq -r --arg name "cicpoffs-fc${FEDORA_VERSION}.rpm" '.assets[] | select(.name == $name).browser_download_url') && \
    dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install \
        scx-scheds \
        scx-tools && \
    dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install \
        fuse-libs \
        uld \
        bazaar \
        iwd \
        greenboot \
        greenboot-default-health-checks \
        ScopeBuddy \
        twitter-twemoji-fonts \
        google-noto-sans-cjk-fonts \
        lato-fonts \
        fira-code-fonts \
        nerd-fonts \
        python3-pip \
        libadwaita \
        bees \
        xwininfo \
        usbip \
        compsize \
        ryzenadj \
        ddcutil \
        input-remapper \
        libinput-utils \
        i2c-tools \
        lm_sensors \
        iio-sensor-proxy \
        fw-ectool \
        fw-fanctrl \
        framework-system \
        udica \
        ladspa-caps-plugins \
        ladspa-noise-suppression-for-voice \
        pipewire-module-filter-chain-sofa \
        python3-icoextract \
        tailscale \
        webapp-manager \
        btop \
        amdsmi \
        duf \
        fish \
        lshw \
        xdotool \
        wmctrl \
        libcec \
        v4l-utils \
        yad \
        f3 \
        lzip \
        p7zip \
        p7zip-plugins \
        rar \
        libxcrypt-compat \
        vulkan-tools \
        xwiimote-ng \
        fastfetch \
        glow \
        gum \
        vim \
        cockpit-networkmanager \
        cockpit-podman \
        cockpit-selinux \
        cockpit-system \
        cockpit-files \
        cockpit-storaged \
        topgrade \
        ydotool \
        stress-ng \
        snapper \
        btrfs-assistant \
        edk2-ovmf \
        lsb_release \
        uupd \
        ds-inhibit \
        waydroid \
        cage \
        wlr-randr \
        gmodpatchtool \
        bazzite-portal \
        ls-iommu && \
    ln -s /dev/null /etc/NetworkManager/dispatcher.d/04-iscsi && \
    systemctl mask iscsi && \
    systemctl mask systemd-remount-fs.service && \
    systemctl mask iwd.service && \
    mkdir -p /usr/lib/extest/ && \
    /ctx/ghcurl "$(/ctx/ghcurl https://api.github.com/repos/ublue-os/extest/releases/latest | jq -r '.assets[] | select(.name| test(".*so$")).browser_download_url')" -Lo /usr/lib/extest/libextest.so && \
    /ctx/ghcurl "https://github.com/ykshek/Sunshine/raw/1347f9ef290c089b815cf186f7d361470bdb9ef7/src_assets/linux/misc/postinst" -Lo /usr/libexec/sunshine-postinst && \
    chmod +x /usr/libexec/sunshine-postinst && \
    setfattr -n user.component -v "extest" /usr/lib/extest/libextest.so && \
    sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service && \
    mkdir -p /etc/xdg/autostart && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher && \
    /ctx/cleanup

# Install Steam & Lutris, plus supporting packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    dnf5 --enable-repo=terra-mesa --enable-repo=terra -y install \
        terra-gamescope.x86_64 \
        terra-gamescope-libs.x86_64 \
        terra-gamescope-libs.i686 \
        jupiter-sd-mounting-btrfs \
        umu-wrapper \
        umu-launcher \
        dbus-x11 \
        xrandr \
        evtest \
        xdg-user-dirs \
        xdg-terminal-exec \
        gobject-introspection \
        libFAudio.x86_64 \
        libFAudio.i686 \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        obs-studio-plugin-vkcapture-hook-libs.x86_64 \
        obs-studio-plugin-vkcapture-hook-libs.i686 \
        openxr && \
    dnf5 -y --enable-repo=terra-mesa --enable-repo=terra --setopt=install_weak_deps=False install \
        steam \
        lutris && \
    dnf5 -y remove \
        gamemode && \
    /ctx/ghcurl "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -Lo /usr/bin/winetricks && \
    chmod +x /usr/bin/winetricks && \
    setfattr -n user.component -v "winetricks" /usr/bin/winetricks && \
    /ctx/cleanup

# Install ujust-picker from GitHub releases
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/ghcurl "$(/ctx/ghcurl "https://api.github.com/repos/ublue-os/bazzite-ujust-picker/releases/latest" -s | jq -r '.assets[] | select(.name | test("x86_64$")) | .browser_download_url')" -sL -o /usr/bin/ujust-picker && \
    chmod +x /usr/bin/ujust-picker && \
    setfattr -n user.component -v "ujust-picker" /usr/bin/ujust-picker && \
    /ctx/cleanup

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y install \
            qt \
            krdp \
            steamdeck-kde-presets-desktop \
            kdeconnectd \
            kdeplasma-addons \
            rom-properties-kf6 \
            fcitx5-chewing \
            fcitx5-mozc \
            fcitx5-chinese-addons \
            fcitx5-hangul \
            fcitx5-m17n \
            kcm-fcitx5 \
            gnome-disk-utility \
            kio-extras \
            krunner-bazaar \
            krdc \
            tesseract-devel \
            tesseract-langpack-eng \
            tesseract-langpack-spa \
            tesseract-langpack-deu \
            tesseract-langpack-jpn \
            tesseract-langpack-jpn_vert \
            tesseract-langpack-fra \
            tesseract-langpack-por \
            tesseract-langpack-rus \
            tesseract-langpack-ita \
            tesseract-langpack-nld \
            tesseract-langpack-pol \
            tesseract-langpack-tur \
            tesseract-langpack-chi_sim \
            tesseract-langpack-chi_sim_vert \
            tesseract-langpack-chi_tra \
            tesseract-langpack-chi_tra_vert \
            tesseract-langpack-ces \
            tesseract-langpack-ell && \
        dnf5 -y remove \
            plasma-drkonqi \
            plasma-welcome \
            plasma-welcome-fedora \
            plasma-discover-kns \
            kcharselect \
            kde-partitionmanager \
            plasma-discover && \
        sed -i '$r /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js' /usr/share/plasma/layout-templates/org.kde.plasma.desktop.defaultPanel/contents/layout.js && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default.jxl && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default-dark.jxl && \
        rm -f /usr/share/backgrounds/default.xml && \
        mkdir -p /usr/share/wallpapers/bazzite/convergence/contents/images && \
        ln -s /usr/share/wallpapers/convergence.jxl /usr/share/wallpapers/bazzite/convergence/contents/images/3940x2160.jxl \
    ; else \
        dnf5 -y install \
            nautilus-gsconnect \
            steamdeck-backgrounds \
            steamdeck-gnome-presets \
            gnome-shell-extension-user-theme \
            gnome-shell-extension-gsconnect \
            rom-properties-gtk4 \
            rom-properties-localsearch3 \
            ibus-mozc \
            openssh-askpass \
            firewall-config && \
        dnf5 -y remove \
            gnome-software \
            gnome-classic-session \
            gnome-tour \
            gnome-extensions-app \
            gnome-system-monitor \
            gnome-initial-setup \
            gnome-shell-extension-background-logo \
            gnome-shell-extension-apps-menu \
            gnome-shell-extension-launch-new-instance \
            gnome-shell-extension-places-menu \
            gnome-shell-extension-window-list && \
        /ctx/ghcurl "https://raw.githubusercontent.com/jlu5/icoextract/master/exe-thumbnailer.thumbnailer" -Lo /usr/share/thumbnailers/exe-thumbnailer.thumbnailer && \
        setfattr -n user.component -v "exe-thumbnailer" /usr/share/thumbnailers/exe-thumbnailer.thumbnailer && \
        /ctx/build-gnome-extensions && \
        systemctl enable dconf-update.service \
    ; fi && \
    dnf5 -y install \
        rom-properties-utils && \
    /ctx/cleanup

# ublue-os-media-automount-udev, mount non-removable device partitions automatically under /media/media-automount/
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 install -y --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:packages \
        ublue-os-media-automount-udev && \
    { systemctl enable ublue-os-media-automount.service || true; } && \
    /ctx/cleanup

# Cleanup & Finalize
COPY system_files/overrides /

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    rm -f /etc/profile.d/toolbox.sh && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so && \
    cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so && \
    sed -i 's@/usr/bin/steam@/usr/bin/bazzite-steam@g' /usr/share/applications/steam.desktop && \
    sed -i 's@Exec=steam steam://open/bigpicture@Exec=/usr/bin/bazzite-steam-bpm@g' /usr/share/applications/steam.desktop && \
    sed -i 's|^Exec=lutris %U$|Exec=env PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python lutris %U|' /usr/share/applications/net.lutris.Lutris.desktop && \
    mkdir -p /etc/skel/.config/autostart/ && \
    cp "/usr/share/applications/steam.desktop" "/etc/skel/.config/autostart/steam.desktop" && \
    sed -i 's@/usr/bin/bazzite-steam %U@/usr/bin/bazzite-steam -silent %U@g' /etc/skel/.config/autostart/steam.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop && \
    sed -i 's/#UserspaceHID.*/UserspaceHID=true/' /etc/bluetooth/input.conf && \
    sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig && \
    rm -f /usr/lib/systemd/system/service.d/50-keep-warm.conf && \
    echo "import \"/usr/share/ublue-os/just/80-bazzite.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/81-bazzite-fixes.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-apps.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-cockpit.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-beesd.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-sunshine.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-waydroid.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/83-bazzite-audio.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/85-bazzite-image.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/84-bazzite-virt.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/86-bazzite-windows.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/87-bazzite-framegen.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/88-bazzite-webapps.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/89-bazzite-mesa-git.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-picker.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-de.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/91-bazzite-decky.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/92-bazzite-verify.just\"" >> /usr/share/ublue-os/justfile && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl enable usr-share-sddm-themes.mount \
    ; else \
        mkdir -p "/usr/share/ublue-os/dconfs/desktop-silverblue/" && \
        cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/desktop-silverblue/" && \
        find "/etc/dconf/db/distro.d/" -maxdepth 1 -type f -exec cp {} "/usr/share/ublue-os/dconfs/desktop-silverblue/" \; && \
        dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" && \
        sed -i 's/\[org.gtk.Settings.FileChooser\]/\[org\/gtk\/settings\/file-chooser\]/g; s/\[org.gtk.gtk4.Settings.FileChooser\]/\[org\/gtk\/gtk4\/settings\/file-chooser\]/g' "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-00-bazzite-desktop-silverblue-global" && \
        rm "/usr/share/ublue-os/dconfs/desktop-silverblue/zz0-"*"-bazzite-desktop-silverblue-"*".gschema.override" && \
        mkdir -p /tmp/bazzite-schema-test && \
        find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
        cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
        glib-compile-schemas --strict /tmp/bazzite-schema-test && \
        glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
        rm -r /tmp/bazzite-schema-test \
    ; fi && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    for repo in \
        fedora-cisco-openh264 \
        fedora-steam \
        fedora-rar \
        tailscale \
        _copr_ublue-os-akmods \
        terra \
        terra-extras \
        negativo17-fedora-multimedia; \
    do \
        sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/$repo.repo; \
    done && for copr in \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        ycollet/audinux \
        che/nerd-fonts; \
    do \
        dnf5 -y copr disable $copr; \
    done && unset -v copr && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' enabled=0)" && \
    sed -i 's#/var/lib/selinux#/etc/selinux#g' /usr/lib/python3.*/site-packages/setroubleshoot/util.py && \
    sed -i 's/power-saver=powersave$/power-saver=powersave-bazzite/' /etc/tuned/ppd.conf && \
    sed -i 's/balanced=balanced$/balanced=balanced-bazzite/' /etc/tuned/ppd.conf && \
    sed -i 's/performance=throughput-performance$/performance=throughput-performance-bazzite/' /etc/tuned/ppd.conf && \
    sed -i 's/balanced=balanced-battery$/balanced=balanced-battery-bazzite\npower-saver=powersave-battery-bazzite/' /etc/tuned/ppd.conf && \
    ln -s /usr/bin/true /usr/bin/pulseaudio && \
    mkdir -p /etc/flatpak/remotes.d && \
    curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
    systemctl enable brew-setup.service && \
    systemctl disable fw-fanctrl.service && \
    systemctl disable scx_loader.service && \
    systemctl enable input-remapper.service && \
    systemctl enable bazzite-flatpak-manager.service && \
    systemctl disable rpm-ostreed-automatic.timer && \
    systemctl enable uupd.timer && \
    systemctl enable incus-workaround.service && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl disable tailscaled.service && \
    systemctl enable dev-hugepages1G.mount && \
    systemctl enable ds-inhibit.service && \
    systemctl --global enable bazzite-user-setup.service && \
    systemctl --global enable podman.socket && \
    systemctl --global enable systemd-tmpfiles-setup.service && \
    systemctl disable waydroid-container.service && \
    systemctl enable greenboot-healthcheck.service && \
    systemctl enable greenboot-set-rollback-trigger.service && \
    systemctl disable force-wol.service && \
    systemctl --global enable bazzite-dynamic-fixes.service && \
    systemctl --global enable ntfs-nag.service && \
    /ctx/ghcurl "https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf" -Lo /etc/dxvk-example.conf && \
    /ctx/ghcurl "https://raw.githubusercontent.com/ublue-os/waydroid-scripts/main/waydroid-choose-gpu.sh" -Lo /usr/bin/waydroid-choose-gpu && \
    chmod +x /usr/bin/waydroid-choose-gpu && \
    dnf5 config-manager setopt skip_if_unavailable=1 && \
    /ctx/ghcurl "https://github.com/ublue-os/toolboxes/raw/refs/heads/main/apps/docker/distrobox.ini" -Lo /etc/distrobox/docker.ini && \
    setfattr -n user.component -v "toolbox-config" /etc/distrobox/docker.ini && \
    /ctx/ghcurl "https://github.com/ublue-os/toolboxes/raw/refs/heads/main/apps/incus/distrobox.ini" -Lo /etc/distrobox/incus.ini && \
    setfattr -n user.component -v "toolbox-config" /etc/distrobox/incus.ini && \
    /ctx/ghcurl "https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh" -Lo /usr/share/bash-prexec && \
    setfattr -n user.component -v "bash-preexec" /usr/share/bash-prexec && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

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
    dnf5 -y remove \
        jupiter-sd-mounting-btrfs && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 -y remove \
            steamdeck-kde-presets-desktop && \
       dnf5 -y install \
            steamdeck-kde-presets \
    ; else \
        dnf5 -y install \
            sddm && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default.jxl && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default-dark.jxl && \
        rm -f /usr/share/backgrounds/default.xml && \
        dnf5 -y remove \
            malcontent-control \
    ; fi && \
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
        gamescope-session-ogui-steam \
        steamos-manager-powerstation \
        steamos-manager-powerstation-gamescope-session-plus \
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
        python-crcmod && \
    chmod +x /usr/share/gamescope-session-plus/gamescope-session-plus && \
    git clone https://github.com/bazzite-org/jupiter-dock-updater-bin.git \
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
# Add sdl gamecontrollerdb used by handheld daemon for externals
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
    mkdir -p /usr/share/sdl/ && \
    /ctx/ghcurl "https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/refs/heads/master/gamecontrollerdb.txt" -Lo /usr/share/sdl/gamecontrollerdb.txt && \
    setfattr -n user.component -v "sdl2" /usr/share/sdl/gamecontrollerdb.txt && \
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
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i 's/Exec=.*/Exec=systemctl start return-to-gamemode.service/' /etc/skel/Desktop/Return.desktop \
    ; fi && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/input-remapper-gtk.desktop && \
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
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
        systemctl disable gdm.service && \
        systemctl enable sddm.service \
    ; else \
        systemctl disable usr-share-sddm-themes.mount \
    ; fi && \
    { rm -v /usr/share/applications/bazzite-steam-bpm.desktop || true; } && \
    systemctl enable --global steamos-manager.service && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable wireplumber-workaround.service && \
    systemctl enable wireplumber-sysconf.service && \
    systemctl enable pipewire-workaround.service && \
    systemctl enable pipewire-sysconf.service && \
    systemctl enable bazzite-tdpfix.service && \
    systemctl --global disable sdgyrodsu.service && \
    systemctl disable input-remapper.service && \
    systemctl disable uupd.timer && \
    systemctl disable jupiter-fan-control.service && \
    systemctl disable vpower.service && \
    systemctl disable jupiter-biosupdate.service && \
    systemctl disable jupiter-controller-update.service && \
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
    IMAGE_NAME="${BASE_IMAGE_NAME}" AKMODNV_PATH="/tmp/rpms/nvidia" MULTILIB=1 /tmp/rpms/nvidia/ublue-os/nvidia-install.sh && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
    dnf5 config-manager setopt "terra-mesa".enabled=0 && \
    dnf5 -y copr disable ublue-os/staging && \
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
    systemctl disable supergfxd.service && \
    dnf5 config-manager setopt skip_if_unavailable=1 && \
    if [ -f /etc/modprobe.d/nvidia-modeset.conf ]; then \
      cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf \
    ; fi && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN --mount=type=tmpfs,target=/run --network=none bootc container lint
