# vim: set ft=make :

# Download and install latest Mesa Git build from mesa-maker releases for testing cutting-edge graphics features
_mesa-git ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    MESA_INSTALL_DIR="$HOME/mesa-git"
    MESA_MAKER_REPO="https://api.github.com/repos/xXJSONDeruloXx/mesa-maker/releases/latest"
    TEMP_DIR=$(mktemp -d)

    if [[ $UID -eq 0 ]]; then
        echo -e "\n${red}${bold}This script should not be run as root.${normal}\n"
        exit 1
    fi

    # Show status at the top with spacing and usage info
    echo ""
    echo -e "${bold}${blue}═══════════════════════════════════════════════════════════════${normal}"
    if [ -d "$MESA_INSTALL_DIR" ]; then
        echo -e "${green}${bold}Mesa Git installation found!${normal}"
        echo -e "${blue}Location:${normal}   $MESA_INSTALL_DIR"
        if [ -f "$MESA_INSTALL_DIR/build-info.txt" ]; then
            echo -e "${blue}Version:${normal}    $(cat "$MESA_INSTALL_DIR/build-info.txt" | head -1)"
        fi
        echo ""
        echo -e "${yellow}To use with Steam:${normal}"
        echo -e "  Set your game's launch options to:"
        echo -e "  ${bold}mesa-git %command%${normal}"
        echo ""
        echo -e "${yellow}To use with any program:${normal}"
        echo -e "  ${bold}mesa-git <your-program> [args...]${normal}"
        echo ""
    else
        echo -e "${red}${bold}Mesa Git installation not found${normal}"
        echo "Run 'ujust _mesa-git download' to get the latest release."
        echo ""
    fi
    echo -e "${bold}${blue}═══════════════════════════════════════════════════════════════${normal}"
    echo ""
    echo -e "${bold}Mesa Git Installer${normal}"
    echo -e "${blue}Choose an action:${normal}"
    echo -e "  ${bold}Download Mesa (latest)${normal}    - Download Mesa from the latest mesa-maker release."
    echo -e "  ${bold}Reinstall Mesa (force)${normal}    - Force a clean reinstall, even if already installed."
    echo -e "  ${bold}Cleanup Mesa install${normal}      - Remove Mesa Git installation."
    echo -e "  ${bold}Exit${normal}                      - Exit this menu."
    echo ""
    OPTION=$(ugum choose "Download Mesa (latest)" "Reinstall Mesa (force)" "Cleanup Mesa install" "Exit")
    case "$OPTION" in
        "Download Mesa (latest)") OPTION="download" ;;
        "Reinstall Mesa (force)") OPTION="reinstall" ;;
        "Cleanup Mesa install") OPTION="cleanup" ;;
        "Exit"|*) exit 0 ;;
    esac

    if [ "$OPTION" = "cleanup" ]; then
        echo -e "${yellow}Cleaning up Mesa Git installation...${normal}"
        if [ -d "$MESA_INSTALL_DIR" ]; then
            echo "Removing Mesa installation at $MESA_INSTALL_DIR..."
            rm -rf "$MESA_INSTALL_DIR"
        fi
        echo -e "${green}Mesa Git cleanup completed${normal}"
        exit 0
    fi

    if [ "$OPTION" = "reinstall" ]; then
        echo -e "${yellow}Forcing reinstall of Mesa Git...${normal}"
        rm -rf "$MESA_INSTALL_DIR"
    elif [ "$OPTION" = "download" ]; then
        if [ -d "$MESA_INSTALL_DIR" ]; then
            echo -e "${yellow}${bold}Mesa Git installation already exists at $MESA_INSTALL_DIR${normal}"
            echo "Use the picker to reinstall or clean up."
            exit 0
        fi
    fi

    # Cleanup temp directory on exit
    trap "rm -rf '$TEMP_DIR'" EXIT

    echo -e "${blue}Fetching latest Mesa release information...${normal}"

    # Get download URL for mesa-git.zip from latest release
    DOWNLOAD_URL=$(curl -s "$MESA_MAKER_REPO" | grep -o '"browser_download_url": *"[^"]*mesa-git\.zip"' | grep -o 'https://[^"]*')

    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${red}${bold}Error: Could not find mesa-git.zip in latest release${normal}"
        echo "Please check https://github.com/xXJSONDeruloXx/mesa-maker/releases"
        exit 1
    fi

    echo -e "${blue}Downloading Mesa Git from: ${normal}$DOWNLOAD_URL"

    # Download the zip file
    if ! curl -L -o "$TEMP_DIR/mesa-git.zip" "$DOWNLOAD_URL"; then
        echo -e "${red}${bold}Error: Failed to download Mesa Git archive${normal}"
        exit 1
    fi

    echo -e "${blue}Extracting Mesa Git to $MESA_INSTALL_DIR...${normal}"

    # Create the installation directory
    mkdir -p "$MESA_INSTALL_DIR"

    # Extract the zip file
    if ! unzip -q "$TEMP_DIR/mesa-git.zip" -d "$TEMP_DIR"; then
        echo -e "${red}${bold}Error: Failed to extract Mesa Git archive${normal}"
        exit 1
    fi

    # Find the extracted directory (should contain the mesa files)
    EXTRACTED_DIR=$(find "$TEMP_DIR" -name "lib64" -type d | head -1 | xargs dirname)

    if [ -z "$EXTRACTED_DIR" ]; then
        echo -e "${red}${bold}Error: Could not find lib64 directory in extracted archive${normal}"
        exit 1
    fi

    # Move contents to installation directory
    cp -r "$EXTRACTED_DIR"/* "$MESA_INSTALL_DIR/"

    echo -e "\n${bold}${green}Mesa Git installation completed!${normal}\n"
    echo -e "${blue}═══════════════════════════════════════════════════════════════${normal}"
    echo -e "${bold}${blue}Installation Location:${normal} ${bold}$MESA_INSTALL_DIR${normal}"
    if [ -f "$MESA_INSTALL_DIR/build-info.txt" ]; then
        echo -e "${bold}${blue}Version:${normal} ${bold}$(cat "$MESA_INSTALL_DIR/build-info.txt" | head -1)${normal}"
    fi
    echo -e "${yellow}${bold}Usage Examples:${normal}"
    echo -e "  ${bold}# Test OpenGL:${normal}"
    echo -e "  ${green}mesa-git glxinfo | grep 'OpenGL version'${normal}"
    echo -e "  ${bold}# Test Vulkan:${normal}"
    echo -e "  ${green}mesa-git vulkaninfo | head -20${normal}"
    echo -e "  ${bold}# Run application with custom Mesa:${normal}"
    echo -e "  ${green}mesa-git your-application${normal}"
    echo -e "  ${bold}# Steam launch option:${normal}"
    echo -e "  ${green}mesa-git %command%${normal}"
    echo -e "${blue}═══════════════════════════════════════════════════════════════${normal}\n"
