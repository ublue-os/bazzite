# vim: set ft=make :

# Set up Lossless Scaling vulkan layer. This mod enables lossless scaling compatibility in linux. Be sure to also install Lossless Scaling from Steam to internal storage.
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

    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
        echo ""
        echo "Current Status:"
        check_lsfg_installed
        echo ""
        echo "${bold}lsfg-vk${normal} enables lossless scaling functionality for supported games."
        echo ""
        echo "Below you can install or remove ${bold}lsfg-vk${normal} directly."
        echo ""
        echo "What would you like to do with lsfg-vk?"
        echo ""
        OPTION=$(ugum choose "Install lsfg-vk directly" "Install Decky Plugin" "Uninstall lsfg-vk" "Exit without changes")
    elif [ "$OPTION" == "help" ]; then
        echo "Usage: just get-lsfg <option>"
        echo "  <option>: Specify an action - 'install' or 'uninstall'"
        echo "  Use 'install' to install lsfg-vk directly."
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
    elif [ "${OPTION,,}" == "install decky plugin" ] || [ "${OPTION,,}" == "install-decky-plugin" ]; then
        echo "Installing Decky LSFG plugin..."
        ujust install-decky-plugins decky-lsfg-vk
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
