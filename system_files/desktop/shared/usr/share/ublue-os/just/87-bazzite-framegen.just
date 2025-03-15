# vim: set ft=make :

# Set up DLSS-Enabler Upscaling and Framegen mod. This mod replaces DLSS upscaling and frame generation with FSR3 equivalents in supported games.
get-framegen ACTION="prompt":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    FG_FILES=(
        "amd_fidelityfx_dx12.dll" "dlssg_to_fsr3_amd_is_better.dll" "libxess.dll"
        "amd_fidelityfx_vk.dll" "dlssg_to_fsr3.ini"
        "d3dcompiler_47.dll" "dxgi.dll" "nvapi64.dll"
        "DisableNvidiaSignatureChecks.reg" "dxvk.conf" "_nvngx.dll"
        "dlss-enabler.dll" "fakenvapi.ini" "nvngx.ini"
        "dlss-enabler-upscaler.dll" "fgmod" "nvngx-wrapper.dll"
        "dlssg_to_fsr3_amd_is_better-3.0.dll" "fgmod-uninstaller.sh" "RestoreNvidiaSignatureChecks.reg"
    )
    function check_fgmod_installed() {
        FG_DIR="$HOME/fgmod"
        if [[ -d "$FG_DIR" ]]; then
            for file in "${FG_FILES[@]}"; do
                # Check if 'licenses' is a directory
                if [[ "$file" == "licenses" ]]; then
                    if [[ ! -d "$FG_DIR/$file" ]]; then
                        echo "${yellow}${bold}FGmod is partially installed. 'licenses' is missing or not a directory.${normal}"
                        return
                    fi
                elif [[ ! -f "$FG_DIR/$file" ]]; then
                    echo "${yellow}${bold}FGmod is partially installed. Missing file: ${file}${normal}"
                    return
                fi
            done
            echo "${green}${bold}FGmod is installed and ready to use.${normal}"
        else
            echo "${red}${bold}FGmod is not installed.${normal}"
        fi
    }
    function check_decky_installed() {
        PLUGIN_DIR="$HOME/homebrew/plugins/Decky-Framegen"
        if [[ -d "$PLUGIN_DIR" ]]; then
            echo "${green}${bold}Decky Framegen plugin is installed.${normal}"
        else
            echo "${red}${bold}Decky Framegen plugin is not installed.${normal}"
        fi
    }
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
        echo ""
        echo "Current Status:"
        check_fgmod_installed
        echo ""
        check_decky_installed
        echo ""
        echo "${bold}FGmod${normal} enables the replacement of DLSS Upscaling and Framegen with FSR3 equivalents."
        echo ""
        echo "Below you can install or remove ${bold}FGmod${normal} files,"
        echo "or install the ${bold}Decky Framegen${normal} plugin for managing everything conveniently in Game Mode."
        echo ""
        echo "To patch a Steam game after installation, use the launch option: '~/fgmod/fgmod %COMMAND%'"
        echo "To revert changes to the game's files, use: '~/fgmod/fgmod-uninstaller.sh %COMMAND%'"
        echo ""
        echo "What would you like to do with FGmod?"
        echo ""
        OPTION=$(ugum choose "Install Decky Framegen plugin" "Install FGmod" "Uninstall FGmod" "Exit without changes")
    elif [ "$OPTION" == "help" ]; then
        echo "Usage: just get-framegen <option>"
        echo "  <option>: Specify an action - 'install', 'install-decky-plugin', or 'uninstall'"
        echo "  Use 'install' to install FGmod."
        echo "  Use 'install-decky-plugin' to install the Decky Framegen plugin."
        echo "  Use 'uninstall' to remove FGmod."
        exit 0
    fi
    if [ "${OPTION,,}" == "install" ] || [ "${OPTION,,}" == "install fgmod" ]; then
        echo "Installing FGmod..."
        TMP_DIR=$(mktemp -d) && cd "$TMP_DIR"
        git clone https://github.com/xXJSONDeruloXx/fgmod-bazzite.git .
        chmod +x prepare.sh
        ./prepare.sh
        echo "FGmod installed successfully!"
        echo "To patch a game, add the launch option '~/fgmod/fgmod %COMMAND%' in its settings."
    elif [ "${OPTION,,}" == "install-decky-plugin" ] || [ "${OPTION,,}" == "install decky framegen plugin" ]; then
        echo "Installing Decky Framegen plugin..."
        API_URL="https://api.github.com/repos/xXJSONDeruloXx/Decky-Framegen/releases/latest"
        PLUGIN_URL=$(curl -s "$API_URL" | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)

        if [ -z "$PLUGIN_URL" ]; then
            echo "Failed to fetch the latest Decky Framegen release. Exiting..."
            exit 1
        fi
        PLUGIN_NAME="Decky-Framegen"
        PLUGIN_DIR="$HOME/homebrew/plugins"
        if [ ! -d "$PLUGIN_DIR" ]; then
            echo "Creating plugins directory with sudo..."
            sudo mkdir -p "$PLUGIN_DIR"
        fi
        cd "$PLUGIN_DIR" || { echo "Failed to navigate to plugins directory"; exit 1; }
        if [ -d "$PLUGIN_NAME" ]; then
            echo "Removing existing $PLUGIN_NAME directory with sudo..."
            sudo rm -rf "$PLUGIN_NAME"
        fi
        echo "Downloading $PLUGIN_NAME from $PLUGIN_URL..."
        sudo curl -L -o "${PLUGIN_NAME}.zip" "$PLUGIN_URL"
        if [ $? -ne 0 ]; then
            echo "Download failed!"
            exit 1
        fi
        echo "Extracting $PLUGIN_NAME..."
        sudo unzip -o "${PLUGIN_NAME}.zip" -d .
        if [ $? -ne 0 ]; then
            echo "Extraction failed!"
            exit 1
        fi
        if [ -d "./${PLUGIN_NAME}/${PLUGIN_NAME}" ]; then
            echo "Fixing folder structure..."
            sudo mv ./${PLUGIN_NAME}/${PLUGIN_NAME}/* ./${PLUGIN_NAME}/
            sudo rm -rf ./${PLUGIN_NAME}/${PLUGIN_NAME}
        fi
        echo "Cleaning up..."
        sudo rm -f "${PLUGIN_NAME}.zip"
        echo "$PLUGIN_NAME has been installed successfully to $PLUGIN_DIR!"
        echo "Please restart Decky Loader to activate the plugin."
    elif [ "${OPTION,,}" == "uninstall" ] || [ "${OPTION,,}" == "uninstall fgmod" ]; then
        echo "Uninstalling FGmod..."
        if [[ -d "$HOME/fgmod" ]]; then
            rm -rf "$HOME/fgmod"
        fi
        downloads_dir="$HOME/Downloads"
        files_to_remove=("prepare.sh" "fgmod.sh" "fgmod-uninstaller.sh")
        for file in "${files_to_remove[@]}"; do
            if [[ -f "$downloads_dir/$file" ]]; then
                rm "$downloads_dir/$file"
            fi
        done
        echo "FGmod removed successfully!"
    elif [ "${OPTION,,}" == "exit" ] || [ "${OPTION,,}" == "exit without changes" ]; then
        echo "No changes made. Exiting..."
        exit 0
    else
        echo "Invalid option. Exiting..."
        exit 1
    fi
