#!/usr/bin/bash

set -euo pipefail

WINE_VERSION="${WINE_VERSION:-11.5}"
WINE_SOURCE_SHA256="${WINE_SOURCE_SHA256:-11370b57ea5d548a54d92c9cd65d0ba635f4f1c3eadace09ed1c419f705e19d1}"
WINE_SOURCE_SERIES="${WINE_VERSION%%.*}.x"
WINE_SOURCE_URL="https://dl.winehq.org/wine/source/${WINE_SOURCE_SERIES}/wine-${WINE_VERSION}.tar.xz"
LLVM_MINGW_VERSION="${LLVM_MINGW_VERSION:-20260324}"
LLVM_MINGW_ARCHIVE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-aarch64.tar.xz"
LLVM_MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/${LLVM_MINGW_ARCHIVE}"
LLVM_MINGW_SHA256="${LLVM_MINGW_SHA256:-d28db713552e9d92699081b573a5b7c543d1d8095ed0d1c15dba184bf6e51440}"

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Native Wine installation is only supported on aarch64 builders" >&2
    exit 1
fi

runtime_packages=(
    SDL2
    cups-libs
    freetype
    gnutls
    gstreamer1
    gstreamer1-plugins-base
    libXcomposite
    libXcursor
    libXinerama
    libXrandr
    libXrender
    libpcap
    libpng
    libv4l
    mesa-dri-drivers
    nss-mdns
    pulseaudio-libs
    sane-backends-libs
    unixODBC
    vulkan-loader
)

build_packages=(
    SDL2-devel
    alsa-lib-devel
    audiofile-devel
    autoconf
    bison
    clang
    cups-devel
    dbus-devel
    flex
    fontconfig-devel
    fontforge
    fontpackages-devel
    freetype-devel
    freeglut-devel
    gettext-devel
    giflib-devel
    gnutls-devel
    gsm-devel
    gstreamer1-devel
    gstreamer1-plugins-base-devel
    icoutils
    lld
    libX11-devel
    libXcomposite-devel
    libXcursor-devel
    libXext-devel
    libXi-devel
    libXinerama-devel
    libXrandr-devel
    libXrender-devel
    libXxf86dga-devel
    libXxf86vm-devel
    libappstream-glib
    libglvnd-devel
    libgphoto2-devel
    libieee1284-devel
    libpcap-devel
    librsvg2-devel
    libstdc++-devel
    libunwind-devel
    libv4l-devel
    libxkbcommon-devel
    make
    mesa-libGL-devel
    mesa-libGLU-devel
    ocl-icd-devel
    opencl-headers
    openldap-devel
    pcsc-lite-devel
    pulseaudio-libs-devel
    sane-backends-devel
    systemd-devel
    unixODBC-devel
    vulkan-devel
    wayland-devel
    'pkgconfig(libusb-1.0)'
)

optional_runtime_packages=(
    mingw64-wine-gecko
)

build_root="$(mktemp -d /var/tmp/bazzite-wine-aarch64.XXXXXX)"
source_tarball="${build_root}/wine-${WINE_VERSION}.tar.xz"
source_dir="${build_root}/wine-${WINE_VERSION}"
build_dir="${build_root}/build"
llvm_mingw_tarball="${build_root}/${LLVM_MINGW_ARCHIVE}"
llvm_mingw_dir="${build_root}/${LLVM_MINGW_ARCHIVE%.tar.xz}"

cleanup() {
    rm -rf "${build_root}"
}
trap cleanup EXIT

# Upgrade first so glibc and all virtual provides are current before
# installing Wine's deps. This prevents "rtld(GNU_HASH) is needed by ..."
# errors caused by stale package metadata in the base image.
# --skip-broken: skip unresolvable packages (e.g. unixODBC with missing
#   linux-aarch64.so.1 VDSO dep, or any other single-package breakage)
# --exclude=mesa*: never let standard Fedora repos replace the Asahi COPR
#   mesa packages -- that would break the Apple Silicon AGX GPU driver
dnf5 -y upgrade --refresh --skip-broken --skip-unavailable --exclude='mesa*'

dnf5 -y install --setopt=install_weak_deps=False \
    --skip-broken --skip-unavailable "${runtime_packages[@]}"
dnf5 -y install --setopt=install_weak_deps=False \
    --skip-broken --skip-unavailable "${build_packages[@]}"
dnf5 -y install --setopt=install_weak_deps=False \
    --skip-broken --skip-unavailable "${optional_runtime_packages[@]}" || true

mkdir -p /usr/local/bin
if command -v llvm-dlltool >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool)" /usr/local/bin/dlltool
elif command -v llvm-dlltool-20 >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool-20)" /usr/local/bin/dlltool
else
    curl -LfsS --retry 5 --retry-delay 2 "${LLVM_MINGW_URL}" -o "${llvm_mingw_tarball}"
    echo "${LLVM_MINGW_SHA256}  ${llvm_mingw_tarball}" | sha256sum -c -
    tar -xf "${llvm_mingw_tarball}" -C "${build_root}"
    export PATH="${llvm_mingw_dir}/bin:${PATH}"
    ln -sf "${llvm_mingw_dir}/bin/llvm-dlltool" /usr/local/bin/dlltool
fi

curl -LfsS --retry 5 --retry-delay 2 "${WINE_SOURCE_URL}" -o "${source_tarball}"
echo "${WINE_SOURCE_SHA256}  ${source_tarball}" | sha256sum -c -

tar -xf "${source_tarball}" -C "${build_root}"
mkdir -p "${build_dir}"

sed -i 's/-Wl,-WX//g' "${source_dir}/configure"

export CC=clang
export CXX=clang++
export LD=ld.lld
export PKG_CONFIG_PATH=""

jobs="$(nproc)"
if (( jobs > 8 )); then
    jobs=8
elif (( jobs < 2 )); then
    jobs=2
fi

pushd "${build_dir}" >/dev/null
"${source_dir}/configure" \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc/wine \
    --x-includes=/usr/include \
    --x-libraries=/usr/lib64 \
    --with-dbus \
    --with-x \
    --enable-win64 \
    --disable-tests
make -j"${jobs}" TARGETFLAGS=""
make install
popd >/dev/null

# A number of tools still probe for wine64/wineserver64 on 64-bit systems.
ln -sf /usr/bin/wine /usr/bin/wine64
ln -sf /usr/bin/wineserver /usr/bin/wineserver64

mkdir -p /usr/share/bazzite
cat > /usr/share/bazzite/wine-aarch64-version <<EOF
WINE_VERSION=${WINE_VERSION}
WINE_SOURCE_URL=${WINE_SOURCE_URL}
EOF

/usr/bin/wine --version | grep -Fx "wine-${WINE_VERSION}"

dnf5 -y remove \
    "${build_packages[@]}" || true

/ctx/cleanup
