install-bazzite-arch:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep -q 'nvidia' <<< ${KARGS}; then
    echo 'Installing Bazzite Arch (Nvidia)...'
    distrobox assemble create --file /usr/share/ublue-os/distrobox/bazzite-arch-nvidia
  else
    echo 'Installing Bazzite Arch...'
    distrobox assemble create --file /usr/share/ublue-os/distrobox/bazzite-arch
  fi

export-steamcmd:
  echo 'Installing SteamCMD...'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --bin steamcmd --export-path ~/.steam'
  ln -s ~/.steam/steamcmd ~/.steam/steamcmd.sh

install-corectrl:
  echo 'Installing CoreCtrl...''
  rpm-ostree install corectrl
  echo 'Setting needed kargs for CoreCtrl...'
  rpm-ostree kargs --append="amdgpu.ppfeaturemask=0xffffffff"

install-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh | sudo bash

remove-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/uninstaller-scripts/silverblue-nix-uninstaller.sh | sudo bash

enable-big-picture:
  #!/usr/bin/env bash
  if grep -q "gnome" <<< $(cat /etc/default/bazzite); then
    systemctl enable --now gnome-autologin
  else
    systemctl enable --now plasma-autologin
  fi
  sed -i 's@/usr/bin/steam-runtime -silent %U@/usr/bin/steam-runtime -bigpicture %U@g' ~/.config/autostart/bazzite-arch-steam-silent.desktop
  mv ~/.config/autostart/bazzite-arch-steam-silent.desktop ~/.config/autostart/bazzite-arch-steam-bigpicture.desktop

get-greenlight:
  echo 'Retrieving Greenlight'
  wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta8/Greenlight-2.0.0-beta8.AppImage -O ~/Desktop/Greenlight.AppImage
  chmod +x ~/Desktop/Greenlight.AppImage

install-extensions-cli:
  #!/usr/bin/env bash
  if grep -q "gnome" <<< $(cat /etc/default/bazzite); then
    pip install --upgrade gnome-extensions-cli
  else 
    echo "This is only supported under GNOME."
  fi

enable-system76-scheduler:
  #!/usr/bin/env bash
  if grep -qv "gnome" <<< $(cat /etc/default/bazzite); then
    echo 'Installing System76-Scheduler plugin for KDE...'
    git clone https://github.com/maxiberta/kwin-system76-scheduler-integration.git --depth 1 /tmp/kwin-system76-scheduler-integration
    kpackagetool5 --type=KWin/Script -i /tmp/kwin-system76-scheduler-integration
    systemctl --user enable --now com.system76.Scheduler.dbusproxy.service
    systemctl enable --now com.system76.Scheduler.service
    kcmshell5 kcm_kwin_scripts
    rm -rf /tmp/kwin-system76-scheduler-integration
  else
    echo 'Enabling System76-Scheduler GNOME extension...'
    gnome-shell-extension-cl -e s76-scheduler@mattjakeman.com
  fi

enable-supergfxctl: 
  #!/usr/bin/env bash
  if grep -q "nvidia" <<< $(cat /etc/default/bazzite); then
    systemctl enable --now supergfxd.service
  else
    echo "This requires an Nvidia image."
  fi

setup-desktop-environment:
  #!/usr/bin/env bash
  if grep -qv "gnome" <<< $(cat /etc/default/bazzite); then
    echo 'Configuring GNOME extensions...'
    gnome-shell-extension-cl -d background-logo@fedorahosted.org
    gnome-shell-extension-cl -e appindicatorsupport@rgcjonas.gmail.com
    gnome-shell-extension-cl -e gsconnect@andyholmes.github.io
    mkdir -p $HOME/.config/presets/user/
    gradience-cli import -p /usr/share/ublue-os/bazzite/themes/vapor.json
    gradience-cli import -p /usr/share/ublue-os/bazzite/themes/vgui2.json
  else 
    echo 'Installing Wallpaper Engine Plugin for KDE...'
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 /tmp/wallpaper-engine-kde-plugin
    plasmapkg2 -i /tmp/wallpaper-engine-kde-plugin/plugin
    rm -rf /tmp/wallpaper-engine-kde-plugin
  fi

enable-vapor-theme:
  #!/usr/bin/env bash
  if grep -q "gnome" <<< $(cat /etc/default/bazzite); then
    gnome-shell-extension-cl -e user-theme@gnome-shell-extensions.gcampax.github.com
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
  if grep -q "gnome" <<< $(cat /etc/default/bazzite); then
    gnome-shell-extension-cl -e user-theme@gnome-shell-extensions.gcampax.github.com
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

set-btrfs-flags:
  echo 'Configuring drive mount parameters...'
  sudo sed -i 's/compress=zstd:1/noatime,lazytime,commit=120,compress-force=zstd:1,space_cache=v2,discard=async/g' /etc/fstab

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
