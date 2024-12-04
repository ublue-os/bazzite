# vim: set ft=make :

# Enable BTRFS deduplication
enable-deduplication:
    systemctl enable btrfs-dedup@var-home.timer
    systemctl enable btrfs-dedup@run-media-mmcblk0p1.timer

# Install Handheld Controller Glyphs theme for hhd & CSS Loader (https://github.com/victor-borges/handheld-controller-glyphs)
install-hhd-controller-glyph-theme:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/handheld-controller-glyphs"
        git clone https://github.com/victor-borges/handheld-controller-glyphs.git --single-branch "$HOME/homebrew/themes/handheld-controller-glyphs"
    else
        echo 'Please install Decky Loader & CSS Loader first'
    fi

# Install EmuDeck (https://www.emudeck.com/)
get-emudeck:
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

# Use EXT4 for SD Cards, allows use of SteamOS formatted SD cards
switch-to-ext4:
    sudo sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

# Install Deck HD BIOS
install-deckhd-bios:
    #!/usr/bin/bash
    SYS_ID="$(/usr/libexec/hwsupport/sysid)"
    if [[ ":Jupiter:" =~ ":$SYS_ID:" ]]; then
      RESOLUTION=$(xrandr --display :0 | grep '*' | uniq | awk '{print $1}')
      if [[ "${RESOLUTION}" = "1920x1200" ]]; then
        sudo systemctl mask --now jupiter-biosupdate.service
        wget -q https://deckhd.com/downloads/install.sh -O /tmp/deckhd-install.sh
        chmod +x /tmp/deckhd-install.sh
        sudo ./tmp/deckhd-install.sh
      else
        echo "Unable to detect DeckHD. Aborting..."
      fi
    else
      echo "This is only applicable to LCD Steam Decks with the DeckHD screen. Aborting..."
    fi

# Enable BIOS & Firmware update services for the Steam Deck
enable-deck-bios-firmware-updates:
    #!/usr/bin/bash
    SYS_ID="$(/usr/libexec/hwsupport/sysid)"
    if [[ ":Jupiter:" =~ ":$SYS_ID:" || ":Galileo:" =~ ":$SYS_ID:" ]]; then
      RESOLUTION=$(xrandr --display :0 | grep '*' | uniq | awk '{print $1}')
      if [[ "${RESOLUTION}" = "1920x1200" ]]; then
        echo "DeckHD detected. Firmware updates enabled. BIOS updates not enabled."
      elif [[ "$(awk '/MemTotal/{print $(NF-1)}' /proc/meminfo)" == "31664740" ]]; then
        echo "32GB RAM modded Deck detected. Firmware updates enabled. BIOS updates not enabled."
      else
        sudo systemctl enable jupiter-biosupdate.service
      fi
      sudo systemctl enable jupiter-controller-update.service
    else
      echo "This is only applicable to Valve's Steam Deck. Aborting..."
    fi

# Disable Steam Deck BIOS updates
disable-bios-updates:
    #!/usr/bin/bash
    sudo systemctl mask --now jupiter-biosupdate.service

# Disable Steam Deck controller firmware updates
disable-firmware-updates:
    #!/usr/bin/bash
    sudo systemctl mask --now jupiter-controller-update.service

# Disable SDGyroDSU
disable-sdgyrodsu:
    #!/usr/bin/bash
    sudo systemctl mask --user sdgyrodsu.service

# runs ryzenadj --max-performance on AC power
enable-ryzenadj-max-performance:
    #/bin/bash
    # credit to adolforegosa on discord for the original fix
    echo 'this fix sets ryzenadj --max-performance whenever AC status changes to battery from plugged-in'
    echo 'SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/ryzenadj --max-performance"' | sudo tee "/etc/udev/rules.d/99-ryzenadj-power-source-change.rules" > /dev/null

    sudo udevadm control --reload-rules
    echo 'installation complete. Reboot to take effect'

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

# disables ryzenadj --max-performance on AC power
disable-ryzenadj-max-performance:
    #/bin/bash
    sudo rm /etc/udev/rules.d/99-ryzenadj-power-source-change.rules
    sudo udevadm control --reload-rules
    echo 'removal complete'

# Re-enable input remapper feature on non-desktop images
restore-input-remapper:
    systemctl enable --now input-remapper.service && \
    cp /usr/share/applications/input-remapper-gtk.desktop ~/.local/share/applications/input-remapper-gtk.desktop && \
    sed -i '/NoDisplay=true/d' ~/.local/share/applications/input-remapper-gtk.desktop

# Install firmware files needed for ayaneo and orangepi speakers
install-speaker-firmware ACTION="":
    #!/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    FIRMWARE_SCRIPT="https://raw.githubusercontent.com/hhd-dev/hwinfo/refs/heads/master/firmware/bazzite-speaker.sh"
    curl -o "/tmp/bazzite-speaker.sh" "$FIRMWARE_SCRIPT" && cat /tmp/bazzite-speaker.sh | pygmentize -l bash -O style=emacs
    echo ""
    echo "Run the above script using elevated permissions?"
    if [ "$OPTION" == "" ]; then
      OPTION=$(Choose "Yes" "No")
    fi
    if [[ "${OPTION,,}" =~ ^yes || "${OPTION,,}" =~ ^-y ]]; then
      sudo bash /tmp/bazzite-speaker.sh
    fi
    rm /tmp/bazzite-speaker.sh

# Install hhd main branch locally until reboot, helpful for hhd testing and debugging. (rename to install-hhd-dev if we unhide)
_hhd-dev:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Installing ${b}Handheld Daemon${n} locally until next reboot."
    curl -L https://raw.githubusercontent.com/hhd-dev/hhd/master/local_hhd.sh | bash

_toggle-autologin:
    #!/usr/bin/bash
    DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
    if [[ -f $DESKTOP_AUTOLOGIN ]]; then
      sudo rm -f $DESKTOP_AUTOLOGIN
    else
      sudo touch $DESKTOP_AUTOLOGIN
    fi
