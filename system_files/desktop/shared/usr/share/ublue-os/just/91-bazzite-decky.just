# vim: set ft=make :

# Install and configure Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader) and plugins for alternative handhelds. Options: status | install | install-prerelease | uninstall
[group("gaming")]
setup-decky ACTION="":
    #!/usr/bin/bash
    if [[ $(id -u) -eq 0 ]]; then
        echo >&2 "ERROR: Do not run this with sudo"
        exit 1
    fi
    source /usr/lib/ujust/ujust.sh
    get_status_token() {
      local decky_service="/etc/systemd/system/plugin_loader.service"
      if [[ ! -f /etc/systemd/system/multi-user.target.wants/plugin_loader.service ]]; then
        echo "uninstall"
      elif [[ -r "$decky_service" ]] && grep -q 'Environment=LOG_LEVEL=DEBUG' "$decky_service"; then
        echo "install-prerelease"
      elif [[ -r "$decky_service" ]]; then
        echo "install"
      else
        return 1
      fi
    }
    DECKY_STATE="${b}${red}Not Installed${n}"
    case "$(get_status_token)" in
      install)
        DECKY_STATE="${b}${green}Installed${n}"
        ;;
      install-prerelease)
        DECKY_STATE="${b}${yellow}Installed (Prerelease)${n}"
        ;;
      uninstall)
        DECKY_STATE="${b}${red}Not Installed${n}"
        ;;
    esac
    install_release() {
      export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
      if [ ! -L "/home/deck" ] && [ ! -e "/home/deck" ]  && [ "$HOME" != "/home/deck" ]; then
        echo "Making a /home/deck symlink to fix plugins that do not use environment variables."
        sudo -A ln -sf "$HOME" /home/deck
      fi
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh |
        sed 's|sudo|sudo -A |g' | sh
      sudo -A chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
    }
    install_prerelease() {
      export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
      if [ ! -L "/home/deck" ] && [ ! -e "/home/deck" ]  && [ "$HOME" != "/home/deck" ]; then
        echo "Making a /home/deck symlink to fix plugins that do not use environment variables."
        sudo -A ln -sf "$HOME" /home/deck
      fi
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_prerelease.sh | sh
      sudo -A chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
    }
    uninstall() {
      echo "Uninstalling Decky Loader..."
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh | sh
      echo "Decky Loader has been uninstalled."
    }
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-decky <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal token"
      echo "  Use 'install' to select Install Decky"
      echo "  Use 'install-prerelease' to select Install Decky Prerelease"
      echo "  Use 'uninstall' to uninstall Decky Loader"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit $?
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Decky Loader setup and configuration${normal}"
      echo "Decky is $DECKY_STATE"
      OPTION=$(ugum choose "Install Decky" "Install Decky Prerelease" "Uninstall Decky" "Exit")
      case "$OPTION" in
        "Install Decky")
        install_release
        ;;
        "Install Decky Prerelease")
        install_prerelease
        ;;
        "Uninstall Decky")
        uninstall
        ;;
        "Exit")
        echo "No changes were made."
        ;;
        *)
        echo "No changes were made."
        ;;
      esac
    elif [[ "$OPTION" == "install" ]]; then
      install_release
      exit 0
    elif [[ "$OPTION" == "install-prerelease" ]] || [[ "$OPTION" == "prerelease" ]]; then
      install_prerelease
      exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
      uninstall
      exit 0
    fi

# Manage Decky Bazzite Buddy plugin. Options: status | install | uninstall
get-decky-bazzite-buddy ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    REPO_OWNER="ublue-os"
    REPO_NAME="decky-bazzite-buddy"
    PLUGIN_NAME="Bazzite Buddy"
    FILENAME="Bazzite.Buddy.zip"
    PLUGIN_BASE_DIR="$HOME/homebrew/plugins"
    PLUGIN_DIR="$HOME/homebrew/plugins/Bazzite Buddy"
    get_status_token() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            echo "install"
        else
            echo "uninstall"
        fi
    }
    get_current_status() {
        if [[ "$(get_status_token)" == "install" ]]; then
            echo "Installed"
        else
            echo "Not Installed"
        fi
    }
    install_plugin() {
        echo "Installing $PLUGIN_NAME..."
        if [ ! -d "$HOME/homebrew" ]; then
            echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
            return 1
        fi
        echo "Fetching latest release information for $PLUGIN_NAME..."
        local release_info
        release_info=$(timeout 30 curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" || echo "")
        local download_url=""
        if [ -n "$release_info" ]; then
            download_url=$(echo "$release_info" | jq -r --arg filename "$FILENAME" '.assets[] | select(.name == $filename) | .browser_download_url' 2>/dev/null || echo "")
        fi
        local plugin_url
        if [ -z "$download_url" ]; then
            echo "Specified file '$FILENAME' not found in latest release or API timeout. Using direct URL..."
            plugin_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest/download/$FILENAME"
        else
            plugin_url="$download_url"
            echo "Found specified file in release: $plugin_url"
        fi
        if [ ! -d "$PLUGIN_BASE_DIR" ]; then
            echo "Creating plugins directory..."
            sudo mkdir -p "$PLUGIN_BASE_DIR"
        fi
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo "Failed to create temp directory"; return 1; }
        if [ -d "$PLUGIN_DIR" ]; then
            echo "Removing existing $PLUGIN_NAME directory..."
            sudo rm -rf "$PLUGIN_DIR"
        fi
        echo "Downloading $PLUGIN_NAME from $plugin_url..."
        local temp_file="plugin_file"
        if ! timeout 60 curl -L -o "$temp_file" "$plugin_url"; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        echo "Extracting $PLUGIN_NAME..."
        if [[ "$plugin_url" == *.tar.gz ]]; then
            if ! tar -xzf "$temp_file"; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        elif [[ "$plugin_url" == *.zip ]]; then
            if ! unzip -o "$temp_file" -d .; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        else
            echo "Unsupported file type. Only .zip and .tar.gz are supported."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        local extracted_folders
        extracted_folders=$(find . -maxdepth 1 -type d -not -name "." | head -n 1)
        if [ -n "$extracted_folders" ] && [ "$extracted_folders" != "./$PLUGIN_NAME" ]; then
            echo "Found plugin folder: $extracted_folders"
            echo "Renaming to $PLUGIN_NAME..."
            mv "$extracted_folders" "./$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME/$PLUGIN_NAME" ]; then
            echo "Fixing nested folder structure..."
            mv "./$PLUGIN_NAME/$PLUGIN_NAME/"* "./$PLUGIN_NAME/" 2>/dev/null || true
            rm -rf "./$PLUGIN_NAME/$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME" ]; then
            echo "Installing $PLUGIN_NAME to $PLUGIN_BASE_DIR..."
            sudo mv "./$PLUGIN_NAME" "$PLUGIN_BASE_DIR/"
            echo "Setting correct permissions..."
            sudo find "$PLUGIN_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            sudo find "$PLUGIN_DIR" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
            echo "$PLUGIN_NAME has been installed successfully!"
            echo "Please restart Decky Loader to activate the plugin."
        else
            echo "Installation failed. Plugin folder could not be found."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 0
    }
    uninstall_plugin() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            sudo rm -rf "$PLUGIN_DIR"
            echo "Bazzite Buddy has been uninstalled."
        else
            echo "Bazzite Buddy is not installed."
        fi
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_plugin
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_plugin
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Decky Bazzite Buddy plugin${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_plugin
                ;;
            "Uninstall")
                uninstall_plugin
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Manage Decky Lossless Scaling plugin. Options: status | install | uninstall
get-decky-lossless-scaling ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    REPO_OWNER="xXJSONDeruloXx"
    REPO_NAME="decky-lsfg-vk"
    PLUGIN_NAME="decky-lsfg-vk"
    FILENAME="Decky.LSFG-VK.zip"
    PLUGIN_BASE_DIR="$HOME/homebrew/plugins"
    PLUGIN_DIR="$HOME/homebrew/plugins/decky-lsfg-vk"
    get_status_token() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            echo "install"
        else
            echo "uninstall"
        fi
    }
    get_current_status() {
        if [[ "$(get_status_token)" == "install" ]]; then
            echo "Installed"
        else
            echo "Not Installed"
        fi
    }
    install_plugin() {
        echo "Installing $PLUGIN_NAME..."
        if [ ! -d "$HOME/homebrew" ]; then
            echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
            return 1
        fi
        echo "Fetching latest release information for $PLUGIN_NAME..."
        local release_info
        release_info=$(timeout 30 curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" || echo "")
        local download_url=""
        if [ -n "$release_info" ]; then
            download_url=$(echo "$release_info" | jq -r --arg filename "$FILENAME" '.assets[] | select(.name == $filename) | .browser_download_url' 2>/dev/null || echo "")
        fi
        local plugin_url
        if [ -z "$download_url" ]; then
            echo "Specified file '$FILENAME' not found in latest release or API timeout. Using direct URL..."
            plugin_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest/download/$FILENAME"
        else
            plugin_url="$download_url"
            echo "Found specified file in release: $plugin_url"
        fi
        if [ ! -d "$PLUGIN_BASE_DIR" ]; then
            echo "Creating plugins directory..."
            sudo mkdir -p "$PLUGIN_BASE_DIR"
        fi
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo "Failed to create temp directory"; return 1; }
        if [ -d "$PLUGIN_DIR" ]; then
            echo "Removing existing $PLUGIN_NAME directory..."
            sudo rm -rf "$PLUGIN_DIR"
        fi
        echo "Downloading $PLUGIN_NAME from $plugin_url..."
        local temp_file="plugin_file"
        if ! timeout 60 curl -L -o "$temp_file" "$plugin_url"; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        echo "Extracting $PLUGIN_NAME..."
        if [[ "$plugin_url" == *.tar.gz ]]; then
            if ! tar -xzf "$temp_file"; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        elif [[ "$plugin_url" == *.zip ]]; then
            if ! unzip -o "$temp_file" -d .; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        else
            echo "Unsupported file type. Only .zip and .tar.gz are supported."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        local extracted_folders
        extracted_folders=$(find . -maxdepth 1 -type d -not -name "." | head -n 1)
        if [ -n "$extracted_folders" ] && [ "$extracted_folders" != "./$PLUGIN_NAME" ]; then
            echo "Found plugin folder: $extracted_folders"
            echo "Renaming to $PLUGIN_NAME..."
            mv "$extracted_folders" "./$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME/$PLUGIN_NAME" ]; then
            echo "Fixing nested folder structure..."
            mv "./$PLUGIN_NAME/$PLUGIN_NAME/"* "./$PLUGIN_NAME/" 2>/dev/null || true
            rm -rf "./$PLUGIN_NAME/$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME" ]; then
            echo "Installing $PLUGIN_NAME to $PLUGIN_BASE_DIR..."
            sudo mv "./$PLUGIN_NAME" "$PLUGIN_BASE_DIR/"
            echo "Setting correct permissions..."
            sudo find "$PLUGIN_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            sudo find "$PLUGIN_DIR" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
            echo "$PLUGIN_NAME has been installed successfully!"
            echo "Please restart Decky Loader to activate the plugin."
        else
            echo "Installation failed. Plugin folder could not be found."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 0
    }
    uninstall_plugin() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            sudo rm -rf "$PLUGIN_DIR"
            echo "Decky Lossless Scaling has been uninstalled."
        else
            echo "Decky Lossless Scaling is not installed."
        fi
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_plugin
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_plugin
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Decky Lossless Scaling plugin${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_plugin
                ;;
            "Uninstall")
                uninstall_plugin
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Manage Decky Framegen plugin. Options: status | install | uninstall
get-framegen ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    REPO_OWNER="xXJSONDeruloXx"
    REPO_NAME="Decky-Framegen"
    PLUGIN_NAME="Decky-Framegen"
    FILENAME="Decky.Framegen.zip"
    PLUGIN_BASE_DIR="$HOME/homebrew/plugins"
    PLUGIN_DIR="$HOME/homebrew/plugins/Decky-Framegen"
    get_status_token() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            echo "install"
        else
            echo "uninstall"
        fi
    }
    get_current_status() {
        if [[ "$(get_status_token)" == "install" ]]; then
            echo "Installed"
        else
            echo "Not Installed"
        fi
    }
    install_plugin() {
        echo "Installing $PLUGIN_NAME..."
        if [ ! -d "$HOME/homebrew" ]; then
            echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
            return 1
        fi
        echo "Fetching latest release information for $PLUGIN_NAME..."
        local release_info
        release_info=$(timeout 30 curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" || echo "")
        local download_url=""
        if [ -n "$release_info" ]; then
            download_url=$(echo "$release_info" | jq -r --arg filename "$FILENAME" '.assets[] | select(.name == $filename) | .browser_download_url' 2>/dev/null || echo "")
        fi
        local plugin_url
        if [ -z "$download_url" ]; then
            echo "Specified file '$FILENAME' not found in latest release or API timeout. Using direct URL..."
            plugin_url="https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest/download/$FILENAME"
        else
            plugin_url="$download_url"
            echo "Found specified file in release: $plugin_url"
        fi
        if [ ! -d "$PLUGIN_BASE_DIR" ]; then
            echo "Creating plugins directory..."
            sudo mkdir -p "$PLUGIN_BASE_DIR"
        fi
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo "Failed to create temp directory"; return 1; }
        if [ -d "$PLUGIN_DIR" ]; then
            echo "Removing existing $PLUGIN_NAME directory..."
            sudo rm -rf "$PLUGIN_DIR"
        fi
        echo "Downloading $PLUGIN_NAME from $plugin_url..."
        local temp_file="plugin_file"
        if ! timeout 60 curl -L -o "$temp_file" "$plugin_url"; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        echo "Extracting $PLUGIN_NAME..."
        if [[ "$plugin_url" == *.tar.gz ]]; then
            if ! tar -xzf "$temp_file"; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        elif [[ "$plugin_url" == *.zip ]]; then
            if ! unzip -o "$temp_file" -d .; then
                echo "Extraction failed!"
                cd - > /dev/null
                rm -rf "$temp_dir"
                return 1
            fi
        else
            echo "Unsupported file type. Only .zip and .tar.gz are supported."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        local extracted_folders
        extracted_folders=$(find . -maxdepth 1 -type d -not -name "." | head -n 1)
        if [ -n "$extracted_folders" ] && [ "$extracted_folders" != "./$PLUGIN_NAME" ]; then
            echo "Found plugin folder: $extracted_folders"
            echo "Renaming to $PLUGIN_NAME..."
            mv "$extracted_folders" "./$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME/$PLUGIN_NAME" ]; then
            echo "Fixing nested folder structure..."
            mv "./$PLUGIN_NAME/$PLUGIN_NAME/"* "./$PLUGIN_NAME/" 2>/dev/null || true
            rm -rf "./$PLUGIN_NAME/$PLUGIN_NAME"
        fi
        if [ -d "./$PLUGIN_NAME" ]; then
            echo "Installing $PLUGIN_NAME to $PLUGIN_BASE_DIR..."
            sudo mv "./$PLUGIN_NAME" "$PLUGIN_BASE_DIR/"
            echo "Setting correct permissions..."
            sudo find "$PLUGIN_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            sudo find "$PLUGIN_DIR" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
            echo "$PLUGIN_NAME has been installed successfully!"
            echo "Please restart Decky Loader to activate the plugin."
        else
            echo "Installation failed. Plugin folder could not be found."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 0
    }
    uninstall_plugin() {
        if [[ -d "$PLUGIN_DIR" ]]; then
            sudo rm -rf "$PLUGIN_DIR"
            echo "Decky Framegen has been uninstalled."
        else
            echo "Decky Framegen is not installed."
        fi
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_plugin
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_plugin
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Decky Framegen plugin${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_plugin
                ;;
            "Uninstall")
                uninstall_plugin
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi
