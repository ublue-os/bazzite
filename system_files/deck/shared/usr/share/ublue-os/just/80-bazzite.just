# Toggle between desktop/gamescope autologin
toggle-autologin:
    #!/usr/bin/bash
    DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
    if [[ -f $DESKTOP_AUTOLOGIN ]]; then
      sudo rm -f $DESKTOP_AUTOLOGIN
    else
      sudo touch $DESKTOP_AUTOLOGIN
    fi

# Install Bazzite's Steam Game Mode Startup Video
install-gamemode-video:
    mkdir -p $HOME/.local/share/Steam/config/uioverrides/movies
    rm -f $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm
    ln -s /usr/share/ublue-os/bazzite/bazzite.webm $HOME/.local/share/Steam/config/uioverrides/movies/deck_startup.webm

# Fix the default Steam config to improve download speeds
fix-steam-download-speed:
    mkdir -p $HOME/.local/share/Steam
    rm -f $HOME/.local/share/Steam/steam_dev.cfg
    bash -c 'printf "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0\n" > $HOME/.local/share/Steam/steam_dev.cfg'

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
    fi

# Remove all waydroid-related files in your user folders
reset-waydroid:
    bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'
    sudo mkdir -p /var/lib/waydroid
    sudo bash -c 'printf "[properties]\nro.hardware.gralloc=minigbm_gbm_mesa\npersist.waydroid.udev=true\npersist.waydroid.uevent=true\nro.sf.lcd_density=215" > /var/lib/waydroid/waydroid.cfg'

# Quickly initialize a waydroid image
init-waydroid:
    #!/usr/bin/bash
    sudo waydroid init -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor'

# Launch Waydroid configuration helper
configure-waydroid:
    #!/usr/bin/bash
    git clone https://github.com/ublue-os/waydroid_script.git --depth 1 /tmp/waydroid_script
    python -m venv /tmp/waydroid_script/venv
    source /tmp/waydroid_script/venv/bin/activate
    sudo pip install -r /tmp/waydroid_script/requirements.txt
    sudo /tmp/waydroid_script/main.py
    deactivate
    sudo rm -rf /tmp/waydroid_script

# Install Sunshine
install-sunshine:
    #!/usr/bin/bash
    sudo sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree.repo
    sudo sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
    sudo systemctl enable sunshine-workaround.service
    ublue-update --wait
    rpm-ostree install -y sunshine
    echo "Sunshine is installed, please reboot to apply changes."

# Remove Sunshine
remove-sunshine:
    #!/usr/bin/bash
    sudo sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree.repo
    sudo sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
    sudo systemctl disable sunshine-workaround.service
    ublue-update --wait
    rpm-ostree remove -y sunshine
    echo "Sunshine has been uninstalled, please reboot to apply changes."

# Autostart Sunshine
autostart-sunshine:
    #!/usr/bin/bash
    systemctl enable --user --now sunshine.service

# Install LACT for overclocking & undervolting AMD GPUs (For HTPC use only)
install-lact:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    ublue-update --wait
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        echo 'Installing LACT Libadwaita...'
        wget \
          $(curl -s https://api.github.com/repos/ilya-zlobintsev/LACT/releases/latest | \
          jq -r ".assets[] | select(.name | test(\"lact-libadwaita.*fedora-$(rpm -E %fedora)\")) | .browser_download_url") \
          -O /tmp/lact.rpm
    else
        echo 'Installing LACT...'
        wget \
          $(curl -s https://api.github.com/repos/ilya-zlobintsev/LACT/releases/latest | \
          jq -r ".assets[] | select(.name | test(\"lact-[0-9].*fedora-$(rpm -E %fedora)\")) | .browser_download_url") \
          -O /tmp/lact.rpm
    fi
    rpm-ostree install --apply-live -y /tmp/lact.rpm
    sudo systemctl enable --now lactd
    rm /tmp/lact.rpm
    echo 'Complete.'

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

# Install SteamCMD (https://developer.valvesoftware.com/wiki/SteamCMD)
get-steamcmd:
    echo 'Installing SteamCMD...'
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
    mkdir -p ~/.steam
    tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
    rm /tmp/steamcmd.tar.gz

# Install OpenRazer for Razer gaming hardware
install-openrazer:
    sudo wget https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo -O /etc/yum.repos.d/hardware:razer.repo && \
    ublue-update --wait && \
    rpm-ostree install -y openrazer-meta razergenie && \
    if ! grep -q "plugdev" /etc/group; then \
      sudo bash -c 'grep "plugdev" /lib/group >> /etc/group' \
    ; fi && \
    sudo usermod -a -G plugdev $USER && \
    echo "Please reboot to apply needed changes."

# Install Wootility for configuring Wooting Keyboards
get-wootility:
    #!/usr/bin/bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Downloads/wootility.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/wootility.AppImage
    else
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Desktop/wootility.AppImage
      chmod +x $HOME/Desktop/wootility.AppImage
    fi

# Patch a bug in some 32-bit Source 1.x titles that causes them to crash at startup
patch-source1-tcmalloc:
    #!/usr/bin/bash
    echo 'Add the following as a launch option in Steam:'
    echo 'LD_PRELOAD=/usr/lib/libtcmalloc_and_profiler.so.4 %command%'
    echo "Delete libtcmalloc_minimal.so.x in the game's bin folder if present."

# Patch GMod's 64-bit beta to work properly on Linux (https://github.com/solsticegamestudios/GModCEFCodecFix)
patch-gmod:
    #!/usr/bin/bash
    mkdir -p /tmp/patch-gmod
    wget \
      $(curl -s https://api.github.com/repos/solsticegamestudios/GModCEFCodecFix/releases/latest | \
      jq -r ".assets[] | select(.name | test(\"GModCEFCodecFix-Linux\")) | .browser_download_url") \
      -P /tmp/patch-gmod
    chmod +x /tmp/patch-gmod/GModCEFCodecFix-Linux
    /tmp/patch-gmod/GModCEFCodecFix-Linux
    rm -rf /tmp/patch-gmod

# Install Adwaita-for-Steam theme for CSS Loader (https://github.com/tkashkin/Adwaita-for-Steam)
install-adwaita-for-steam:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      if [ -d "$HOME/homebrew/themes" ]; then
        git clone https://github.com/tkashkin/Adwaita-for-Steam.git --single-branch "$HOME/homebrew/themes/Adwaita-for-Steam"
      else
        echo 'Please install Decky Loader & CSS Loader first, see ujust get-decky'
      fi
    else 
      echo "This is only supported under GNOME."
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

# Force-enable AMD pstate
pstate-force-enable:
    rpm-ostree kargs --append-if-missing=amd_pstate=active

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

# Set system to boot without showing the grub screen with options
hide-grub:
    #!/usr/bin/bash  
    sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
    echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
    echo 'GRUB_HIDDEN_TIMEOUT=3' | sudo tee -a /etc/default/grub 1>/dev/null
    if [ -d /sys/firmware/efi ]; then
      sudo grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      sudo grub2-mkconfig -o /etc/grub2.cfg
    fi

# Set system to boot with the grub screen showing options (Default)
unhide-grub:
    #!/usr/bin/bash
    sudo sed -i '/GRUB_HIDDEN_TIMEOUT=3/d' /etc/default/grub
    sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
    sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
    if [ -d /sys/firmware/efi ]; then
      sudo grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      sudo grub2-mkconfig -o /etc/grub2.cfg
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

# Enable Flatpak Theming
enable-flatpak-theming:
    flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=~/.icons:ro --filesystem=~/.themes:ro

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
    #!/usr/bin/bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Re-enable input remapper feature on non-desktop images
enable-input-remapper:
    systemctl enable --now input-remapper.service && \
    cp /usr/share/applications/input-remapper-gtk.desktop ~/.local/share/applications/input-remapper-gtk.desktop && \
    sed -i '/NoDisplay=true/d' ~/.local/share/applications/input-remapper-gtk.deskto

# Install Oversteer for Logitech steering wheels
install-oversteer: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c 'sudo dnf copr enable -y kylegospo/oversteer && \
      sudo dnf install -y oversteer && \
      distrobox-export --app oversteer'

# Install Solaar for Logitech Mice, Keyboards, and Trackpads
install-solaar: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c 'sudo dnf install -y \
      solaar && \
      distrobox-export --app solaar' && \
    mkdir -p ~/.config/autostart && \
    rm -f ~/.config/autostart/fedora-solaar.desktop && \
    cp ~/.local/share/applications/fedora-solaar.desktop ~/.config/autostart/fedora-solaar.desktop && \
    sed -i 's/fedora --   solaar/fedora --   solaar --window=hide/g' ~/.config/autostart/fedora-solaar.desktop

# Install Resilio Sync, a file synchronization utility powered by BitTorrent
install-resilio-sync: distrobox-check-fedora
    distrobox-enter -n fedora -- 'sudo rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc' && \
    distrobox-enter -n fedora -- 'sudo wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/resilio-sync.repo -O /etc/yum.repos.d/resilio-sync.repo' && \
    distrobox-enter -n fedora -- 'sudo dnf install -y resilio-sync' && \
    mkdir -p ~/.config/systemd/user/ && \
    rm -f ~/.config/systemd/user/fedora-resilio-sync.service && \
    wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/fedora-resilio-sync.service -O ~/.config/systemd/user/fedora-resilio-sync.service && \
    systemctl --user daemon-reload && \
    systemctl enable --user --now fedora-resilio-sync.service

# Install scrcpy, a utility that mirrors Android devices (video and audio) connected via USB or over TCP/IP
install-scrcpy: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c 'sudo dnf copr enable -y zeno/scrcpy && \
      sudo dnf install -y scrcpy && \
      distrobox-export --app scrcpy'

# Install OpenTabletDriver, an open source, cross-platform, user-mode tablet driver
install-opentabletdriver:
    if grep -qvz "arch" <<< $(distrobox list); then \
      distrobox-create --nvidia --image ghcr.io/ublue-os/arch-distrobox:latest -n arch -Y; \
    fi && \
    distrobox enter -n arch -- ' paru -S opentabletdriver --noconfirm' && \
    mkdir -p ~/.config/systemd/user/ && \
    rm -f ~/.config/systemd/user/arch-opentabletdriver.service && \
    wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/OpenTabletDriver/opentabletdriver.service -O ~/.config/systemd/user/arch-opentabletdriver.service && \
    systemctl --user daemon-reload && \
    systemctl enable --user --now arch-opentabletdriver.service && \
    distrobox enter -n arch -- 'distrobox-export --app otd-gui'

# Restore Bazzite Breeze GTK4 theme (KDE Only)
restore-bazzite-breeze-gtk-theme:
    rm -f $HOME/.config/gtk-4.0/gtk.css
    rm -f $HOME/.config/gtk-4.0/kde_window_geometry.css
    cp /usr/etc/skel/.config/gtk-4.0/gtk.css $HOME/.config/gtk-4.0/gtk.css
    cp /usr/etc/skel/.config/gtk-4.0/kde_window_geometry.css $HOME/.config/gtk-4.0/kde_window_geometry.css

# Restore Bazzite customized DE settings (GNOME only)
restore-gnome-de-settings:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      dconf load / < /usr/etc/dconf/db/local.d/02-bazzite-global
      dconf load / < /usr/etc/dconf/db/local.d/03-bazzite-dash
      dconf load / < /usr/etc/dconf/db/local.d/05-bazzite-extensions
      dconf load / < /usr/etc/dconf/db/local.d/06-bazzite-theme
      dconf load / < /usr/etc/dconf/db/local.d/07-bazzite-deck
    else
      echo 'This command may only be used on GNOME.'
    fi

# Restore Bazzite customized applications folders (GNOME only)
restore-gnome-folders:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      dconf load / < /usr/etc/dconf/db/local.d/04-bazzite-folders
    else
      echo 'This command may only be used on GNOME.'
    fi

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/bin/env bash
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      /usr/bin/ujust distrobox-fedora
    fi
