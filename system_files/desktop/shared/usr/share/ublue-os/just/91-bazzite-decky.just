# vim: set ft=make :

# Install and configure Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader) and plugins for alternative handhelds
[group("gaming")]
setup-decky ACTION="":
    #!/usr/bin/bash
    if [[ $(id -u) -eq 0 ]]; then
        echo >&2 "ERROR: Do not run this with sudo"
        exit 1
    fi
    source /usr/lib/ujust/ujust.sh
    DECKY_STATE="${b}${red}Not Installed${n}"
    if [[ -f /etc/systemd/system/multi-user.target.wants/plugin_loader.service ]]; then
      DECKY_STATE="${b}${green}Installed${n}"
    fi
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
      echo "  Use 'install' to select Install Decky"
      echo "  Use 'prerelease' to select Install Decky Prerelease"
      echo "  Use 'uninstall' to uninstall Decky Loader"
      exit 0
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
    elif [[ "$OPTION" == "prerelease" ]]; then
      install_prerelease
      exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
      uninstall
      exit 0
    fi

# Universal Decky plugin installer with menu interface
[group("gaming")]
install-decky-plugins ACTION="":
    #!/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh

    # Plugin configuration - add new plugins here
    declare -A PLUGINS
    PLUGINS["bazzite-buddy"]="bazzite-org|decky-bazzite-buddy|bazzite-buddy|Access Bazzite changelogs in game mode"
    PLUGINS["decky-framegen"]="xXJSONDeruloXx|Decky-Framegen|Decky-Framegen|Easily install OptiScaler into any Steam game."
    PLUGINS["decky-lsfg-vk"]="xXJSONDeruloXx|decky-lsfg-vk|decky-lsfg-vk|Use Lossless Scaling easily from Game Mode."

    # Core plugin installation function
    install_plugin() {
        local repo_owner="$1"
        local repo_name="$2" 
        local plugin_name="$3"
        local description="$4"
        local plugin_dir="$HOME/homebrew/plugins"

        echo "Installing $plugin_name: $description"

        # Check if Decky is installed
        if [ ! -d "$HOME/homebrew" ]; then
            echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
            return 1
        fi

        # Get the latest release information with timeout
        echo "Fetching latest release information for $plugin_name..."
        local release_info
        release_info=$(timeout 30 curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" || echo "")

        # Extract the download URL for the zip file
        local download_urls=""
        if [ -n "$release_info" ]; then
            download_urls=$(echo "$release_info" | jq -r '.assets[].browser_download_url | select(endswith(".zip"))' 2>/dev/null || echo "")
        fi

        # Determine plugin URL
        local plugin_url
        if [ -z "$download_urls" ]; then
            echo "No zip files found in the latest release or API timeout. Using fallback URL..."
            plugin_url="https://github.com/$repo_owner/$repo_name/releases/latest/download/$plugin_name.zip"
        else
            plugin_url=$(echo "$download_urls" | head -n 1)
            echo "Found latest release: $plugin_url"
        fi

        # Ensure plugins directory exists
        if [ ! -d "$plugin_dir" ]; then
            echo "Creating plugins directory..."
            sudo mkdir -p "$plugin_dir"
        fi

        # Work in a temporary directory
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || { echo "Failed to create temp directory"; return 1; }

        # Remove any existing plugin folder
        if [ -d "$plugin_dir/$plugin_name" ]; then
            echo "Removing existing $plugin_name directory..."
            sudo rm -rf "$plugin_dir/$plugin_name"
        fi

        # Download the zip file
        echo "Downloading $plugin_name from $plugin_url..."
        local temp_zip="plugin.zip"
        if ! timeout 60 curl -L -o "$temp_zip" "$plugin_url"; then
            echo "Download failed or timed out!"
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi

        # Extract plugin
        echo "Extracting $plugin_name..."
        if ! unzip -o "$temp_zip" -d .; then
            echo "Extraction failed!"
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi

        # Handle different extracted folder names
        local extracted_folders
        extracted_folders=$(find . -maxdepth 1 -type d -not -name "." | head -n 1)

        if [ -n "$extracted_folders" ] && [ "$extracted_folders" != "./$plugin_name" ]; then
            echo "Found plugin folder: $extracted_folders"
            echo "Renaming to $plugin_name..."
            mv "$extracted_folders" "./$plugin_name"
        fi

        # Handle nested folder structure if needed
        if [ -d "./$plugin_name/$plugin_name" ]; then
            echo "Fixing nested folder structure..."
            mv "./$plugin_name/$plugin_name/"* "./$plugin_name/" 2>/dev/null || true
            rm -rf "./$plugin_name/$plugin_name"
        fi

        # Move plugin to final location
        if [ -d "./$plugin_name" ]; then
            echo "Installing $plugin_name to $plugin_dir..."
            sudo mv "./$plugin_name" "$plugin_dir/"

            # Fix permissions
            echo "Setting correct permissions..."
            sudo find "$plugin_dir/$plugin_name" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            sudo find "$plugin_dir/$plugin_name" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true

            echo "$plugin_name has been installed successfully!"
        else
            echo "Installation failed. Plugin folder could not be found."
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
        fi

        # Clean up
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 0
    }

    # Main function
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
        echo "Usage: ujust install-decky-plugins [plugin-name]"
        echo "  [plugin-name]: Install a specific plugin directly"
        echo "  Available plugins:"
        for plugin in "${!PLUGINS[@]}"; do
            IFS='|' read -r owner repo name desc <<< "${PLUGINS[$plugin]}"
            echo "    $plugin: $desc"
        done
        exit 0
    fi

    # Check if Decky is installed first
    if [ ! -d "$HOME/homebrew" ]; then
        echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
        exit 1
    fi

    # If specific plugin provided, install it directly
    if [ -n "$OPTION" ]; then
        found=false
        for plugin in "${!PLUGINS[@]}"; do
            if [[ "${plugin,,}" == "${OPTION,,}" ]]; then
                IFS='|' read -r owner repo name desc <<< "${PLUGINS[$plugin]}"
                if install_plugin "$owner" "$repo" "$name" "$desc"; then
                    echo "Please restart Decky Loader to activate the plugin."
                else
                    echo "Failed to install $plugin"
                    exit 1
                fi
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            echo "Plugin '$OPTION' not found. Use 'ujust install-decky-plugins help' to see available plugins."
            exit 1
        fi
        exit 0
    fi

    # Interactive menu
    echo "${bold}Decky Plugin Installer${normal}"
    echo "Choose a plugin to install:"
    echo

    # Create menu options
    menu_options=()
    for plugin in "${!PLUGINS[@]}"; do
        IFS='|' read -r owner repo name desc <<< "${PLUGINS[$plugin]}"
        menu_options+=("$plugin")
    done
    menu_options+=("Exit")

    # Sort options (except Exit)
    IFS=$'\n' sorted_options=($(sort <<<"${menu_options[*]:0:$((${#menu_options[@]}-1))}"))
    sorted_options+=("Exit")

    CHOICE=$(ugum choose "${sorted_options[@]}")

    if [ "$CHOICE" == "Exit" ]; then
        echo "No changes made."
        exit 0
    fi

    # Install selected plugin
    IFS='|' read -r owner repo name desc <<< "${PLUGINS[$CHOICE]}"
    if install_plugin "$owner" "$repo" "$name" "$desc"; then
        echo "Please restart Decky Loader to activate the plugin."
    else
        echo "Failed to install $CHOICE"
        exit 1
    fi
