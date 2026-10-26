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
#
# If you choose to fork this repo, see the
# build_files folder for relevant build
# scripts.

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-45}"
ARG ARCH="${ARCH:-x86_64}"

ARG BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}}"
ARG NVIDIA_BASE="${NVIDIA_BASE:-bazzite}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-ogc}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-7.0.9-ogc3.2.fc${FEDORA_VERSION}.${ARCH}}"
ARG NVIDIA_FLAVOR="${NVIDIA_FLAVOR:-nvidia-open}"
ARG BUILD_DECK="FALSE"
ARG BUILD_NVIDIA="FALSE"

FROM ${BASE_IMAGE} AS base-image
FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-extra
FROM ghcr.io/ublue-os/akmods-${NVIDIA_FLAVOR}:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-nvidia
FROM ghcr.io/ublue-os/brew:latest@sha256:c201bc801e4828849e8e36c4adcb5c0f38d35ac3ff9546a0ecab0fd2beabf51f AS brew

FROM scratch AS ctx
COPY build_files /

FROM scratch AS system_files
COPY system_files /

FROM base-image AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_VERSION="${FEDORA_VERSION:-45}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"
ARG NVIDIA_FLAVOR
ARG BUILD_DECK
ARG BUILD_NVIDIA

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,src=firmware,dst=/ctx/firmware,relabel=shared \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods,src=/rpms/common,dst=/tmp/rpms/common \
    --mount=type=bind,from=akmods,src=/rpms/kmods,dst=/tmp/rpms/kmods \
    --mount=type=bind,from=akmods-extra,src=/rpms/extra,dst=/tmp/rpms/extra \
    --mount=type=bind,from=akmods-extra,src=/rpms/kmods,dst=/tmp/rpms/kmods-extra \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/nvidia \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=brew,source=/system_files,target=/tmp/brew_files \
    --mount=type=bind,from=system_files,source=/,target=/tmp/system_files \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=GITHUB_TOKEN \
    /ctx/build

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
