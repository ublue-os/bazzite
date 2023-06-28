ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY system_files/desktop/etc /etc
COPY system_files/desktop/usr /usr

# Add Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/repo/fedora-$(rpm -E %fedora)/kylegospo-hl2linux-selinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo

# Install ROCM for non-Nvidia images
RUN if [[ "-nvidia" !== "${IMAGE_FLAVOR}" ]]; then rpm-ostree install \
    rocm-hip \
    rocm-opencl \
    ; fi

# Install new packages
RUN rpm-ostree install \
    python3-pip \
    libadwaita \
    distrobox \
    steamdeck-kde-themes \
    sddm-sugar-steamOS \
    wallpaper-engine-kde-plugin \
    duperemove \
    kdeconnectd \
    input-remapper \
    system76-scheduler \
    hl2linux-selinux \
    btop \
    fish \
    python3-pip

# Remove unneeded packages
RUN rpm-ostree override remove \
    firefox \
    firefox-langpacks \
    plasma-welcome \
    toolbox

# Run firstboot script per-profile
RUN mkdir -p "/usr/etc/profile.d/"
RUN ln -s "/usr/share/ublue-os/firstboot/launcher/login-profile.sh" \
    "/usr/etc/profile.d/ublue-firstboot.sh"

# Cleanup & Finalize
RUN pip install --prefix=/usr yafti && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable input-remapper.service && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/lib/duperemove && \
    ostree container commit && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp

FROM bazzite as bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

# Add LatencyFleX Copr
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O \
    /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Re-enable Copr repos
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo

# Remove system76-scheduler
RUN rpm-ostree override remove system76-scheduler
RUN rm -f /usr/bin/system76-scheduler-dbus-proxy.sh

# Remove steamdeck-kde-themes
RUN rpm-ostree override remove steamdeck-kde-themes

COPY system_files/deck/etc /etc
COPY system_files/deck/usr /usr
RUN ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
    ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

# Install mesa-va-drivers shim (Needed due to dependency issues in Steam package)
RUN rpm-ostree install \
    mesa-va-drivers

# Install new packages
RUN rpm-ostree install \
    steam \
    gamescope \
    gamescope-session \
    jupiter-fan-control \
    jupiter-hw-support-btrfs \
    steamdeck-kde-presets \
    ryzenadj \
    gamemode \
    latencyflex-vulkan-layer \
    vkBasalt \
    mangohud \
    skopeo

# Install dock updater, this is done manually due to proprietary parts preventing it from being on Copr.
RUN git clone https://github.com/KyleGospo/jupiter-dock-updater-bin.git && \
    mv -v jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater

# Suspend using power button
RUN sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' /etc/systemd/logind.conf

# Cleanup & Finalize
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo && \
    systemctl enable set-cfs-tweaks.service && \
    systemctl enable gamescope-autologin.service && \
    systemctl disable input-remapper.service && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/lib/duperemove && \
    ostree container commit
