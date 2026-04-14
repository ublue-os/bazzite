#!/usr/bin/bash
#
# Build and install Proton natively for aarch64.
#
# Proton is Valve's compatibility layer (patched Wine + DXVK + vkd3d-proton).
# The official Proton repo supports --target-arch=arm64 on the experimental
# branch. This build is OPTIONAL and gated by SKIP_PROTON (default: skip)
# because it takes 2-5 hours.
#
# The resulting Proton is installed to:
#   /usr/share/steam/compatibilitytools.d/proton-bazzite-aarch64/
# so that Steam discovers it, and symlinked to:
#   /usr/share/heroic/tools/proton/proton-bazzite-aarch64/
# so Heroic can use it as well.

set -euo pipefail

if [[ "${SKIP_PROTON:-1}" == "1" ]]; then
    echo "Skipping native Proton aarch64 build (SKIP_PROTON=1, use --build-proton to enable)."
    exit 0
fi

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Native Proton build is only supported on aarch64 builders" >&2
    exit 1
fi

PROTON_BRANCH="${PROTON_BRANCH:-experimental_10.0}"
PROTON_BUILD_NAME="${PROTON_BUILD_NAME:-proton-bazzite-aarch64}"
PROTON_REPO="https://github.com/ValveSoftware/Proton.git"

RPMDB_CHECK_QUERY=(rpm -qa --qf '%{NAME}\n')
RPMDB_SQLITE_PATH="/usr/lib/sysimage/rpm/rpmdb.sqlite"
DNF5_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=0"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)

rpmdb_is_healthy() {
    "${RPMDB_CHECK_QUERY[@]}" >/dev/null 2>&1 || return 1
    rpmdb --verifydb >/dev/null 2>&1 || return 1
    if [[ -f "${RPMDB_SQLITE_PATH}" ]] && command -v python3 >/dev/null 2>&1; then
        python3 - "${RPMDB_SQLITE_PATH}" <<'PY' >/dev/null 2>&1 || return 1
import sqlite3, sys
conn = sqlite3.connect(f"file:{sys.argv[1]}?mode=ro", uri=True)
try:
    row = conn.execute("PRAGMA quick_check").fetchone()
    raise SystemExit(0 if row and row[0] == "ok" else 1)
finally:
    conn.close()
PY
    fi
    return 0
}

repair_rpmdb_if_needed() {
    local reason="${1:-}"
    if rpmdb_is_healthy; then return 0; fi
    echo "RPM database query failed${reason:+ (${reason})}; rebuilding." >&2
    rpm --rebuilddb >/dev/null 2>&1 || true
    rpmdb_is_healthy
}

refresh_dnf_metadata() {
    dnf5 clean all >/dev/null 2>&1 || true
    rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

install_packages() {
    local description="$1"
    shift
    repair_rpmdb_if_needed "before ${description} install"
    if dnf5 -y install "${DNF5_STRICT_REPO_ARGS[@]}" "$@"; then
        return 0
    fi
    echo "${description} install failed; cleaning metadata and retrying." >&2
    refresh_dnf_metadata
    repair_rpmdb_if_needed "after failed ${description} install" || true
    dnf5 -y install "${DNF5_STRICT_REPO_ARGS[@]}" "$@"
}

echo "=== Building Proton (${PROTON_BRANCH}) for aarch64 ==="
echo "Build name: ${PROTON_BUILD_NAME}"
echo "This will take 2-5 hours depending on hardware."
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# Install build dependencies
# ──────────────────────────────────────────────────────────────────────────────
echo "Installing Proton build dependencies..."

snapshot_before="$(rpm -qa --qf '%{NAME}\n' | sort)"

build_packages=(
    git
    make
    gcc
    gcc-c++
    ccache
    meson
    ninja-build
    cmake
    python3
    python3-pip
    autoconf
    automake
    bison
    flex
    gettext-devel
    fontconfig-devel
    freetype-devel
    gnutls-devel
    libX11-devel
    libXcomposite-devel
    libXcursor-devel
    libXext-devel
    libXi-devel
    libXinerama-devel
    libXrandr-devel
    libXrender-devel
    libXxf86vm-devel
    libglvnd-devel
    libpcap-devel
    libstdc++-devel
    libunwind-devel
    libxkbcommon-devel
    pulseaudio-libs-devel
    vulkan-loader-devel
    vulkan-headers
    wayland-devel
    alsa-lib-devel
    cups-devel
    dbus-devel
    mingw64-gcc
    mingw64-gcc-c++
    mingw32-gcc
    mingw32-gcc-c++
    glslang
    spirv-tools
    lld
    clang
    patch
    perl
    'pkgconfig(libusb-1.0)'
)

install_packages "Proton build toolchain" \
    "${build_packages[@]}"

# ──────────────────────────────────────────────────────────────────────────────
# Clone Proton source
# ──────────────────────────────────────────────────────────────────────────────
BUILD_DIR="/tmp/proton-build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Cloning Proton ${PROTON_BRANCH} (with submodules, this takes a while)..."
git clone --depth 1 --branch "${PROTON_BRANCH}" "${PROTON_REPO}" proton
cd proton
git submodule update --init --recursive --depth 1 --jobs "$(nproc)"

# ──────────────────────────────────────────────────────────────────────────────
# Configure and build
# ──────────────────────────────────────────────────────────────────────────────
PROTON_BUILD_OUTPUT="${BUILD_DIR}/build"
mkdir -p "${PROTON_BUILD_OUTPUT}"

echo "Configuring Proton for arm64..."
./configure.sh \
    --build-name="${PROTON_BUILD_NAME}" \
    --target-arch=arm64 \
    --enable-ccache \
    2>&1 | tail -20

cd "${PROTON_BUILD_OUTPUT}"

NPROC=$(nproc)
MEM_GB=$(awk '/MemTotal/{printf "%d", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "4")
MAX_JOBS=$(( MEM_GB > 1 ? MEM_GB : 1 ))
JOBS=$(( NPROC < MAX_JOBS ? NPROC : MAX_JOBS ))
echo "Building Proton with ${JOBS} parallel jobs (${NPROC} cores, ${MEM_GB}GB RAM)..."

make -j"${JOBS}" 2>&1 | tail -50
make install 2>&1 | tail -10

# ──────────────────────────────────────────────────────────────────────────────
# Install Proton to system paths
# ──────────────────────────────────────────────────────────────────────────────
STEAM_COMPAT_DIR="/usr/share/steam/compatibilitytools.d/${PROTON_BUILD_NAME}"
HEROIC_PROTON_DIR="/usr/share/heroic/tools/proton"

PROTON_DIST="${PROTON_BUILD_OUTPUT}/dist"
if [[ ! -d "${PROTON_DIST}" ]]; then
    PROTON_DIST=$(find "${PROTON_BUILD_OUTPUT}" -maxdepth 2 -type d -name "dist" | head -1)
fi
if [[ ! -d "${PROTON_DIST}" ]]; then
    PROTON_DIST=$(find "${PROTON_BUILD_OUTPUT}" -maxdepth 3 -type d -name "${PROTON_BUILD_NAME}" | head -1)
fi
if [[ -z "${PROTON_DIST}" || ! -d "${PROTON_DIST}" ]]; then
    echo "ERROR: Could not find Proton build output."
    find "${PROTON_BUILD_OUTPUT}" -maxdepth 3 -type d 2>/dev/null | head -20
    exit 1
fi

echo "Installing Proton from ${PROTON_DIST}..."
rm -rf "${STEAM_COMPAT_DIR}"
mkdir -p "${STEAM_COMPAT_DIR}"
cp -a "${PROTON_DIST}"/. "${STEAM_COMPAT_DIR}"/

mkdir -p "${HEROIC_PROTON_DIR}"
ln -sf "${STEAM_COMPAT_DIR}" "${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"

# ──────────────────────────────────────────────────────────────────────────────
# Write version metadata
# ──────────────────────────────────────────────────────────────────────────────
mkdir -p /usr/share/bazzite
PROTON_VER=$(cat "${STEAM_COMPAT_DIR}/version" 2>/dev/null || echo "${PROTON_BRANCH}")
cat > /usr/share/bazzite/proton-aarch64-version << EOF
PROTON_VERSION=${PROTON_VER}
PROTON_BRANCH=${PROTON_BRANCH}
PROTON_BUILD_NAME=${PROTON_BUILD_NAME}
PROTON_ARCH=aarch64
PROTON_BUILD_TYPE=source
PROTON_STEAM_PATH=${STEAM_COMPAT_DIR}
PROTON_HEROIC_PATH=${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# ──────────────────────────────────────────────────────────────────────────────
# Clean up build artifacts and build-only dependencies
# ──────────────────────────────────────────────────────────────────────────────
echo "Cleaning up Proton build artifacts..."
rm -rf "${BUILD_DIR}"
ccache -C 2>/dev/null || true

snapshot_after="$(rpm -qa --qf '%{NAME}\n' | sort)"
newly_installed="$(comm -13 <(echo "${snapshot_before}") <(echo "${snapshot_after}"))"

build_only_remove=(
    ccache
    mingw64-gcc
    mingw64-gcc-c++
    mingw32-gcc
    mingw32-gcc-c++
    glslang
    spirv-tools
    cmake
    meson
    ninja-build
    autoconf
    automake
)

for pkg in "${build_only_remove[@]}"; do
    if echo "${newly_installed}" | grep -qx "${pkg}"; then
        dnf5 -y remove "${pkg}" 2>/dev/null || true
    fi
done

echo ""
echo "Proton ${PROTON_VER} (aarch64) installed successfully."
echo "  Steam path:  ${STEAM_COMPAT_DIR}"
echo "  Heroic path: ${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"
echo "  Metadata:    /usr/share/bazzite/proton-aarch64-version"

/ctx/cleanup
