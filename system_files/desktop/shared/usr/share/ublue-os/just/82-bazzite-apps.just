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

# Install CoolerControl, a GUI for viewing all your system's sensors and for creating custom fan and pump profiles based on any available temperature sensor28
[group("apps")]
install-coolercontrol:
    #!/usr/bin/env bash
    set -eo pipefail

    cat <<'EOF'
    {{ YELLOW }}This recipe will proceed to {{ BOLD }}layer{{ NORMAL }} {{ YELLOW }}CoolerControl{{ NORMAL }}.
    {{ YELLOW }}If updates start to fail, please use "{{ BOLD }}rpm-ostree reset{{ NORMAL }}"
    {{ YELLOW }}See https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/#major-caveats-using-rpm-ostree{{ NORMAL }}
    EOF

    layered() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }
    packages=()
    for pkg in liquidctl coolercontrol; do
        if layered "$pkg"; then
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

# Install Displaylink, Needed for some laptop docks to output video
[group("apps")]
install-displaylink:
    #!/usr/bin/env bash
    set -eo pipefail

    cat <<'EOF'
    {{ YELLOW }}This recipe will proceed to {{ BOLD }}layer{{ NORMAL }} {{ YELLOW }}Displaylink{{ NORMAL }}.
    {{ YELLOW }}If updates start to fail, please use "{{ BOLD }}rpm-ostree reset{{ NORMAL }}"
    {{ YELLOW }}See https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/#major-caveats-using-rpm-ostree{{ NORMAL }}
    EOF

    layered() {
        local pkg="$1"
        rpm-ostree status --json | jq -e ".deployments[] | select(.booted == true) | .packages | index(\"$pkg\")" > /dev/null
    }
    packages=()
    for pkg in displaylink; do
        if layered "$pkg"; then
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

# Install OpenRazer for Razer gaming hardware
[group("hardware")]
install-openrazer:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPENRAZER_CONFIGURATOR_APP="None of openrazer frontend apps"
    sudo curl -Lo /etc/yum.repos.d/hardware:razer.repo https://openrazer.github.io/hardware:razer.repo && \
    rpm-ostree install -y openrazer-daemon && \
        if ! grep -q "plugdev" /etc/group; then \
      sudo bash -c 'grep "plugdev" /lib/group >> /etc/group' \
    ; fi && \
    sudo usermod -a -G plugdev $USER && \
    echo "${bold}Select OpenRazer Frontend Apps${normal}"
    OPTION=$(Choose "Razer Genie" "Polychromatic" "None")
    if [[ "${OPTION,,}" =~ ^razer[[:space:]]genie ]]; then
        echo "Installing Razer Genie..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak --system install -y flathub xyz.z3ntu.razergenie
        OPENRAZER_CONFIGURATOR_APP="Razer Genie"
    elif [[ "${OPTION,,}" =~ ^polychromatic ]]; then
        echo "Installing Polychromatic..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak --system install -y flathub app.polychromatic.controller
        OPENRAZER_CONFIGURATOR_APP="Polychromatic"
    else
        echo "Not Selecting GUI Frontend"
    fi
    echo "$OPENRAZER_CONFIGURATOR_APP is installed"
    echo "Please reboot to apply needed changes."

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

# Install OpenRGB (https://openrgb.org/). Options: status | install | uninstall
[group("hardware")]
install-openrgb ACTION="":
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

# Install Boxtron, a Steam Play compatibility tool to run DOS games using native Linux DOSBox
[group("gaming")]
install-boxtron: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c '\
      sudo dnf install dosbox-staging inotify-tools timidity++ fluid-soundfont-gm -y && \
      cd ~/.steam/root/compatibilitytools.d/ && \
      curl -L https://github.com/dreamer/boxtron/releases/download/v0.5.4/boxtron.tar.xz | tar xJf - && \
      distrobox-export --bin /usr/bin/dosbox'

# Install Resilio Sync, a file synchronization utility powered by BitTorrent. Options: status | install | uninstall
install-resilio-sync ACTION="":
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

# Install OpenTabletDriver, an open source, cross-platform, user-mode tablet driver. Options: status | install | uninstall
[group("hardware")]
install-opentabletdriver ACTION="":
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
        | jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("opentabletdriver.*tar.gz$")) | .browser_download_url' \
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
        echo "Usage: ujust install-opentabletdriver <option>"
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
