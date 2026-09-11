# vim: set ft=make :

# Set up LSFG-VK V2. This enables Lossless Scaling frame generation on Linux. Be sure to also install Lossless Scaling through Steam.
get-lsfg ACTION="prompt":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    function get_current_status() {
        # Current LSFG-VK V2 installation
        if [[ -f "$HOME/.local/lib/liblsfg-vk-layer.so" ]] && \
           [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json" ]]; then
            echo "${green}${bold}LSFG-VK V2 Installed${normal}"

        # Legacy system-wide installation
        elif [[ -f "/usr/local/lib/liblsfg-vk.so" ]] && \
             [[ -f "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "${yellow}${bold}LSFG-VK V2 Not Installed (legacy installation detected)${normal}"

        # Legacy per-user installation
        elif [[ -f "$HOME/.local/lib/liblsfg-vk.so" ]] && \
             [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "${yellow}${bold}LSFG-VK V2 Not Installed (legacy installation detected)${normal}"
        else
            echo "${red}${bold}LSFG-VK V2 Not Installed${normal}"
        fi
    }

    function get_status_token() {
        # Preserve existing status-token behavior
        if [[ -f "$HOME/.local/lib/liblsfg-vk-layer.so" ]] && \
           [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json" ]]; then
            echo "install"
        elif [[ -f "/usr/local/lib/liblsfg-vk.so" ]] && \
             [[ -f "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "install"
        elif [[ -f "$HOME/.local/lib/liblsfg-vk.so" ]] && \
             [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "install"
        else
            echo "uninstall"
        fi
    }

    function remove_current_files() {
        rm -f \
            "$HOME/.local/bin/lsfg-vk-cli" \
            "$HOME/.local/bin/lsfg-vk-ui" \
            "$HOME/.local/lib/liblsfg-vk-layer.x86.so" \
            "$HOME/.local/lib/liblsfg-vk-layer.so" \
            "$HOME/.local/share/applications/gay.pancake.lsfg-vk-ui.desktop" \
            "$HOME/.local/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png" \
            "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.x86.json" \
            "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json"
    }

    function remove_legacy_files() {
        # Remove legacy per-user installation
        rm -f \
            "$HOME/.local/lib/liblsfg-vk.so" \
            "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" \
            "$HOME/.local/bin/lsfg-vk" \
            "$HOME/Desktop/lsfg-vk-ui.desktop"

        # Only request sudo if a legacy system-wide installation exists
        if [[ -f "/usr/local/lib/liblsfg-vk.so" ]] || \
           [[ -f "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]] || \
           [[ -f "/usr/local/bin/lsfg-vk-ui" ]] || \
           [[ -f "/usr/local/share/applications/lsfg-vk-ui.desktop" ]] || \
           [[ -f "/usr/local/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png" ]]; then

            echo "Preparing for LSFG-VK V2 by removing the legacy installation..."

            sudo rm -f \
                "/usr/local/lib/liblsfg-vk.so" \
                "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" \
                "/usr/local/bin/lsfg-vk-ui" \
                "/usr/local/share/applications/lsfg-vk-ui.desktop" \
                "/usr/local/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png"
        fi
    }

    function refresh_app_menu() {
        if command -v kbuildsycoca6 >/dev/null 2>&1; then
            kbuildsycoca6 --noincremental >/dev/null 2>&1
        fi
    }

    OPTION="{{ ACTION }}"

    case "${OPTION,,}" in
        prompt)
            current_status=$(get_current_status)
            echo "${bold}LSFG-VK V2${normal} enables Lossless Scaling frame generation on Linux."
            echo "Below you can install or remove ${bold}LSFG-VK V2${normal}."
            echo "Current status: $current_status"

            CHOICE=$(ugum choose \
                "Install LSFG-VK V2" \
                "Uninstall LSFG-VK V2" \
                "Exit without changes")

            case "$CHOICE" in
                "Install LSFG-VK V2")
                    OPTION="install"
                    ;;
                "Uninstall LSFG-VK V2")
                    OPTION="uninstall"
                    ;;
                "Exit without changes")
                    OPTION="exit"
                    ;;
                *)
                    echo "No changes made. Exiting..."
                    exit 0
                    ;;
            esac
            ;;

        help)
            echo "Usage: just get-lsfg <option>"
            echo "  <option>: Specify an action - 'install' or 'uninstall'"
            echo "  Use 'install' to install LSFG-VK V2."
            echo "  Use 'uninstall' to remove LSFG-VK V2."
            exit 0
            ;;

        status)
            get_status_token
            exit 0
            ;;
    esac

    case "${OPTION,,}" in
        install|"install lsfg-vk"|"install lsfg-vk v2")
            echo "Installing LSFG-VK V2..."
            echo "Downloading latest LSFG-VK V2 release..."

            BUILDS_URL="https://builds.lsfg-vk.dev/"

            # Find the stable build identified by upstream as "Latest release".
            RELEASE_PATH=$(
                timeout 30 curl -fsSL "$BUILDS_URL" |
                    grep 'Latest release (' |
                    sed -n 's/.*href="\([^"]*\.tar\.xz\)".*/\1/p' |
                    head -n 1
            )

            if [ -z "$RELEASE_PATH" ]; then
                echo "Failed to find the latest LSFG-VK V2 release. Exiting..."
                exit 1
            fi

            if [[ "$RELEASE_PATH" =~ ^https?:// ]]; then
                DOWNLOAD_URL="$RELEASE_PATH"
            else
                DOWNLOAD_URL="${BUILDS_URL}${RELEASE_PATH#./}"
            fi

            TEMP_DIR=$(mktemp -d)

            if [ -z "$TEMP_DIR" ] || [ ! -d "$TEMP_DIR" ]; then
                echo "Failed to create temporary directory. Exiting..."
                exit 1
            fi

            trap 'rm -rf "$TEMP_DIR"' EXIT

            ARCHIVE="$TEMP_DIR/lsfg-vk.tar.xz"

            if ! timeout 60 curl -fL "$DOWNLOAD_URL" -o "$ARCHIVE"; then
                echo "LSFG-VK V2 download failed or timed out!"
                exit 1
            fi

            # Verify this is a V2 archive before touching the existing installation.
            if ! tar -tf "$ARCHIVE" | grep -q 'lib/liblsfg-vk-layer.so' || \
               ! tar -tf "$ARCHIVE" | grep -q 'share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json'; then
                echo "Downloaded archive does not contain the expected LSFG-VK V2 files. Exiting..."
                exit 1
            fi

            # Ensure upgrades/reinstalls do not leave stale files behind.
            remove_current_files
            remove_legacy_files

            echo "Installing LSFG-VK V2 to ~/.local..."
            mkdir -p "$HOME/.local"

            if ! tar -xf "$ARCHIVE" -C "$HOME/.local"; then
                echo "LSFG-VK V2 installation failed!"
                exit 1
            fi

            # Verify the primary Vulkan layer files were installed.
            if [[ ! -f "$HOME/.local/lib/liblsfg-vk-layer.so" ]] || \
               [[ ! -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json" ]]; then
                echo "LSFG-VK V2 installation failed: expected files were not found."
                exit 1
            fi

            rm -rf "$TEMP_DIR"
            trap - EXIT

            refresh_app_menu

            echo "LSFG-VK V2 installed successfully!"
            echo
            echo "The LSFG-VK V2 UI is now available in your applications menu."
            echo "Please ensure Lossless Scaling is installed through Steam."
            ;;

        uninstall|"uninstall lsfg-vk"|"uninstall lsfg-vk v2")
            echo "Uninstalling LSFG-VK V2..."

            remove_current_files
            remove_legacy_files

            refresh_app_menu

            echo "LSFG-VK V2 uninstalled successfully!"
            ;;

        exit|"exit without changes")
            echo "No changes made. Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid option. Exiting..."
            exit 1
            ;;
    esac
