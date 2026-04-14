#!/usr/bin/bash
#
# Build and install Proton natively for aarch64.
#
# Proton's build system requires Docker/Podman (it builds inside the Proton
# SDK container). This means it CANNOT run inside a Containerfile RUN layer.
# This script is designed to run either:
#   - As a post-install step on the live Bazzite system (ujust install-proton-aarch64)
#   - During the asahi-rebase.sh conversion (before the container build)
#
# When called from inside a container build (detected via /.dockerenv or
# /run/.containerenv), it exits gracefully.

set -euo pipefail

if [[ "${SKIP_PROTON:-1}" == "1" ]]; then
    echo "Skipping native Proton aarch64 build (SKIP_PROTON=1, use --build-proton to enable)."
    exit 0
fi

# Proton's build system requires a container engine (Docker/Podman) because
# it compiles inside the Proton SDK container. This is impossible inside a
# Containerfile RUN layer (no container-in-container support).
if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
    echo "Proton build detected container environment -- skipping."
    echo "Proton requires Docker/Podman and must be built on a live system."
    echo "After Bazzite boots, run: ujust install-proton-aarch64"
    exit 0
fi

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Native Proton build is only supported on aarch64 systems." >&2
    exit 1
fi

# Proton needs a container engine
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Proton build requires podman or docker." >&2
    echo "Install with: sudo dnf install -y podman" >&2
    exit 1
fi

PROTON_BRANCH="${PROTON_BRANCH:-experimental_10.0}"
PROTON_BUILD_NAME="${PROTON_BUILD_NAME:-proton-bazzite-aarch64}"
PROTON_REPO="https://github.com/ValveSoftware/Proton.git"
CONTAINER_ENGINE=""
if command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE="podman"
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
fi

echo "=== Building Proton (${PROTON_BRANCH}) for aarch64 ==="
echo "Build name:       ${PROTON_BUILD_NAME}"
echo "Container engine: ${CONTAINER_ENGINE}"
echo "This will take 2-5 hours depending on hardware."
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# Install build dependencies
# ──────────────────────────────────────────────────────────────────────────────
echo "Installing build dependencies..."
if command -v dnf5 >/dev/null 2>&1; then
    DNF_CMD="dnf5"
elif command -v dnf >/dev/null 2>&1; then
    DNF_CMD="dnf"
else
    echo "ERROR: dnf not found." >&2
    exit 1
fi

sudo "${DNF_CMD}" -y install \
    git make gcc gcc-c++ ccache meson ninja-build cmake \
    python3 python3-pip autoconf automake bison flex \
    gettext-devel fontconfig-devel freetype-devel gnutls-devel \
    libX11-devel libXcomposite-devel libXcursor-devel \
    libXext-devel libXi-devel libXinerama-devel \
    libXrandr-devel libXrender-devel libXxf86vm-devel \
    libglvnd-devel libpcap-devel libstdc++-devel \
    libunwind-devel libxkbcommon-devel \
    pulseaudio-libs-devel vulkan-loader-devel vulkan-headers \
    wayland-devel alsa-lib-devel cups-devel dbus-devel \
    mingw64-gcc mingw64-gcc-c++ mingw32-gcc mingw32-gcc-c++ \
    glslang spirv-tools lld clang patch perl \
    'pkgconfig(libusb-1.0)' 2>&1 | tail -5

# ──────────────────────────────────────────────────────────────────────────────
# Clone Proton source
# ──────────────────────────────────────────────────────────────────────────────
BUILD_DIR="/tmp/proton-build-$$"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Cloning Proton ${PROTON_BRANCH} (with submodules — this takes a while)..."
git clone --depth 1 --branch "${PROTON_BRANCH}" "${PROTON_REPO}" proton
cd proton
git submodule update --init --recursive --depth 1 --jobs "$(nproc)"

# ──────────────────────────────────────────────────────────────────────────────
# Configure
# ──────────────────────────────────────────────────────────────────────────────
PROTON_BUILD_OUTPUT="${BUILD_DIR}/build"
mkdir -p "${PROTON_BUILD_OUTPUT}"
cd "${PROTON_BUILD_OUTPUT}"

echo "Configuring Proton for arm64..."
CONFIGURE_ARGS=(
    --build-name="${PROTON_BUILD_NAME}"
    --target-arch=arm64
    --enable-ccache
    --container-engine="${CONTAINER_ENGINE}"
)

"${BUILD_DIR}/proton/configure.sh" "${CONFIGURE_ARGS[@]}" 2>&1 | tail -20

# ──────────────────────────────────────────────────────────────────────────────
# Build
# ──────────────────────────────────────────────────────────────────────────────
NPROC=$(nproc)
MEM_GB=$(awk '/MemTotal/{printf "%d", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "4")
MAX_JOBS=$(( MEM_GB > 1 ? MEM_GB : 1 ))
JOBS=$(( NPROC < MAX_JOBS ? NPROC : MAX_JOBS ))
echo "Building Proton with ${JOBS} parallel jobs (${NPROC} cores, ${MEM_GB}GB RAM)..."

make -j"${JOBS}" 2>&1 | tail -50

# ──────────────────────────────────────────────────────────────────────────────
# Install Proton
# ──────────────────────────────────────────────────────────────────────────────
STEAM_COMPAT_DIR="${HOME}/.steam/root/compatibilitytools.d/${PROTON_BUILD_NAME}"
SYSTEM_COMPAT_DIR="/usr/share/steam/compatibilitytools.d/${PROTON_BUILD_NAME}"
HEROIC_PROTON_DIR="${HOME}/.config/heroic/tools/proton"

PROTON_DIST=""
for candidate in \
    "${PROTON_BUILD_OUTPUT}/dist" \
    "${PROTON_BUILD_OUTPUT}/${PROTON_BUILD_NAME}" \
    "${PROTON_BUILD_OUTPUT}/files"; do
    if [[ -d "${candidate}" ]]; then
        PROTON_DIST="${candidate}"
        break
    fi
done
if [[ -z "${PROTON_DIST}" ]]; then
    PROTON_DIST=$(find "${PROTON_BUILD_OUTPUT}" -maxdepth 3 -type d -name "dist" 2>/dev/null | head -1)
fi
if [[ -z "${PROTON_DIST}" || ! -d "${PROTON_DIST}" ]]; then
    echo "ERROR: Could not find Proton build output."
    find "${PROTON_BUILD_OUTPUT}" -maxdepth 3 -type d 2>/dev/null | head -20
    exit 1
fi

echo "Installing Proton from ${PROTON_DIST}..."

mkdir -p "${STEAM_COMPAT_DIR}"
cp -a "${PROTON_DIST}"/. "${STEAM_COMPAT_DIR}"/

mkdir -p "${HEROIC_PROTON_DIR}"
ln -sf "${STEAM_COMPAT_DIR}" "${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"

if [[ "$(id -u)" -eq 0 ]]; then
    mkdir -p "${SYSTEM_COMPAT_DIR}"
    cp -a "${PROTON_DIST}"/. "${SYSTEM_COMPAT_DIR}"/
fi

# ──────────────────────────────────────────────────────────────────────────────
# Write version metadata
# ──────────────────────────────────────────────────────────────────────────────
sudo mkdir -p /usr/share/bazzite 2>/dev/null || mkdir -p /usr/share/bazzite 2>/dev/null || true
PROTON_VER=$(cat "${STEAM_COMPAT_DIR}/version" 2>/dev/null || echo "${PROTON_BRANCH}")
METADATA_PATH="/usr/share/bazzite/proton-aarch64-version"
cat > "${METADATA_PATH}" 2>/dev/null || sudo tee "${METADATA_PATH}" > /dev/null << EOF
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
# Clean up
# ──────────────────────────────────────────────────────────────────────────────
echo "Cleaning up Proton build artifacts..."
rm -rf "${BUILD_DIR}"
ccache -C 2>/dev/null || true

echo ""
echo "Proton ${PROTON_VER} (aarch64) installed successfully."
echo "  Steam path:  ${STEAM_COMPAT_DIR}"
echo "  Heroic path: ${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"
echo "  Restart Steam to see it in compatibility tool settings."
