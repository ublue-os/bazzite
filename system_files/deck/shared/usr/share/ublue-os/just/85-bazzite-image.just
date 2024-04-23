# vim: set ft=make :

# Install ROG Ally Theme for CSS Loader (https://github.com/semakusut/SBP-ROG-Ally)
install-rog-ally-theme:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/SBP-ROG-Ally"
        git clone https://github.com/semakusut/SBP-ROG-Ally.git --single-branch "$HOME/homebrew/themes/SBP-ROG-Ally"
    else
        echo 'Please install Decky Loader & CSS Loader first'
    fi

# Install Lenovo Legion Go for CSS Loader (https://github.com/frazse/SBP-Legion-Go-Theme)
install-legion-go-theme:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/SBP-Legion-Go-Theme"
        git clone https://github.com/frazse/SBP-Legion-Go-Theme.git --single-branch "$HOME/homebrew/themes/SBP-Legion-Go-Theme"
    else
        echo 'Please install Decky Loader & CSS Loader first'
    fi

# Install PS5-to-Xbox glyph theme for hhd & CSS Loader (https://github.com/frazse/PS5-to-Xbox-glyphs)
install-hhd-xbox-glyph-theme:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/PS5-to-Xbox-glyphs"
        git clone https://github.com/frazse/PS5-to-Xbox-glyphs.git --single-branch "$HOME/homebrew/themes/PS5-to-Xbox-glyphs"
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
    SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"
    if [[ ":Jupiter:" =~ ":$SYS_ID:" ]]; then
      RESOLUTION=$(sudo lshw -json -c display | jq -r .[]."configuration"."resolution")
      if [[ "${RESOLUTION}" = "1200,1920" ]]; then
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

disable-swipe-gestures:
    #!/usr/bin/bash
    echo "disabling swipe gestures for QAM and HOME"
    mkdir -p $HOME/.config/environment.d
    echo "export GAMESCOPE_DISABLE_TOUCH_GESTURES=1" > "$HOME/.config/environment.d/bazzite-disable-gamescope-gestures.conf"
    echo "Done. Please restart Steam Game Mode to see changes"

enable-swipe-gestures:
    #!/usr/bin/bash
    echo "enabling swipe gestures for QAM and HOME"
    rm -f "$HOME/.config/environment.d/bazzite-disable-gamescope-gestures.conf"
    echo "Done. Please restart Steam Game Mode to see changes"

# Enable BIOS & Firmware update services for the Steam Deck
enable-deck-bios-firmware-updates:
    #!/usr/bin/bash
    SYS_ID="$(cat /sys/devices/virtual/dmi/id/product_name)"
    if [[ ":Jupiter:" =~ ":$SYS_ID:" || ":Galileo:" =~ ":$SYS_ID:" ]]; then
      RESOLUTION=$(sudo lshw -json -c display | jq -r .[]."configuration"."resolution")
      if [[ "${RESOLUTION}" = "1200,1920" ]]; then
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

# Re-enable input remapper feature on non-desktop images
restore-input-remapper:
    systemctl enable --now input-remapper.service && \
    cp /usr/share/applications/input-remapper-gtk.desktop ~/.local/share/applications/input-remapper-gtk.desktop && \
    sed -i '/NoDisplay=true/d' ~/.local/share/applications/input-remapper-gtk.desktop

_toggle-autologin:
    #!/usr/bin/bash
    DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
    if [[ -f $DESKTOP_AUTOLOGIN ]]; then
      sudo rm -f $DESKTOP_AUTOLOGIN
    else
      sudo touch $DESKTOP_AUTOLOGIN
    fi
