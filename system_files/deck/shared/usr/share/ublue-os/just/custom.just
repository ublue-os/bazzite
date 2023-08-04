enable-gamescope-autologin:
  #!/usr/bin/env bash
  if grep "gnome" <<< $(rpm-ostree status); then
    systemctl disable --now gnome-autologin
  else
    systemctl disable --now plasma-autologin
  fi
  systemctl enable --now gamescope-autologin

enable-desktop-autologin:
  #!/usr/bin/env bash
  systemctl disable --now gamescope-autologin
  if grep "gnome" <<< $(rpm-ostree status); then
    systemctl enable --now gnome-autologin
  else
    systemctl enable --now plasma-autologin
  fi

set-steamos-kargs:
  echo 'Setting kargs...'
  rpm-ostree kargs --append="amd_pstate=active" --append="amd_iommu=off" --append="amdgpu.gttsize=8128" --append="spi_amd.speed_dev=1" --append="audit=0" --append="initcall_blacklist=simpledrm_platform_driver_init" --delete-if-present="nomodeset"

create-steam-shortcuts:
  cp /usr/share/applications/steam.desktop ~/Desktop
  sed -i 's@Steam (Runtime)@Steam@g' ~/Desktop/steam.desktop
  cp /etc/skel.d/Desktop/Return.desktop ~/Desktop

get-decky:
  #!/usr/bin/env bash
  export HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
  curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
  sudo chcon -t bin_t $HOME/homebrew/services/PluginLoader

get-emudeck:
  echo 'Retrieving EmuDeck...'
  wget https://www.emudeck.com/EmuDeck.desktop -P ~/Desktop
  chmod +x ~/Desktop/EmuDeck.desktop

get-steamcmd:
  echo 'Installing SteamCMD...'
  wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
  tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
  rm /tmp/steamcmd.tar.gz

install-extensions-cli:
  #!/usr/bin/env bash
  if grep "gnome" <<< $(rpm-ostree status); then
    pip install --upgrade gnome-extensions-cli
  else
    echo "This is only supported under GNOME."
  fi

enable-system76-scheduler:
  #!/usr/bin/env bash
  if grep -v "gnome" <<< $(rpm-ostree status); then
    echo 'Installing System76-Scheduler plugin for KDE...'
    git clone https://github.com/maxiberta/kwin-system76-scheduler-integration.git --depth 1 /tmp/kwin-system76-scheduler-integration
    kpackagetool5 --type=KWin/Script -i /tmp/kwin-system76-scheduler-integration
    systemctl --user enable --now com.system76.Scheduler.dbusproxy.service
    systemctl enable --now com.system76.Scheduler.service
    kcmshell5 kcm_kwin_scripts
    rm -rf /tmp/kwin-system76-scheduler-integration
  else
    echo 'Enabling System76-Scheduler GNOME extension...'
    gsettings set org.gnome.shell enabled-extensions ['appindicatorsupport@rgcjonas.gmail.com', 'gsconnect@andyholmes.github.io', 's76-scheduler@mattjakeman.com', 'tofumenu@tofu', 'user-theme@gnome-shell-extensions.gcampax.github.com']
    gsettings set org.gnome.shell.extensions.fedora-menu menu-button-icon-size 20
  fi

install-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh | bash

remove-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/uninstaller-scripts/silverblue-nix-uninstaller.sh | bash

get-greenlight:
  echo 'Retrieving Greenlight'
  wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta8/Greenlight-2.0.0-beta8.AppImage -O ~/Desktop/Greenlight.AppImage
  chmod +x ~/Desktop/Greenlight.AppImage

get-boilr:
  wget \
    $(curl -s https://api.github.com/repos/PhilipK/BoilR/releases/latest | \
    jq -r ".assets[] | select(.name | test(\"linux_BoilR\")) | .browser_download_url") \
    -O ~/Desktop/BoilR
  chmod +x ~/Desktop/BoilR

enable-wallpaper-engine:
  #!/usr/bin/env bash
  if grep -v "gnome" <<< $(rpm-ostree status); then
    echo 'Installing Wallpaper Engine Plugin for KDE...'
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 /tmp/wallpaper-engine-kde-plugin
    plasmapkg2 -i /tmp/wallpaper-engine-kde-plugin/plugin
    rm -rf /tmp/wallpaper-engine-kde-plugin
  else
    echo "This is only supported under KDE."
  fi

setup-gradience:
  #!/usr/bin/env bash
  if grep "gnome" <<< $(rpm-ostree status); then
    gradience-cli import -p /usr/share/ublue-os/bazzite/themes/vapor.json
    gradience-cli import -p /usr/share/ublue-os/bazzite/themes/vgui2.json
  else 
    echo "This is only supported under GNOME."
  fi

enable-vapor-theme:
  #!/usr/bin/env bash
  if grep "gnome" <<< $(rpm-ostree status); then
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
  if grep "gnome" <<< $(rpm-ostree status); then
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
  if grep 'inactive' <<< ${STATUS}; then
    systemctl enable deckswap.service
    echo 'deckswap enabled. Please reboot.'
  else
    echo 'deckswap is already enabled.'
  fi

deckswap-off:
  #!/usr/bin/env bash
  STATUS=$(systemctl status deckswap.service)
  if grep -v 'inactive' <<< ${STATUS}; then
    systemctl disable deckswap.service
    echo 'deckswap disabled. Please reboot.'
  else
    echo 'deckswap is already disabled.'
  fi

resize-deckswap:
  #!/usr/bin/env bash
  CONFIG='/etc/default/deckswap'
  CURRENT_SIZE=$(cat "${CONFIG}" | grep "SWAP_SIZE" | sed 's/SWAP_SIZE=//g')
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

enable-duperemove:
  systemctl enable --now duperemove-weekly@$(systemd-escape $HOME).timer
  systemctl enable --now duperemove-weekly@$(systemd-escape /run/media/mmcblk0p1).timer

set-btrfs-flags:
  #!/usr/bin/env bash
  echo 'Configuring drive mount parameters...'
  sudo sed -i 's/compress=zstd:1/noatime,lazytime,commit=120,compress-force=zstd:1,space_cache=v2,discard=async/g' /etc/fstab
  if grep '64GB' <<< $(lsblk -o MODEL); then
    echo 'Increasing compression for detected 64GB eMMC'
    sudo sed -i 's/compress-force=zstd:1/compress-force=zstd:3/g' /etc/fstab
  fi

switch-to-ext4:
  sudo sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

zram-on:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep 'zram' <<< ${KARGS}; then
    rpm-ostree kargs --delete=zram
    echo 'ZRAM enabled. Please reboot.'
  else
    echo 'ZRAM is already enabled.'
  fi

zram-off:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep -v 'zram' <<< ${KARGS}; then
    rpm-ostree kargs --append=zram=0
    echo 'ZRAM disabled. Please reboot.'
  else
    echo 'ZRAM is already disabled.'
  fi

resize-zram:
  #!/usr/bin/env bash
  CONFIG='/etc/systemd/zram-generator.conf'
  if grep "zram-size" <<< $(cat ${CONFIG}); then
    CURRENT_SIZE=$(cat "${CONFIG}" | grep "zram-size" | sed 's/zram-size=//g')
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
      if grep "zram-size" <<< $(cat ${CONFIG}); then
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
  echo 'GRUB_HIDDEN_TIMEOUT=1' | sudo tee -a /etc/default/grub 1>/dev/null
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi

unhide-grub:
  #!/usr/bin/env bash
  sudo sed -i '/GRUB_HIDDEN_TIMEOUT=1/d' /etc/default/grub
  sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
