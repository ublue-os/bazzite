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
CURL_COMMON_ARGS=(
    -LfsS
    --retry 5
    --retry-all-errors
    --retry-delay 2
    --connect-timeout 20
)

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Native Wine installation is only supported on aarch64 builders" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to resolve the latest Wine/llvm-mingw releases" >&2
    exit 1
fi

runtime_packages=(
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
    alsa-lib-devel
    autoconf
    bison
    clang
    cups-devel
    dbus-devel
    flex
    fontconfig-devel
    freetype-devel
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
    # libglvnd-devel is the real provider of libGL development headers on
    # modern Fedora. Avoid the legacy mesa-libGL-devel compatibility package
    # here because it is more sensitive to transient Mesa repo skew between
    # the Fedora base image, Asahi Mesa, and RPM Fusion mirrors.
    libglvnd-devel
    libpcap-devel
    librsvg2-devel
    libstdc++-devel
    libunwind-devel
    libxkbcommon-devel
    make
    openldap-devel
    pcsc-lite-devel
    pulseaudio-libs-devel
    systemd-devel
    vulkan-loader-devel
    vulkan-headers
    wayland-devel
    'pkgconfig(libusb-1.0)'
)

optional_compat_runtime_packages=(
    OpenCL-ICD-Loader
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

optional_odbc_runtime_packages=(
    unixODBC
)

optional_compat_build_packages=(
    OpenCL-ICD-Loader-devel
    opencl-headers
    sane-backends-devel
    libgphoto2-devel
    libieee1284-devel
    gsm-devel
    libv4l-devel
    ffmpeg-free-devel
    samba-devel
    freeglut-devel
    mesa-libGLU-devel
)

optional_odbc_build_packages=(
    unixODBC-devel
)

build_root=""
odbc_enabled=0
required_build_cleanup_list=""
optional_build_cleanup_list=""
optional_failed_cleanup_list=""
# Required Wine deps must not skip Fedora/RPM Fusion repos. A skipped repo turns
# into a misleading depsolve wall, so fail early and retry metadata once.
DNF5_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=0"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)
DNF5_INSTALL_ARGS=(
    -y
    install
    --refresh
    --allowerasing
    --nogpgcheck
    --setopt=install_weak_deps=False
    "${DNF5_STRICT_REPO_ARGS[@]}"
)
FEDORA_REPO_OVERRIDE="/etc/dnf/repos.override.d/zz-bazzite-fedora-direct.repo"
RPMDB_CHECK_QUERY=(rpm -qa --qf '%{NAME}\n')

pin_official_fedora_repos() {
    local fedora_ver

    fedora_ver="$(rpm -E %fedora)"

    mkdir -p "$(dirname "${FEDORA_REPO_OVERRIDE}")"
    cat > "${FEDORA_REPO_OVERRIDE}" <<EOF
[fedora]
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/releases/${fedora_ver}/Everything/\$basearch/os/
metalink=
mirrorlist=

[updates]
baseurl=https://dl.fedoraproject.org/pub/fedora/linux/updates/${fedora_ver}/Everything/\$basearch/
metalink=
mirrorlist=

[fedora-cisco-openh264]
baseurl=https://codecs.fedoraproject.org/openh264/${fedora_ver}/\$basearch/
metalink=
mirrorlist=

[rpmfusion-free]
baseurl=https://download1.rpmfusion.org/free/fedora/releases/${fedora_ver}/Everything/\$basearch/os/
metalink=
mirrorlist=

[rpmfusion-free-updates]
baseurl=https://download1.rpmfusion.org/free/fedora/updates/${fedora_ver}/\$basearch/
metalink=
mirrorlist=

[rpmfusion-nonfree]
baseurl=https://download1.rpmfusion.org/nonfree/fedora/releases/${fedora_ver}/Everything/\$basearch/os/
metalink=
mirrorlist=

[rpmfusion-nonfree-updates]
baseurl=https://download1.rpmfusion.org/nonfree/fedora/updates/${fedora_ver}/\$basearch/
metalink=
mirrorlist=

[updates-archive]
enabled=0

[fedora-asahi-remix-hotfixes]
enabled=0
EOF
}

print_repo_debug() {
    local rpmdb_ok=1

    if ! repair_rpmdb_if_needed "before repo debug"; then
        rpmdb_ok=0
    fi

    {
        echo "Enabled repos:"
        dnf5 repolist --enabled || true
        echo
        echo "Fedora repo configuration:"
        grep -RHE '^\[|^baseurl=|^metalink=|^mirrorlist=|^enabled=' \
            /etc/dnf/repos.override.d/*.repo \
            /etc/yum.repos.d/fedora*.repo \
            /etc/yum.repos.d/fedora-cisco-openh264.repo \
            /etc/yum.repos.d/rpmfusion*.repo 2>/dev/null || true
        echo
        echo "Installed graphics stack snapshot:"
        if (( rpmdb_ok == 1 )); then
            rpm -qa 'mesa*' 'libglvnd*' 'vulkan*' 'OpenCL*' | sort || true
        else
            echo "RPM database is still unreadable after rebuild attempt."
        fi
        echo
        echo "Candidate graphics packages from enabled repos:"
        dnf5 repoquery --available \
            libglvnd-devel \
            mesa-libGL-devel \
            mesa-libGLU-devel \
            vulkan-loader \
            vulkan-loader-devel \
            vulkan-headers \
            OpenCL-ICD-Loader \
            OpenCL-ICD-Loader-devel \
            opencl-headers 2>/dev/null || true
    } >&2
}

cleanup() {
    if [[ -n "${build_root}" ]]; then
        rm -rf "${build_root}"
    fi
}
trap cleanup EXIT

repair_rpmdb_if_needed() {
    local reason="${1:-}"
    local rpmdb_root="/usr/lib/sysimage/rpm"

    if "${RPMDB_CHECK_QUERY[@]}" >/dev/null 2>&1; then
        return 0
    fi

    echo "RPM database query failed${reason:+ (${reason})}; rebuilding database." >&2
    rm -f "${rpmdb_root}"/__db.* 2>/dev/null || true
    rpm --rebuilddb >/dev/null 2>&1 || true

    if "${RPMDB_CHECK_QUERY[@]}" >/dev/null 2>&1; then
        echo "RPM database rebuild succeeded." >&2
        return 0
    fi

    echo "RPM database is still unreadable after rebuild attempt${reason:+ (${reason})}." >&2
    return 1
}

resolve_installed_package_names() {
    local installed_package
    local package
    local query_output
    local -A installed_packages=()

    repair_rpmdb_if_needed "before package resolution" >/dev/null

    for package in "$@"; do
        if query_output="$(rpm -q --whatprovides --qf '%{NAME}\n' "${package}" 2>/dev/null)"; then
            while IFS= read -r installed_package; do
                [[ -n "${installed_package}" ]] || continue
                installed_packages["${installed_package}"]=1
            done <<< "${query_output}"
        fi
    done

    if (( ${#installed_packages[@]} > 0 )); then
        printf '%s\n' "${!installed_packages[@]}" | sort -u
    fi
}

snapshot_installed_packages() {
    local output_file="$1"

    repair_rpmdb_if_needed "before package snapshot"
    rpm -qa --qf '%{NAME}\n' | sort -u > "${output_file}"
}

record_newly_installed_packages() {
    local before_file="$1"
    local output_file="$2"
    local package_name
    local -a package_names=()

    shift 2
    mapfile -t package_names < <(resolve_installed_package_names "$@")
    : > "${output_file}"

    for package_name in "${package_names[@]}"; do
        if ! grep -Fxq "${package_name}" "${before_file}"; then
            printf '%s\n' "${package_name}" >> "${output_file}"
        fi
    done

    sort -u -o "${output_file}" "${output_file}"
}

remove_package_list_file() {
    local list_file="$1"
    local -a package_names=()

    [[ -s "${list_file}" ]] || return 0
    repair_rpmdb_if_needed "before build dependency cleanup"

    mapfile -t package_names < "${list_file}"
    if (( ${#package_names[@]} > 0 )); then
        dnf5 -y remove "${package_names[@]}"
    fi
}

install_optional_packages() {
    local description="$1"
    shift

    repair_rpmdb_if_needed "before optional ${description} install"
    if dnf5 "${DNF5_INSTALL_ARGS[@]}" "$@"; then
        return 0
    fi

    repair_rpmdb_if_needed "after failed optional ${description} install" || true
    echo "Optional ${description} packages could not be installed; continuing without ${description} support." >&2
    return 1
}

refresh_dnf_metadata() {
    dnf5 clean all >/dev/null 2>&1 || true
    rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

install_required_packages() {
    local description="$1"
    shift

    repair_rpmdb_if_needed "before ${description} install"
    if dnf5 "${DNF5_INSTALL_ARGS[@]}" "$@"; then
        return 0
    fi

    echo "${description} install failed; cleaning metadata and retrying once." >&2
    refresh_dnf_metadata
    repair_rpmdb_if_needed "after failed ${description} install" || true
    if dnf5 "${DNF5_INSTALL_ARGS[@]}" "$@"; then
        return 0
    fi

    echo "${description} install failed again after metadata refresh." >&2
    repair_rpmdb_if_needed "before final ${description} debug" || true
    print_repo_debug
    return 1
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
            curl "${CURL_COMMON_ARGS[@]}" "${WINE_TAGS_API}" |
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
            curl "${CURL_COMMON_ARGS[@]}" "${sha512_manifest_url}" |
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
        release_json="$(curl "${CURL_COMMON_ARGS[@]}" "${release_api}")"
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
pin_official_fedora_repos
repair_rpmdb_if_needed "before Wine dependency installation"

build_root="$(mktemp -d /var/tmp/bazzite-wine-aarch64.XXXXXX)"
tool_bin="${build_root}/bin"
source_tarball="${build_root}/wine-${WINE_VERSION}.tar.xz"
source_dir="${build_root}/wine-${WINE_VERSION}"
build_dir="${build_root}/build"
llvm_mingw_tarball="${build_root}/${LLVM_MINGW_ARCHIVE}"
llvm_mingw_dir="${build_root}/${LLVM_MINGW_ARCHIVE%.tar.xz}"
required_before_packages="${build_root}/required-before.txt"
required_build_cleanup_list="${build_root}/required-build-cleanup.txt"
optional_before_packages="${build_root}/optional-before.txt"
optional_build_cleanup_list="${build_root}/optional-build-cleanup.txt"
optional_failed_cleanup_list="${build_root}/optional-failed-cleanup.txt"
odbc_before_packages="${build_root}/odbc-before.txt"
odbc_build_cleanup_list="${build_root}/odbc-build-cleanup.txt"
odbc_failed_cleanup_list="${build_root}/odbc-failed-cleanup.txt"

# No system upgrade here — build-arm.sh already ran dnf5 update --refresh
# in the previous Containerfile layer. Running it again pulls in unrelated
# base-system packages (speech-dispatcher, openmpi-libs) with broken
# dependency chains on the Asahi F43 base image.
# Only install Wine's own deps below.

snapshot_installed_packages "${required_before_packages}"
install_required_packages "Wine runtime dependency" "${runtime_packages[@]}"
install_required_packages "Wine build dependency" "${build_packages[@]}"
record_newly_installed_packages "${required_before_packages}" "${required_build_cleanup_list}" "${build_packages[@]}"

snapshot_installed_packages "${optional_before_packages}"
if install_optional_packages "Wine optional compatibility runtime" "${optional_compat_runtime_packages[@]}" &&
    install_optional_packages "Wine optional compatibility build" "${optional_compat_build_packages[@]}"; then
    record_newly_installed_packages "${optional_before_packages}" "${optional_build_cleanup_list}" "${optional_compat_build_packages[@]}"
else
    record_newly_installed_packages "${optional_before_packages}" "${optional_failed_cleanup_list}" \
        "${optional_compat_build_packages[@]}" "${optional_compat_runtime_packages[@]}"
    remove_package_list_file "${optional_failed_cleanup_list}"
fi

snapshot_installed_packages "${odbc_before_packages}"
if install_optional_packages "Wine ODBC runtime" "${optional_odbc_runtime_packages[@]}" &&
    install_optional_packages "Wine ODBC build" "${optional_odbc_build_packages[@]}"; then
    odbc_enabled=1
    record_newly_installed_packages "${odbc_before_packages}" "${odbc_build_cleanup_list}" "${optional_odbc_build_packages[@]}"
else
    record_newly_installed_packages "${odbc_before_packages}" "${odbc_failed_cleanup_list}" \
        "${optional_odbc_build_packages[@]}" "${optional_odbc_runtime_packages[@]}"
    remove_package_list_file "${odbc_failed_cleanup_list}"
fi

mkdir -p "${tool_bin}"
export PATH="${tool_bin}:${PATH}"
if command -v llvm-dlltool >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool)" "${tool_bin}/dlltool"
elif command -v llvm-dlltool-20 >/dev/null 2>&1; then
    ln -sf "$(command -v llvm-dlltool-20)" "${tool_bin}/dlltool"
else
    curl "${CURL_COMMON_ARGS[@]}" "${LLVM_MINGW_URL}" -o "${llvm_mingw_tarball}"
    echo "${LLVM_MINGW_SHA256}  ${llvm_mingw_tarball}" | sha256sum -c -
    tar -xf "${llvm_mingw_tarball}" -C "${build_root}"
    export PATH="${llvm_mingw_dir}/bin:${PATH}"
    ln -sf "${llvm_mingw_dir}/bin/llvm-dlltool" "${tool_bin}/dlltool"
fi

curl "${CURL_COMMON_ARGS[@]}" "${WINE_SOURCE_URL}" -o "${source_tarball}"
echo "${WINE_SOURCE_SHA512}  ${source_tarball}" | sha512sum -c -

tar -xf "${source_tarball}" -C "${build_root}"
mkdir -p "${build_dir}"

sed -i 's/-Wl,-WX//g' "${source_dir}/configure"

export CC=clang
export CXX=clang++
export LD=ld.lld
export PKG_CONFIG_PATH=""

cpu_jobs="$(nproc)"
jobs="${cpu_jobs}"
memory_limit_mb="$(awk '/MemTotal:/ {print int($2 / 1024)}' /proc/meminfo)"
if [[ -r /sys/fs/cgroup/memory.max ]]; then
    cgroup_memory_max="$(< /sys/fs/cgroup/memory.max)"
    if [[ "${cgroup_memory_max}" != "max" ]]; then
        cgroup_memory_mb=$(( cgroup_memory_max / 1024 / 1024 ))
        if (( cgroup_memory_mb > 0 && cgroup_memory_mb < memory_limit_mb )); then
            memory_limit_mb="${cgroup_memory_mb}"
        fi
    fi
fi
memory_jobs=$(( memory_limit_mb / 1536 ))
if (( memory_jobs < 2 )); then
    memory_jobs=2
fi
if (( jobs > memory_jobs )); then
    jobs="${memory_jobs}"
fi
echo "Wine build parallelism: jobs=${jobs} cpu_jobs=${cpu_jobs} memory_limit_mb=${memory_limit_mb}"

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

remove_package_list_file "${required_build_cleanup_list}"
remove_package_list_file "${optional_build_cleanup_list}"
remove_package_list_file "${odbc_build_cleanup_list}"

/ctx/cleanup
