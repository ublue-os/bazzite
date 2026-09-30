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
    /ctx/bazzite/install-kernel-akmods

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
    /ctx/bazzite-deck/setup-copr-repos

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite-deck/configure-desktop

# Install new packages
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite-deck/install-packages

# Install Steam Deck patched UPower
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite-deck/install-patched-upower

# Install Gamescope Session Supporting changes
# Add bootstrap_steam.tar.gz used by gamescope-session (Thanks GE & Nobara Project!)
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite-deck/install-gamescope-session

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite-deck/cleanup-finalize

RUN --mount=type=tmpfs,target=/run \
    --network=none \
    bootc container lint

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
    /ctx/bazzite-nvidia/remove-nvidia-conflicts

# Install NVIDIA driver
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/nvidia \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite-nvidia/install-nvidia-driver

# Cleanup & Finalize
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/bazzite-nvidia/cleanup-and-finalize

RUN --mount=type=tmpfs,target=/run \
    --network=none \
    bootc container lint
