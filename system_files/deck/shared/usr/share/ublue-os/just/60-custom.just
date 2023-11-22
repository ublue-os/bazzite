# Toggle between desktop/gamescope autologin
toggle-autologin:
    #!/usr/bin/env bash
    DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
    if [[ -f $DESKTOP_AUTOLOGIN ]]; then
      sudo rm -f $DESKTOP_AUTOLOGIN
    else
      sudo touch $DESKTOP_AUTOLOGIN
    fi

# Remove all waydroid-related files in your user folders
reset-waydroid:
    bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'
    sudo mkdir -p /var/lib/waydroid
    sudo bash -c 'printf "[properties]\nro.hardware.gralloc=minigbm_gbm_mesa\npersist.waydroid.udev=true\npersist.waydroid.uevent=true\nro.sf.lcd_density=215" > /var/lib/waydroid/waydroid.cfg'

# Quickly initialize a waydroid image
init-waydroid:
    #!/usr/bin/env bash
    sudo waydroid init -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor'

# Launch Waydroid configuration helper
configure-waydroid:
    #!/usr/bin/env bash
    git clone https://github.com/casualsnek/waydroid_script.git --depth 1 /tmp/waydroid_script
    python -m venv /tmp/waydroid_script/venv
    source /tmp/waydroid_script/venv/bin/activate
    sudo pip install -r /tmp/waydroid_script/requirements.txt
    sudo /tmp/waydroid_script/main.py
    deactivate
    sudo rm -rf /tmp/waydroid_script

# Install Decky Loader (https://github.com/SteamDeckHomebrew/decky-loader)
get-decky:
    #!/usr/bin/env bash
    export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
    sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader

# Install EmuDeck (https://www.emudeck.com/)
get-emudeck:
    #!/usr/bin/env bash
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
    rpm-ostree install openrazer-meta razergenie && \
    if ! grep -q "plugdev" /etc/group; then \
      sudo bash -c 'grep "plugdev" /lib/group >> /etc/group' \
    ; fi && \
    sudo usermod -a -G plugdev $USER && \
    echo "Please reboot to apply needed changes."

# Install Nix with the Determinate Nix Installer
install-nix:
    #!/usr/bin/env bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo bash -s -- install --no-confirm

# Uninstall Nix
remove-nix:
    sudo /nix/nix-installer uninstall

# Install Fleek (https://getfleek.dev/)
install-fleek:
    #!/usr/bin/env bash
    if [[ -d "/nix" ]]; then
      mkdir -p $HOME/.config/nix
      echo "experimental-features = nix-command flakes" >> $HOME/.config/nix/nix.conf
      curl -fsSL https://getfleek.dev/installer | env FORCE=1 bash
    else
      echo "Install nix with ujust install-nix before running ujust install-fleek."
    fi

# Integrate Nix/Fleek applications with system theme
install-fleek-themes:
    #!/usr/bin/env bash
    if [[ -x "/var/usrlocal/bin/fleek" ]]; then
      IMAGE_INFO="/usr/share/ublue-os/image-info.json"
      BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
      if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        fleek add adw-gtk3 --apply
      else
        fleek add breeze-icons
        fleek add libsForQt5.breeze-qt5
        fleek apply
      fi
    else
      echo "Install fleek with ujust install-fleek before running ujust install-fleek-themes."
    fi

# Install Greenlight xCloud and xHome streaming AppImage
get-greenlight:
    #!/usr/bin/env bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget "https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta14/Greenlight-2.0.0-beta14.AppImage" -O $HOME/Downloads/Greenlight.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/Greenlight.AppImage
    else
      wget "https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta14/Greenlight-2.0.0-beta14.AppImage" -O $HOME/Desktop/Greenlight.AppImage
      chmod +x $HOME/Desktop/Greenlight.AppImage
    fi

# Install Wootility for configuring Wooting Keyboards
get-wootility:
    #!/usr/bin/env bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Downloads/wootility.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/wootility.AppImage
    else
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Desktop/wootility.AppImage
      chmod +x $HOME/Desktop/wootility.AppImage
    fi

# Install BoilR, a Steam Library and art management tool
get-boilr:
    #!/usr/bin/env bash
    curl \
      $(curl -s https://api.github.com/repos/PhilipK/BoilR/releases/latest | \
      jq -r ".assets[] | select(.name | test(\"linux_BoilR\")) | .browser_download_url") \
      --create-dirs -o ~/Applications/BoilR
    chmod +x ~/Applications/BoilR
    for px in 64 128 256;\
    do \
    curl $(curl -s https://api.github.com/repos/PhilipK/BoilR/contents/resources/$px/io.github.philipk.boilr.png | \
    jq -r ".download_url") \
    --create-dirs -o ~/.local/share/icons/hicolor/$px\x$px/apps/io.github.philipk.boilr.png;\
    done
    mkdir -p $HOME/.local/share/applications
    HOME=$HOME
    echo -e \
    "[Desktop Entry]\n\
    Version=1.0\n\
    Type=Application\n\
    Name=BoilR\n\
    Comment=Add non-steam games to your steam library\n\
    Categories=Utility;Amusement;\n\
    Keywords=Steam;Heroic;Lutris;Itch;Origin;GOG;UPlay;Icons;Images;Non-Steam;Games;\n\
    Icon=io.github.philipk.boilr\n\
    Exec=$HOME/Applications/BoilR\n\
    Terminal=false\n\
    StartupNotify=true" \
    > ~/.local/share/applications/BoilR.desktop
    if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
      cp ~/.local/share/applications/BoilR.desktop ~/Desktop
    fi

# Patch a bug in some 32-bit Source 1.x titles that causes them to crash at startup
patch-source1-tcmalloc:
    echo 'Add the following as a launch option in Steam:'
    echo 'LD_PRELOAD=/usr/lib/libtcmalloc_and_profiler.so.4 %command%'
    echo "Delete libtcmalloc_minimal.so.x in the game's bin folder if present."

# Patch GMod's 64-bit beta to work properly on Linux (https://github.com/solsticegamestudios/GModCEFCodecFix)
patch-gmod:
    #!/usr/bin/env bash
    mkdir -p /tmp/patch-gmod
    wget \
      $(curl -s https://api.github.com/repos/solsticegamestudios/GModCEFCodecFix/releases/latest | \
      jq -r ".assets[] | select(.name | test(\"GModCEFCodecFix-Linux\")) | .browser_download_url") \
      -P /tmp/patch-gmod
    chmod +x /tmp/patch-gmod/GModCEFCodecFix-Linux
    /tmp/patch-gmod/GModCEFCodecFix-Linux
    rm -rf /tmp/patch-gmod

# Activate Valve-inspired Vapor theme on GNOME
enable-vapor-theme:
    #!/usr/bin/env bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
      gsettings set org.gnome.mutter center-new-windows true
      gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
      gsettings set org.gnome.desktop.interface color-scheme prefer-dark
      gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
      gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/steamdeck/Steam\ Deck\ Logo\ Default.jpg
      gsettings set org.gnome.desktop.background picture-uri-dark file:///usr/share/backgrounds/steamdeck/Steam\ Deck\ Logo\ Default.jpg
      gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans Medium 11"
      gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 11"
      gsettings set org.gnome.desktop.interface font-name "Noto Sans 11"
      gsettings set org.gnome.desktop.sound theme-name "steam"
      gradience-cli flatpak-overrides -e both
      gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vapor.json
    else 
      echo "This is only supported under GNOME."
    fi

# Activate Valve-inspired VGUI2 theme on GNOME
enable-vgui2-theme:
    #!/usr/bin/env bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
      gsettings set org.gnome.mutter center-new-windows true
      gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
      gsettings set org.gnome.desktop.interface color-scheme prefer-dark
      gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
      gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/steamdeck/VGUI2.jpg
      gsettings set org.gnome.desktop.background picture-uri-dark file:///usr/share/backgrounds/steamdeck/VGUI2.jpg
      gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans Medium 11"
      gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 11"
      gsettings set org.gnome.desktop.interface font-name "Noto Sans 11"
      gsettings set org.gnome.desktop.sound theme-name "steam"
      gradience-cli flatpak-overrides -e both
      gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vgui2.json
    else 
      echo "This is only supported under GNOME."
    fi

# Install Adwaita-for-Steam theme for CSS Loader (https://github.com/tkashkin/Adwaita-for-Steam)
install-adwaita-for-steam:
    #!/usr/bin/env bash
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
    #!/usr/bin/env bash
    STATUS=$(systemctl status deckswap.service)
    if grep -q 'inactive' <<< ${STATUS}; then
      systemctl enable --now deckswap.service
      echo 'deckswap enabled.'
    else
      echo 'deckswap is already enabled.'
    fi

# Disable legacy swapfile
deckswap-off:
    #!/usr/bin/env bash
    STATUS=$(systemctl status deckswap.service)
    if grep -qv 'inactive' <<< ${STATUS}; then
      systemctl disable --now deckswap.service
      echo 'deckswap disabled.'
    else
      echo 'deckswap is already disabled.'
    fi

# Resize legacy swapfile (Default 1GB, max 16GB)
resize-deckswap:
    #!/usr/bin/env bash
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
    #!/usr/bin/env bash
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
    #!/usr/bin/env bash
    ublue-update --wait
    KARGS=$(rpm-ostree kargs)
    if grep -qv 'zram' <<< ${KARGS}; then
      rpm-ostree kargs --append=systemd.zram=0
      echo 'ZRAM disabled. Please reboot.'
    else
      echo 'ZRAM is already disabled.'
    fi

# Resize ZRAM (Default 1GB)
resize-zram:
    #!/usr/bin/env bash
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
    #!/usr/bin/env bash  
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
    #!/usr/bin/env bash
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
    #!/usr/bin/env bash
    RESOLUTION=$(sudo lshw -json -c display | jq -r .[]."configuration"."resolution")
    if [[ "${RESOLUTION}" = "1200,1920" ]]; then
        sudo systemctl mask --now jupiter-biosupdate.service
        wget -q https://deckhd.com/downloads/install.sh -O /tmp/deckhd-install.sh
        chmod +x /tmp/deckhd-install.sh
        sudo ./tmp/deckhd-install.sh
    else
        echo "Unable to detect DeckHD. Aborting..."
    fi

# Enable BIOS & Firmware update services for the Steam Deck
enable-deck-bios-firmware-updates:
    #!/usr/bin/env bash
    sudo systemctl enable jupiter-biosupdate.service
    sudo systemctl enable jupiter-controller-update.service

# Disable Steam Deck BIOS updates
disable-bios-updates:
    #!/usr/bin/env bash
    sudo systemctl mask --now jupiter-biosupdate.service

# Disable Steam Deck controller firmware updates
disable-firmware-updates:
    #!/usr/bin/env bash
    sudo systemctl mask --now jupiter-controller-update.service

# Disable SDGyroDSU
disable-sdgyrodsu:
    #!/usr/bin/env bash
    sudo systemctl mask --user sdgyrodsu.service

_toggle_wayland:
    #!/usr/bin/env bash
    source /etc/default/desktop-wayland
    if ${DESKTOP_WAYLAND}; then
      sudo sed -i 's/true/false/g' /etc/default/desktop-wayland
    else
      sudo sed -i 's/false/true/g' /etc/default/desktop-wayland
    fi

# Enable Flatpak Theming
enable-flatpak-theming:
    flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=~/.icons:ro --filesystem=~/.themes:ro

# Enable XwaylandVideoBridge for screensharing under Wayland
fix-screenshare:
    cp /usr/share/applications/org.kde.xwaylandvideobridge.desktop $HOME/.config/autostart/

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
    #!/usr/bin/env bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Install Webapp manager
install-webapp-manager: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c "sudo dnf copr enable -y kylegospo/webapp-manager && \
      sudo dnf install -y webapp-manager && \
      distrobox-export --app webapp-manager"

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

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/bin/env bash
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      /usr/bin/ujust distrobox-fedora
    fi
