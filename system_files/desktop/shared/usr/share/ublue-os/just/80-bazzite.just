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
    flatpak --system -y install --reinstall --or-update ${FLATPAK_LIST}

# Toggle SSH availability on boot
toggle-ssh ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    # Get hostname and IP address
    HOSTNAME=$(hostname)
    IP_ADDRESS=$(hostname -I | awk '{print $1}') # First IP address
    # Get current SSH status
    SSH_STATUS="Disabled"
    if systemctl is-enabled sshd | grep -q enabled; then
      SSH_STATUS="Enabled"
    fi
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust toggle-ssh <option>"
      echo "  <option>: Specify the option to skip the interactive prompt"
      echo "  Use 'enable' to enable SSH on boot"
      echo "  Use 'disable' to disable SSH on boot"
      exit 0
    elif [ "$OPTION" == "" ]; then
      # Display current status
      echo -e "\n${bold}Hostname:${normal} $HOSTNAME"
      echo -e "${bold}IP Address:${normal} $IP_ADDRESS"
      if [ "$SSH_STATUS" == "Enabled" ]; then
        echo -e "${bold}SSH Availability on Boot:${normal} ${green}$SSH_STATUS${normal}\n"
      else
        echo -e "${bold}SSH Availability on Boot:${normal} ${yellow}$SSH_STATUS${normal}\n"
      fi
      # Prompt user for action
      echo "Choose an option:"
      OPTION=$(ugum choose "Enable SSH" "Disable SSH" "Exit without saving")
    fi
    case "$OPTION" in
      "Enable SSH"|enable)
        echo "Enabling SSH on boot..."
        sudo systemctl enable sshd
        sudo systemctl start sshd
        echo -e "SSH is now ${green}Enabled${normal}. You can SSH using:"
        echo -e "${bold}${USER}@${IP_ADDRESS}${normal}"
        echo " "
        ;;
      "Disable SSH"|disable)
        echo "Disabling SSH on boot..."
        sudo systemctl disable sshd
        sudo systemctl stop sshd
        echo -e "SSH is now ${yellow}Disabled${normal}."
        echo " "
        ;;
      "Exit without saving"|*)
        echo "No changes made."
        ;;
    esac

# Regenerate GRUB config, useful in dual-boot scenarios where a second operating system isn't listed
regenerate-grub:
    #!/usr/bin/bash
    source /usr/libexec/bazzite-boot-remount
    remount_boot_rw
    if [ -d /sys/firmware/efi ]; then
      sudo grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      sudo grub2-mkconfig -o /etc/grub2.cfg
    fi
    remount_boot_ro

# Configure grub bootmenu visibility. pass action 'help' for more info.
configure-grub ACTION="":
    #!/usr/bin/bash
    source /usr/libexec/bazzite-boot-remount
    source /usr/lib/ujust/ujust.sh
    # Function to display usage/help with some color
    print_help() {
      echo -e "Usage: ujust configure-grub <option>"
      echo
      echo -e "Where <option> can be:"
      echo -e "  ${bold}${cyan}hide${normal} = GRUB is hidden after a successful boot, even for dual-boot setups."
      echo -e "  ${bold}${yellow}unhide${normal} = GRUB is hidden after a successful boot, but it will show if dual-booting."
      echo -e "  ${bold}${green}show${normal} = GRUB always shows on boot."
      echo
      echo "If <option> is omitted, you will be prompted to choose interactively."
    }
    # Function to get the current GRUB menu_auto_hide setting and explain it
    get_current_setting() {
      local CURRENT_SETTING
      CURRENT_SETTING=$(sudo grub2-editenv - list | grep menu_auto_hide | cut -d= -f2)
      if [ -z "$CURRENT_SETTING" ]; then
        echo "Current GRUB menu_auto_hide setting: ${bold}${red}Not Set (default to 0)${normal}"
        echo "Explanation:"
        echo "  - ${bold}0${normal}: GRUB always shows on boot."
        return 0
      else
        case "$CURRENT_SETTING" in
          0)
            echo "Current GRUB menu_auto_hide setting: ${bold}${green}0 (Always Show)${normal}"
            echo "Explanation:"
            echo "  - ${bold}0${normal}: GRUB always shows on boot."
            ;;
          1)
            echo "Current GRUB menu_auto_hide setting: ${bold}${yellow}1 (Hide After Successful Boot, except when Dual Booting)${normal}"
            echo "Explanation:"
            echo "  - ${bold}1${normal}: GRUB is hidden after a successful boot, but it will show if dual-booting."
            ;;
          2)
            echo "Current GRUB menu_auto_hide setting: ${bold}${cyan}2 (Hide After Successful Boot)${normal}"
            echo "Explanation:"
            echo "  - ${bold}2${normal}: GRUB is hidden after a successful boot, even for dual-boot setups."
            ;;
          *)
            echo "Current GRUB menu_auto_hide setting: ${bold}${red}Unknown${normal}"
            echo "Explanation:"
            echo "  - This setting is unrecognized. Reset it to 0, 1, or 2."
            ;;
        esac
      fi
    }
    # Interactive menu for choosing the new behavior
    interactive_menu() {
      local options=(
        "Hide After Successful Boot (menu_auto_hide=2)"
        "Same except when Dual Booting (menu_auto_hide=1)"
        "Always Show Grub (menu_auto_hide=0)"
        "Exit without changes"
      )
      local choice
      choice=$(ugum choose "${options[@]}")
      echo "$choice"
    }
    # Function to apply the selected setting
    apply_setting() {
      local selected_option="$1"
      remount_boot_rw
      # Support the interactive strings as well as short commands
      case "$(echo "$selected_option" | tr '[:upper:]' '[:lower:]')" in
        *"(menu_auto_hide=2)"*|hide)
          sudo grub2-editenv - set menu_auto_hide=2
          echo "GRUB menu is now set to ${bold}${cyan}Hide After Successful Boot${normal}."
          ;;
        *"(menu_auto_hide=1)"*|unhide)
          sudo grub2-editenv - set menu_auto_hide=1
          echo "GRUB menu is now set to ${bold}${yellow}Hide After Successful Boot except when Dual Booting${normal}."
          ;;
        *"(menu_auto_hide=0)"*|show)
          sudo grub2-editenv - set menu_auto_hide=0
          echo "GRUB menu is now set to ${bold}${green}Always Show${normal}."
          ;;
        *"exit without changes"*|exit)
          echo "${bold}No changes were made. Exiting...${normal}"
          ;;
        help)
          print_help
          ;;
        *)
          echo "${bold}${red}Invalid option selected. No changes were made.${normal}"
          ;;
      esac
      remount_boot_ro
    }
    OPTION="{{ ACTION }}"   # from “configure-grub ACTION=...”
    if [ "$OPTION" == "help" ]; then
      print_help
      exit 0
    fi
    get_current_setting
    echo
    # If no ACTION was passed, go interactive
    if [ -z "$OPTION" ]; then
      NEW_SETTING=$(interactive_menu)
      if [ -n "$NEW_SETTING" ]; then
        apply_setting "$NEW_SETTING"
      else
        echo "${bold}No changes were made.${normal}"
      fi
    else
      apply_setting "$OPTION"
    fi

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
    #!/usr/bin/bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Enables automounting of labeled BTRFS/EXT4 partitions under /run/media/system
enable-automounting:
    #!/usr/bin/bash
    set -eo pipefail
    rule=/etc/udev/rules.d/99-media-automount.rules
    if [[ "$(readlink $rule || :)" == /dev/null ]]; then
        sudo -A rm -f $rule
    fi
    if systemctl status --no-pager ublue-os-media-automount.service >/dev/null 2>&1; then
        sudo -A systemctl enable --now ublue-os-media-automount.service
    fi

# Disables automounting of labeled BTRFS/EXT4 partitions under /run/media/system
disable-automounting:
    #!/usr/bin/bash
    set -eo pipefail
    rule=/etc/udev/rules.d/99-media-automount.rules
    sudo ln -sf /dev/null $rule
    if systemctl status --no-pager ublue-os-media-automount.service >/dev/null 2>&1; then
        sudo -A systemctl disable ublue-os-media-automount.service
    fi

# Enable support for Tailscale
enable-tailscale:
    systemctl enable --now tailscaled.service

# Enable Framework Fan Control
enable-framework-fan-control:
    systemctl enable --now fw-fanctrl.service

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
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      WATCHDOG_KARGS="--delete-if-present=nowatchdog"
      if [[ "$CPU_MODEL" =~ "Intel" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=iTCO_wdt"
      elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=sp5100_tco"
      fi
      rpm-ostree kargs $WATCHDOG_KARGS
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      WATCHDOG_KARGS="--append-if-missing=nowatchdog"
      if [[ "$CPU_MODEL" =~ "Intel" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=iTCO_wdt"
      elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
        WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=sp5100_tco"
      fi
      rpm-ostree kargs $WATCHDOG_KARGS
    fi

# Install and configure Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader) and plugins for alternative handhelds
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

# Configure snapshotting for /var/home
configure-snapshots ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-snapshots <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' enable snapshotting of /var/home"
      echo "  Use 'disable' disable snapshotting of /var/home"
      echo "  Use 'wipe' disable snapshotting and remove all automatic snapshots of /var/home"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Snapper setup and configuration${normal}"
      OPTION=$(Choose "Enable Snapper" "Disable Snapper" "Wipe Snapper config and automatic snapshots")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      /usr/libexec/bazzite-snapper-config enable
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      /usr/libexec/bazzite-snapper-config disable
    elif [[ "${OPTION,,}" =~ ^wipe ]]; then
      /usr/libexec/bazzite-snapper-config wipe
    fi

# Enable a Bluefin-style CLI experience
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
    brew bundle --file /usr/share/ublue-os/homebrew/bazzite-cli.Brewfile
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

# Install Bazzite Buddy plugin to easily access changelogs in game mode
get-decky-bazzite-buddy:
    #!/bin/bash
    set -euo pipefail
    REPO_OWNER="xXJSONDeruloXx"
    REPO_NAME="bazzite-buddy"
    PLUGIN_NAME="bazzite-buddy"
    PLUGIN_DIR="$HOME/homebrew/plugins"

    # Check if Decky is installed
    if [ ! -d "$HOME/homebrew" ]; then
      echo "Error: Decky Loader is not installed. Please run 'ujust setup-decky install' first."
      exit 1
    fi

    # Get the latest release information with timeout
    echo "Fetching latest release information..."
    RELEASE_INFO=$(timeout 30 curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" || echo "")

    # Extract the download URL for the zip file
    if [ -n "$RELEASE_INFO" ]; then
      DOWNLOAD_URLS=$(echo "$RELEASE_INFO" | jq -r '.assets[].browser_download_url | select (endswith(".zip"))')
    else
      DOWNLOAD_URLS=""
    fi

    # Check if any zip files were found
    if [ -z "$DOWNLOAD_URLS" ]; then
      echo "No zip files found in the latest release or API timeout. Falling back to stable URL..."
      PLUGIN_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/stable/bazzite-buddy.zip"
    else
      # Pick the first zip file (usually there's only one)
      PLUGIN_URL=$(echo "$DOWNLOAD_URLS" | head -n 1)
      echo "Found latest release: $PLUGIN_URL"
    fi

    # Ensure plugins directory exists and has correct permissions
    if [ ! -d "$PLUGIN_DIR" ]; then
      echo "Creating plugins directory..."
      sudo mkdir -p "$PLUGIN_DIR"
    fi

    # Work in a temporary directory to avoid permission issues
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || { echo "Failed to create temp directory"; exit 1; }

    # Remove any existing plugin folder
    if [ -d "$PLUGIN_DIR/$PLUGIN_NAME" ]; then
      echo "Removing existing $PLUGIN_NAME directory..."
      sudo rm -rf "$PLUGIN_DIR/$PLUGIN_NAME"
    fi

    # Download the zip file
    echo "Downloading plugin from $PLUGIN_URL..."
    TEMP_ZIP="plugin.zip"
    timeout 60 curl -L -o "$TEMP_ZIP" "$PLUGIN_URL"
    if [ $? -ne 0 ]; then
      echo "Download failed or timed out!"
      cd - > /dev/null
      rm -rf "$TEMP_DIR"
      exit 1
    fi

    echo "Extracting plugin..."
    unzip -o "$TEMP_ZIP" -d .
    if [ $? -ne 0 ]; then
      echo "Extraction failed!"
      cd - > /dev/null
      rm -rf "$TEMP_DIR"
      exit 1
    fi

    # Handle different extracted folder names
    # Look for any extracted folders that might contain the plugin
    EXTRACTED_FOLDERS=$(find . -maxdepth 1 -type d -name "bazzite*" -o -name "Bazzite*" | grep -v "^\./$" || echo "")

    # If we found a folder but it's not the expected name
    if [ -n "$EXTRACTED_FOLDERS" ] && [ ! -d "./$PLUGIN_NAME" ]; then
      FOUND_FOLDER=$(echo "$EXTRACTED_FOLDERS" | head -n 1)
      echo "Found plugin folder with different name: $FOUND_FOLDER"
      echo "Renaming to $PLUGIN_NAME..."
      mv "$FOUND_FOLDER" "./$PLUGIN_NAME"
    fi

    # Handle nested folders structure if needed
    if [ -d "./${PLUGIN_NAME}/${PLUGIN_NAME}" ]; then
      echo "Fixing nested folder structure..."
      mv "./${PLUGIN_NAME}/${PLUGIN_NAME}"/* "./${PLUGIN_NAME}/"
      rm -rf "./${PLUGIN_NAME}/${PLUGIN_NAME}"
    fi

    # Check if we have a plugin with capital letters
    if [ ! -d "./$PLUGIN_NAME" ] && [ -d "./Bazzite.Buddy" ]; then
      echo "Found Bazzite.Buddy folder, renaming to $PLUGIN_NAME..."
      mv "./Bazzite.Buddy" "./$PLUGIN_NAME"
    fi

    # Move plugin to final location
    if [ -d "./$PLUGIN_NAME" ]; then
      echo "Installing plugin to $PLUGIN_DIR..."
      sudo mv "./$PLUGIN_NAME" "$PLUGIN_DIR/"

      # Fix permissions on plugin files and make scripts executable
      echo "Setting correct permissions..."
      sudo find "$PLUGIN_DIR/$PLUGIN_NAME" -name "*.sh" -exec chmod +x {} \;
      sudo find "$PLUGIN_DIR/$PLUGIN_NAME" -name "*.py" -exec chmod +x {} \;

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

# Toggle whether Steam launches with the -steamdeck flag, which causes Big Picture / Game Mode to emulate Steam Deck behavior. Disabling this can prevent games from forcing Steam Deck-specific assets, such as lower-resolution textures.
_toggle-steamdeck-alias:
    #!/usr/bin/bash
    # Toggles whether Steam presents the system as a Steam Deck via -steamdeck
    override_flag="$HOME/.config/bazzite/disable_steamdeck_flag"
    session_dir="$HOME/.config/gamescope-session-plus/sessions.d"
    session_file="$session_dir/steam"
    mkdir -p "$(dirname "$override_flag")"
    mkdir -p "$session_dir"
    cat > "$session_file" <<'EOF'
    DECK_OVERRIDE_FLAG="$HOME/.config/bazzite/disable_steamdeck_flag"
    if [[ ! -f "$DECK_OVERRIDE_FLAG" ]]; then
      export CLIENTCMD="steam -gamepadui -steamos3 -steampal -steamdeck"
    else
      export CLIENTCMD="steam -gamepadui -steamos3 -steampal"
    fi
    EOF
    current_status="Enabled"
    if [[ -f "$override_flag" ]]; then
      current_status="Disabled"
    fi
    echo -e "\nCurrent Steam Deck presentation mode: $current_status\n"
    CHOICE=$(ugum choose \
      "Present as Steam Deck (Enable -steamdeck)" \
      "Do Not Present as Steam Deck (Disable -steamdeck)" \
      "Exit without changes")
    case "$CHOICE" in
      "Present as Steam Deck (Enable -steamdeck)")
        if [[ -f "$override_flag" ]]; then
          rm -f "$override_flag"
          echo -e "\nSteam Deck presentation ENABLED. (-steamdeck will be passed to Steam)\n"
          echo "Reboot your system for the change to take effect."
        else
          echo -e "\nAlready enabled.\n"
        fi
        ;;
      "Do Not Present as Steam Deck (Disable -steamdeck)")
        touch "$override_flag"
        echo -e "\nSteam Deck presentation DISABLED. (-steamdeck will NOT be passed to Steam)\n"
        echo "Reboot your system for the change to take effect."
        ;;
      "Exit without changes")
        echo "No changes made."
        ;;
      *)
        echo "Invalid choice. Exiting."
        ;;
    esac

# get logs for this boot and last boot, cleanly output in terminal as pastebin links, to simplify troubleshooting and issue reporting.
get-logs:
    #!/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    # Get logs for this boot
    this_boot_logs=$(journalctl -b | fpaste 2>/dev/null)
    echo -e "${bold}Logs This Boot:${normal} $this_boot_logs"
    echo " "
    # Get logs for last boot
    last_boot_logs=$(journalctl -b -1 | fpaste 2>/dev/null)
    echo -e "${bold}Logs Last Boot:${normal} $last_boot_logs"
    echo " "
