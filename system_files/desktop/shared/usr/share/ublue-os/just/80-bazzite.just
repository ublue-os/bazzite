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
[group("network")]
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
[group("system")]
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
[group("system")]
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
[group("hardware")]
add-user-to-input-group:
    #!/usr/bin/bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Enables automounting of labeled BTRFS/EXT4 partitions under /run/media/system
[group("automounting")]
enable-automounting:
    #!/usr/bin/pkexec /usr/bin/bash
    set -eo pipefail
    rm -f /etc/udev/rules.d/99-media-automount.rules # DELETEME
    if systemctl status --no-pager ublue-os-media-automount.service >/dev/null 2>&1; then
        systemctl enable --now ublue-os-media-automount.service
    fi

# Disables automounting of labeled BTRFS/EXT4 partitions under /run/media/system
[group("automounting")]
disable-automounting:
    #!/usr/bin/pkexec /usr/bin/bash
    set -eo pipefail
    rm -f /etc/udev/rules.d/99-media-automount.rules # DELETEME
    if systemctl status --no-pager ublue-os-media-automount.service >/dev/null 2>&1; then
        systemctl disable ublue-os-media-automount.service
    fi

# Enable framework automounting udev rules.
[group("automounting")]
enable-framework-automount:
    #!/usr/bin/pkexec /usr/bin/bash
    set -eo pipefail
    rm -f /etc/udev/rules.d/99-framework-steam-automount.rules

# Disable framework automounting udev rules.
[group("automounting")]
disable-framework-automount:
    #!/usr/bin/pkexec /usr/bin/bash
    set -eo pipefail
    ln -sf /dev/null /etc/udev/rules.d/99-framework-steam-automount.rules

# Disable SteamOS automount, this fixes ntfs partitions getting mounted.
[group("automounting")]
disable-steamos-automount:
    @pkexec ln -sf /dev/null /etc/udev/rules.d/99-steamos-automount.rules

# Enable SteamOS automount.
[group("automounting")]
enable-steamos-automount:
    @pkexec rm -f /etc/udev/rules.d/99-steamos-automount.rules

# Disable all partition automounting. This might increase boot times.
[group("automounting")]
disable-automount-all:
    @pkexec --keep-cwd ujust disable-framework-automount disable-automounting disable-steamos-automount

# Enable all automounting.
[group("automounting")]
enable-automount-all:
    @pkexec --keep-cwd ujust enable-framework-automount enable-automounting enable-steamos-automount

# Enable support for Tailscale
[group("network")]
enable-tailscale:
    systemctl enable --now tailscaled.service

# Enable Framework Fan Control
[group("hardware")]
enable-framework-fan-control:
    systemctl enable --now fw-fanctrl.service

# Configure watchdog (default: enabled, recovers the system in the event of a malfunction)
[group("system")]
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

# Ptyxis terminal transparency
[group("utilities")]
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
[group("system")]
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
[group("development")]
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
[group("utilities")]
benchmark:
    echo 'Running a 1 minute benchmark ...'
    cd /tmp && stress-ng --matrix 0 -t 1m --times

# toggles password prompt feedback in terminal, where sudo password prompts will display asterisks when enabled
[group("development")]
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

# Toggle whether Steam launches with the -steamdeck flag, which causes Big Picture / Game Mode to emulate Steam Deck behavior. Disabling this can prevent games from forcing Steam Deck-specific assets, such as lower-resolution textures.
[group("gaming")]
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
[group("utilities")]
get-logs:
    #!/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    # Get system status information
    echo -e "${bold}System Information:${normal}"
    echo " "
    rpm-ostree status
    echo " "
    # Get logs for this boot
    this_boot_logs=$(journalctl -b | fpaste 2>/dev/null)
    echo -e "${bold}Logs This Boot:${normal} $this_boot_logs"
    echo " "
    # Get logs for last boot
    last_boot_logs=$(journalctl -b -1 | fpaste 2>/dev/null)
    echo -e "${bold}Logs Last Boot:${normal} $last_boot_logs"
    echo " "
    # Concatenate all outputs and copy to clipboard
    {
      echo "System Information:"
      rpm-ostree status
      echo
      echo "Logs This Boot: $this_boot_logs"
      echo
      echo "Logs Last Boot: $last_boot_logs"
    } | wl-copy
    echo -e "${green}All output has been copied to your clipboard.${normal}"
