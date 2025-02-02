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

FROM ghcr.io/ublue-os/${KERNEL_FLAVOR}-kernel:${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS kernel
FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra

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

# Remove CLIWRAP
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    if [ ! -d /usr/libexec/rpm-ostree/wrapped ]; then \
    echo "cliwrap is not setup, skipping..."; exit 0 \
    ; fi && \
    rm -f \
    /usr/bin/yum \
    /usr/bin/dnf \
    /usr/bin/kernel-install && \
    mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin && \
    rm -rf /usr/libexec/rpm-ostree && \
    dnf5 install -y dnf5-plugins && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
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
    sentry/switcheroo-control_discrete \
    hikariknight/looking-glass-kvmfr \
    mavit/discover-overlay \
    lizardbyte/beta \
    rok/cdemu \
    rodoma92/kde-cdemu-manager \
    rodoma92/rmlint \
    ilyaz/LACT \
    ; do \
    dnf5 -y copr enable $copr; \
    dnf -y config-manager setopt copr:copr.fedorainfracloud.org:${cloud////:}.priority=98 ;\
    done && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyrlabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
    dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
    dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf5 config-manager setopt \
    tailscale-stable.gpgcheck=0 \
    fedora-multimedia.enabled=1 fedora-multimedia.priority=3 fedora-multimedia.exclude="mesa-*" \
    fedora-rar.priority=3 \
    fedora-steam.priority=3 \
    "*bazzite*".priority=1 \
    "*terra*".priority=2 \
    "*rpmfusion*".priority=4 "*rpmfusion*".exclude="mesa-*" && \
    "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install kernel
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=bind,from=kernel,src=/tmp/rpms,dst=/tmp/kernel-rpms \
    --mount=type=tmpfs,dst=/tmp \
    echo "Will install ${KERNEL_FLAVOR} kernel" && \
    for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do \
    rpm --erase $pkg --nodeps \
    ; done && \
    dnf5 install -y \
    /tmp/kernel-rpms/kernel-[0-9]*.rpm \
    /tmp/kernel-rpms/kernel-core-*.rpm \
    /tmp/kernel-rpms/kernel-modules-*.rpm \
    /tmp/kernel-rpms/kernel-uki-virt-*.rpm && \
    dnf5 install -y \
    scx-scheds && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
    rpm-ostree rpm-ostree && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
    bootc bootc && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Setup firmware
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p /tmp/linux-firmware-neptune && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-cali.bin && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.wmfw https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-cali.wmfw && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-prot.bin && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.wmfw https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-prot.wmfw && \
    curl -Lo /tmp/linux-firmware-neptune/rtl8822cu_fw.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/rtl_bt/rtl8822cu_fw.bin && \
    xz --check=crc32 /tmp/linux-firmware-neptune/* && \
    mv -vf /tmp/linux-firmware-neptune/rtl8822cu_fw.bin.xz /usr/lib/firmware/rtl_bt/rtl8822cu_fw.bin.xz && \
    mv -vf /tmp/linux-firmware-neptune/* /usr/lib/firmware/cirrus/ && \
    rm -rf /tmp/linux-firmware-neptune && \
    mkdir -p /tmp/linux-firmware-galileo && \
    curl https://gitlab.com/evlaV/linux-firmware-neptune/-/archive/"${JUPITER_FIRMWARE_VERSION}"/linux-firmware-neptune-"${JUPITER_FIRMWARE_VERSION}".tar.gz?path=ath11k/QCA206X -o /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    tar --strip-components 1 --no-same-owner --no-same-permissions --no-overwrite-dir -xvf /tmp/linux-firmware-galileo/ath11k.tar.gz -C /tmp/linux-firmware-galileo && \
    xz --check=crc32 /tmp/linux-firmware-galileo/ath11k/QCA206X/hw2.1/* && \
    rm -f /usr/lib/firmware/ath11k/QCA206X/* && \
    rm -rf /usr/lib/firmware/ath11k/QCA2066 && \
    mv -vf /tmp/linux-firmware-galileo/ath11k/QCA206X /usr/lib/firmware/ath11k/QCA206X && \
    rm -rf /tmp/linux-firmware-galileo/ath11k && \
    rm -rf /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    ln -s QCA206X /usr/lib/firmware/ath11k/QCA2066 && \
    curl -Lo /tmp/linux-firmware-galileo/hpbtfw21.tlv https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpbtfw21.tlv && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21.309 https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21.309 && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21.bin && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21g.309 https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21g.309 && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21g.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21g.bin && \
    xz --check=crc32 /tmp/linux-firmware-galileo/* && \
    mv -vf /tmp/linux-firmware-galileo/* /usr/lib/firmware/qca/ && \
    rm -rf /tmp/linux-firmware-galileo && \
    rm -rf /usr/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf && \
    ln -s /usr/local/firmware/aw87xxx_acf.bin /usr/lib/firmware/aw87xxx_acf.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_air1s.bin /usr/lib/firmware/aw87xxx_acf_air1s.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_kun.bin /usr/lib/firmware/aw87xxx_acf_kun.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_minipro.bin /usr/lib/firmware/aw87xxx_acf_minipro.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_orangepi.bin /usr/lib/firmware/aw87xxx_acf_orangepi.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_airplus.bin /usr/lib/firmware/aw87xxx_acf_airplus.bin && \
    ln -s /usr/local/firmware/aw87xxx_acf_flip.bin /usr/lib/firmware/aw87xxx_acf_flip.bin && \
    if [[ "${IMAGE_FLAVOR}" =~ "asus" ]]; then \
    dnf5 -y copr enable lukenukem/asus-linux && \
    dnf5 install -y \
    asusctl \
    asusctl-rog-gui && \
    dnf5 -y copr disable lukenukem/asus-linux \
    ; elif [[ "${IMAGE_FLAVOR}" == "surface" ]]; then \
    dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo && \
    dnf5 swap -y \
    libwacom-data libwacom-surface-data && \
    dnf5 swap -y \
    libwacom libwacom-surface && \
    dnf5 install -y \
    iptsd \
    libcamera \
    libcamera-tools \
    libcamera-gstreamer \
    libcamera-ipa \
    pipewire-plugin-libcamera && \
    dnf5 config-manager setopt linux-surface.enabled=0 \
    ; fi && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Add ublue packages
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 config-manager setopt copr:copr.fedorainfracloud.org:ublue-os:akmods.enabled=1 && \
    dnf5 install -y \
    /tmp/akmods-rpms/kmods/*kvmfr*.rpm \
    /tmp/akmods-rpms/kmods/*xone*.rpm \
    /tmp/akmods-rpms/kmods/*openrazer*.rpm \
    /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
    /tmp/akmods-rpms/kmods/*wl*.rpm \
    /tmp/akmods-rpms/kmods/*framework-laptop*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gcadapter_oc*.rpm \
    /tmp/akmods-extra-rpms/kmods/*zenergy*.rpm \
    /tmp/akmods-extra-rpms/kmods/*vhba*.rpm \
    /tmp/akmods-extra-rpms/kmods/*gpd-fan*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayaneo-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ayn-platform*.rpm \
    /tmp/akmods-extra-rpms/kmods/*bmi260*.rpm \
    /tmp/akmods-extra-rpms/kmods/*ryzen-smu*.rpm \
    /tmp/akmods-extra-rpms/kmods/*evdi*.rpm && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
    fwupd fwupd && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-*.repo && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install Valve's patched Mesa, Pipewire, Bluez, and Xwayland#
# Install patched switcheroo control with proper discrete GPU support
# Tempporary fix for GPU Encoding
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    dnf5 install -y \
    mesa-dri-drivers.i686 && \
    mkdir -p /tmp/mesa-fix64/dri && \
    cp /usr/lib64/libgallium-*.so /tmp/mesa-fix64/ && \
    cp /usr/lib64/dri/kms_swrast_dri.so /tmp/mesa-fix64/dri/ && \
    cp /usr/lib64/dri/libdril_dri.so /tmp/mesa-fix64/dri/ && \
    cp /usr/lib64/dri/swrast_dri.so /tmp/mesa-fix64/dri/ && \
    cp /usr/lib64/dri/virtio_gpu_dri.so /tmp/mesa-fix64/dri/ && \
    mkdir -p /tmp/mesa-fix32/dri && \
    cp /usr/lib/libgallium-*.so /tmp/mesa-fix32/ && \
    cp /usr/lib/dri/kms_swrast_dri.so /tmp/mesa-fix32/dri/ && \
    cp /usr/lib/dri/libdril_dri.so /tmp/mesa-fix32/dri/ && \
    cp /usr/lib/dri/swrast_dri.so /tmp/mesa-fix32/dri/ && \
    cp /usr/lib/dri/virtio_gpu_dri.so /tmp/mesa-fix32/dri/ && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
    bluez bluez && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
    pipewire pipewire && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
    xorg-x11-server-Xwayland xorg-x11-server-Xwayland && \
    dnf swap -y \
    --repo=terra-extras \
    mesa-filesystem mesa-filesystem && \
    rsync -a /tmp/mesa-fix64/ /usr/lib64/ && \
    rsync -a /tmp/mesa-fix32/ /usr/lib/ && \
    rm -rf /tmp/mesa-fix64 && \
    rm -rf /tmp/mesa-fix32 && \
    dnf5 install -y --enable-repo="*rpmfusion*" \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils && \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:sentry:switcheroo-control_discrete \
    switcheroo-control switcheroo-control && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    dnf5 remove -y \
    ublue-os-update-services \
    firefox \
    firefox-langpacks \
    htop && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install new packages
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 install -y \
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
    tuned-profiles-cpu-partitioning \
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
    btrfs-assistant \
    podman-compose \
    edk2-ovmf \
    qemu \
    rocm-hip \
    rocm-opencl \
    rocm-clinfo \
    rocm-smi \
    waydroid \
    cage \
    wlr-randr && \
    libvirt \
    lsb_release && \
    dnf5 install -y \
    ublue-update && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    mkdir -p /etc/xdg/autostart && \
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
    rm -rf /tmp/ls-iommu && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install Steam & Lutris, plus supporting packages
# Downgrade ibus to fix an issue with the Steam keyboard
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
    ibus ibus \
    dnf5 install -y \
    jupiter-sd-mounting-btrfs \
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
    gobject-introspection \
    clinfo \
    steam \
    lutris \
    umu-launcher \
    wine-core.x86_64 \
    wine-core.i686 \
    wine-pulseaudio.x86_64 \
    wine-pulseaudio.i686 \
    libFAudio.x86_64 \
    libFAudio.i686 \
    winetricks \
    latencyflex-vulkan-layer \
    mesa-vulkan-drivers.i686 \
    mesa-va-drivers.i686 \
    vkBasalt.x86_64 \
    vkBasalt.i686 \
    mangohud.x86_64 \
    mangohud.i686 \
    gamescope.x86_64 \
    gamescope-libs.i686 \
    gamescope-shaders \
    libobs_vkcapture.x86_64 \
    libobs_glcapture.x86_64 \
    libobs_vkcapture.i686 \
    libobs_glcapture.i686 && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/winetricks.desktop && \
    curl -Lo /tmp/latencyflex.tar.xz $(curl https://api.github.com/repos/ishitatsuyuki/LatencyFleX/releases/latest | jq -r '.assets[] | select(.name| test(".*.tar.xz$")).browser_download_url') && \
    mkdir -p /tmp/latencyflex && \
    tar --no-same-owner --no-same-permissions --no-overwrite-dir --strip-components 1 -xvf /tmp/latencyflex.tar.xz -C /tmp/latencyflex && \
    rm -f /tmp/latencyflex.tar.xz && \
    cp -r /tmp/latencyflex/wine/usr/lib/wine/* /usr/lib64/wine/ && \
    rm -rf /tmp/latencyflex && \
    curl -Lo /usr/bin/latencyflex https://raw.githubusercontent.com/KyleGospo/LatencyFleX-Installer/main/install.sh && \
    chmod +x /usr/bin/latencyflex && \
    sed -i 's@/usr/lib/wine/@/usr/lib64/wine/@g' /usr/bin/latencyflex && \
    sed -i 's@"dxvk.conf"@"/usr/share/latencyflex/dxvk.conf"@g' /usr/bin/latencyflex && \
    chmod +x /usr/bin/latencyflex && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
    dnf5 install -y \
    qt \
    krdp \
    steamdeck-kde-presets-desktop \
    wallpaper-engine-kde-plugin \
    kdeconnectd \
    kdeplasma-addons \
    rom-properties-kf6 \
    joystickwake \
    fcitx5-mozc \
    fcitx5-chinese-addons \
    fcitx5-hangul \
    kcm-fcitx5 \
    ptyxis && \
    dnf5 remove -y \
    plasma-welcome \
    plasma-welcome-fedora \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
    kf6-kio-core kf6-kio-core \
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 --branch main /tmp/wallpaper-engine-kde-plugin && \
    kpackagetool6 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin && \
    rm -rf /tmp/wallpaper-engine-kde-plugin && \
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:steam.desktop,applications:net.lutris.Lutris.desktop,applications:org.gnome.Ptyxis.desktop,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,steam.desktop,net.lutris.Lutris.desktop,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,org.gnome.Ptyxis.desktop,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
    sed -i 's@\[Desktop Action new-window\]@\[Desktop Action new-window\]\nX-KDE-Shortcuts=Ctrl+Alt+T@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
    sed -i '/^Comment/d' /usr/share/applications/org.gnome.Ptyxis.desktop && \
    sed -i 's@Exec=ptyxis@Exec=kde-ptyxis@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
    sed -i 's@Keywords=@Keywords=konsole;console;@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
    cp /usr/share/applications/org.gnome.Ptyxis.desktop /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.konsole.desktop && \
    rm -f /usr/share/kglobalaccel/org.kde.konsole.desktop && \
    setcap 'cap_net_raw+ep' /usr/libexec/ksysguard/ksgrd_network_helper \
    ; else \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
    gnome-shell gnome-shell && \
    dnf5 install -y \
    nautilus-gsconnect \
    steamdeck-backgrounds \
    gnome-randr-rust \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-compiz-windows-effect \
    gnome-shell-extension-compiz-alike-magic-lamp-effect \
    gnome-shell-extension-just-perfection \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-hanabi \
    gnome-shell-extension-gamerzilla \
    gnome-shell-extension-bazzite-menu \
    gnome-shell-extension-hotedge \
    gnome-shell-extension-caffeine \
    rom-properties-gtk3 \
    ibus-mozc \
    openssh-askpass && \
    dnf5 remove -y \
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
    rm -rf /tmp/tilingshell && \
    systemctl enable dconf-update.service \
    ; fi && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Homebrew
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp
    touch /.dockerenv && \
    mkdir -p /var/home && \
    mkdir -p /var/roothome && \
    curl -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh && \
    chmod +x /tmp/brew-install && \
    /tmp/brew-install && \
    tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew && \
    curl -Lo /usr/share/bash-prexec https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh &&\
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Cleanup & Finalize
COPY system_files/overrides /
RUN rm -f /etc/profile.d/toolbox.sh && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    cp --no-dereference --preserve=links /usr/lib/libdrm.so.2 /usr/lib/libdrm.so && \
    cp --no-dereference --preserve=links /usr/lib64/libdrm.so.2 /usr/lib64/libdrm.so && \
    sed -i 's@/usr/bin/steam@/usr/bin/bazzite-steam@g' /usr/share/applications/steam.desktop && \
    echo "Replace steam BPM shortcut action" && \
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
    echo "Running error test for Bazzite Desktop gschema override. Aborting if failed." && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    echo "Compiling gschema to include Bazzite Desktop setting overrides" && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    coprs=() && \
    mapfile -t coprs <<<"$(find /etc/yum.repos.d/_copr*.repo)" && \
    for copr in "${coprs[@]}"; do \
    sed -i 's@enabled=1@enabled=0@g' "$copr" \
    ; done && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-steam.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-rar.repo && \
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
    /usr/libexec/containerbuild/image-info && \
    /usr/libexec/containerbuild/build-initramfs && \
    /usr/libexec/containerbuild/cleanup.sh && \
    mkdir -p /var/tmp && \
    chmod 1777 /var/tmp && \
    ostree container commit

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
RUN for copr in \
    ublue-os/akmods
    kylegospo/bazzite \
    kylegospo/bazzite-multilib \
    kylegospo/latencyflex \
    kylegospo/obs-vkcapture \
    kylegospo/wallpaper-engine-kde-plugin \
    hhd-dev/hhd \
    ycollet/audinux \
    ; do \
    dnf5 -y copr enable $copr \
    ; done && \
    dnf5 remove -y \
        jupiter-sd-mounting-btrfs && \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        dnf5 swap -y \
            steamdeck-kde-presets-desktop steamdeck-kde-presets \
    ; else \
        dnf5 install -y \
            steamdeck-gnome-presets \
            gnome-shell-extension-caribou-blocker \
            sddm \
    ; fi && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install new packages
# Dock updater - done manually due to proprietary parts preventing it from being on Copr
# Neptune firmware - done manually due to "TBD" license on needed audio firmware
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 install -y \
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
    rm -rf /tmp/jupiter-dock-updater-bin && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install Steam Deck patched UPower, remove Tuned GUI
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
        upower upower && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install Gamescope Session & Supporting changes
# Add bootstrap_steam.tar.gz used by gamescope-session (Thanks GE & Nobara Project!)
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    mkdir -p /usr/share/gamescope-session-plus/ && \
    curl -Lo /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz && \
    dnf5 install -y \
        gamescope-session-plus \
        gamescope-session-steam && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Cleanup & Finalize
RUN /usr/libexec/containerbuild/image-info && \
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
    coprs=() && \
    mapfile -t coprs <<<"$(find /etc/yum.repos.d/_copr*.repo)" && \
    for copr in "${coprs[@]}"; do \
    sed -i 's@enabled=1@enabled=0@g' "$copr" \
    ; done && \
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
    echo "Running error test for Bazzite Deck gschema override. Aborting if failed." && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    echo "Compiling gschema to include Bazzite Deck setting overrides" && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    echo "Removing Steam BPM workaround .desktop file" && \
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
    /usr/libexec/containerbuild/cleanup.sh && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    ostree container commit

################
# NVIDIA BUILDS
################

FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS nvidia-akmods

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
    dnf5 remove -y \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install NVIDIA driver
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=bind,from=nvidia-akmods,src=/rpms,dst=/tmp/akmods-rpms \
    dnf5 config-manager setopt fedora-multimedia.enabled=1 && \
    dnf5 install -y \
        mesa-vdpau-drivers.x86_64 \
        mesa-vdpau-drivers.i686 && \
    curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/main/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    sed -i "s/rpm-ostree install/dnf install -y/" /tmp/nvidia-install.sh && \
    IMAGE_NAME="${BASE_IMAGE_NAME}" /tmp/nvidia-install.sh && \
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
    ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Cleanup & Finalize
RUN echo "import \"/usr/share/ublue-os/just/95-bazzite-nvidia.just\"" >> /usr/share/ublue-os/justfile && \
    dnf5 config-manager setopt fedora-multimedia.enabled=0 && \
    if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
      mkdir -p "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
      cp "/usr/share/glib-2.0/schemas/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" "/usr/share/ublue-os/dconfs/nvidia-silverblue/" && \
      dconf-override-converter to-dconf "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" && \
      rm "/usr/share/ublue-os/dconfs/nvidia-silverblue/zz0-"*"-bazzite-nvidia-silverblue-"*".gschema.override" \
    ; fi && \
    mkdir -p /tmp/bazzite-schema-test && \
    find "/usr/share/glib-2.0/schemas/" -type f ! -name "*.gschema.override" -exec cp {} "/tmp/bazzite-schema-test/" \; && \
    cp "/usr/share/glib-2.0/schemas/zz0-"*".gschema.override" "/tmp/bazzite-schema-test/" && \
    echo "Running error test for Bazzite Nvidia gschema override. Aborting if failed." && \
    glib-compile-schemas --strict /tmp/bazzite-schema-test && \
    echo "Compiling gschema to include Bazzite Nvidia setting overrides" && \
    glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null && \
    rm -r /tmp/bazzite-schema-test && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    /usr/libexec/containerbuild/image-info && \
    /usr/libexec/containerbuild/build-initramfs && \
    /usr/libexec/containerbuild/cleanup.sh && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    ostree container commit
