# vim: set ft=make :
# ARM64 gaming stack management recipes

# Complete post-install gaming setup for aarch64 (installs Heroic, verifies emulation, optimizes storage)
[group("arm")]
complete-gaming-setup:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    echo "========================================"
    echo "  Bazzite ARM64 Complete Gaming Setup"
    echo "========================================"
    echo ""
    echo "This will:"
    echo "  1. Verify x86 emulation stack (FEX-Emu, Box64, muvm, Steam)"
    echo "  2. Install Heroic Games Launcher (aarch64 native build)"
    echo "  3. Verify Wine installation"
    echo "  4. Show Proton build instructions"
    echo "  5. Help set up external drive for game storage"
    echo ""
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi

    echo ""
    echo "=== Step 1/5: x86 Emulation Stack ==="
    EMULATION_OK=1
    if ! command -v FEXInterpreter &>/dev/null; then
        echo "FEX-Emu is missing. Installing..."
        /usr/libexec/bazzite-arm-runtime-dnf install fex-emu || EMULATION_OK=0
    else
        echo "  FEX-Emu: OK"
    fi
    if ! command -v box64 &>/dev/null; then
        echo "Box64 is missing. Installing..."
        /usr/libexec/bazzite-arm-runtime-dnf install box64 || EMULATION_OK=0
    else
        echo "  Box64: OK"
    fi
    if ! command -v muvm &>/dev/null; then
        echo "muvm is missing. Installing..."
        /usr/libexec/bazzite-arm-runtime-dnf install muvm libkrun libkrunfw || EMULATION_OK=0
    else
        echo "  muvm: OK"
    fi
    if ! rpm -q steam &>/dev/null 2>&1; then
        echo "Steam is missing. Installing..."
        /usr/libexec/bazzite-arm-runtime-dnf install steam || EMULATION_OK=0
    else
        echo "  Steam: OK"
    fi
    if [[ "${EMULATION_OK}" == "1" ]]; then
        echo "  All emulation components verified."
    else
        echo "  WARNING: Some emulation components could not be installed."
        echo "  Run 'ujust check-x86-emulation' for details."
    fi

    echo ""
    echo "=== Step 2/5: Heroic Games Launcher ==="
    if command -v heroic &>/dev/null || [[ -d /opt/heroic ]]; then
        echo "  Heroic is already installed."
        if [[ -f "${HOME}/.local/share/bazzite/heroic-launcher-version" ]]; then
            grep "^HEROIC_VERSION=" "${HOME}/.local/share/bazzite/heroic-launcher-version" 2>/dev/null | sed 's/^/  /' || true
        fi
    else
        echo "  Heroic not found. Starting installation..."
        ujust install-heroic || echo "  WARNING: Heroic installation failed. Try: ujust install-heroic"
    fi

    echo ""
    echo "=== Step 3/5: Wine ==="
    if command -v wine &>/dev/null; then
        echo "  Wine: $(wine --version 2>/dev/null || echo 'installed')"
    else
        echo "  Wine: not installed"
        echo "  Wine should have been included in the image build."
        echo "  If missing, you may need to rebuild the image with SKIP_WINE=0."
    fi

    echo ""
    echo "=== Step 4/5: Proton ==="
    if ls ~/.steam/root/compatibilitytools.d/GE-Proton* >/dev/null 2>&1; then
        PROTON_GE_DIR=$(ls -d ~/.steam/root/compatibilitytools.d/GE-Proton* 2>/dev/null | sort -V | tail -1)
        echo "  Proton GE: installed ($(basename "${PROTON_GE_DIR}"))"
    elif [[ -f "${HOME}/.local/share/bazzite/proton-aarch64-version" ]]; then
        echo "  Proton: installed (native aarch64 build)"
        grep "^PROTON_VERSION=" "${HOME}/.local/share/bazzite/proton-aarch64-version" 2>/dev/null | sed 's/^/  /' || true
    else
        echo "  Proton: not installed"
        echo ""
        echo "  Installing Proton GE (download, ~500MB)..."
        ujust install-proton-ge || echo "  WARNING: Proton GE installation failed. Try: ujust install-proton-ge"
    fi

    echo ""
    echo "=== Step 5/5: External Storage ==="
    GAMES_MOUNT="/var/mnt/games"
    if findmnt -n "${GAMES_MOUNT}" >/dev/null 2>&1; then
        echo "  External drive mounted at ${GAMES_MOUNT}"
        df -h "${GAMES_MOUNT}" | tail -1 | awk '{print "  Size:", $2, " Used:", $3, " Free:", $4}'
        echo ""
        read -rp "  Redirect all game storage to external drive? (y/N): " storage_confirm
        if [[ "$storage_confirm" == [yY] ]]; then
            ujust use-external-storage "${GAMES_MOUNT}"
        fi
    else
        echo "  No external drive mounted at ${GAMES_MOUNT}."
        echo "  To set up an external drive:"
        echo "    1. Connect your external drive"
        echo "    2. Run: ujust setup-games-drive /dev/<your-device>"
        echo "    3. Run: ujust use-external-storage"
    fi

    echo ""
    echo "========================================"
    echo "  Setup Complete!"
    echo "========================================"
    echo ""
    ujust gaming-status

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
    if [[ -f "${HOME}/.local/share/bazzite/proton-aarch64-version" ]]; then
        echo "  Proton:   installed (native aarch64 build)"
        grep "^PROTON_VERSION=" "${HOME}/.local/share/bazzite/proton-aarch64-version" 2>/dev/null | sed 's/^/  /' || true
        grep "^PROTON_STEAM_PATH=" "${HOME}/.local/share/bazzite/proton-aarch64-version" 2>/dev/null | sed 's/^/  /' || true
    else
        echo "  Proton:   not installed (use 'ujust install-proton-aarch64' to build)"
    fi
    echo ""
    if command -v heroic &>/dev/null || [[ -d /opt/heroic ]]; then
        echo "  Heroic:   installed"
        if [[ -f "${HOME}/.local/share/bazzite/heroic-launcher-version" ]]; then
            grep "^HEROIC_VERSION=" "${HOME}/.local/share/bazzite/heroic-launcher-version" 2>/dev/null | sed 's/^/  /' || true
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
# WARNING: Requires a working container engine. On Asahi's 16K page kernel,
# standard aarch64 containers may fail with mprotect errors. Use

# 'ujust install-proton-ge' instead for a pre-built Proton that runs via FEX.
[group("arm")]
install-proton-aarch64:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
        echo "ERROR: Proton build requires podman or docker."
        echo "Install with: sudo dnf5 install -y podman"
        exit 1
    fi
    CONTAINER_ENGINE=""
    if command -v podman >/dev/null 2>&1; then
        CONTAINER_ENGINE="podman"
    elif command -v docker >/dev/null 2>&1; then
        CONTAINER_ENGINE="docker"
    fi
    echo "=== Build Native Proton for aarch64 ==="
    echo ""
    echo "This builds Valve's Proton compatibility layer from source, targeting"
    echo "arm64 natively. The build takes 2-5 hours depending on your hardware."
    echo "Requires: ${CONTAINER_ENGINE} (Proton builds inside a container)"
    echo ""
    echo "Proton will be installed to:"
    echo "  ~/.steam/root/compatibilitytools.d/proton-bazzite-aarch64/"
    echo "  ~/.config/heroic/tools/proton/proton-bazzite-aarch64 (symlink)"
    echo ""
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi

    echo "--- Installing build dependencies ---"
    sudo dnf5 -y install --skip-unavailable \
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

    PROTON_BRANCH="${PROTON_BRANCH:-experimental_10.0}"
    PROTON_BUILD_NAME="proton-bazzite-aarch64"
    BUILD_DIR="/tmp/proton-build-$$"
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    trap 'rm -rf "${BUILD_DIR}"' EXIT

    echo "Checking container viability..."
    TEST_IMG="registry.fedoraproject.org/fedora:$(rpm -E %fedora)"
    if ! "${CONTAINER_ENGINE}" run --rm "${TEST_IMG}" true 2>/dev/null; then
        echo "ERROR: Container engine '${CONTAINER_ENGINE}' cannot run containers."
        echo "On Asahi's 16K-page kernel, standard aarch64 containers may fail."
        echo "Try: ujust install-proton-ge (pre-built, no container needed)"
        exit 1
    fi

    echo "Cloning Proton ${PROTON_BRANCH} (with submodules -- this takes a while)..."
    git clone --depth 1 --branch "${PROTON_BRANCH}" \
        https://github.com/ValveSoftware/Proton.git "${BUILD_DIR}/proton"
    cd "${BUILD_DIR}/proton"
    git submodule update --init --recursive --depth 1 --jobs "$(nproc)"

    echo "Configuring Proton for arm64..."
    mkdir -p "${BUILD_DIR}/build"
    cd "${BUILD_DIR}/build"
    "${BUILD_DIR}/proton/configure.sh" \
        --build-name="${PROTON_BUILD_NAME}" \
        --target-arch=arm64 \
        --enable-ccache \
        --container-engine="${CONTAINER_ENGINE}" 2>&1 | tail -20

    NPROC=$(nproc)
    MEM_GB=$(awk '/MemTotal/{printf "%d", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "4")
    MAX_JOBS=$(( MEM_GB > 1 ? MEM_GB : 1 ))
    JOBS=$(( NPROC < MAX_JOBS ? NPROC : MAX_JOBS ))
    echo "Building Proton with ${JOBS} parallel jobs (${NPROC} cores, ${MEM_GB}GB RAM)..."
    echo "This will take 2-5 hours."
    make -j"${JOBS}" 2>&1 | tail -50

    echo "--- Installing Proton ---"
    STEAM_COMPAT_DIR="${HOME}/.steam/root/compatibilitytools.d/${PROTON_BUILD_NAME}"
    HEROIC_PROTON_DIR="${HOME}/.config/heroic/tools/proton"

    PROTON_DIST=""
    for candidate in \
        "${BUILD_DIR}/build/dist" \
        "${BUILD_DIR}/build/${PROTON_BUILD_NAME}" \
        "${BUILD_DIR}/build/files"; do
        if [[ -d "${candidate}" ]]; then
            PROTON_DIST="${candidate}"
            break
        fi
    done
    if [[ -z "${PROTON_DIST}" ]]; then
        PROTON_DIST=$(find "${BUILD_DIR}/build" -maxdepth 3 -type d -name "dist" 2>/dev/null | head -1)
    fi
    if [[ -z "${PROTON_DIST}" || ! -d "${PROTON_DIST}" ]]; then
        echo "ERROR: Could not find Proton build output."
        find "${BUILD_DIR}/build" -maxdepth 3 -type d 2>/dev/null | head -20
        exit 1
    fi

    echo "Installing from ${PROTON_DIST}..."
    mkdir -p "${STEAM_COMPAT_DIR}"
    cp -a "${PROTON_DIST}"/. "${STEAM_COMPAT_DIR}"/
    mkdir -p "${HEROIC_PROTON_DIR}"
    ln -sf "${STEAM_COMPAT_DIR}" "${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"

    PROTON_VER=$(cat "${STEAM_COMPAT_DIR}/version" 2>/dev/null || echo "${PROTON_BRANCH}")
    mkdir -p "${HOME}/.local/share/bazzite"
    cat << PVEREOF | sed 's/^    //' > "${HOME}/.local/share/bazzite/proton-aarch64-version"
    PROTON_VERSION=${PROTON_VER}
    PROTON_BRANCH=${PROTON_BRANCH}
    PROTON_BUILD_NAME=${PROTON_BUILD_NAME}
    PROTON_ARCH=aarch64
    PROTON_BUILD_TYPE=source
    PROTON_STEAM_PATH=${STEAM_COMPAT_DIR}
    PROTON_HEROIC_PATH=${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}
    BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    PVEREOF

    echo "Cleaning up build artifacts..."
    rm -rf "${BUILD_DIR}"
    ccache -C 2>/dev/null || true

    echo ""
    echo "Proton ${PROTON_VER} (aarch64) installed successfully."
    echo "  Steam path:  ${STEAM_COMPAT_DIR}"
    echo "  Heroic path: ${HEROIC_PROTON_DIR}/${PROTON_BUILD_NAME}"
    echo "  Restart Steam to see it in compatibility tool settings."

# Install Heroic Games Launcher from source for aarch64
[group("arm")]
install-heroic:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi

    CURRENT=""
    if [[ -f "${HOME}/.local/share/bazzite/heroic-launcher-version" ]]; then
        CURRENT=$(grep "^HEROIC_VERSION=" "${HOME}/.local/share/bazzite/heroic-launcher-version" 2>/dev/null | cut -d= -f2)
    fi

    LATEST=$(curl -LfsS --retry 3 --retry-delay 2 \
        https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases \
        | jq -r '[.[] | select(.prerelease == false and .draft == false)][0].tag_name // empty')
    if [[ -z "${LATEST}" ]]; then
        echo "ERROR: Could not fetch latest Heroic release from GitHub."
        exit 1
    fi
    LATEST_CLEAN="${LATEST#v}"

    echo "=== Install Heroic Games Launcher (aarch64) ==="
    echo ""
    echo "  Current: ${CURRENT:-not installed}"
    echo "  Latest:  ${LATEST_CLEAN}"
    echo ""
    if [[ "${CURRENT}" == "${LATEST_CLEAN}" ]]; then
        echo "Already up to date."
        exit 0
    fi
    echo "This builds Heroic from source for arm64 (takes 5-15 minutes)."
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi

    echo "--- Installing build dependencies ---"
    BUILD_DEPS=(
        nodejs npm git python3 python3-pip make gcc gcc-c++
        libX11-devel libXScrnSaver-devel libnotify-devel nss
        libdrm-devel mesa-libgbm-devel alsa-lib-devel
        cups-libs atk at-spi2-atk gtk3
    )
    RUNTIME_DEPS=(
        nodejs nss libnotify libXScrnSaver alsa-lib cups-libs
        atk at-spi2-atk gtk3 mesa-libgbm libdrm python3
    )
    sudo dnf5 -y install --skip-unavailable "${BUILD_DEPS[@]}" "${RUNTIME_DEPS[@]}" 2>&1 | tail -5

    echo "Installing pnpm..."
    sudo npm install -g pnpm 2>&1 | tail -3

    echo "Installing legendary (Epic Games CLI)..."
    pip3 install --no-cache-dir --user --break-system-packages legendary-gl 2>/dev/null || \
        echo "WARNING: legendary-gl install failed; Epic Games may need manual setup."

    BUILD_DIR="/tmp/heroic-build-$$"
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"

    echo "Cloning Heroic ${LATEST}..."
    git clone --depth 1 --branch "${LATEST}" \
        https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher.git "${BUILD_DIR}/heroic"
    cd "${BUILD_DIR}/heroic"

    echo "Installing Node.js dependencies with pnpm..."
    pnpm install --no-frozen-lockfile 2>&1 | tail -10

    echo "Compiling Heroic source (electron-vite build)..."
    npx --yes electron-vite build 2>&1 | tail -15

    echo "Packaging Heroic for linux/arm64..."
    npx --yes electron-builder build --linux dir --arm64 2>&1 | tail -30

    DIST_DIR="${BUILD_DIR}/heroic/dist/linux-arm64-unpacked"
    if [[ ! -d "${DIST_DIR}" ]]; then
        DIST_DIR="${BUILD_DIR}/heroic/dist/linux-unpacked"
    fi
    if [[ ! -d "${DIST_DIR}" ]]; then
        echo "ERROR: Build output not found."
        find "${BUILD_DIR}/heroic/dist" -maxdepth 2 -type d -name "*unpacked*" 2>/dev/null || true
        rm -rf "${BUILD_DIR}"
        exit 1
    fi

    echo "Installing Heroic to /opt/heroic..."
    sudo rm -rf /opt/heroic
    sudo mkdir -p /opt/heroic
    sudo cp -a "${DIST_DIR}"/. /opt/heroic/
    sudo chmod +x /opt/heroic/heroic 2>/dev/null || \
        sudo chmod +x /opt/heroic/heroic-games-launcher 2>/dev/null || true

    mkdir -p "${HOME}/.local/bin"
    cat << 'WRAPPER' | sed 's/^    //' > "${HOME}/.local/bin/heroic"
    #!/usr/bin/bash
    exec /opt/heroic/heroic "$@" 2>/dev/null || exec /opt/heroic/heroic-games-launcher "$@"
    WRAPPER
    chmod +x "${HOME}/.local/bin/heroic"

    mkdir -p "${HOME}/.local/share/applications"
    cat << 'DESKTOP' | sed 's/^    //' > "${HOME}/.local/share/applications/heroic.desktop"
    [Desktop Entry]
    Name=Heroic Games Launcher
    Comment=Open Source GOG and Epic Games Launcher
    Exec=${HOME}/.local/bin/heroic %U
    Terminal=false
    Type=Application
    Icon=heroic
    Categories=Game;
    MimeType=x-scheme-handler/heroic;
    StartupWMClass=heroic
    DESKTOP

    if [[ -f /opt/heroic/resources/icon.png ]]; then
        ICON_DIR="${HOME}/.local/share/icons/hicolor/256x256/apps"
        mkdir -p "${ICON_DIR}"
        cp /opt/heroic/resources/icon.png "${ICON_DIR}/heroic.png"
    fi

    mkdir -p "${HOME}/.local/share/bazzite"
    cat << VEREOF | sed 's/^    //' > "${HOME}/.local/share/bazzite/heroic-launcher-version"
    HEROIC_VERSION=${LATEST_CLEAN}
    HEROIC_ARCH=aarch64
    HEROIC_BUILD_TYPE=source
    HEROIC_INSTALL_PATH=/opt/heroic
    LEGENDARY_INSTALLED=$(command -v legendary >/dev/null 2>&1 && echo "yes" || echo "no")
    BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    VEREOF

    echo "Cleaning up build artifacts..."
    rm -rf "${BUILD_DIR}"
    npm cache clean --force 2>/dev/null || true

    echo ""
    echo "Heroic Games Launcher ${LATEST_CLEAN} installed successfully."
    echo "  Binary:  ${HOME}/.local/bin/heroic"
    echo "  Install: /opt/heroic"
    echo "  Desktop: ${HOME}/.local/share/applications/heroic.desktop"
    if command -v legendary >/dev/null 2>&1; then
        echo "  legendary (Epic Games CLI): $(command -v legendary)"
    fi

# Update Heroic Games Launcher to the latest release (alias for install-heroic)
[group("arm")]
update-heroic:
    #!/usr/bin/bash
    ujust install-heroic

# Install Proton GE (pre-built x86_64, runs via FEX-Emu) for Steam/Heroic/Lutris
[group("arm")]
install-proton-ge:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi

    echo "=== Install Proton GE (via FEX-Emu) ==="
    echo ""
    echo "Proton GE is the recommended way to run Proton on Apple Silicon."
    echo "The x86_64 binaries run through FEX-Emu emulation (same as Steam)."
    echo ""

    LATEST_GE=$(curl -LfsS --retry 3 \
        https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | jq -r '.tag_name // empty')
    if [[ -z "${LATEST_GE}" ]]; then
        echo "ERROR: Could not fetch latest Proton GE release."
        exit 1
    fi

    COMPAT_DIR="${HOME}/.steam/root/compatibilitytools.d"
    HEROIC_PROTON_DIR="${HOME}/.config/heroic/tools/proton"

    if [[ -d "${COMPAT_DIR}/${LATEST_GE}" ]]; then
        echo "Proton GE ${LATEST_GE} is already installed."
        exit 0
    fi

    TARBALL_URL=$(curl -LfsS --retry 3 \
        https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url' | head -1)
    if [[ -z "${TARBALL_URL}" ]]; then
        echo "ERROR: Could not find Proton GE download URL."
        exit 1
    fi

    echo "Version:  ${LATEST_GE}"
    echo "Download: ${TARBALL_URL}"
    echo ""
    read -rp "Download and install (~500MB)? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "${TMPDIR}"' EXIT

    echo "Downloading..."
    curl -L --retry 3 --retry-delay 5 -# \
        "${TARBALL_URL}" -o "${TMPDIR}/${LATEST_GE}.tar.gz"

    echo "Extracting..."
    mkdir -p "${COMPAT_DIR}"
    tar -xzf "${TMPDIR}/${LATEST_GE}.tar.gz" -C "${COMPAT_DIR}"/

    mkdir -p "${HEROIC_PROTON_DIR}"
    ln -sf "${COMPAT_DIR}/${LATEST_GE}" "${HEROIC_PROTON_DIR}/${LATEST_GE}"

    echo ""
    echo "Proton GE ${LATEST_GE} installed."
    echo "  Steam: restart Steam → Settings → Compatibility → select ${LATEST_GE}"
    echo "  Heroic: ${HEROIC_PROTON_DIR}/${LATEST_GE}"
    echo "  Lutris: set runner to Proton GE in game configuration"

# Configure Lutris for aarch64 (native Wine, external storage, no x86_64 runtime downloads)
[group("arm")]
setup-lutris-aarch64:
    #!/usr/bin/bash
    set -euo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi

    echo "=== Configure Lutris for aarch64 ==="
    echo ""
    echo "Lutris ships x86_64 Wine runners by default which don't work on"
    echo "Apple Silicon's 16K page kernel. This configures Lutris to use:"
    echo "  - Native aarch64 Wine ($(wine --version 2>/dev/null || echo 'not installed'))"
    echo "  - System libraries instead of x86_64 runtime downloads"
    echo "  - External drive for game storage"
    echo ""

    if ! command -v wine >/dev/null 2>&1; then
        echo "ERROR: Native Wine is not installed."
        echo "Wine should be part of the Bazzite image. Rebuild with SKIP_WINE=0."
        exit 1
    fi

    mkdir -p ~/.config/lutris
    mkdir -p ~/.local/share/lutris/runners
    GAME_PATH="${HOME}/Games"
    if [[ -L "${GAME_PATH}" ]]; then
        GAME_PATH="$(readlink -f "${GAME_PATH}")"
    fi

    cat << CONF | sed 's/^    //' > ~/.config/lutris/lutris.conf
    [lutris]
    game_path = ${GAME_PATH}
    runtime_updates = false

    [wine]
    version = system
    custom_wine_path = /usr/bin/wine
    esync = true
    fsync = true

    [system]
    disable_runtime = true
    prefer_system_libs = true
    mangohud = true
    CONF

    cat << WYML | sed 's/^    //' > ~/.local/share/lutris/runners/wine.yml
    wine:
      version: system
      custom_wine_path: /usr/bin/wine
      show_debug: "-all"
      esync: true
      fsync: true
      fsr: false
      battleye: false
      eac: false
    system:
      disable_runtime: true
      prefer_system_libs: true
      game_path: ${GAME_PATH}
    WYML

    rm -rf ~/.local/share/lutris/runtime/Ubuntu-18.04-x86_64 2>/dev/null || true
    rm -rf ~/.local/share/lutris/runtime/Ubuntu-18.04-i686 2>/dev/null || true

    echo "Lutris configured for aarch64."
    echo "  Wine:         /usr/bin/wine ($(wine --version 2>/dev/null))"
    echo "  Runtime:      system libraries (x86_64 downloads disabled)"
    echo "  Games path:   ${GAME_PATH}"
    echo ""
    echo "Note: The 'Unsupported architecture aarch64' message in Lutris is"
    echo "cosmetic and does not affect functionality with these settings."
