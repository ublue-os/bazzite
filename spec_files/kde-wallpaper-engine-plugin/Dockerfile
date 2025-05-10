FROM fedora:43@sha256:752797e54c0ea10dc7afa3e1d475e9bcab1bcef30e2b2eb4d27ab9f507ed02db

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