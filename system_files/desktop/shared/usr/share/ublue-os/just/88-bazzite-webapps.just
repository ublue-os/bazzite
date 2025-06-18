# vim: set ft=make :

# Add various video and game streaming services to Steam
get-media-app service="":
    #!/usr/bin/bash
    # Load ugum for interactive menu
    source /usr/lib/ujust/ujust.sh
    # Function to install StreamingServiceLauncher
    install_launcher() {
        echo "Installing StreamingServiceLauncher..."
        # Create necessary directories
        mkdir -p "$HOME/.local/bin"
        mkdir -p "$HOME/Applications"
        # Clean up any old versions
        rm -f "$HOME/.local/bin/StreamingServiceLauncher.AppImage"
        rm -f "$HOME/Applications/StreamingServiceLauncher.AppImage"
        rm -f "$HOME/.local/bin/streaming-service-launcher"
        # Download latest release
        RELEASE_URL="https://api.github.com/repos/aarron-lee/StreamingServiceLauncher/releases/latest"
        wget -q $(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url") \
            -O "$HOME/Applications/StreamingServiceLauncher.AppImage"
        # Create launcher script
        echo "#!/bin/bash" > "$HOME/.local/bin/streaming-service-launcher"
        echo "\"$HOME/Applications/StreamingServiceLauncher.AppImage\" --appname=\$1 --no-sandbox" >> "$HOME/.local/bin/streaming-service-launcher"
        # Make executables
        chmod +x "$HOME/Applications/StreamingServiceLauncher.AppImage"
        chmod +x "$HOME/.local/bin/streaming-service-launcher"
        if [ ! -f "$HOME/Applications/StreamingServiceLauncher.AppImage" ]; then
            echo "Installation failed"
            exit 1
        fi
        echo "Installation completed successfully"
    }
    # Check for StreamingServiceLauncher and install if needed
    [ ! -f "$HOME/Applications/StreamingServiceLauncher.AppImage" ] && install_launcher
    # Create scripts directory
    mkdir -p "$HOME/Applications/streaming_scripts"
    # Display menu
    if [ -n "{{ service }}" ]; then
        CHOICE="{{ service }}"
    else
        echo -e "\n${bold}Select a streaming service to add to Steam:${normal}"
        CHOICE=$(ugum choose \
            "YouTube" \
            "Netflix" \
            "Amazon Luna" \
            "Disney Plus" \
            "Amazon Prime Video" \
            "Apple TV" \
            "Curiosity Stream" \
            "Crunchyroll" \
            "GeForce Now" \
            "HBO Max" \
            "Hulu" \
            "Plex HTPC" \
            "Jellyfin Media Player" \
            "Paramount Plus" \
            "Peacock" \
            "Sling TV" \
            "Spotify" \
            "Vimeo" \
            "Xbox Cloud Gaming" \
            "YouTube Music" \
            "YouTube TV" \
            "Exit")
    fi
    # Exit early if user chose to exit
    [ "$CHOICE" = "Exit" ] && { echo "Exiting..."; exit 0; }
    # Create webapp script and add to Steam
    create_script() {
        local script_path="$HOME/Applications/streaming_scripts/$1"
        echo "#!/bin/bash" > "$script_path"
        echo "\"$HOME/.local/bin/streaming-service-launcher\" \"$2\"" >> "$script_path"
        chmod +x "$script_path"
        steamos-add-to-steam "$script_path"
        echo "Added $1 to Steam successfully!"
    }
    install_vacuumtube() {
        local installed=false
        if grep -q 'rocks.shy.VacuumTube' <<< $(flatpak list); then
            echo "VacuumTube is already installed"
            installed=true
        else
            echo "Installing VacuumTube..."
            if flatpak install --system -y flathub rocks.shy.VacuumTube; then
                echo "VacuumTube installed successfully"
                installed=true
            else
                echo "Failed to install VacuumTube. Please try installing manually with:"
                echo "flatpak install --system flathub rocks.shy.VacuumTube"
            fi
        fi
        # Only proceed with Steam integration if installation was successful
        if [ "$installed" = true ]; then
            # Create launcher script for Steam
            local script_path="$HOME/Applications/streaming_scripts/Youtube"
            echo "#!/bin/bash" > "$script_path"
            echo "flatpak run rocks.shy.VacuumTube" >> "$script_path"
            chmod +x "$script_path"
            # Add to Steam
            steamos-add-to-steam "$script_path"
            echo "Added VacuumTube to Steam successfully!"
        else
            echo "Skipping Steam integration due to installation failure."
        fi
    }
    install_crunchyroll() {
        if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
            wget \
                $(curl -s https://api.github.com/repos/aarron-lee/crunchyroll-linux/releases/latest | \
                jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url") \
                -O $HOME/Downloads/Crunchyroll.AppImage
            chmod +x $HOME/Downloads/Crunchyroll.AppImage
            flatpak run it.mijorus.gearlever $HOME/Downloads/Crunchyroll.AppImage
        else
            wget \
                $(curl -s https://api.github.com/repos/aarron-lee/crunchyroll-linux/releases/latest | \
                jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url") \
                -O $HOME/Desktop/Crunchyroll.AppImage
            chmod +x $HOME/Desktop/Crunchyroll.AppImage
        fi
    }
    install_plex_htpc(){
        local installed=false
        if grep -q 'tv.plex.PlexHTPC' <<< $(flatpak list); then
            echo "Plex HTPC is already installed"
            installed=true
        else
            echo "Installing Plex HTPC..."
            if flatpak install --system -y tv.plex.PlexHTPC; then
                echo "Plex HTPC installed successfully"
                installed=true
            else
                echo "Failed to install Plex HTPC. Please try installing manually with:"
                echo "flatpak install --system tv.plex.PlexHTPC"
            fi
        fi
        # Only proceed with Steam integration if installation was successful
        if [ "$installed" = true ]; then
            # Create launcher script for Steam
            local script_path="$HOME/Applications/streaming_scripts/plex-htpc"
            echo "#!/bin/bash" > "$script_path"
            echo "flatpak run tv.plex.PlexHTPC" >> "$script_path"
            chmod +x "$script_path"
            # Add to Steam
            steamos-add-to-steam "$script_path"
            echo "Added Plex HTPC to Steam successfully!"
        else
            echo "Skipping Steam integration due to installation failure."
        fi
    }
    install_jellyfin_media_player() {
        local installed=false
        if grep -q 'com.github.iwalton3.jellyfin-media-player' <<< $(flatpak list); then
            echo "Jellyfin Media Player is already installed"
            installed=true
        else
            echo "Installing Jellyfin Media Player..."
            if flatpak install --system -y com.github.iwalton3.jellyfin-media-player; then
                echo "Jellyfin Media Player installed successfully"
                installed=true
            else
                echo "Failed to install Jellyfin Media Player. Please try installing manually with:"
                echo "flatpak install --system com.github.iwalton3.jellyfin-media-player"
            fi
        fi
        # Only proceed with Steam integration if installation was successful
        if [ "$installed" = true ]; then
            # Create launcher script for Steam
            local script_path="$HOME/Applications/streaming_scripts/jellyfin-media-player"
            echo "#!/bin/bash" > "$script_path"
            echo "flatpak run com.github.iwalton3.jellyfin-media-player" >> "$script_path"
            chmod +x "$script_path"
            # Add to Steam
            steamos-add-to-steam "$script_path"
            echo "Added Jellyfin Media Player to Steam successfully!"
        else
            echo "Skipping Steam integration due to installation failure."
        fi
    }
    # Commenting out for now as GeForce NOW native app is borked on non steam deck devices, even those running SteamOS.
    # install_geforce_now() {
    #     local installed=false
    #     if grep -q 'com.nvidia.geforcenow' <<< $(flatpak list); then
    #         echo "GeForce NOW is already installed"
    #         installed=true
    #     else
    #         echo "Installing GeForce NOW..."
    #         # Add the NVIDIA GeForce NOW Flatpak repository if not already added
    #         flatpak remote-add --system --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo
    #         if flatpak install -y --system GeForceNOW com.nvidia.geforcenow; then
    #             echo "GeForce NOW installed successfully"
    #             installed=true
    #         else
    #             echo "Failed to install GeForce NOW. Please try installing manually with:"
    #             echo "flatpak install --system GeForceNOW com.nvidia.geforcenow"
    #         fi
    #     fi
    #     # Only proceed with Steam integration if installation was successful
    #     if [ "$installed" = true ]; then
    #         # Create launcher script for Steam
    #         local script_path="$HOME/Applications/streaming_scripts/geforce-now.sh"
    #         echo "#!/bin/bash" > "$script_path"
    #         echo "flatpak run com.nvidia.geforcenow" >> "$script_path"
    #         chmod +x "$script_path"
    #         # Add to Steam
    #         steamos-add-to-steam "$script_path"
    #         echo "Added GeForce NOW to Steam successfully!"
    #     else
    #         echo "Skipping Steam integration due to installation failure."
    #     fi
    # }
    # Process user choice
    case "$CHOICE" in
        "YouTube") install_vacuumtube ;;
        "Netflix") create_script "netflix" "netflix" ;;
        "Amazon Luna") create_script "amazon-luna" "amazonLuna" ;;
        "Disney Plus") create_script "disney-plus" "disneyPlus" ;;
        "Amazon Prime Video") create_script "prime-video" "amazonPrimeVideo" ;;
        "Apple TV") create_script "apple-tv" "appleTv" ;;
        "Curiosity Stream") create_script "curiosity-stream" "curiosityStream" ;;
        "Crunchyroll") install_crunchyroll ;;
        "GeForce Now") create_script "geforce-now" "geForceNow" ;;
        "HBO Max") create_script "hbo-max" "hboMax" ;;
        "Hulu") create_script "hulu" "hulu" ;;
        "Plex HTPC") install_plex_htpc ;;
        "Jellyfin Media Player") install_jellyfin_media_player ;;
        "Paramount Plus") create_script "paramount-plus" "paramountPlus" ;;
        "Peacock") create_script "peacock" "peacock" ;;
        "Sling TV") create_script "sling-tv" "slingTV" ;;
        "Spotify") create_script "spotify" "spotify" ;;
        "Vimeo") create_script "vimeo" "vimeo" ;;
        "Xbox Cloud Gaming") create_script "xbox-cloud" "xboxGamePassStreaming" ;;
        "YouTube Music") create_script "youtube-music" "youtubeMusic" ;;
        "YouTube TV") create_script "youtube-tv" "youTubeTV" ;;
        *) echo "Invalid choice" ; exit 1 ;;
    esac
