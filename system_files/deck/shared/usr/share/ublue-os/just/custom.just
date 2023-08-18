enable-gamescope-autologin:
  #!/usr/bin/env bash
  source /etc/default/bazzite
  if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
    systemctl disable --now gnome-autologin
  elif [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
    systemctl disable --now plasma-autologin
  fi
  systemctl enable --now gamescope-autologin

enable-desktop-autologin:
  #!/usr/bin/env bash
  source /etc/default/bazzite
  systemctl disable --now gamescope-autologin
  if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
    systemctl enable --now gnome-autologin
  elif [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
    systemctl enable --now plasma-autologin
  fi

configure-waydroid:
  #!/usr/bin/env bash
  SCRIPT='/tmp/waydroid_script'
  git clone https://github.com/casualsnek/waydroid_script --depth 1 ${SCRIPT}
  sudo pip install --user -r ${SCRIPT}/requirements.txt
  sudo ${SCRIPT}/main.py
  sudo pip uninstall -r ${SCRIPT}/requirements.txt
  rm -rf ${SCRIPT}

get-decky:
  #!/usr/bin/env bash
  export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
  curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_prerelease.sh | sh
  sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader

get-emudeck:
  #!/usr/bin/env bash
  echo 'Retrieving EmuDeck...'
  if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
    wget https://www.emudeck.com/EmuDeck.desktop -O ~/.local/share/applications/EmuDeck.desktop
  else
    wget https://www.emudeck.com/EmuDeck.desktop -O ~/Desktop/EmuDeck.desktop
  fi

get-steamcmd:
  echo 'Installing SteamCMD...'
  wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
  mkdir -p ~/.steam
  tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
  rm /tmp/steamcmd.tar.gz

install-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh | bash

remove-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/uninstaller-scripts/silverblue-nix-uninstaller.sh | bash

get-greenlight:
  echo 'Retrieving Greenlight'
  wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta8/Greenlight-2.0.0-beta8.AppImage -O ~/Desktop/Greenlight.AppImage
  chmod +x ~/Desktop/Greenlight.AppImage

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

enable-vapor-theme:
  #!/usr/bin/env bash
  source /etc/default/bazzite
  if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gsettings set org.gnome.mutter center-new-windows true
    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/steamdeck/Steam\ Deck\ Logo\ Default.jpg
    gsettings set org.gnome.desktop.background picture-uri-dark file:///usr/share/backgrounds/steamdeck/Steam\ Deck\ Logo\ Default.jpg
    gradience-cli flatpak-overrides -e both
    gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vapor.json
  else 
    echo "This is only supported under GNOME."
  fi

enable-vgui2-theme:
  #!/usr/bin/env bash
  source /etc/default/bazzite
  if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gsettings set org.gnome.mutter center-new-windows true
    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/steamdeck/VGUI2.jpg
    gsettings set org.gnome.desktop.background picture-uri-dark file:///usr/share/backgrounds/steamdeck/VGUI2.jpg
    gradience-cli flatpak-overrides -e both
    gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vgui2.json
  else 
    echo "This is only supported under GNOME."
  fi

deckswap-on:
  #!/usr/bin/env bash
  STATUS=$(systemctl status deckswap.service)
  if grep -q 'inactive' <<< ${STATUS}; then
    systemctl enable deckswap.service
    echo 'deckswap enabled. Please reboot.'
  else
    echo 'deckswap is already enabled.'
  fi

deckswap-off:
  #!/usr/bin/env bash
  STATUS=$(systemctl status deckswap.service)
  if grep -qv 'inactive' <<< ${STATUS}; then
    systemctl disable deckswap.service
    echo 'deckswap disabled. Please reboot.'
  else
    echo 'deckswap is already disabled.'
  fi

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
      sudo sed -i 's/SWAP_SIZE='${CURRENT_SIZE}'G/SWAP_SIZE='${NEW_SIZE}'G/g' ${CONFIG}
      echo 'Current size: '${NEW_SIZE}'G. Please reboot.'
    else
      echo 'Error: Input out of range (1-16). Running again.'
      just --unstable resize-deckswap
    fi
  else
    echo 'Error: Input is not an integer. Running again.'
    just --unstable resize-deckswap
  fi

switch-to-ext4:
  sudo sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

zram-on:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep -q 'zram' <<< ${KARGS}; then
    rpm-ostree kargs --delete=zram
    echo 'ZRAM enabled. Please reboot.'
  else
    echo 'ZRAM is already enabled.'
  fi

zram-off:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep -qv 'zram' <<< ${KARGS}; then
    rpm-ostree kargs --append=zram=0
    echo 'ZRAM disabled. Please reboot.'
  else
    echo 'ZRAM is already disabled.'
  fi

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
        sudo sed -i 's/zram-size='${CURRENT_SIZE}'/zram-size='${NEW_SIZE}'/g' ${CONFIG}
      else
        sudo -A echo "zram-size=${NEW_SIZE}" >> ${CONFIG}
      fi
      echo 'Current size: '${NEW_SIZE}'. Please reboot.'
    else
      echo 'Error: Input out of range (512-4096). Running again.'
      just --unstable resize-zram
    fi
  else
    echo 'Error: Input is not an integer. Running again.'
    just --unstable resize-zram
  fi

hide-grub:
  #!/usr/bin/env bash  
  sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
  echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
  echo 'GRUB_HIDDEN_TIMEOUT=3' | sudo tee -a /etc/default/grub 1>/dev/null
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi

unhide-grub:
  #!/usr/bin/env bash
  sudo sed -i '/GRUB_HIDDEN_TIMEOUT=3/d' /etc/default/grub
  sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi

disable-deck-services:
  #!/usr/bin/env bash
  sudo systemctl disable jupiter-fan-control.service
  sudo systemctl disable vpower.service
  sudo systemctl disable jupiter-biosupdate.service
  sudo systemctl disable jupiter-controller-update.service

disable-bios-updates:
  #!/usr/bin/env bash
  sudo systemctl disable jupiter-biosupdate.service

disable-firmware-updates:
  #!/usr/bin/env bash
  sudo systemctl disable jupiter-controller-update.service

_toggle_wayland:
  #!/usr/bin/env bash
  source /etc/default/desktop-wayland
  if ${DESKTOP_WAYLAND}; then
    sudo sed -i 's/true/false/g' /etc/default/desktop-wayland
  else
    sudo sed -i 's/false/true/g' /etc/default/desktop-wayland
  fi
