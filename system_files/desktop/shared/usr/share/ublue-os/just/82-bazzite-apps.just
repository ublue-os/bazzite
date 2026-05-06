# vim: set ft=make :

# Install an appimage file from a local file or URL
_install_appimage_file $APPIMAGE_SRC $filename="":
    #!/usr/bin/bash
    set -eo pipefail
    DOWNLOAD_DIR="{{ cache_directory() }}/ujust/appimages"
    mkdir -p "$DOWNLOAD_DIR"
    trap "rm -rf $DOWNLOAD_DIR" EXIT

    appimage_file="$DOWNLOAD_DIR/${filename:-${APPIMAGE_SRC##*/}}"

    if ! grep -q 'it.mijorus.gearlever' < <(flatpak list --columns application); then
        flatpak install --system -y flathub it.mijorus.gearlever <&-
    fi
    if [[ $APPIMAGE_SRC =~ ^https?:// ]]; then
        echo "Downloading $APPIMAGE_SRC to $appimage_file"
        wget -nv "$APPIMAGE_SRC" -O "$appimage_file" && echo "Download complete"
    else
        cp "$APPIMAGE_SRC" "$appimage_file"
    fi
    chmod +x "$appimage_file"
    echo "Click {{ BOLD }}Unlock{{ NORMAL }} then {{ BLUE + BOLD }}Move to the app menu{{ NORMAL }} and close window to finish installation."
    sleep 3
    LC_ALL=C flatpak run it.mijorus.gearlever "$appimage_file" <&-

# Manage CoolerControl, a GUI for viewing sensors and creating fan and pump profiles. Options: status | install | uninstall
[group("apps")]
install-coolercontrol ACTION="":
    #!/usr/bin/env bash
    set -eo pipefail
    source /usr/lib/ujust/ujust.sh

    layered_package() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }

    get_status_token() {
        if layered_package liquidctl && layered_package coolercontrol; then
            echo "install"
        else
            echo "uninstall"
        fi
    }

    get_current_status() {
        if layered_package liquidctl && layered_package coolercontrol; then
            echo "Installed"
        elif layered_package liquidctl || layered_package coolercontrol; then
            echo "Partially Installed"
        else
            echo "Not Installed"
        fi
    }

    install_coolercontrol() {
        echo '{{ YELLOW }}This recipe will proceed to {{ BOLD }}layer{{ NORMAL }} {{ YELLOW }}CoolerControl{{ NORMAL }}.'
        echo '{{ YELLOW }}If updates start to fail, please use "{{ BOLD }}rpm-ostree reset{{ NORMAL }}"'
        echo '{{ YELLOW }}See https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/#major-caveats-using-rpm-ostree{{ NORMAL }}'

        packages=()
        for pkg in liquidctl coolercontrol; do
            if layered_package "$pkg"; then
                echo "$pkg is already layered, skipping."
            else
                packages+=("$pkg")
            fi
        done

        if [ ${#packages[@]} -gt 0 ]; then
            repo_path="/etc/yum.repos.d/terra.repo"

            if ( ! grep -q "enabled=0" "$repo_path" ); then  # if not matches found
                echo 'Terra Repository is already enabled, skipping.'
            else
                echo 'Enabling Terra Repository.'
                sudo sed -i 's@enabled=0@enabled=1@g' "$repo_path"
            fi

            echo "Installing: ${packages[*]}"
            rpm-ostree install -y "${packages[@]}"
            echo 'Complete, please reboot to apply changes.'
        else
            echo "No changes were made."
        fi
    }

    uninstall_coolercontrol() {
        packages=()
        for pkg in liquidctl coolercontrol; do
            if layered_package "$pkg"; then
                packages+=("$pkg")
            fi
        done

        if [ ${#packages[@]} -gt 0 ]; then
            echo "Uninstalling: ${packages[*]}"
            rpm-ostree uninstall -y "${packages[@]}"
            echo 'Complete, please reboot to apply changes.'
        else
            echo "CoolerControl is not layered."
        fi
    }

    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust install-coolercontrol <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install CoolerControl"
        echo "  Use 'uninstall' to uninstall CoolerControl"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_coolercontrol
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_coolercontrol
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}CoolerControl${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_coolercontrol
                ;;
            "Uninstall")
                uninstall_coolercontrol
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Manage DisplayLink, needed for some laptop docks to output video. Options: status | install | uninstall
[group("apps")]
install-displaylink ACTION="":
    #!/usr/bin/env bash
    set -eo pipefail
    source /usr/lib/ujust/ujust.sh

    layered_package() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }

    get_status_token() {
        if layered_package displaylink; then
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

    install_displaylink() {
        echo '{{ YELLOW }}This recipe will proceed to {{ BOLD }}layer{{ NORMAL }} {{ YELLOW }}DisplayLink{{ NORMAL }}.'
        echo '{{ YELLOW }}If updates start to fail, please use "{{ BOLD }}rpm-ostree reset{{ NORMAL }}"'
        echo '{{ YELLOW }}See https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/#major-caveats-using-rpm-ostree{{ NORMAL }}'

        packages=()
        for pkg in displaylink; do
            if layered_package "$pkg"; then
                echo "$pkg is already layered, skipping."
            else
                packages+=("$pkg")
            fi
        done

        if [ ${#packages[@]} -gt 0 ]; then
            repo_path="/etc/yum.repos.d/negativo17-fedora-multimedia.repo"

            if ( ! grep -q "enabled=0" "$repo_path" ); then  # if not matches found
                echo 'Negativo17 Multimedia Repository is already enabled, skipping.'
            else
                echo 'Enabling Negativo17 Multimedia Repository.'
                sudo sed -i 's@enabled=0@enabled=1@g' "$repo_path"
            fi

            echo "Installing: ${packages[*]}"
            rpm-ostree install -y "${packages[@]}"
            echo 'Complete, please reboot to apply changes.'
        else
            echo "No changes were made."
        fi
    }

    uninstall_displaylink() {
        if layered_package displaylink; then
            echo "Uninstalling: displaylink"
            rpm-ostree uninstall -y displaylink
            echo 'Complete, please reboot to apply changes.'
        else
            echo "DisplayLink is not layered."
        fi
    }

    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust install-displaylink <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install DisplayLink"
        echo "  Use 'uninstall' to uninstall DisplayLink"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_displaylink
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_displaylink
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}DisplayLink${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_displaylink
                ;;
            "Uninstall")
                uninstall_displaylink
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
[group("apps")]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    set -euo pipefail
    # Ensure Homebrew is available in non-interactive shells
    if ! command -v brew >/dev/null 2>&1 && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    brew tap ublue-os/tap
    brew install --cask jetbrains-toolbox-linux
    if ! command -v jetbrains-toolbox >/dev/null 2>&1; then
        echo "jetbrains-toolbox was not found on PATH after installation. You may need to restart your shell or ensure Homebrew's bin directory is on your PATH." >&2
        exit 1
    fi
    jetbrains-toolbox &> /dev/null &

alias install-asusctl := asus

# Install asusctl and ROG Control Center, ASUS ROG hardware managing tools. Options: status | install | uninstall
[group("hardware")]
asus ACTION="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ $(id -u) -eq 0 ]]; then
        echo >&2 "ERROR: Do not run this with sudo"
        exit 1
    fi

    source /usr/lib/ujust/ujust.sh

    # Ensure Homebrew is available in non-interactive shells
    if ! command -v brew >/dev/null 2>&1 && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    brew_package() {
        local pkg="$1"
        [[ -d /home/linuxbrew/.linuxbrew/Caskroom/$pkg ]]
    }

    layered_package() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }

    get_status_token() {
        if brew_package asusctl-linux && brew_package rog-control-center-linux; then
            echo "install"
        else
            echo "uninstall"
        fi
    }

    get_current_status() {
        if brew_package asusctl-linux && brew_package rog-control-center-linux; then
            echo "{{ BOLD }}{{ GREEN }}Installed{{ NORMAL }}"
        elif brew_package asusctl-linux || brew_package rog-control-center-linux; then
            echo "{{ BOLD }}{{ YELLOW }}Partially Installed{{ NORMAL }}"
        elif layered_package asusctl || layered_package asusctl-rog-gui || layered_package rog-control-center; then
            echo "{{ YELLOW }}Installed (layered){{ NORMAL }}"
        else
            echo "{{ RED }}Not Installed{{ NORMAL }}"
        fi
    }

    install_asus_tools() {
        layered_packages=()
        for pkg in asusctl asusctl-rog-gui rog-control-center; do
            if layered_package "$pkg"; then
                layered_packages+=("$pkg")
            fi
        done

        if [ ${#layered_packages[@]} -gt 0 ]; then
            local REPLY
            echo "This script installs Brew casks from Universal Blue's tap used to manage ASUS"
            echo "ROG hardware, but it appears your system already has {{ BOLD }}layered {{ NORMAL }}packages."
            echo "{{ BOLD }}Layered packages: {{ NORMAL }}${layered_packages[*]}"
            while true; do
                read -r -p "Proceed to remove these layers first? {{ YELLOW }}(Y/n){{ NORMAL }} " REPLY || exit 1
                if [[ ! $REPLY || $REPLY == "Y" || $REPLY == "y" ]]; then
                    sudo systemctl disable --now asusd.service asus-shutdown.service
                    sudo udevadm control --reload
                    sudo udevadm trigger
                    systemctl --user disable --now asusd-user.service
                    rpm-ostree uninstall -y "${layered_packages[*]}"
                    echo 'Complete, please reboot to apply changes.'
                    exit 0
                elif [[ $REPLY == "N" || $REPLY == "n" ]]; then
                    echo 'Cancelled.'
                    exit 1
                fi
            done
        fi

        brew_packages=()
        for pkg in asusctl-linux rog-control-center-linux; do
            if brew_package "$pkg"; then
                echo "$pkg is already installed, skipping."
            else
                brew_packages+=("$pkg")
            fi
        done

        if [ ${#brew_packages[@]} -gt 0 ]; then
            brew tap ublue-os/tap
            echo "Installing: ${brew_packages[*]}"
            brew install --cask "${brew_packages[@]}"
            sudo systemctl daemon-reload
            sudo systemctl enable --now asusd.service asus-shutdown.service
            sudo udevadm control --reload
            sudo udevadm trigger
            systemctl --user daemon-reload
            systemctl --user enable --now asusd-user.service
            echo 'Complete, all required services are enabled.'
        else
            echo "No changes were made."
        fi
    }

    uninstall_asus_tools() {
        brew_packages=()
        layered_packages=()
        for pkg in asusctl-linux rog-control-center-linux; do
            if brew_package "$pkg"; then
                brew_packages+=("$pkg")
            fi
        done

        for pkg in asusctl asusctl-rog-gui rog-control-center; do
            if layered_package "$pkg"; then
                layered_packages+=("$pkg")
            fi
        done

        if [ ${#brew_packages[@]} -gt 0 ]; then
            sudo systemctl disable --now asusd.service asus-shutdown.service
            sudo udevadm control --reload
            sudo udevadm trigger
            systemctl --user disable --now asusd-user.service
            echo "Uninstalling: ${brew_packages[*]}"
            brew remove "${brew_packages[@]}"
            echo 'Complete.'
        elif [ ${#layered_packages[@]} -gt 0 ]; then
            sudo systemctl disable --now asusd.service asus-shutdown.service
            sudo udevadm control --reload
            sudo udevadm trigger
            systemctl --user disable --now asusd-user.service
            echo "Uninstalling: ${layered_packages[*]}"
            rpm-ostree uninstall -y "${layered_packages[*]}"
            echo 'Complete, please reboot to apply changes.'
        else
            echo "ASUS ROG utilities are not installed."
        fi
    }

    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust asus <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install asusctl and ROG Control Center"
        echo "  Use 'uninstall' to uninstall asusctl and ROG Control Center"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_asus_tools
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_asus_tools
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}ASUS ROG hardware managing tools${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_asus_tools
                ;;
            "Uninstall")
                uninstall_asus_tools
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

alias install-steamcmd := get-steamcmd

# Install SteamCMD (https://developer.valvesoftware.com/wiki/SteamCMD). Options: status | install | uninstall
[group("gaming")]
get-steamcmd ACTION="":
    #!/usr/bin/bash
    get_status_token() {
        if [[ -f "$HOME/.steam/steamcmd.sh" ]] || [[ -f "$HOME/.local/bin/steamcmd" ]]; then
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
    install_steamcmd() {
        if [[ $UID -eq 0 ]]; then
            echo >&2 "This ujust should not be run as root."
            exit 1
        fi
        echo 'Installing SteamCMD...'
        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
        mkdir -p ~/.steam
        tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
        rm /tmp/steamcmd.tar.gz
        if [[ -f ~/.steam/steamcmd.sh ]]; then
            mkdir -p ~/.local/bin
            rm -f ~/.local/bin/steamcmd
            printf '#!/usr/bin/bash\nexec ~/.steam/steamcmd.sh "$@"\n' > ~/.local/bin/steamcmd
            chmod +x ~/.local/bin/steamcmd
        fi
    }
    uninstall_steamcmd() {
        rm -f "$HOME/.local/bin/steamcmd"
        rm -f "$HOME/.steam/steamcmd.sh"
        echo "SteamCMD has been uninstalled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust get-steamcmd <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install SteamCMD"
        echo "  Use 'uninstall' to uninstall SteamCMD"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit $?
    elif [[ "$OPTION" == "install" ]]; then
        install_steamcmd
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_steamcmd
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}SteamCMD${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_steamcmd
                ;;
            "Uninstall")
                uninstall_steamcmd
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Manage OpenRazer for Razer gaming hardware. Options: status | install | uninstall
[group("hardware")]
install-openrazer ACTION="":
    #!/usr/bin/bash
    set -eo pipefail
    source /usr/lib/ujust/ujust.sh
    layered_package() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }
    flatpak_installed() {
        local app="$1"
        flatpak list --system --columns=application 2>/dev/null | grep -Fx "$app" >/dev/null
    }
    get_status_token() {
        if ! layered_package openrazer-daemon; then
            echo "uninstall"
        elif flatpak_installed xyz.z3ntu.razergenie; then
            echo "install-razer-genie"
        elif flatpak_installed app.polychromatic.controller; then
            echo "install-polychromatic"
        else
            echo "install"
        fi
    }
    get_current_status() {
        if ! layered_package openrazer-daemon; then
            echo "Not Installed"
        elif flatpak_installed xyz.z3ntu.razergenie; then
            echo "Installed (Razer Genie)"
        elif flatpak_installed app.polychromatic.controller; then
            echo "Installed (Polychromatic)"
        else
            echo "Installed"
        fi
    }
    install_openrazer() {
        local FRONTEND_OPTION="${1:-}"
        OPENRAZER_CONFIGURATOR_APP="None of openrazer frontend apps"
        if [[ -z "$FRONTEND_OPTION" ]]; then
            echo "${bold}Select OpenRazer Frontend Apps${normal}"
            FRONTEND_OPTION=$(ugum choose "Razer Genie" "Polychromatic" "None")
        fi
        if [[ "${FRONTEND_OPTION,,}" =~ ^razer[[:space:]]genie ]]; then
            echo "Installing Razer Genie..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            flatpak --system install -y flathub xyz.z3ntu.razergenie
            OPENRAZER_CONFIGURATOR_APP="Razer Genie"
        elif [[ "${FRONTEND_OPTION,,}" =~ ^polychromatic ]]; then
            echo "Installing Polychromatic..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            flatpak --system install -y flathub app.polychromatic.controller
            OPENRAZER_CONFIGURATOR_APP="Polychromatic"
        else
            echo "Not Selecting GUI Frontend"
        fi
        sudo curl -Lo /etc/yum.repos.d/hardware:razer.repo https://openrazer.github.io/hardware:razer.repo
        rpm-ostree install -y openrazer-daemon
        if ! grep -q "plugdev" /etc/group; then
            sudo bash -c 'grep "plugdev" /lib/group >> /etc/group'
        fi
        sudo usermod -a -G plugdev "$USER"
        echo "$OPENRAZER_CONFIGURATOR_APP is installed"
        echo "Please reboot to apply needed changes."
    }
    uninstall_openrazer() {
        if layered_package openrazer-daemon; then
            rpm-ostree uninstall -y openrazer-daemon
            echo "OpenRazer daemon has been uninstalled."
        else
            echo "OpenRazer daemon is not layered."
        fi
        if flatpak_installed xyz.z3ntu.razergenie; then
            flatpak --system remove -y xyz.z3ntu.razergenie
        fi
        if flatpak_installed app.polychromatic.controller; then
            flatpak --system remove -y app.polychromatic.controller
        fi
        echo "Please reboot to apply needed changes."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust install-openrazer <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install OpenRazer without a frontend"
        echo "  Use 'install-razer-genie' to install OpenRazer with Razer Genie"
        echo "  Use 'install-polychromatic' to install OpenRazer with Polychromatic"
        echo "  Use 'uninstall' to uninstall OpenRazer"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_openrazer "None"
        exit 0
    elif [[ "$OPTION" == "install-razer-genie" ]]; then
        install_openrazer "Razer Genie"
        exit 0
    elif [[ "$OPTION" == "install-polychromatic" ]]; then
        install_openrazer "Polychromatic"
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_openrazer
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}OpenRazer${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_openrazer
                ;;
            "Uninstall")
                uninstall_openrazer
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

alias install-emudeck := get-emudeck

# Install EmuDeck (https://www.emudeck.com/). Options: status | install | uninstall
[group("gaming")]
get-emudeck ACTION="":
    #!/usr/bin/bash
    set -eo pipefail
    get_status_token() {
        if compgen -G "$HOME/Applications/*EmuDeck*.AppImage" > /dev/null; then
            echo "install"
        elif find "$HOME/.local/share/applications" -maxdepth 1 -type f -name "*.desktop" \
            \( -iname "*emudeck*" -o -iname "*org.emudeck.com*" \) 2>/dev/null | grep -q .; then
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
    install_emudeck() {
        remote_appimage_url="$(
            curl -s https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest | \
            jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url"
        )"
        just _install_appimage_file "$remote_appimage_url"
    }
    uninstall_emudeck() {
        find "$HOME/Applications" -maxdepth 1 -type f -name "*EmuDeck*.AppImage" -delete 2>/dev/null || true
        find "$HOME/.local/share/applications" -maxdepth 1 -type f \
            \( -iname "*emudeck*.desktop" -o -iname "*org.emudeck.com*.desktop" \) \
            -delete 2>/dev/null || true
        find "$HOME/.local/share/icons" -type f \
            \( -iname "*emudeck*" -o -iname "*org.emudeck.com*" \) \
            -delete 2>/dev/null || true
        echo "EmuDeck has been uninstalled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_emudeck
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_emudeck
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}EmuDeck${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_emudeck
                ;;
            "Uninstall")
                uninstall_emudeck
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

alias install-openrgb := openrgb

# Manage OpenRGB (https://openrgb.org/). Options: status | install | uninstall
[group("hardware")]
openrgb ACTION="":
    #!/usr/bin/bash
    set -eo pipefail
    get_status_token() {
        if compgen -G "$HOME/Applications/*OpenRGB*.AppImage" > /dev/null; then
            echo "install"
        elif find "$HOME/.local/share/applications" -maxdepth 1 -type f -name "*.desktop" \
            \( -iname "*openrgb*" -o -iname "*org.openrgb*" \) 2>/dev/null | grep -q .; then
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
    install_openrgb() {
        just _install_appimage_file "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage"
    }
    uninstall_openrgb() {
        find "$HOME/Applications" -maxdepth 1 -type f -name "*OpenRGB*.AppImage" -delete 2>/dev/null || true
        find "$HOME/.local/share/applications" -maxdepth 1 -type f \
            \( -iname "*openrgb*.desktop" -o -iname "*org.openrgb*.desktop" \) \
            -delete 2>/dev/null || true
        find "$HOME/.local/share/icons" -type f \
            \( -iname "*openrgb*" -o -iname "*org.openrgb*" \) \
            -delete 2>/dev/null || true
        echo "OpenRGB has been uninstalled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_openrgb
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_openrgb
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}OpenRGB${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_openrgb
                ;;
            "Uninstall")
                uninstall_openrgb
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Manage Boxtron, a Steam Play compatibility tool to run DOS games using native Linux DOSBox. Options: status | install | uninstall
[group("gaming")]
install-boxtron ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    boxtron_installed() {
        for base in "$HOME/.steam/root/compatibilitytools.d" "$HOME/.local/share/Steam/compatibilitytools.d"; do
            if [[ -d "$base/boxtron" ]] || [[ -d "$base/Boxtron" ]]; then
                return 0
            fi
        done
        return 1
    }
    get_status_token() {
        if boxtron_installed; then
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
    install_boxtron() {
        just distrobox-check-fedora
        distrobox enter -n fedora -- bash -c '\
          sudo dnf install dosbox-staging inotify-tools timidity++ fluid-soundfont-gm -y && \
          cd ~/.steam/root/compatibilitytools.d/ && \
          curl -L https://github.com/dreamer/boxtron/releases/download/v0.5.4/boxtron.tar.xz | tar xJf - && \
          distrobox-export --bin /usr/bin/dosbox'
    }
    uninstall_boxtron() {
        removed=false
        for path in \
            "$HOME/.steam/root/compatibilitytools.d/boxtron" \
            "$HOME/.steam/root/compatibilitytools.d/Boxtron" \
            "$HOME/.local/share/Steam/compatibilitytools.d/boxtron" \
            "$HOME/.local/share/Steam/compatibilitytools.d/Boxtron"; do
            if [[ -e "$path" ]]; then
                rm -rf "$path"
                removed=true
            fi
        done
        if distrobox list 2>/dev/null | grep -qE '(^|[[:space:]])fedora([[:space:]]|$)'; then
            distrobox enter -n fedora -- bash -c 'distrobox-export --bin /usr/bin/dosbox --delete || true'
        fi
        if [[ "$removed" == "true" ]]; then
            echo "Boxtron has been uninstalled."
        else
            echo "Boxtron is not installed."
        fi
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust install-boxtron <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install Boxtron"
        echo "  Use 'uninstall' to uninstall Boxtron"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_boxtron
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_boxtron
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Boxtron${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_boxtron
                ;;
            "Uninstall")
                uninstall_boxtron
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

alias install-resilio-sync := resilio-sync

# Manage Resilio Sync, a file synchronization utility powered by BitTorrent. Options: status | install | uninstall
resilio-sync ACTION="":
    #!/usr/bin/bash
    set -eo pipefail
    has_fedora_distrobox() {
        distrobox list 2>/dev/null | grep -qE '(^|[[:space:]])fedora([[:space:]]|$)'
    }
    get_status_token() {
        if [[ -f "$HOME/.config/systemd/user/fedora-resilio-sync.service" ]] || systemctl --user is-enabled fedora-resilio-sync.service >/dev/null 2>&1; then
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
    install_resilio_sync() {
        just distrobox-check-fedora
        distrobox-enter -n fedora -- bash -c 'sudo rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc' && \
        distrobox-enter -n fedora -- bash -c 'sudo wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/resilio-sync.repo -O /etc/yum.repos.d/resilio-sync.repo' && \
        distrobox-enter -n fedora -- bash -c 'sudo dnf install -y resilio-sync' && \
        mkdir -p ~/.config/systemd/user/ && \
        rm -f ~/.config/systemd/user/fedora-resilio-sync.service && \
        wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/fedora-resilio-sync.service -O ~/.config/systemd/user/fedora-resilio-sync.service && \
        systemctl --user daemon-reload && \
        systemctl enable --user --now fedora-resilio-sync.service
    }
    uninstall_resilio_sync() {
        systemctl --user disable --now fedora-resilio-sync.service 2>/dev/null || true
        rm -f ~/.config/systemd/user/fedora-resilio-sync.service
        systemctl --user daemon-reload
        if has_fedora_distrobox; then
            distrobox-enter -n fedora -- bash -c 'sudo dnf remove -y resilio-sync || true'
            distrobox-enter -n fedora -- bash -c 'sudo rm -f /etc/yum.repos.d/resilio-sync.repo'
        fi
        echo "Resilio Sync has been uninstalled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "install" ]]; then
        install_resilio_sync
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_resilio_sync
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Resilio Sync${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_resilio_sync
                ;;
            "Uninstall")
                uninstall_resilio_sync
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

alias install-opentabletdriver := opentabletdriver

# Manage OpenTabletDriver, an open source, cross-platform, user-mode tablet driver. Options: status | install | uninstall
[group("hardware")]
opentabletdriver ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    get_status_token() {
        if flatpak list --columns=application 2>/dev/null | grep -Fx 'net.opentabletdriver.OpenTabletDriver' >/dev/null || \
           [[ -f "$HOME/.config/systemd/user/opentabletdriver.service" ]]; then
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
    install_opentabletdriver() {
        echo "Installing OpenTabletDriver..."
        curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest \
        | jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("opentabletdriver.*linux.*binary.*tar.gz$")) | .browser_download_url' \
        | wget -qi - -O /tmp/OpenTabletDriver/opentabletdriver.tar.gz && \
        tar --strip-components=1 -xvzf /tmp/OpenTabletDriver/opentabletdriver.tar.gz -C /tmp/OpenTabletDriver && \
        sudo cp /tmp/OpenTabletDriver/etc/udev/rules.d/70-opentabletdriver.rules /etc/udev/rules.d/71-opentabletdriver.rules && \
        rm -rf /tmp/OpenTabletDriver && \
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
        flatpak --system install -y flathub net.opentabletdriver.OpenTabletDriver && \
        mkdir -p $HOME/.config/OpenTabletDriver && \
        flatpak override --user --filesystem=xdg-config/OpenTabletDriver net.opentabletdriver.OpenTabletDriver && \
        mkdir -p $HOME/.config/systemd/user && \
        curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service > $HOME/.config/systemd/user/opentabletdriver.service  && \
        systemctl --user daemon-reload && \
        systemctl enable --user --now opentabletdriver.service && \
        rpm-ostree kargs --append-if-missing=modprobe.blacklist=hid_uclogic --append-if-missing=modprobe.blacklist=wacom
    }
    uninstall_opentabletdriver() {
        echo "Uninstalling OpenTabletDriver..."
        sudo -A rm /etc/udev/rules.d/71-opentabletdriver.rules && \
        flatpak --system remove -y flathub net.opentabletdriver.OpenTabletDriver && \
        systemctl disable --user --now opentabletdriver.service && \
        rpm-ostree kargs --delete-if-present=modprobe.blacklist=hid_uclogic --delete-if-present=modprobe.blacklist=wacom
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust opentabletdriver <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'install' to install OpenTabletDriver"
        echo "  Use 'uninstall' to uninstall OpenTabletDriver"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit $?
    elif [[ "$OPTION" == "install" ]]; then
        install_opentabletdriver
        exit 0
    elif [[ "$OPTION" == "uninstall" ]]; then
        uninstall_opentabletdriver
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}OpenTabletDriver${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Install" "Uninstall" "Exit without changes")
        case "$OPTION" in
            "Install")
                install_opentabletdriver
                ;;
            "Uninstall")
                uninstall_opentabletdriver
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      Assemble noconfirmcreate "" "fedora"
    fi
