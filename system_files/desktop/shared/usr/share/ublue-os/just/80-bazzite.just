# vim: set ft=make :

# Restore the default Terminal
restore-original-terminal:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
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

# Install Bazzite's Steam Game Mode Startup Video
install-gamemode-video:
    mkdir -p $HOME/.local/share/Steam/config/uioverrides/movies
    rm -f $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm
    ln -s /usr/share/ublue-os/bazzite/bazzite.webm $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm

# Force-enable AMD pstate
pstate-force-enable:
    rpm-ostree kargs --append-if-missing=amd_pstate=active

# Configure grub bootmenu visibility and fix duplicate entries
configure-grub ACTION="":
    #!/bin/bash
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
    #!/bin/bash
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
