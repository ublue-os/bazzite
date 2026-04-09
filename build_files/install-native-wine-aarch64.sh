#!/usr/bin/bash

set -euo pipefail

if [[ "${SKIP_WINE:-0}" == "1" ]]; then
    echo "Skipping native Wine aarch64 build (SKIP_WINE=1)."
    exit 0
fi

WINE_VERSION="${WINE_VERSION:-}"
WINE_SOURCE_SERIES="${WINE_SOURCE_SERIES:-}"
WINE_SOURCE_URL="${WINE_SOURCE_URL:-}"
WINE_SOURCE_SHA512="${WINE_SOURCE_SHA512:-}"
LLVM_MINGW_VERSION="${LLVM_MINGW_VERSION:-}"
LLVM_MINGW_ARCHIVE="${LLVM_MINGW_ARCHIVE:-}"
LLVM_MINGW_URL="${LLVM_MINGW_URL:-}"
LLVM_MINGW_SHA256="${LLVM_MINGW_SHA256:-}"

WINE_TAGS_API="https://gitlab.winehq.org/api/v4/projects/wine%2Fwine/repository/tags?per_page=100"
LLVM_MINGW_RELEASES_API="https://api.github.com/repos/mstorsjo/llvm-mingw/releases"

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Native Wine installation is only supported on aarch64 builders" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to resolve the latest Wine/llvm-mingw releases" >&2
    exit 1
fi

runtime_packages=(
    OpenCL-ICD-Loader
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
    pulseaudio-libs
    vulkan-loader
)

build_packages=(
    SDL2-devel
    alsa-lib-devel
    autoconf
    bison
    clang
    cups-devel
    dbus-devel
    flex
    fontconfig-devel
    freetype-devel
    freeglut-devel
    gettext-devel
    giflib-devel
    gnutls-devel
    gstreamer1-devel
    gstreamer1-plugins-base-devel
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
    libglvnd-devel
    libpcap-devel
    librsvg2-devel
    libstdc++-devel
    libunwind-devel
    libxkbcommon-devel
    make
    mesa-libGL-devel
    OpenCL-ICD-Loader-devel
    opencl-headers
    openldap-devel
    pcsc-lite-devel
    pulseaudio-libs-devel
    systemd-devel
    vulkan-devel
    wayland-devel
    'pkgconfig(libusb-1.0)'
)

optional_runtime_packages=(
    unixODBC
    nss-mdns
    sane-backends-libs
    libv4l
    samba-client-libs
    samba-libs
    libavcodec-free
    libavformat-free
    libavutil-free
    libswresample-free
    libswscale-free
)

optional_build_packages=(
    unixODBC-devel
    sane-backends-devel
    libgphoto2-devel
    libieee1284-devel
    gsm-devel
    libv4l-devel
    ffmpeg-free-devel
    samba-devel
    mesa-libGLU-devel
)

build_root=""
odbc_enabled=0

cleanup() {
    if [[ -n "${build_root}" ]]; then
        rm -rf "${build_root}"
    fi
}
trap cleanup EXIT

remove_installed_packages() {
    local installed_package
    local package
    local query_output
    local -A installed_packages=()

    for package in "$@"; do
        if query_output="$(rpm -q --whatprovides --qf '%{NAME}\n' "${package}" 2>/dev/null)"; then
            while IFS= read -r installed_package; do
                [[ -n "${installed_package}" ]] || continue
                installed_packages["${installed_package}"]=1
            done <<< "${query_output}"
        fi
    done

    if (( ${#installed_packages[@]} > 0 )); then
        dnf5 -y remove "${!installed_packages[@]}"
    fi
}

install_optional_packages() {
    local description="$1"
    shift

    if dnf5 -y install --refresh --best --allowerasing --nogpgcheck --setopt=install_weak_deps=False "$@"; then
        return 0
    fi

    echo "Optional ${description} packages could not be installed; continuing without ${description} support." >&2
    dnf5 -y remove "$@" >/dev/null 2>&1 || true
    return 1
}

refresh_dnf_metadata() {
    dnf5 clean all >/dev/null 2>&1 || true
    rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

install_required_packages() {
    local description="$1"
    shift

    if dnf5 -y install --refresh --best --allowerasing --nogpgcheck --setopt=install_weak_deps=False "$@"; then
        return 0
    fi

    echo "${description} install failed; cleaning metadata, syncing the base image, and retrying once." >&2
    refresh_dnf_metadata
    dnf5 -y distro-sync --refresh --best --allowerasing --nogpgcheck --exclude='mesa*'
    dnf5 -y install --refresh --best --allowerasing --nogpgcheck --setopt=install_weak_deps=False "$@"
}

resolve_wine_source() {
    local sha512_manifest_url
    local wine_tag

    if [[ -z "${WINE_VERSION}" && -n "${WINE_SOURCE_URL}" ]]; then
        if [[ "${WINE_SOURCE_URL}" =~ /wine-([0-9]+\.[0-9]+)\.tar\.xz$ ]]; then
            WINE_VERSION="${BASH_REMATCH[1]}"
        else
            echo "Unable to infer WINE_VERSION from ${WINE_SOURCE_URL}" >&2
            exit 1
        fi
    fi

    if [[ -z "${WINE_VERSION}" ]]; then
        wine_tag="$(
            curl -LfsS --retry 5 --retry-delay 2 "${WINE_TAGS_API}" |
                jq -r 'first(.[] | .name | select(test("^wine-[0-9]+\\.[0-9]+$"))) // empty'
        )"

        if [[ -z "${wine_tag}" ]]; then
            echo "Unable to resolve the latest Wine release tag from ${WINE_TAGS_API}" >&2
            exit 1
        fi

        WINE_VERSION="${wine_tag#wine-}"
    fi

    WINE_SOURCE_SERIES="${WINE_SOURCE_SERIES:-${WINE_VERSION%%.*}.x}"
    WINE_SOURCE_URL="${WINE_SOURCE_URL:-https://dl.winehq.org/wine/source/${WINE_SOURCE_SERIES}/wine-${WINE_VERSION}.tar.xz}"

    if [[ -z "${WINE_SOURCE_SHA512}" ]]; then
        sha512_manifest_url="https://dl.winehq.org/wine/source/${WINE_SOURCE_SERIES}/sha512sums.asc"
        WINE_SOURCE_SHA512="$(
            curl -LfsS --retry 5 --retry-delay 2 "${sha512_manifest_url}" |
                awk -v source_name="wine-${WINE_VERSION}.tar.xz" '$2 == source_name { print $1; exit }'
        )"

        if [[ -z "${WINE_SOURCE_SHA512}" ]]; then
            echo "Unable to resolve SHA-512 for wine-${WINE_VERSION}.tar.xz from ${sha512_manifest_url}" >&2
            exit 1
        fi
    fi

    echo "Resolved Wine ${WINE_VERSION} from ${WINE_SOURCE_URL}"
}

resolve_llvm_mingw_release() {
    local digest
    local release_api
    local release_json

    if [[ -z "${LLVM_MINGW_VERSION}" && -n "${LLVM_MINGW_ARCHIVE}" ]]; then
        if [[ "${LLVM_MINGW_ARCHIVE}" =~ ^llvm-mingw-([0-9]+)- ]]; then
            LLVM_MINGW_VERSION="${BASH_REMATCH[1]}"
        else
            echo "Unable to infer LLVM_MINGW_VERSION from ${LLVM_MINGW_ARCHIVE}" >&2
            exit 1
        fi
    fi

    if [[ -n "${LLVM_MINGW_VERSION}" ]]; then
        release_api="${LLVM_MINGW_RELEASES_API}/tags/${LLVM_MINGW_VERSION}"
    else
        release_api="${LLVM_MINGW_RELEASES_API}/latest"
    fi

    if [[ -z "${LLVM_MINGW_VERSION}" || -z "${LLVM_MINGW_ARCHIVE}" || -z "${LLVM_MINGW_URL}" || -z "${LLVM_MINGW_SHA256}" ]]; then
        release_json="$(curl -LfsS --retry 5 --retry-delay 2 "${release_api}")"
        LLVM_MINGW_VERSION="${LLVM_MINGW_VERSION:-$(jq -r '.tag_name // empty' <<< "${release_json}")}"
        LLVM_MINGW_ARCHIVE="${LLVM_MINGW_ARCHIVE:-$(
            jq -r 'first(.assets[] | .name | select(test("^llvm-mingw-[0-9]+-ucrt-ubuntu-22\\.04-aarch64\\.tar\\.xz$"))) // empty' \
                <<< "${release_json}"
        )}"

        if [[ -z "${LLVM_MINGW_ARCHIVE}" ]]; then
            LLVM_MINGW_ARCHIVE="$(jq -r 'first(.assets[] | .name | select(test("^llvm-mingw-.*-ucrt-ubuntu-22\\.04-aarch64\\.tar\\.xz$"))) // empty' <<< "${release_json}")"
        fi

        LLVM_MINGW_URL="${LLVM_MINGW_URL:-$(jq -r --arg archive "${LLVM_MINGW_ARCHIVE}" 'first(.assets[] | select(.name == $archive) | .browser_download_url) // empty' <<< "${release_json}")}"
        digest="$(jq -r --arg archive "${LLVM_MINGW_ARCHIVE}" 'first(.assets[] | select(.name == $archive) | .digest) // empty' <<< "${release_json}")"
        LLVM_MINGW_SHA256="${LLVM_MINGW_SHA256:-${digest#sha256:}}"
    fi

    if [[ -z "${LLVM_MINGW_VERSION}" || -z "${LLVM_MINGW_ARCHIVE}" || -z "${LLVM_MINGW_URL}" || -z "${LLVM_MINGW_SHA256}" ]]; then
        echo "Unable to resolve latest llvm-mingw aarch64 metadata from ${release_api}" >&2
        exit 1
    fi

    echo "Resolved llvm-mingw ${LLVM_MINGW_VERSION} from ${LLVM_MINGW_URL}"
}

resolve_wine_source
resolve_llvm_mingw_release

build_root="$(mktemp -d /var/tmp/bazzite-wine-aarch64.XXXXXX)"
tool_bin="${build_root}/bin"
source_tarball="${build_root}/wine-${WINE_VERSION}.tar.xz"
source_dir="${build_root}/wine-${WINE_VERSION}"
build_dir="${build_root}/build"
llvm_mingw_tarball="${build_root}/${LLVM_MINGW_ARCHIVE}"
llvm_mingw_dir="${build_root}/${LLVM_MINGW_ARCHIVE%.tar.xz}"

# Upgrade first so the build root is current before installing Wine's deps.
# Prefer a normal upgrade first and fall back to distro-sync only if the solver
# cannot complete a straightforward upgrade on the current base image.
# --exclude=mesa*: never let standard Fedora repos replace the Asahi COPR
#   mesa packages -- that would break the Apple Silicon AGX GPU driver
if ! dnf5 -y upgrade --refresh --nogpgcheck --skip-unavailable --exclude='mesa*'; then
    echo "dnf5 upgrade failed; retrying with distro-sync --skip-broken."
    dnf5 -y distro-sync --refresh --nogpgcheck --skip-broken --skip-unavailable --exclude='mesa*'
fi

required_packages=(
    "${runtime_packages[@]}"
    "${build_packages[@]}"
)

install_required_packages "Wine runtime/build dependency" "${required_packages[@]}"

if install_optional_packages "ODBC runtime" "${optional_runtime_packages[@]}" &&
    install_optional_packages "ODBC build" "${optional_build_packages[@]}"; then
    odbc_enabled=1
else
    remove_installed_packages "${optional_build_packages[@]}" "${optional_runtime_packages[@]}"
fi

mkdir -p "${tool_bin}"
export PATH="${tool_bin}:${PATH}"
if command -v llvm-dlltool >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool)" "${tool_bin}/dlltool"
elif command -v llvm-dlltool-20 >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool-20)" "${tool_bin}/dlltool"
else
    curl -LfsS --retry 5 --retry-delay 2 "${LLVM_MINGW_URL}" -o "${llvm_mingw_tarball}"
    echo "${LLVM_MINGW_SHA256}  ${llvm_mingw_tarball}" | sha256sum -c -
    tar -xf "${llvm_mingw_tarball}" -C "${build_root}"
    export PATH="${llvm_mingw_dir}/bin:${PATH}"
    ln -sf "${llvm_mingw_dir}/bin/llvm-dlltool" "${tool_bin}/dlltool"
fi

curl -LfsS --retry 5 --retry-delay 2 "${WINE_SOURCE_URL}" -o "${source_tarball}"
echo "${WINE_SOURCE_SHA512}  ${source_tarball}" | sha512sum -c -

tar -xf "${source_tarball}" -C "${build_root}"
mkdir -p "${build_dir}"

sed -i 's/-Wl,-WX//g' "${source_dir}/configure"

export CC=clang
export CXX=clang++
export LD=ld.lld
export PKG_CONFIG_PATH=""

jobs="$(nproc)"
# Use all available CPUs for the Wine compilation.
# nproc reflects the actual hardware thread count on the build machine
# (e.g. 16 on an M2 Max) so there is no reason to artificially cap it.
# Keep a floor of 2 so the build still works on minimal VMs.
if (( jobs < 2 )); then
    jobs=2
fi

configure_args=(
    --prefix=/usr
    --libdir=/usr/lib64
    --sysconfdir=/etc/wine
    --x-includes=/usr/include
    --x-libraries=/usr/lib64
    --with-dbus
    --with-x
    --enable-win64
    --disable-tests
)

pushd "${build_dir}" >/dev/null
"${source_dir}/configure" "${configure_args[@]}"
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
WINE_ODBC_ENABLED=${odbc_enabled}
EOF

/usr/bin/wine --version | grep -Fx "wine-${WINE_VERSION}"

remove_installed_packages "${build_packages[@]}"
remove_installed_packages "${optional_build_packages[@]}"

/ctx/cleanup
