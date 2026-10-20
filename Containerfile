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
ARG FEDORA_VERSION="${FEDORA_VERSION:-45}"
ARG ARCH="${ARCH:-x86_64}"

ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-ogc}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-7.0.9-ogc3.2.fc${FEDORA_VERSION}.${ARCH}}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia-open}"
ARG FINAL_STAGE="${FINAL_STAGE:-bazzite}"

FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-nvidia
FROM ghcr.io/ublue-os/brew:latest@sha256:393b567da078f0f0638450c388e229011dae06f94a90017cb7525b57d9faa46e AS brew

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
ARG FEDORA_VERSION="${FEDORA_VERSION:-45}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

# Copy Homebrew files from the brew image
COPY --from=brew /system_files/ /tmp/brew_files/
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/bazzite/copy-brew-files

COPY system_files/desktop/shared/ system_files/desktop/${BASE_IMAGE_NAME}/ /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,src=firmware,dst=/ctx/firmware,relabel=shared \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms/common,dst=/tmp/rpms/common \
    --mount=type=bind,from=akmods,src=/rpms/kmods,dst=/tmp/rpms/kmods \
    --mount=type=bind,from=akmods-extra,src=/rpms/extra,dst=/tmp/rpms/extra \
    --mount=type=bind,from=akmods-extra,src=/rpms/kmods,dst=/tmp/rpms/kmods-extra \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite/install-nonfree-firmware-blobs \
    && /ctx/bazzite/install-kernel-akmods \
    && /ctx/bazzite/initialize \
    && /ctx/bazzite/valve-patches \
    && /ctx/bazzite/global-remove \
    && /ctx/bazzite/install-packages \
    && /ctx/bazzite/install-steam-lutris \
    && /ctx/bazzite/install-ujust-picker \
    && /ctx/bazzite/configure-desktops \
    && /ctx/bazzite/ublue-os-media-automount-udev \
    && /ctx/bazzite/finalize-image-type \
    && /ctx/reset-mtimes

# Copy overrides
COPY system_files/overrides /

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
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite-deck/configure-desktop \
    && /ctx/bazzite-deck/install-patched-upower \
    && /ctx/bazzite-deck/install-packages \
    && /ctx/bazzite-deck/install-gamescope-session \
    && /ctx/bazzite-deck/finalize-image-type \
    && /ctx/reset-mtimes

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

COPY system_files/nvidia/shared system_files/nvidia/${BASE_IMAGE_NAME} /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/nvidia \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/bazzite-nvidia/remove-nvidia-conflicts \
    && /ctx/bazzite-nvidia/install-nvidia-driver \
    && /ctx/bazzite-nvidia/finalize-image-type \
    && /ctx/reset-mtimes


################
# FINALIZE & CLEANUP
################

FROM ${FINAL_STAGE}

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite-deck}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/image-info \
    && /ctx/build-initramfs \
    && /ctx/finalize \
    && /ctx/cleanup

RUN --mount=type=tmpfs,target=/run \
    --network=none \
    bootc container lint
