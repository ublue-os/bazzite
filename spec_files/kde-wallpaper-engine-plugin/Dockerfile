FROM fedora:44@sha256:e610aabae07cf173f3fab7acfeb194cf348ec7af0cc299a79a279afec9a3b4b7

RUN dnf install -y \
    vulkan-loader-devel \
    plasma-workspace-devel \
    libplasma-devel \
    gstreamer1-plugin-libav \
    lz4-devel \
    mpv-libs-devel \
    python3-websockets \
    qt6-qtbase-private-devel \
    qt6-qtwebsockets-devel \
    qt6-qtwebchannel-devel \
    git \
    cmake \
    extra-cmake-modules \
    kf6-rpm-macros \
    fedpkg \
    rpkg \
    cmake \
    extra-cmake-modules \
    git \
    gstreamer1-plugin-libav \
    kf6-rpm-macros \
    libplasma-devel \
    lz4-devel \
    mpv-libs-devel \
    plasma-workspace-devel \
    python3-websockets \
    qt6-qtbase-private-devel \
    qt6-qtwebchannel-devel \
    qt6-qtwebsockets-devel \
    vulkan-loader-devel \
    && dnf clean all

WORKDIR /workspace