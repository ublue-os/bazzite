# vim: set ft=make :
# ARM64 gaming stack management recipes

# Show the installed aarch64 gaming stack status
[group("arm")]
gaming-status:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    echo "=== Bazzite ARM64 Gaming Stack ==="
    echo ""
    echo "--- Native aarch64 ---"
    echo ""
    if command -v wine &>/dev/null; then
        echo "  Wine:     $(wine --version 2>/dev/null || echo 'installed')"
    else
        echo "  Wine:     not installed"
    fi
    if [[ -f /usr/share/bazzite/wine-aarch64-version ]]; then
        grep "^WINE_VERSION=" /usr/share/bazzite/wine-aarch64-version 2>/dev/null | sed 's/^/  /' || true
    fi
    echo ""
    if [[ -f /usr/share/bazzite/proton-aarch64-version ]]; then
        echo "  Proton:   installed (native aarch64 build)"
        grep "^PROTON_VERSION=" /usr/share/bazzite/proton-aarch64-version 2>/dev/null | sed 's/^/  /' || true
        grep "^PROTON_STEAM_PATH=" /usr/share/bazzite/proton-aarch64-version 2>/dev/null | sed 's/^/  /' || true
    else
        echo "  Proton:   not installed (use 'ujust install-proton-aarch64' to build)"
    fi
    echo ""
    if command -v heroic &>/dev/null || [[ -d /opt/heroic ]]; then
        echo "  Heroic:   installed"
        if [[ -f /usr/share/bazzite/heroic-launcher-version ]]; then
            grep "^HEROIC_VERSION=" /usr/share/bazzite/heroic-launcher-version 2>/dev/null | sed 's/^/  /' || true
        fi
    else
        echo "  Heroic:   not installed"
    fi
    echo ""
    if command -v lutris &>/dev/null; then
        echo "  Lutris:   $(rpm -q lutris 2>/dev/null || echo 'installed')"
    else
        echo "  Lutris:   not installed"
    fi
    echo ""
    if command -v gamescope &>/dev/null; then
        echo "  Gamescope: installed"
    else
        echo "  Gamescope: not installed"
    fi
    echo ""
    if command -v mangohud &>/dev/null; then
        echo "  MangoHud: installed"
    else
        echo "  MangoHud: not installed"
    fi
    echo ""
    if command -v legendary &>/dev/null; then
        echo "  legendary (Epic Games CLI): installed"
    else
        echo "  legendary (Epic Games CLI): not installed"
    fi
    echo ""
    echo "--- Emulated (x86 via FEX-Emu) ---"
    echo ""
    if command -v steam &>/dev/null || rpm -q steam &>/dev/null 2>&1; then
        echo "  Steam:    installed ($(rpm -q steam 2>/dev/null || echo 'available'))"
    else
        echo "  Steam:    not installed"
    fi
    echo ""
    if command -v FEXInterpreter &>/dev/null; then
        echo "  FEX-Emu:  installed"
    else
        echo "  FEX-Emu:  not installed"
    fi
    echo ""
    if command -v box64 &>/dev/null; then
        echo "  Box64:    installed"
    else
        echo "  Box64:    not installed"
    fi

# Build and install native Proton for aarch64 from source (takes 2-5 hours)
[group("arm")]
install-proton-aarch64:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    echo "=== Build Native Proton for aarch64 ==="
    echo ""
    echo "This builds Valve's Proton compatibility layer from source, targeting"
    echo "arm64 natively. The build takes 2-5 hours depending on your hardware."
    echo ""
    echo "Proton will be installed to:"
    echo "  ~/.steam/root/compatibilitytools.d/proton-bazzite-aarch64/"
    echo ""
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi
    PROTON_BRANCH="${PROTON_BRANCH:-experimental_10.0}"
    PROTON_BUILD_NAME="proton-bazzite-aarch64"
    BUILD_DIR="/tmp/proton-build-$$"
    mkdir -p "${BUILD_DIR}"
    echo "Cloning Proton ${PROTON_BRANCH}..."
    git clone --depth 1 --branch "${PROTON_BRANCH}" \
        https://github.com/ValveSoftware/Proton.git "${BUILD_DIR}/proton"
    cd "${BUILD_DIR}/proton"
    git submodule update --init --recursive --depth 1 --jobs "$(nproc)"
    echo "Configuring..."
    mkdir -p "${BUILD_DIR}/build"
    ./configure.sh \
        --build-name="${PROTON_BUILD_NAME}" \
        --target-arch=arm64 \
        --enable-ccache
    cd "${BUILD_DIR}/build"
    echo "Building (this will take a while)..."
    make -j"$(nproc)"
    echo "Installing..."
    INSTALL_DIR="${HOME}/.steam/root/compatibilitytools.d/${PROTON_BUILD_NAME}"
    mkdir -p "${INSTALL_DIR}"
    cp -a dist/. "${INSTALL_DIR}/" 2>/dev/null || cp -a "${PROTON_BUILD_NAME}/." "${INSTALL_DIR}/"
    echo ""
    echo "Proton installed to ${INSTALL_DIR}"
    echo "Restart Steam to see it in compatibility tool settings."
    rm -rf "${BUILD_DIR}"

# Update Heroic Games Launcher to the latest release
[group("arm")]
update-heroic:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    echo "=== Update Heroic Games Launcher ==="
    CURRENT=""
    if [[ -f /usr/share/bazzite/heroic-launcher-version ]]; then
        CURRENT=$(grep "^HEROIC_VERSION=" /usr/share/bazzite/heroic-launcher-version 2>/dev/null | cut -d= -f2)
    fi
    LATEST=$(curl -LfsS https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases \
        | jq -r '[.[] | select(.prerelease == false and .draft == false)][0].tag_name // empty')
    if [[ -z "${LATEST}" ]]; then
        echo "ERROR: Could not fetch latest Heroic release."
        exit 1
    fi
    echo "Current: ${CURRENT:-unknown}"
    echo "Latest:  ${LATEST}"
    if [[ "${CURRENT}" == "${LATEST#v}" ]]; then
        echo "Already up to date."
        exit 0
    fi
    echo ""
    read -rp "Update Heroic to ${LATEST}? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi
    BUILD_DIR="/tmp/heroic-update-$$"
    mkdir -p "${BUILD_DIR}"
    echo "Cloning Heroic ${LATEST}..."
    git clone --depth 1 --branch "${LATEST}" \
        https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher.git "${BUILD_DIR}/heroic"
    cd "${BUILD_DIR}/heroic"
    echo "Installing dependencies..."
    npm install --legacy-peer-deps
    echo "Building..."
    npx electron-builder build --linux dir --arm64 --config.npmRebuild=true
    DIST_DIR="${BUILD_DIR}/heroic/dist/linux-arm64-unpacked"
    if [[ ! -d "${DIST_DIR}" ]]; then
        DIST_DIR="${BUILD_DIR}/heroic/dist/linux-unpacked"
    fi
    if [[ ! -d "${DIST_DIR}" ]]; then
        echo "ERROR: Build output not found."
        exit 1
    fi
    echo "Installing..."
    sudo rm -rf /opt/heroic
    sudo mkdir -p /opt/heroic
    sudo cp -a "${DIST_DIR}"/. /opt/heroic/
    sudo chmod +x /opt/heroic/heroic 2>/dev/null || sudo chmod +x /opt/heroic/heroic-games-launcher 2>/dev/null || true
    sudo mkdir -p /usr/share/bazzite
    LATEST_CLEAN="${LATEST#v}"
    echo "HEROIC_VERSION=${LATEST_CLEAN}" | sudo tee /usr/share/bazzite/heroic-launcher-version > /dev/null
    echo "HEROIC_ARCH=aarch64" | sudo tee -a /usr/share/bazzite/heroic-launcher-version > /dev/null
    echo "BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)" | sudo tee -a /usr/share/bazzite/heroic-launcher-version > /dev/null
    echo ""
    echo "Heroic updated to ${LATEST_CLEAN}."
    rm -rf "${BUILD_DIR}"
