# vim: set ft=make :

# Restore the default Terminal
restore-original-terminal:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    mkdir -p $HOME/.local/share/applications
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        rm -f $HOME/.local/share/applications/org.gnome.Terminal.desktop
        cp /usr/share/applications/org.gnome.Terminal.desktop $HOME/.local/share/applications/org.gnome.Terminal.desktop
        sed -i '/NoDisplay=true/d' $HOME/.local/share/applications/org.gnome.Terminal.desktop
    else
        rm -f $HOME/.local/share/applications/org.kde.konsole.desktop
        cp /usr/share/applications/org.kde.konsole.desktop $HOME/.local/share/applications/org.kde.konsole.desktop
        sed -i '/NoDisplay=true/d' $HOME/.local/share/applications/org.kde.konsole.desktop
        echo "Done. Change your default Terminal in System Settings to complete the swap."
    fi

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

# Install Bazzite's Steam Game Mode Startup Video
install-gamemode-video:
    mkdir -p $HOME/.local/share/Steam/config/uioverrides/movies
    rm -f $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm
    cp /usr/share/ublue-os/bazzite/bazzite.webm $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm

# Force-enable AMD pstate
pstate-force-enable:
    rpm-ostree kargs --append-if-missing=amd_pstate=active

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

# Set the default powerprofile to load when the desktop starts
configure-powerprofile ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-powerprofile <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'powersave' to select Powersave"
      echo "  Use 'balanced' to select Balanced"
      exit 0
    elif [ "$OPTION" == "" ]; then
      # Cleanup old method
      if [ -f "~/.config/autostart/bazzite-powersave.desktop" ]; then
        rm ~/.config/autostart/bazzite-powersave.desktop
      fi
      # New method from here on
      echo "${bold}Power profile configuration${normal}"
      echo "This lets you set the default power profile."
      echo "We do not recommend changing this from ${b}Balanced${n} if you use this device primarily for gaming!"
      echo "If you have any performance or audio related issues..."
      echo "${invert}${b}Please test with the default power profile set to Balanced${n} before reporting!"
      echo ""
      echo "Which power profile do you want to use when the desktop loads?"
      OPTION=$(Choose "Powersave" "Balanced")
    fi
    if [[ "${OPTION,,}" =~ powersave ]]; then
      echo "Setting default powerprofile to ${b}Powersave${n}"
      sudo sed -iE 's/default=(.+)/default=power-saver/' /etc/tuned/ppd.conf
      /usr/libexec/bazzite-powersave
    elif [[ "${OPTION,,}" =~ balanced ]]; then
      echo "Setting default powerprofile to ${b}Balanced${n}"
      sudo sed -iE 's/default=(.+)/default=balanced/' /etc/tuned/ppd.conf
      /usr/libexec/bazzite-powersave 0
    fi

# Install and configure Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader) and plugins for alternative handhelds
setup-decky ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    DECKY_STATE="${b}${red}Not Installed${n}"
    if [[ -d $HOME/homebrew/plugins ]]; then
      DECKY_STATE="${b}${green}Installed${n}"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-watchdog <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'install' to select Install Decky"
      echo "  Use 'simpledeckytdp' to select Get SimpleDeckyTDP"
      echo "  Use 'hhd-decky' to select Get HHD-decky"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Setup Decky Loader${normal}"
      echo "This lets you setup decky and install some decky plugins for alternative handhelds"
      echo "Tip: CTRL+Click on the plugin name to visit the project page for more info"
      echo "Decky Loader is $DECKY_STATE"
      OPTION=$(
        Choose \
        "Install Decky" \
        "Get $(Urllink "https://github.com/aarron-lee/SimpleDeckyTDP" SimpleDeckyTDP)${n}" \
        "Get $(Urllink "https://github.com/hhd-dev/hhd-decky" HHD-Decky)${n}"
        )
    fi
    if [[ "${OPTION,,}" =~ install ]]; then
      export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
      curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
      sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader
    elif [[ "${OPTION,,}" =~ simpledeckytdp ]]; then
      if [[ -d $HOME/homebrew/plugins ]]; then
        sudo rm -rf $HOME/homebrew/plugins/SimpleDeckyTDP
        curl -L $(curl -s https://api.github.com/repos/aarron-lee/SimpleDeckyTDP/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -o /tmp/SimpleDeckyTDP.tar.gz
        sudo tar -xzf /tmp/SimpleDeckyTDP.tar.gz -C $HOME/homebrew/plugins
        rm /tmp/SimpleDeckyTDP.tar.gz
        sudo sed -i 's/ENABLE_HARDWARE_CONTROL_ON_NON_DECK_HARDWARE=0/ENABLE_HARDWARE_CONTROL_ON_NON_DECK_HARDWARE=1/g' /etc/default/steam-hardware-control
        echo 'Installed. Please reboot to apply needed changes.'
      else
        echo 'Please install Decky Loader by running "ujust setup-decky install" first.'
      fi
    elif [[ "${OPTION,,}" =~ hhd-decky ]]; then
      if [[ -d $HOME/homebrew/plugins ]]; then
        sudo rm -rf $HOME/homebrew/plugins/hhd-decky
        curl -L $(curl -s https://api.github.com/repos/hhd-dev/hhd-decky/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -o /tmp/hhd-decky.tar.gz
        sudo tar -xzf /tmp/hhd-decky.tar.gz -C $HOME/homebrew/plugins
        rm /tmp/hhd-decky.tar.gz
        echo 'Installed.'
      else
        echo 'Please install Decky Loader by running "ujust setup-decky install" first.'
      fi
    fi

# Install EmuDeck (https://www.emudeck.com/)
install-emudeck:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    echo 'Retrieving EmuDeck...'
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      wget https://www.emudeck.com/EmuDeck.desktop -O ~/.local/share/applications/EmuDeck.desktop
      echo 'EmuDeck installer added to your application grid.'
    else
      wget https://www.emudeck.com/EmuDeck.desktop -O ~/Desktop/EmuDeck.desktop
      echo 'EmuDeck installer added to your desktop.'
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
