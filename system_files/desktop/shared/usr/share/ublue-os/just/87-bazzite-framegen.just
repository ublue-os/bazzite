# vim: set ft=make :

# Set up Lossless Scaling vulkan layer and decky plugin. This mod enables lossless scaling compatibility in linux. Be sure to also install Lossless Scaling from Steam to internal storage.
get-lsfg ACTION="prompt":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    function check_lsfg_installed() {
        # Check new installation location
        if [[ -f "/usr/local/lib/liblsfg-vk.so" ]] && [[ -f "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "${green}${bold}lsfg-vk is installed and ready to use.${normal}"
        # Check legacy installation location
        elif [[ -f "$HOME/.local/lib/liblsfg-vk.so" ]] && [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            echo "${yellow}${bold}lsfg-vk is installed (legacy location) - consider reinstalling for latest version.${normal}"
        else
            echo "${red}${bold}lsfg-vk is not installed.${normal}"
        fi
    }

    function check_decky_lsfg_installed() {
        BASE="$HOME/homebrew/plugins"
        NEW_PLUGIN_DIR="$BASE/decky-lsfg-vk"
        LEGACY_DIR1="$BASE/Lossless Scaling"
        LEGACY_DIR2="$BASE/Lossless-Scaling"
        if [[ -d "$NEW_PLUGIN_DIR" ]]; then
            echo "${green}${bold}Decky lsfg-vk plugin (new name) is installed.${normal}"
            if [[ -d "$LEGACY_DIR1" || -d "$LEGACY_DIR2" ]]; then
                echo "${yellow}${bold}Legacy Lossless Scaling plugin directory also present; you can remove it from Decky settings.${normal}"
            fi
        elif [[ -d "$LEGACY_DIR1" || -d "$LEGACY_DIR2" ]]; then
            echo "${yellow}${bold}Legacy Lossless Scaling plugin detected. Reinstall to migrate to new decky-lsfg-vk name.${normal}"
        else
            echo "${red}${bold}Decky Lossless Scaling plugin is not installed.${normal}"
        fi
    }

    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
        echo ""
        echo "Current Status:"
        check_lsfg_installed
        echo ""
        check_decky_lsfg_installed
        echo ""
        echo "${bold}lsfg-vk${normal} enables lossless scaling functionality for supported games."
        echo ""
        echo "Below you can install or remove ${bold}lsfg-vk${normal} directly,"
        echo "or install the ${bold}Decky Lossless Scaling${normal} plugin for managing everything conveniently in Game Mode."
        echo ""
        echo "What would you like to do with lsfg-vk?"
        echo ""
        OPTION=$(ugum choose "Install Decky Lossless Scaling plugin" "Install lsfg-vk directly" "Uninstall lsfg-vk" "Exit without changes")
    elif [ "$OPTION" == "help" ]; then
        echo "Usage: just get-lsfg <option>"
        echo "  <option>: Specify an action - 'install', 'install-decky-plugin', or 'uninstall'"
        echo "  Use 'install' to install lsfg-vk directly."
        echo "  Use 'install-decky-plugin' to install the Decky Lossless Scaling plugin."
        echo "  Use 'uninstall' to remove lsfg-vk."
        exit 0
    fi

    if [ "${OPTION,,}" == "install" ] || [ "${OPTION,,}" == "install lsfg-vk directly" ]; then
        echo "Installing lsfg-vk directly..."

        # Get the latest release download URL
        API_URL="https://api.github.com/repos/PancakeTAS/lsfg-vk/releases/latest"
        DOWNLOAD_URL=$(timeout 30 curl -s "$API_URL" | grep "browser_download_url" | grep "lsfg-vk.*x86_64\.zip" | cut -d '"' -f 4 || echo "")

        if [ -z "$DOWNLOAD_URL" ]; then
            echo "Failed to fetch the latest lsfg-vk release or API timeout. Exiting..."
            exit 1
        fi

        # Work in a temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR" || { echo "Failed to create temp directory"; exit 1; }

        echo "Downloading lsfg-vk from $DOWNLOAD_URL..."
        timeout 60 curl -L -o "lsfg-vk.zip" "$DOWNLOAD_URL"
        if [ $? -ne 0 ]; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        echo "Extracting lsfg-vk..."
        unzip -o "lsfg-vk.zip" -d .
        if [ $? -ne 0 ]; then
            echo "Extraction failed!"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Check if files were extracted directly to current directory
        if [ -f "./lib/liblsfg-vk.so" ] && [ -f "./share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]; then
            echo "Files extracted directly to current directory"
            EXTRACTED_DIR="."
        else
            # Find the extracted directory
            EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "lsfg-vk*" | head -n 1)
            if [ -z "$EXTRACTED_DIR" ]; then
                echo "Could not find extracted lsfg-vk directory!"
                cd - > /dev/null
                rm -rf "$TEMP_DIR"
                exit 1
            fi
            echo "Found extracted directory: $EXTRACTED_DIR"
        fi

        # Remove legacy files if they exist
        echo "Removing legacy lsfg-vk files if they exist..."
        if [[ -f "$HOME/.local/lib/liblsfg-vk.so" ]]; then
            rm -fv "$HOME/.local/lib/liblsfg-vk.so"
            echo "Removed legacy lsfg-vk library"
        fi

        if [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            rm -fv "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
            echo "Removed legacy lsfg-vk Vulkan layer"
        fi

        # Install to /usr/local with sudo
        echo "Installing lsfg-vk to /usr/local..."
        if [ -d "$EXTRACTED_DIR/bin" ]; then
            sudo cp -r "$EXTRACTED_DIR/bin"/* /usr/local/bin/
            sudo chmod +x /usr/local/bin/lsfg-vk-ui
            echo "Installed binaries to /usr/local/bin/ and made executable"
        fi

        if [ -d "$EXTRACTED_DIR/lib" ]; then
            sudo mkdir -p /usr/local/lib
            sudo cp -r "$EXTRACTED_DIR/lib"/* /usr/local/lib/
            echo "Installed libraries to /usr/local/lib/"
        fi

        if [ -d "$EXTRACTED_DIR/share" ]; then
            sudo mkdir -p /usr/local/share
            sudo cp -r "$EXTRACTED_DIR/share"/* /usr/local/share/
            echo "Installed shared files to /usr/local/share/"
        fi

        # Fix the Vulkan layer JSON to use the correct library path
        VULKAN_LAYER_FILE="/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
        if [ -f "$VULKAN_LAYER_FILE" ]; then
            echo "Updating Vulkan layer library path..."
            sudo sed -i 's|"library_path": "liblsfg-vk.so"|"library_path": "../../../lib/liblsfg-vk.so"|' "$VULKAN_LAYER_FILE"
            echo "Updated Vulkan layer library path to use absolute reference"
        fi

        # Copy desktop file to user's desktop if it exists
        DESKTOP_FILE="$EXTRACTED_DIR/share/applications/lsfg-vk-ui.desktop"
        if [ -f "$DESKTOP_FILE" ]; then
            mkdir -p "$HOME/Desktop"
            cp "$DESKTOP_FILE" "$HOME/Desktop/"
            chmod +x "$HOME/Desktop/lsfg-vk-ui.desktop"
            echo "Copied desktop file to ~/Desktop/"
        fi

        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"

        echo "lsfg-vk installed successfully!"
        echo "The lsfg-vk UI should now be available in your applications menu and on your desktop."
    elif [ "${OPTION,,}" == "install-decky-plugin" ] || [ "${OPTION,,}" == "install decky lossless scaling plugin" ]; then
        echo "Installing Decky Lossless Scaling plugin..."

        # Check if Decky is installed
        if [ ! -d "$HOME/homebrew" ]; then
            echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
            exit 1
        fi

        # Robust fetch of most recent release asset (including pre-releases) with fallbacks and debug
        API_URL="https://api.github.com/repos/xXJSONDeruloXx/decky-lsfg-vk/releases"
        DIRECT_ASSET_URL="https://github.com/xXJSONDeruloXx/decky-lsfg-vk/releases/latest/download/decky-lsfg-vk.zip"
        TMP_API_JSON=$(mktemp)
        AUTH_HEADER=""
        if [ -n "$GITHUB_TOKEN" ]; then
            AUTH_HEADER="-H Authorization: Bearer $GITHUB_TOKEN"
        fi
        HTTP_STATUS=$(curl -sSL -w "%{http_code}" -o "$TMP_API_JSON" -H "Accept: application/vnd.github+json" -H "User-Agent: bazzite-just" $AUTH_HEADER "$API_URL" || echo "000")
        [ "${LSFG_DEBUG}" = "1" ] && echo "Debug: API status $HTTP_STATUS"
        if [ "$HTTP_STATUS" != "200" ]; then
            [ "${LSFG_DEBUG}" = "1" ] && echo "Debug: API response:" && sed 's/.*/    &/' "$TMP_API_JSON"
        fi
        PLUGIN_URL=""
        if command -v jq >/dev/null 2>&1 && [ "$HTTP_STATUS" = "200" ]; then
            PLUGIN_URL=$(jq -r '.[0].assets[]?.browser_download_url | select(test("decky-lsfg-vk.*\\.zip$"))' "$TMP_API_JSON" | head -n1)
        fi
        if [ -z "$PLUGIN_URL" ] && [ "$HTTP_STATUS" = "200" ]; then
            # Fallback without jq: parse JSON to get first release's assets
            PLUGIN_URL=$(awk -F '"' '/browser_download_url/ && /decky-lsfg-vk/ && /zip/ {for(i=1;i<=NF;i++){if($i ~ /^https:.*decky-lsfg-vk.*zip$/){print $i; exit}}}' "$TMP_API_JSON" | head -n1)
        fi
        rm -f "$TMP_API_JSON"
        if [ -z "$PLUGIN_URL" ]; then
            [ "${LSFG_DEBUG}" = "1" ] && echo "Debug: Falling back to direct asset URL pattern"
            PLUGIN_URL="$DIRECT_ASSET_URL"
        fi

        # Quick HEAD check to ensure asset exists (ignore errors)
        if ! curl -sI -L -H "User-Agent: bazzite-just" "$PLUGIN_URL" | grep -qi "200"; then
            echo "Failed to fetch the latest decky-lsfg-vk release (asset not reachable). Exiting..."
            exit 1
        fi

        PLUGIN_NAME="decky-lsfg-vk"
        PLUGIN_DIR="$HOME/homebrew/plugins"

        # Ensure plugins directory exists and has correct permissions
        if [ ! -d "$PLUGIN_DIR" ]; then
            echo "Creating plugins directory..."
            sudo mkdir -p "$PLUGIN_DIR"
        fi

        # Work in a temporary directory to avoid permission issues
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR" || { echo "Failed to create temp directory"; exit 1; }

        # Remove any existing plugin folder (new name)
        if [ -d "$PLUGIN_DIR/$PLUGIN_NAME" ]; then
            echo "Removing existing $PLUGIN_NAME directory..."
            sudo rm -rf "$PLUGIN_DIR/$PLUGIN_NAME"
        fi
        # Remove legacy plugin folders if present
        for legacy in "Lossless Scaling" "Lossless-Scaling"; do
            if [ -d "$PLUGIN_DIR/$legacy" ]; then
                echo "Removing legacy plugin directory: $legacy"
                sudo rm -rf "$PLUGIN_DIR/$legacy"
            fi
        done

        echo "Downloading $PLUGIN_NAME from $PLUGIN_URL..."
        ASSET_NAME=$(basename "$PLUGIN_URL")
        if ! timeout 120 curl -L --fail -H "User-Agent: bazzite-just" -o "$ASSET_NAME" "$PLUGIN_URL"; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        echo "Extracting $PLUGIN_NAME..."
        if ! unzip -o "$ASSET_NAME" -d . >/dev/null; then
            echo "Extraction failed!"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Handle nested folder structure if needed
        if [ -d "./${PLUGIN_NAME}/${PLUGIN_NAME}" ]; then
            echo "Fixing folder structure..."
            mv "./${PLUGIN_NAME}/${PLUGIN_NAME}"/* "./${PLUGIN_NAME}/"
            rm -rf "./${PLUGIN_NAME}/${PLUGIN_NAME}"
        fi

        # Handle different extracted folder names (legacy or variant)
        EXTRACTED_FOLDERS=$(find . -maxdepth 1 -type d \( -name "decky*lsfg*vk*" -o -name "Lossless*Scaling*" -o -name "lossless*scaling*" \) | grep -v "^\./$" || echo "")
        if [ -n "$EXTRACTED_FOLDERS" ] && [ ! -d "./$PLUGIN_NAME" ]; then
            FOUND_FOLDER=$(echo "$EXTRACTED_FOLDERS" | head -n 1)
            echo "Found plugin folder with different name: $FOUND_FOLDER"
            echo "Renaming to $PLUGIN_NAME..."
            mv "$FOUND_FOLDER" "./$PLUGIN_NAME"
        fi

        # Move plugin to final location
        if [ -d "./$PLUGIN_NAME" ]; then
            echo "Installing plugin to $PLUGIN_DIR..."
            sudo mv "./$PLUGIN_NAME" "$PLUGIN_DIR/"

            # Fix permissions on plugin files and make scripts executable
            echo "Setting correct permissions..."
            sudo find "$PLUGIN_DIR/$PLUGIN_NAME" -type f -name "*.sh" -exec chmod +x {} \;
            sudo find "$PLUGIN_DIR/$PLUGIN_NAME" -type f -name "*.py" -exec chmod +x {} \;

            echo "$PLUGIN_NAME has been installed successfully to $PLUGIN_DIR!"
            echo "Please restart Decky Loader to activate the plugin."
        else
            echo "Installation failed. Plugin folder could not be found as expected."
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    elif [ "${OPTION,,}" == "uninstall" ] || [ "${OPTION,,}" == "uninstall lsfg-vk" ]; then
        echo "Uninstalling lsfg-vk..."

        # Remove new installation files from /usr/local
        if [[ -f "/usr/local/lib/liblsfg-vk.so" ]]; then
            sudo rm -fv "/usr/local/lib/liblsfg-vk.so"
            echo "Removed lsfg-vk library from /usr/local"
        fi

        if [[ -f "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            sudo rm -fv "/usr/local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
            echo "Removed lsfg-vk Vulkan layer from /usr/local"
        fi

        if [[ -f "/usr/local/bin/lsfg-vk-ui" ]]; then
            sudo rm -fv "/usr/local/bin/lsfg-vk-ui"
            echo "Removed lsfg-vk UI binary from /usr/local"
        fi

        if [[ -f "/usr/local/share/applications/lsfg-vk-ui.desktop" ]]; then
            sudo rm -fv "/usr/local/share/applications/lsfg-vk-ui.desktop"
            echo "Removed lsfg-vk desktop file from /usr/local"
        fi

        if [[ -f "/usr/local/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png" ]]; then
            sudo rm -fv "/usr/local/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png"
            echo "Removed lsfg-vk icon from /usr/local"
        fi

        # Remove legacy installation files from ~/.local
        if [[ -f "$HOME/.local/lib/liblsfg-vk.so" ]]; then
            rm -fv "$HOME/.local/lib/liblsfg-vk.so"
            echo "Removed legacy lsfg-vk library from ~/.local"
        fi

        if [[ -f "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json" ]]; then
            rm -fv "$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
            echo "Removed legacy lsfg-vk Vulkan layer from ~/.local"
        fi

        # Remove desktop file from user's desktop
        if [[ -f "$HOME/Desktop/lsfg-vk-ui.desktop" ]]; then
            rm -fv "$HOME/Desktop/lsfg-vk-ui.desktop"
            echo "Removed lsfg-vk desktop file from ~/Desktop"
        fi

        # Remove lsfg-vk binary if it exists (legacy cleanup)
        if [[ -f "$HOME/.local/bin/lsfg-vk" ]]; then
            rm -f "$HOME/.local/bin/lsfg-vk"
            echo "Removed legacy lsfg-vk binary from ~/.local/bin/"
        fi

        echo "lsfg-vk uninstalled successfully!"
    elif [ "${OPTION,,}" == "exit" ] || [ "${OPTION,,}" == "exit without changes" ]; then
        echo "No changes made. Exiting..."
        exit 0
    else
        echo "Invalid option. Exiting..."
        exit 1
    fi
