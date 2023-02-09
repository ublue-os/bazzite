ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ghcr.io/ublue-os/kinoite-nvidia:latest

COPY etc /etc
COPY usr /usr
RUN mkdir -p /var/lib/duperemove && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-info && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice && \
ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

# Re-enable RPMFusion Repos
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-free{,-updates}.repo

# Add needed Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Install new packages
RUN rpm-ostree install \
distrobox \
steam \
steam-devices \
gamescope \
gamescope-session \
jupiter-fan-control \
jupiter-hw-support-btrfs \
steamdeck-kde-presets \
gamemode \
latencyflex-vulkan-layer \
vkBasalt \
mangohud \
duperemove \
kdeconnectd \
btop \
fish \
kate
# $(rpm -qa --qf "%{NAME} ")
# The above prints every package installed, this acts similarly to rpm-ostree update when making an OCI image and resolves issues with installing Steam

# Install dock updater, this is done manually as it has proprietary parts and cannot be built in Copr.
RUN git clone https://github.com/KyleGospo/jupiter-dock-updater-bin.git && \
mv -v jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater

# Remove unneeded packages
RUN rpm-ostree override remove toolbox

# Install mesa freeworld components and ffmpeg for hardware accelerated video decode
RUN rpm-ostree override remove \
mesa-va-drivers \
libavutil-free \
libswscale-free \
libswresample-free \
libavformat-free \
libavcodec-free \
libavfilter-free \
libpostproc-free \
--install=mesa-va-drivers-freeworld.x86_64 \
--install=mesa-va-drivers-freeworld.i686 \
--install=mesa-vdpau-drivers-freeworld \
--install=ffmpeg-libs \
--install=ffmpeg \
--install=libavcodec-freeworld

# Cleanup & Finalize
RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree{,-updates}.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-free{,-updates}.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    rpm-ostree cleanup -m && \
    rm -rf \
    /tmp/* \
    /var/* && \
    ostree container commit
