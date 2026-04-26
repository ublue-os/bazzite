#!/usr/bin/bash
#
# Build and install Heroic Games Launcher natively for aarch64.
#
# Heroic does not ship official aarch64 Linux binaries. Since it is an
# Electron/Node.js application, we can build it from source targeting
# linux/arm64. The resulting app is installed to /opt/heroic and a
# desktop entry + /usr/bin/heroic wrapper are created.
#
# The companion CLI tools (legendary for Epic, gogdl for GOG) are
# Python-based and run natively on aarch64 without any special handling.

set -euo pipefail

if [[ "${SKIP_HEROIC:-1}" == "1" ]]; then
    echo "Skipping Heroic Games Launcher build (SKIP_HEROIC=1, use --build-heroic to enable)."
    exit 0
fi

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "Heroic launcher build is only supported on aarch64 builders" >&2
    exit 1
fi

# In atomic/ostree container images /root is often a symlink to /var/roothome
# which doesn't exist during the build. npm/node/electron-builder all need a
# writable HOME for caches, config, and the Electron zip download cache.
if [[ ! -d "/root" ]] || [[ -L "/root" ]]; then
    rm -f /root 2>/dev/null || true
    mkdir -p /root
fi
export HOME="/root"
export npm_config_cache="/tmp/npm-cache"
export ELECTRON_CACHE="/tmp/electron-cache"
export XDG_CACHE_HOME="/tmp/xdg-cache"
mkdir -p "${npm_config_cache}" "${ELECTRON_CACHE}" "${XDG_CACHE_HOME}"

HEROIC_VERSION="${HEROIC_VERSION:-}"
HEROIC_RELEASES_API="https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases"
CURL_COMMON_ARGS=(
    -LfsS
    --retry 5
    --retry-all-errors
    --retry-delay 2
    --connect-timeout 20
)

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

# ──────────────────────────────────────────────────────────────────────────────
# Resolve Heroic version
# ──────────────────────────────────────────────────────────────────────────────
if [[ -z "${HEROIC_VERSION}" ]]; then
    echo "Resolving latest Heroic Games Launcher release..."
    HEROIC_VERSION=$(
        curl "${CURL_COMMON_ARGS[@]}" "${HEROIC_RELEASES_API}" \
        | jq -r '[.[] | select(.prerelease == false and .draft == false)][0].tag_name // empty'
    )
    if [[ -z "${HEROIC_VERSION}" ]]; then
        echo "ERROR: Could not resolve latest Heroic release from GitHub API." >&2
        exit 1
    fi
fi

HEROIC_VERSION_CLEAN="${HEROIC_VERSION#v}"
echo "Building Heroic Games Launcher ${HEROIC_VERSION} for aarch64..."

# ──────────────────────────────────────────────────────────────────────────────
# Install build dependencies
# ──────────────────────────────────────────────────────────────────────────────
echo "Installing build dependencies..."

build_packages=(
    nodejs
    npm
    git
    python3
    make
    gcc
    gcc-c++
    libX11-devel
    libXScrnSaver-devel
    libnotify-devel
    nss
    libdrm-devel
    mesa-libgbm-devel
    alsa-lib-devel
    cups-libs
    atk
    at-spi2-atk
    gtk3
)

runtime_packages=(
    nodejs
    nss
    libnotify
    libXScrnSaver
    alsa-lib
    cups-libs
    atk
    at-spi2-atk
    gtk3
    mesa-libgbm
    libdrm
    python3
    python3-pip
)

snapshot_before="$(rpm -qa --qf '%{NAME}\n' | sort)"

install_packages "Heroic build dependencies" \
    "${build_packages[@]}" \
    "${runtime_packages[@]}"

# electron-builder requires pnpm for node module collection
echo "Installing pnpm..."
npm install -g pnpm 2>&1 | tail -3

# ──────────────────────────────────────────────────────────────────────────────
# Install native Python game store CLIs
# ──────────────────────────────────────────────────────────────────────────────
echo "Installing native aarch64 game store CLIs..."
pip3 install --no-cache-dir --break-system-packages --prefix=/usr legendary-gl 2>/dev/null || \
    echo "WARNING: legendary-gl pip install failed; Epic Games may need manual setup."

# ──────────────────────────────────────────────────────────────────────────────
# Clone and build Heroic
# ──────────────────────────────────────────────────────────────────────────────
BUILD_DIR="/tmp/heroic-build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Cloning Heroic ${HEROIC_VERSION}..."
git clone --depth 1 --branch "${HEROIC_VERSION}" \
    https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher.git heroic
cd heroic

echo "Installing Node.js dependencies with pnpm..."
pnpm install --no-frozen-lockfile 2>&1 | tail -10

echo "Compiling Heroic source (electron-vite build)..."
npx --yes electron-vite build 2>&1 | tail -15

echo "Packaging Heroic for linux/arm64..."
npx --yes electron-builder build --linux dir --arm64 \
    2>&1 | tail -30

DIST_DIR="${BUILD_DIR}/heroic/dist/linux-arm64-unpacked"
if [[ ! -d "${DIST_DIR}" ]]; then
    DIST_DIR="${BUILD_DIR}/heroic/dist/linux-unpacked"
fi
if [[ ! -d "${DIST_DIR}" ]]; then
    echo "Searching for build output..."
    find "${BUILD_DIR}/heroic/dist" -maxdepth 2 -type d -name "*unpacked*" 2>/dev/null || true
    echo "ERROR: Could not find Heroic build output directory." >&2
    exit 1
fi
echo "Build output: ${DIST_DIR}"

# ──────────────────────────────────────────────────────────────────────────────
# Install to /opt/heroic
# ──────────────────────────────────────────────────────────────────────────────
echo "Installing Heroic to /opt/heroic..."
rm -rf /opt/heroic
mkdir -p /opt/heroic
cp -a "${DIST_DIR}"/. /opt/heroic/
chmod +x /opt/heroic/heroic 2>/dev/null || chmod +x /opt/heroic/heroic-games-launcher 2>/dev/null || true

mkdir -p /usr/bin
cat > /usr/bin/heroic << 'WRAPPER'
#!/usr/bin/bash
exec /opt/heroic/heroic "$@" 2>/dev/null || exec /opt/heroic/heroic-games-launcher "$@"
WRAPPER
chmod +x /usr/bin/heroic

mkdir -p /usr/share/applications
cat > /usr/share/applications/heroic.desktop << 'DESKTOP'
[Desktop Entry]
Name=Heroic Games Launcher
Comment=Open Source GOG and Epic Games Launcher
Exec=/usr/bin/heroic %U
Terminal=false
Type=Application
Icon=heroic
Categories=Game;
MimeType=x-scheme-handler/heroic;
StartupWMClass=heroic
DESKTOP

if [[ -f /opt/heroic/resources/app.asar ]]; then
    for size in 16 32 48 64 128 256 512; do
        icon_src="/opt/heroic/resources/icon.png"
        if [[ -f "${icon_src}" ]]; then
            mkdir -p "/usr/share/icons/hicolor/${size}x${size}/apps"
            cp "${icon_src}" "/usr/share/icons/hicolor/${size}x${size}/apps/heroic.png" 2>/dev/null || true
            break
        fi
    done
fi

# ──────────────────────────────────────────────────────────────────────────────
# Write version metadata
# ──────────────────────────────────────────────────────────────────────────────
mkdir -p /usr/share/bazzite
cat > /usr/share/bazzite/heroic-launcher-version << EOF
HEROIC_VERSION=${HEROIC_VERSION_CLEAN}
HEROIC_ARCH=aarch64
HEROIC_BUILD_TYPE=source
HEROIC_INSTALL_PATH=/opt/heroic
LEGENDARY_INSTALLED=$(command -v legendary >/dev/null 2>&1 && echo "yes" || echo "no")
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
echo "Heroic version metadata written to /usr/share/bazzite/heroic-launcher-version"

# ──────────────────────────────────────────────────────────────────────────────
# Clean up build artifacts and build-only dependencies
# ──────────────────────────────────────────────────────────────────────────────
echo "Cleaning up build artifacts..."
rm -rf "${BUILD_DIR}"
npm cache clean --force 2>/dev/null || true

snapshot_after="$(rpm -qa --qf '%{NAME}\n' | sort)"
newly_installed="$(comm -13 <(echo "${snapshot_before}") <(echo "${snapshot_after}"))"

build_only_packages=(
    libX11-devel
    libXScrnSaver-devel
    libnotify-devel
    libdrm-devel
    mesa-libgbm-devel
    alsa-lib-devel
    gcc
    gcc-c++
    make
)

for pkg in "${build_only_packages[@]}"; do
    if echo "${newly_installed}" | grep -qx "${pkg}"; then
        dnf5 -y remove "${pkg}" 2>/dev/null || true
    fi
done

echo ""
echo "Heroic Games Launcher ${HEROIC_VERSION_CLEAN} installed successfully."
echo "  Binary: /usr/bin/heroic"
echo "  Install: /opt/heroic"
echo "  Desktop: /usr/share/applications/heroic.desktop"
if command -v legendary >/dev/null 2>&1; then
    echo "  legendary (Epic Games CLI): $(command -v legendary)"
fi

/ctx/cleanup
