install-bazzite-arch:
  #!/usr/bin/env bash
  KARGS=$(rpm-ostree kargs)
  if grep 'nvidia' <<< ${KARGS}; then
    echo 'Installing Bazzite Arch (Nvidia)...'
    distrobox assemble create --file /usr/share/ublue-os/distrobox/bazzite-arch-nvidia
  else
    echo 'Installing Bazzite Arch...'
    distrobox assemble create --file /usr/share/ublue-os/distrobox/bazzite-arch
  fi

export-steamcmd:
  distrobox-enter -n bazzite-arch -- '  distrobox-export --bin steamcmd --export-path ~/.steam'
  ln -s ~/.steam/steamcmd ~/.steam/steamcmd.sh

install-corectrl:
  rpm-ostree install corectrl
  rpm-ostree kargs --append="amdgpu.ppfeaturemask=0xffffffff"

install-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh | sudo bash

remove-nix:
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/uninstaller-scripts/silverblue-nix-uninstaller.sh | sudo bash

enable-big-picture:
  systemctl enable --now plasma-autologin
  sed -i 's@/usr/bin/steam-runtime -silent %U@/usr/bin/steam-runtime -bigpicture %U@g' ~/.config/autostart/bazzite-arch-steam-silent.desktop
  mv ~/.config/autostart/bazzite-arch-steam-silent.desktop ~/.config/autostart/bazzite-arch-steam-bigpicture.desktop

get-greenlight:
  echo 'Retrieving Greenlight'
  wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta8/Greenlight-2.0.0-beta8.AppImage -O ~/Desktop/Greenlight.AppImage
  chmod +x ~/Desktop/Greenlight.AppImage

enable-system76-scheduler:
  git clone https://github.com/maxiberta/kwin-system76-scheduler-integration.git --depth 1 /tmp/kwin-system76-scheduler-integration
  kpackagetool5 --type=KWin/Script -i /tmp/kwin-system76-scheduler-integration
  systemctl --user enable --now com.system76.Scheduler.dbusproxy.service
  systemctl enable --now com.system76.Scheduler.service
  kcmshell5 kcm_kwin_scripts
  rm -rf /tmp/kwin-system76-scheduler-integration

enable-wallpaper-engine:
  git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --single-branch /tmp/wallpaper-engine-kde-plugin
  plasmapkg2 -i /tmp/wallpaper-engine-kde-plugin/plugin
  rm -rf /tmp/wallpaper-engine-kde-plugin

set-btrfs-flags:
  sudo sed -i 's/compress=zstd:1/noatime,lazytime,commit=120,compress-force=zstd:1,space_cache=v2,discard=async/g' /etc/fstab

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
