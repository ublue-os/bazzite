# vim: set ft=make :

# Install System Flatpaks (Support for Rebasing)
_install-system-flatpaks:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        FLATPAKS="gnome_flatpaks/flatpaks"
    else
        FLATPAKS="kde_flatpaks/flatpaks"
    fi
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/ublue-os/bazzite/main/installer/${FLATPAKS} | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Configure grub bootmenu visibility and fix duplicate entries
configure-grub ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    GRUB_STATE="$(grep -P "^GRUB_TIMEOUT_STYLE=hidden" /etc/default/grub)"
    OPTION={{ ACTION }}
    if [ "$GRUB_STATE" == "GRUB_TIMEOUT_STYLE=hidden" ]; then
        GRUB_STATE="${b}Hidden${n}"
    else
        GRUB_STATE="${b}Not Hidden${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-grub <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'hide' to select Hide Grub"
      echo "  Use 'unhide' to select Unhide Grub"
      echo "  Use 'fix' to select Fix double ostree entry"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Grub menu configuration${normal}"
      echo "Grub menu is set to: $GRUB_STATE"
      OPTION=$(Choose "Hide Grub" "Unhide Grub" "Fix double ostree entry")
    fi
    if [[ "${OPTION,,}" =~ ^hide ]]; then
      sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
      echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
      echo 'GRUB_HIDDEN_TIMEOUT=1' | sudo tee -a /etc/default/grub 1>/dev/null
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    elif [[ "${OPTION,,}" =~ ^unhide ]]; then
      sudo sed -i '/GRUB_HIDDEN_TIMEOUT=1/d' /etc/default/grub
      sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
      sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    elif [[ "${OPTION,,}" =~ ^fix ]]; then
      sudo grub2-switch-to-blscfg
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    fi

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
    #!/usr/bin/bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Enable support for DisplayLink
enable-displaylink:
    systemctl enable --now displaylink.service

# Enable support for Tailscale
enable-tailscale:
    systemctl enable --now tailscaled.service

# toggles password prompt feedback in terminal, where sudo password prompts will display asterisks when enabled
toggle-password-feedback ACTION="":
    #!/usr/bin/bash
    PWFEEDBACK_FILE="/etc/sudoers.d/enable-pwfeedback"
    OPTION={{ ACTION }}
    if [ "$OPTION" = "on" ]; then
      echo 'Defaults pwfeedback' | sudo tee $PWFEEDBACK_FILE
      echo "enabled, restart terminal to see changes"
    elif [ "$OPTION" = "off" ]; then
      sudo rm -f $PWFEEDBACK_FILE
      echo "disabled pwfeedback. restart your terminal to see changes"
    elif sudo test -f $PWFEEDBACK_FILE; then
      sudo rm -f $PWFEEDBACK_FILE
      echo "disabled pwfeedback. restart your terminal to see changes"
    else
      echo 'Defaults pwfeedback' | sudo tee $PWFEEDBACK_FILE
      echo "enabled, restart terminal to see changes"
    fi

# Configure watchdog (default: enabled, recovers the system in the event of a malfunction)
configure-watchdog ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    WATCHDOG_STATE="$(rpm-ostree kargs)"
    CPU_MODEL=$(lscpu --json | jq -r '."lscpu"[7]."data"')
    OPTION={{ ACTION }}
    if [[ "$WATCHDOG_STATE" =~ (nowatchdog|modprobe\.blacklist=(iTCO_wdt|sp5100_tco)) ]]; then
        WATCHDOG_STATE="${red}${b}Disabled${n}"
    else
        WATCHDOG_STATE="${green}${b}Enabled${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-watchdog <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to select Enable Watchdog"
      echo "  Use 'disable' to select Disable Watchdog"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Watchdog configuration${normal}"
      echo "Having the watchdog enabled will let it recover the system in the event of a malfunction, however"
      echo "disabling the watchdog can give a potential performance improvement due to fewer interrupts"
      echo "Watchdog is $WATCHDOG_STATE"
      OPTION=$(Choose "Enable Watchdog" "Disable Watchdog")
    fi
    if [[ "$OPTION" =~ ^enable ]]; then
      WATCHDOG_KARGS="--delete-if-present=nowatchdog"
      if [[ "$CPU_MODEL" =~ "Intel" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=iTCO_wdt"
      elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=sp5100_tco"
      fi
      rpm-ostree kargs $WATCHDOG_KARGS
    elif [[ "$OPTION" =~ ^disable ]]; then
      WATCHDOG_KARGS="--append-if-missing=nowatchdog"
      if [[ "$CPU_MODEL" =~ "Intel" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=iTCO_wdt"
      elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=sp5100_tco"
      fi
      rpm-ostree kargs $WATCHDOG_KARGS
    fi

# Install and configure Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader) and plugins for alternative handhelds
setup-decky ACTION="install":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    DECKY_STATE="${b}${red}Not Installed${n}"
    if [[ -d $HOME/homebrew/plugins ]]; then
      DECKY_STATE="${b}${green}Installed${n}"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-decky <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'install' to select Install Decky"
      echo "  Use 'prerelease' to select Install Decky Prerelease"
      exit 0
    fi
    if [[ "${OPTION,,}" =~ install ]]; then
      export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
      if [ ! -L "/home/deck" ] && [ ! -e "/home/deck" ]  && [ "$HOME" != "/home/deck" ]; then
        echo "Making a /home/deck symlink to fix plugins that do not use environment variables."
        sudo ln -sf "$HOME" /home/deck
      fi
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
      sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
    fi
    if [[ "${OPTION,,}" =~ prerelease ]]; then
      export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
      if [ ! -L "/home/deck" ] && [ ! -e "/home/deck" ]  && [ "$HOME" != "/home/deck" ]; then
        echo "Making a /home/deck symlink to fix plugins that do not use environment variables."
        sudo ln -sf "$HOME" /home/deck
      fi
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_prerelease.sh | sh
      sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
    fi

# Ptyxis terminal transparency
ptyxis-transparency opacity="0.95":
    #!/usr/bin/bash
    set -euxo pipefail
    if [[ -n "$(echo "{{ opacity }}" | grep -v '^[.0-9]*$')" ]]; then
      printf "Value must be numeric: %s.\n" "{{ opacity }}"
    elif [[ $(echo "0<{{ opacity }} && 1>={{ opacity }}" | bc -q) -eq 1 ]]; then
      raw="$(gsettings get org.gnome.Ptyxis profile-uuids)"
      uuids="$(sed -En 's|[^0-9a-z]*||g; s|([0-9a-z]{32})|\1\n|gp' <<<${raw})"
      for i in ${uuids}; do
        location="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${i}/"
        gsettings set "${location}" opacity "{{ opacity }}"; done
      printf "Ptyxis opacity is now %s.\n" "{{ opacity }}"
    else
      printf "Value must be between 0 and 1: %s.\n" "{{ opacity }}"
    fi

# Bazzite CLI mod for bluefin style cli-bing (modfied copy of https://github.com/ublue-os/bluefin/blob/faf7303afa6f8d6e747940c1d1ba63c6d2d43c80/system_files/shared/usr/libexec/ublue-bling.sh#L62)
bazzite-cli:
    #!/usr/bin/bash
    #shellcheck disable=SC2154

    set -eou pipefail

    # Source libujust for colors/ugum
    source /usr/lib/ujust/ujust.sh

    # Exit Handling
    function Exiting(){
        printf "%s%sExiting...%s\n" "${red}" "${bold}" "${normal}"
        printf "Rerun script with %s%sujust bazzite-cli%s\n" "${blue}" "${bold}" "${normal}"
        exit 0
    }

    # Trap function
    function ctrl_c(){
        printf "\nSignal SIGINT caught\n"
        Exiting
    }

    # Brew Bundle Install
    function brew-bundle(){
    echo 'Installing bling from Homebrew 🍻🍻🍻'
    brew bundle --file /usr/share/ublue-os/homebrew/bazzite-cli.Brewfile --no-lock
    }

    # Check if bling is already sourced
    function check-bling() {
    shell="$1"
    if [[ "${shell}" == "fish" ]]; then
        line=$(grep -n "source /usr/share/bazzite-cli/bling.fish" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    elif [[ "${shell}" == "zsh" ]]; then
        line=$(grep -n "source /usr/share/bazzite-cli/bling.sh" \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    elif [[ "${shell}" == "bash" ]]; then
        line=$(grep -n "source /usr/share/bazzite-cli/bling.sh" \
            "${HOME}/.bashrc" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    else
        echo 'Unknown Shell ... You are on your own'
        exit 1;
    fi
    }

    # Add Bling
    function add-bling(){
    shell="$1"
    if ! brew-bundle; then
        Exiting
    fi
    echo 'Setting up your Shell 🐚🐚🐚'
    if [[ "${shell}" == "fish" ]]; then
        echo 'Adding bling to your config.fish 🐟🐟🐟'
        cat<<-EOF >> "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
    ### bling.fish source start
    test -f /usr/share/bazzite-cli/bling.fish && source /usr/share/bazzite-cli/bling.fish
    ### bling.fish source end
    EOF
    elif [[ "${shell}" == "zsh" ]]; then
        echo 'Adding bling to your .zshrc 💤💤💤'
        cat<<-EOF >> "${ZDOTDIR:-$HOME}/.zshrc"
    ### bling.sh source start
    test -f /usr/share/bazzite-cli/bling.sh && source /usr/share/bazzite-cli/bling.sh
    ### bling.sh source end
    EOF
    elif [[ "${shell}" == "bash" ]]; then
        echo 'Adding bling to your .bashrc 💥💥💥'
        cat<<-EOF >> "${HOME}/.bashrc"
    ### bling.sh source start
    test -f /usr/share/bazzite-cli/bling.sh && source /usr/share/bazzite-cli/bling.sh
    ### bling.sh source end
    EOF
    else
        echo 'Unknown Shell ... You are on your own'
    fi
    }

    # Remove bling, handle if old method
    function remove-bling(){
    shell="$1"
    if [[ "${shell}" == "fish" ]]; then
        sed -i '/### bling.fish source start/,/### bling.fish source end/d' \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.fish" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
    elif [[ "${shell}" == "zsh" ]]; then
        sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${ZDOTDIR:-$HOME}/.zshrc"
    elif [[ "${shell}" == "bash" ]]; then
        sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
            "${HOME}/.bashrc" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
            "${HOME}/.bashrc" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${HOME}/.bashrc"
    fi
    }

    # Main function.
    function main(){

    # Get Shell
    shell=$(basename "$SHELL")
    reentry="$1"
    clear
    if [[ -n "${reentry:-}" ]]; then
        printf "%s%s%s\n\n" "${bold}" "$reentry" "$normal"
    fi

    # Check if bling is enabled and display
    printf "Shell:\t%s%s%s%s\n" "${green}" "${bold}" "${shell}" "${normal}"
    if ! check-bling "${shell}"; then
        printf "Bling:\t%s%sEnabled%s\n" "${green}" "${bold}" "${normal}"
    else
        printf "Bling:\t%s%sDisabled%s\n" "${red}" "${bold}" "${normal}"
    fi

    # ugum enable/disable
    CHOICE=$(Choose enable disable cancel)

    # Enable/Disable. Recurse if bad option.
    if [[ "${CHOICE}" == "enable" ]]; then
        if check-bling "${shell}"; then
            trap ctrl_c SIGINT
            add-bling "${shell}"
            printf "%s%sInstallation Complete%s ... please close and reopen your terminal!" "${green}" "${bold}" "${normal}"
        else
            main "Bling is already configured ..."
        fi
    elif [[ "${CHOICE}" == "disable" ]]; then
        if check-bling "${shell}"; then
            main "Bling is not yet configured ..."
        else
            remove-bling "${shell}"
            trap ctrl_c SIGINT
            printf "%s%sBling Removed%s ... please close and reopen your terminal\n" "${red}" "${bold}" "${normal}"
        fi
    else
        Exiting
    fi
    }

    # Entrypoint
    main ""

# Run a one minute system benchmark
benchmark:
    echo 'Running a 1 minute benchmark ...'
    cd /tmp && stress-ng --matrix 0 -t 1m --times

post-gamescope-logs:
    #!/usr/bin/bash
    OUTPUT_FILE="/tmp/gathered_info.txt"

    # Clear the output file or create it if it doesn't exist
    > "$OUTPUT_FILE"

    # Gather information from various sources
    {
        echo "GPU info"
        lshw -C display

        # Add a blank line for readability
        echo

        filepaths=(
            "/sys/devices/virtual/dmi/id/bios_date"
            "/sys/devices/virtual/dmi/id/board_name"
            "/sys/devices/virtual/dmi/id/board_vendor"
            "/sys/devices/virtual/dmi/id/product_name"
            "$HOME/.gamescope-cmd.log"
            "$HOME/.gamescope-stdout.log"
        )

        # Iterate over each file path in the array
        for filepath in "${filepaths[@]}"; do
            # Print the file path
            echo "File: $filepath"

            # Check if the file exists before trying to read it
            if [[ -f "$filepath" ]]; then
                # Print the file content
                cat "$filepath"
            else
                echo "File not found: $filepath"
            fi

            # Add a blank line for readability
            echo
        done

        echo "----- Contents of $HOME/.config/environment.d/ -----"
        mkdir -p $HOME/.config/environment.d
        cat "$HOME/.config/environment.d/"* 2>/dev/null || echo "No files found in $HOME/.config/environment.d/"

    } >> "$OUTPUT_FILE"

    fpaste $OUTPUT_FILE

    # cleanup output file
    rm -rf $OUTPUT_FILE
