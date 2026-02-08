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
ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG ARCH="${ARCH:-x86_64}"

ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_REF="${KERNEL_REF:-ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH}}"
ARG NVIDIA_REF="${NVIDIA_REF:-ghcr.io/bazzite-org/nvidia-drivers:latest-f${FEDORA_VERSION}-${ARCH}}"

FROM ${KERNEL_REF} AS kernel
FROM ${NVIDIA_REF} AS nvidia

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
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared system_files/desktop/${BASE_IMAGE_NAME} /
COPY firmware /

# Copy Homebrew files from the brew image
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:3a49f567df02179f6f2db4c10616122380aaed632dc04c3b25c86135d915f051 /system_files /

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p /var/roothome && \
    dnf5 -y install dnf5-plugins && \
    for copr in \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        ublue-os/obs-vkcapture \
        ycollet/audinux \
        ublue-os/rom-properties \
        ublue-os/hhd \
        lizardbyte/beta \
        che/nerd-fonts; \
    do \
        echo "Enabling copr: $copr"; \
        dnf5 -y copr enable $copr; \
        dnf5 -y config-manager setopt copr:copr.fedorainfracloud.org:${copr////:}.priority=98 ;\
    done && unset -v copr && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras,-mesa} && \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 -y config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo && \
    sed -i 's|baseurl=https://pkg.surfacelinux.com/fedora/f\$releasever/|baseurl=https://pkg.surfacelinux.com/fedora/f42/|' /etc/yum.repos.d/linux-surface.repo && \
    dnf5 -y config-manager setopt "linux-surface".enabled=false && \
    dnf5 -y config-manager setopt "*bazzite*".priority=1 && \
    dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade scx-tools scx-scheds steam python3-protobuf zlib-devel" && \
    dnf5 -y config-manager setopt "terra-mesa".enabled=true && \
    eval "$(/ctx/dnf5-setopt setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')" && \
    dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" && \
    dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    dnf5 -y config-manager setopt "*staging*".exclude="scx-tools scx-scheds kf6-* mesa* mutter*" && \
    /ctx/cleanup

# Install kernel
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=kernel,src=/,dst=/rpms/kernel \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-kernel && \
    dnf5 -y config-manager setopt "*rpmfusion*".enabled=0 && \
    rm -rf /.git && \
    /ctx/cleanup

# Install patched fwupd
# Install Valve's patched Mesa, Pipewire, Bluez, and Xwayland
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install --enable-repo="linux-surface" --allowerasing \
        iptsd \
        libwacom-surface && \
    dnf5 -y remove \
        pipewire-config-raop && \
    declare -A toswap=( \
        ["copr:copr.fedorainfracloud.org:ublue-os:bazzite"]="wireplumber" \
        ["copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib"]="pipewire bluez xorg-x11-server-Xwayland NetworkManager" \
        ["terra-mesa"]="mesa-filesystem" \
        ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd" \
    ) && \
    for repo in "${!toswap[@]}"; do \
        for package in ${toswap[$repo]}; do dnf5 -y swap --repo=$repo $package $package; done; \
    done && unset -v toswap repo package && \
    dnf5 versionlock add \
        pipewire \
        pipewire-alsa \
        pipewire-gstreamer \
        pipewire-jack-audio-connection-kit \
        pipewire-jack-audio-connection-kit-libs \
        pipewire-libs \
        pipewire-plugin-libcamera \
        pipewire-pulseaudio \
        pipewire-utils \
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
        mesa-va-drivers \
        mesa-vulkan-drivers \
        fwupd \
        fwupd-plugin-flashrom \
        fwupd-plugin-modem-manager \
        fwupd-plugin-uefi-capsule-data \
        NetworkManager \
        NetworkManager-wifi \
        NetworkManager-libnm && \
    dnf5 -y install \
        mesa-va-drivers.i686 \
        libfreeaptx && \
    dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
        libaacs \
        libbdplus \
        libbluray \
        libbluray-utils && \
    /ctx/cleanup

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y remove \
        ublue-os-update-services \
        firefox \
        firefox-langpacks \
        toolbox \
        htop && \
    /ctx/cleanup

# Install new packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \ 
    --mount=type=secret,id=GITHUB_TOKEN \
    dnf5 -y install \
        $(/ctx/ghcurl https://api.github.com/repos/ublue-os/cicpoffs/releases/latest | jq -r '.assets[] | select(.name| test(".*rpm$")).browser_download_url') && \
    dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install \
        scx-scheds \
        scx-tools && \
    dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install \
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
        Sunshine \
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
        qemu \
        libvirt \
        guestfs-tools \
        lsb_release \
        uupd \
        ds-inhibit \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        waydroid \
        cage \
        wlr-randr \
        bazzite-portal \
        ls-iommu && \
    systemctl mask iscsi && \
    systemctl mask wpa_supplicant.service && \
    systemctl disable iwd.service && \
    mkdir -p /usr/lib/extest/ && \
    /ctx/ghcurl "$(/ctx/ghcurl https://api.github.com/repos/ublue-os/extest/releases/latest | jq -r '.assets[] | select(.name| test(".*so$")).browser_download_url')" -Lo /usr/lib/extest/libextest.so && \
    chmod +x /usr/bin/framework_tool && \
    sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service && \
    setcap 'cap_sys_admin+p' $(readlink -f /usr/bin/sunshine) && \
    dnf5 -y --setopt=install_weak_deps=False install \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        rocm-smi && \
    mkdir -p /etc/xdg/autostart && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher && \
    /ctx/cleanup

# Install Steam & Lutris, plus supporting packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    dnf5 -y install \
        gamescope.x86_64 \
        gamescope-libs.x86_64 \
        gamescope-libs.i686 \
        gamescope-shaders \
        jupiter-sd-mounting-btrfs \
        umu-launcher \
        dbus-x11 \
        xdg-user-dirs \
        xdg-terminal-exec \
        gobject-introspection \
        libFAudio.x86_64 \
        libFAudio.i686 \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        libobs_vkcapture.x86_64 \
        libobs_glcapture.x86_64 \
        libobs_vkcapture.i686 \
        libobs_glcapture.i686 \
        openxr && \
    dnf5 -y --setopt=install_weak_deps=False install \
        steam \
        lutris && \
    dnf5 -y remove \
        gamemode && \
    /ctx/ghcurl "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -Lo /usr/bin/winetricks && \
    chmod +x /usr/bin/winetricks && \
    /ctx/cleanup

# Install ujust-picker from GitHub releases
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/ghcurl "$(/ctx/ghcurl "https://api.github.com/repos/ublue-os/bazzite-ujust-picker/releases/latest" -s | jq -r '.assets[] | select(.name | test("x86_64$")) | .browser_download_url')" -sL -o /usr/bin/ujust-picker && \
    chmod +x /usr/bin/ujust-picker && \
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
            fcitx5-mozc \
            fcitx5-chinese-addons \
            fcitx5-hangul \
            kcm-fcitx5 \
            gnome-disk-utility \
            kio-extras \
            krunner-bazaar \
            ptyxis && \
        dnf5 -y remove \
            plasma-welcome \
            plasma-welcome-fedora \
            plasma-discover-kns \
            kcharselect \
            kde-partitionmanager \
            plasma-discover \
            konsole && \
        sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:steam.desktop,applications:net.lutris.Lutris.desktop,applications:org.gnome.Ptyxis.desktop,applications:io.github.kolunmi.Bazaar.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
        sed -i 's@\[Desktop Action new-window\]@\[Desktop Action new-window\]\nX-KDE-Shortcuts=Ctrl+Alt+T@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i '/^Comment/d' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Exec=ptyxis@Exec=kde-ptyxis@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Keywords=@Keywords=konsole;console;@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        cp /usr/share/applications/org.gnome.Ptyxis.desktop /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default.jxl && \
        ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default-dark.jxl && \
        rm -f /usr/share/backgrounds/default.xml \
    ; else \
        declare -A toswap=( \
            ["copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib"]="mutter gnome-shell" \
        ) && \
        for repo in "${!toswap[@]}"; do \
            for package in ${toswap[$repo]}; do dnf5 -y swap --repo=$repo $package $package; done; \
        done && unset -v toswap repo package && \
        dnf5 versionlock add \
            mutter \
            gnome-shell \
            gsettings-desktop-schemas && \
        dnf5 -y install \
            nautilus-gsconnect \
            steamdeck-backgrounds \
            steamdeck-gnome-presets \
            gnome-randr-rust \
            gnome-shell-extension-user-theme \
            gnome-shell-extension-gsconnect \
            rom-properties-gtk3 \
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
        /ctx/build-gnome-extensions && \
        systemctl enable dconf-update.service \
    ; fi && \
    /ctx/cleanup

# ublue-os-media-automount-udev, mount non-removable device partitions automatically under /media/media-automount/
RUN --mount=type=cache,dst=/var/cache \
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
    echo "import \"/usr/share/ublue-os/just/82-bazzite-beesd.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-sunshine.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-waydroid.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/83-bazzite-audio.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/84-bazzite-virt.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/86-bazzite-windows.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/87-bazzite-framegen.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/88-bazzite-webapps.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/89-bazzite-mesa-git.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-picker.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-de.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/91-bazzite-decky.just\"" >> /usr/share/ublue-os/justfile && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
      systemctl enable usr-share-sddm-themes.mount && \
      mkdir -p "/usr/share/ublue-os/dconfs/desktop-kinoite/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" "/usr/share/ublue-os/dconfs/desktop-kinoite/" && \
      find "/etc/dconf/db/distro.d/" -maxdepth 1 -type f -exec cp {} "/usr/share/ublue-os/dconfs/desktop-kinoite/" \; && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/desktop-kinoite/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" && \
      rm "/usr/share/ublue-os/dconfs/desktop-kinoite/zz0-"*"-bazzite-desktop-kinoite-"*".gschema.override" && \
      sed -i 's@Exec=/usr/bin/ptyxis@Exec=/usr/bin/kde-ptyxis@g' /usr/share/dbus-1/services/org.gnome.Ptyxis.service \
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
    for repo in \
        fedora-cisco-openh264 \
        fedora-steam \
        fedora-rar \
        google-chrome \
        tailscale \
        _copr_ublue-os-akmods \
        terra \
        terra-extras \
        negativo17-fedora-uld \
        negativo17-fedora-multimedia; \
    do \
        sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/$repo.repo; \
    done && for copr in \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ublue-os/staging \
        ublue-os/packages \
        ublue-os/obs-vkcapture \
        ycollet/audinux \
        ublue-os/rom-properties \
        ublue-os/hhd \
        lizardbyte/beta \
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
    systemctl --global disable sunshine.service && \
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
    /ctx/ghcurl "https://github.com/ublue-os/toolboxes/raw/refs/heads/main/apps/incus/distrobox.ini" -Lo /etc/distrobox/incus.ini && \
    /ctx/ghcurl "https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh" -Lo /usr/share/bash-prexec && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN bootc container lint

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
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y copr enable ublue-os/packages && \
    dnf5 -y copr enable ublue-os/bazzite && \
    dnf5 -y copr enable ublue-os/bazzite-multilib && \
    dnf5 -y copr enable ublue-os/obs-vkcapture && \
    dnf5 -y copr enable ublue-os/hhd && \
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
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 -y install \
        jupiter-fan-control \
        jupiter-hw-support-btrfs \
        galileo-mura \
        steamdeck-dsp \
        powerbuttond \
        $([[ "$IMAGE_BRANCH" == "unstable" || "$IMAGE_BRANCH" == "testing" ]] && echo "hhd-git" || echo "hhd") \
        hhd-ui \
        steamos-manager \
        acpica-tools \
        vpower \
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
    git clone https://github.com/bazzite-org/jupiter-dock-updater-bin.git \
        --depth 1 \
        /tmp/jupiter-dock-updater-bin && \
    mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/libexec/jupiter-dock-updater && \
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

# Install Gamescope Session & Supporting changes
# Add bootstrap_steam.tar.gz used by gamescope-session (Thanks GE & Nobara Project!)
# Add sdl gamecontrollerdb used by handheld daemon for externals
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    mkdir -p /usr/share/gamescope-session-plus/ && \
    curl --retry 3 -Lo /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz && \
    mkdir -p /usr/share/sdl/ && \
    /ctx/ghcurl "https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/refs/heads/master/gamecontrollerdb.txt" -Lo /usr/share/sdl/gamecontrollerdb.txt && \
    dnf5 -y install \
    --repo copr:copr.fedorainfracloud.org:ublue-os:bazzite \
        gamescope-session-plus \
        gamescope-session-steam && \
    /ctx/cleanup

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p "/etc/xdg/autostart" && \
    mv "/etc/skel/.config/autostart/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        sed -i 's/Exec=.*/Exec=systemctl start return-to-gamemode.service/' /etc/skel/Desktop/Return.desktop && \
        mkdir -p /usr/share/ublue-os/backup && \
        mv /usr/share/applications/com.github.maliit.keyboard.desktop /usr/share/ublue-os/backup/com.github.maliit.keyboard.desktop \
    ; fi && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/input-remapper-gtk.desktop && \
    for copr in \
        ublue-os/staging \
        ublue-os/packages \
        ublue-os/bazzite \
        ublue-os/bazzite-multilib \
        ublue-os/obs-vkcapture \
        ublue-os/hhd \
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
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    { rm -v /usr/share/applications/bazzite-steam-bpm.desktop || true; } && \
    systemctl enable hhd.service && \
    systemctl enable --global steamos-manager.service && \
    systemctl enable bazzite-autologin.service && \
    systemctl enable wireplumber-workaround.service && \
    systemctl enable wireplumber-sysconf.service && \
    systemctl enable pipewire-workaround.service && \
    systemctl enable pipewire-sysconf.service && \
    systemctl enable cec-onboot.service && \
    systemctl enable cec-onpoweroff.service && \
    systemctl enable cec-onsleep.service && \
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

RUN bootc container lint

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
        nvidia-gpu-firmware \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        rocm-smi && \
    /ctx/cleanup

# Install NVIDIA driver
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    --mount=type=bind,from=nvidia,src=/,dst=/rpms/nvidia \
    dnf5 -y copr enable ublue-os/staging && \
    dnf5 -y install \
        egl-wayland.x86_64 \
        egl-wayland.i686 && \
    /ctx/install-nvidia && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
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
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    systemctl disable supergfxd.service && \
    dnf5 config-manager setopt skip_if_unavailable=1 && \
    /ctx/image-info && \
    /ctx/build-initramfs && \
    /ctx/finalize

RUN bootc container lint
