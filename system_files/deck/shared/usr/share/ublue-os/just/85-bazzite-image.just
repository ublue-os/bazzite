# vim: set ft=make :

# Toggle between desktop/gamescope autologin
toggle-autologin:
    #!/usr/bin/bash
    DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
    if [[ -f $DESKTOP_AUTOLOGIN ]]; then
      sudo rm -f $DESKTOP_AUTOLOGIN
    else
      sudo touch $DESKTOP_AUTOLOGIN
    fi

# Install Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader)
get-decky:
    #!/usr/bin/bash
    export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
    sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader

# Install SimpleDeckyTDP for TDP Control on the Lenovo Legion Go (Requires Decky Loader)
get-simpledeckytdp:
    #!/usr/bin/bash
    if [[ -d $HOME/homebrew/plugins ]]; then
      sudo rm -rf $HOME/homebrew/plugins/SimpleDeckyTDP
      curl -L $(curl -s https://api.github.com/repos/aarron-lee/SimpleDeckyTDP/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -o /tmp/SimpleDeckyTDP.tar.gz
      sudo tar -xzf /tmp/SimpleDeckyTDP.tar.gz -C $HOME/homebrew/plugins
      rm /tmp/SimpleDeckyTDP.tar.gz
      sudo sed -i 's/ENABLE_HARDWARE_CONTROL_ON_NON_DECK_HARDWARE=0/ENABLE_HARDWARE_CONTROL_ON_NON_DECK_HARDWARE=1/g' /etc/default/steam-hardware-control
    else
      echo 'Please install Decky Loader by running ujust get-decky first.'
    fi

# Install HHD Decky Plugin for controlling input on the Lenovo Legion Go and ASUS Ally
get-hhd-decky:
    #!/usr/bin/bash
    if [[ -d $HOME/homebrew/plugins ]]; then
      sudo rm -rf $HOME/homebrew/plugins/hhd-decky
      curl -L $(curl -s https://api.github.com/repos/hhd-dev/hhd-decky/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -o /tmp/hhd-decky.tar.gz
      sudo tar -xzf /tmp/hhd-decky.tar.gz -C $HOME/homebrew/plugins
      rm /tmp/hhd-decky.tar.gz
    else
      echo 'Please install Decky Loader by running ujust get-decky first.'
    fi

# Install EmuDeck (https://www.emudeck.com/)
get-emudeck:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    echo 'Retrieving EmuDeck...'
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      wget https://www.emudeck.com/EmuDeck.desktop -O ~/.local/share/applications/EmuDeck.desktop
    else
      wget https://www.emudeck.com/EmuDeck.desktop -O ~/Desktop/EmuDeck.desktop
    fi

# Enable legacy swapfile (Not recommended)
deckswap-on:
    #!/usr/bin/bash
    STATUS=$(systemctl status deckswap.service)
    if grep -q 'inactive' <<< ${STATUS}; then
      systemctl enable --now deckswap.service
      echo 'deckswap enabled.'
    else
      echo 'deckswap is already enabled.'
    fi

# Disable legacy swapfile
deckswap-off:
    #!/usr/bin/bash
    STATUS=$(systemctl status deckswap.service)
    if grep -qv 'inactive' <<< ${STATUS}; then
      systemctl disable --now deckswap.service
      echo 'deckswap disabled.'
    else
      echo 'deckswap is already disabled.'
    fi

# Resize legacy swapfile (Default 1GB, max 16GB)
resize-deckswap:
    #!/usr/bin/bash
    CONFIG='/etc/default/deckswap'
    CURRENT_SIZE=$(cat "${CONFIG}" | grep -q "SWAP_SIZE" | sed 's/SWAP_SIZE=//g')
    echo 'Current size: '${CURRENT_SIZE}
    read -p 'Enter new size (1-16) in gigabytes (1G): ' NEW_SIZE
    if [ -z "${NEW_SIZE//[0-9]}" ]; then
      if [ -z "${NEW_SIZE}" ]; then
        NEW_SIZE=1
      fi
      if ((${NEW_SIZE} >= 1 && ${NEW_SIZE} <= 16)); then
        sudo sed -i 's/SWAP_SIZE=.*/SWAP_SIZE='${NEW_SIZE}'G/g' ${CONFIG}
        echo 'Current size: '${NEW_SIZE}'G.'
      else
        echo 'Error: Input out of range (1-16). Running again.'
        ujust resize-deckswap
      fi
      systemctl restart deckswap.service
    else
      echo 'Error: Input is not an integer. Running again.'
      ujust resize-deckswap
    fi

# Use EXT4 for SD Cards, allows use of SteamOS formatted SD cards
switch-to-ext4:
    sudo sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

# Enable ZRAM (Enabled by default)
zram-on:
    #!/usr/bin/bash
    ublue-update --wait
    KARGS=$(rpm-ostree kargs)
    if grep -q 'zram' <<< ${KARGS}; then
      rpm-ostree kargs --delete=systemd.zram=0
      echo 'ZRAM enabled. Please reboot.'
    else
      echo 'ZRAM is already enabled.'
    fi

# Disable ZRAM (Not recommended)
zram-off:
    #!/usr/bin/bash
    ublue-update --wait
    KARGS=$(rpm-ostree kargs)
    if grep -qv 'zram' <<< ${KARGS}; then
      rpm-ostree kargs --append-if-missing=systemd.zram=0
      echo 'ZRAM disabled. Please reboot.'
    else
      echo 'ZRAM is already disabled.'
    fi

# Resize ZRAM (Default 1GB)
resize-zram:
    #!/usr/bin/bash
    CONFIG='/etc/systemd/zram-generator.conf'
    if grep -q "zram-size" <<< $(cat ${CONFIG}); then
      CURRENT_SIZE=$(cat "${CONFIG}" | grep -q "zram-size" | sed 's/zram-size=//g')
    else
      CURRENT_SIZE=1024
    fi
    echo 'Current size: '${CURRENT_SIZE}
    read -p 'Enter new size (512-4096) in megabytes (1024): ' NEW_SIZE
    if [ -z "${NEW_SIZE//[0-9]}" ]; then
      if [ -z "${NEW_SIZE}" ]; then
        NEW_SIZE=1024
      fi
      if ((${NEW_SIZE} >= 512 && ${NEW_SIZE} <= 4096)); then
        if grep -q "zram-size" <<< $(cat ${CONFIG}); then
          sudo sed -i 's/zram-size=.*/zram-size='${NEW_SIZE}'/g' ${CONFIG}
        else
          sudo echo "zram-size=${NEW_SIZE}" >> ${CONFIG}
        fi
        systemctl daemon-reload
        systemctl start /dev/zram0
        zramctl
      else
        echo 'Error: Input out of range (512-4096). Running again.'
        ujust resize-zram
      fi
    else
      echo 'Error: Input is not an integer. Running again.'
      ujust resize-zram
    fi

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

_toggle_wayland:
    #!/usr/bin/bash
    source /etc/default/desktop-wayland
    if ${DESKTOP_WAYLAND}; then
      sudo sed -i 's/true/false/g' /etc/default/desktop-wayland
    else
      sudo sed -i 's/false/true/g' /etc/default/desktop-wayland
    fi

# Re-enable input remapper feature on non-desktop images
enable-input-remapper:
    systemctl enable --now input-remapper.service && \
    cp /usr/share/applications/input-remapper-gtk.desktop ~/.local/share/applications/input-remapper-gtk.desktop && \
    sed -i '/NoDisplay=true/d' ~/.local/share/applications/input-remapper-gtk.deskto
