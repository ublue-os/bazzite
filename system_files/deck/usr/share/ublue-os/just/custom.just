enable-gamescope-autologin:
  systemctl disable --now plasma-autologin
  systemctl enable --now gamescope-autologin

enable-plasma-autologin:
  systemctl disable --now gamescope-autologin
  systemctl enable --now plasma-autologin

set-steamos-kargs:
  rpm-ostree kargs --append="amd_pstate=active" --append="amd_iommu=off" --append="amdgpu.gttsize=8128" --append="spi_amd.speed_dev=1" --append="fbcon=vc:2-6" --delete-if-present="nomodeset"

create-steam-shortcuts:
  cp /usr/share/applications/steam.desktop ~/Desktop
  sed -i 's@Steam (Runtime)@Steam@g' ~/Desktop/steam.desktop
  cp /etc/skel.d/Desktop/Return.desktop ~/Desktop

get-decky: _auth
  curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sudo -A sh
  sudo -A chcon -R -t bin_t $HOME/homebrew/services/PluginLoader

get-emudeck:
  echo 'Retrieving EmuDeck...'
  wget https://www.emudeck.com/EmuDeck.desktop -P ~/Desktop
  chmod +x ~/Desktop/EmuDeck.desktop

install-nix: _auth
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/installer-scripts/silverblue-nix-installer.sh | sudo -A bash

remove-nix: _auth
  curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/main/uninstaller-scripts/silverblue-nix-uninstaller.sh | sudo -A bash

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

get-chiaki:
  flatpak install \
    $(curl -s https://api.github.com/repos/streetpea/chiaki4deck/releases/latest | \
    jq -r ".assets[] | select(.name | test(\"flatpakref\")) | .browser_download_url")

enable-wallpaper-engine:
  git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --single-branch /tmp/wallpaper-engine-kde-plugin
  plasmapkg2 -i /tmp/wallpaper-engine-kde-plugin/plugin
  rm -rf /tmp/wallpaper-engine-kde-plugin

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

resize-deckswap: _auth
  #!/usr/bin/env bash
  CONFIG='/etc/default/deckswap'
  CURRENT_SIZE=$(cat "${CONFIG}" | sed 's/SWAP_SIZE=//g')
  echo 'Current size: '${CURRENT_SIZE}
  read -p 'Enter new size (1-16) in gigabytes (1G): ' NEW_SIZE
  if [ -z "${NEW_SIZE//[0-9]}" ]; then
    if [ -z "${NEW_SIZE}" ]; then
      NEW_SIZE=1
    fi
    if ((${NEW_SIZE} >= 1 && ${NEW_SIZE} <= 16)); then
      sudo -A sed -i 's/SWAP_SIZE='${CURRENT_SIZE}'G/SWAP_SIZE='${NEW_SIZE}'G/g' ${CONFIG}
      echo 'Current size: '${NEW_SIZE}'G. Please reboot.'
    else
      echo 'Error: Input out of range (1-16). Running again.'
      just resize-deckswap
    fi
  else
    echo 'Error: Input is not an integer. Running again.'
    just resize-deckswap
  fi

switch-to-ext4: _auth
  sudo -A sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

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

resize-zram: _auth
  #!/usr/bin/env bash
  CONFIG='/etc/systemd/zram-generator.conf'
  CURRENT_SIZE=$(cat "${CONFIG}" | sed 's/zram-size=//g')
  echo 'Current size: '${CURRENT_SIZE}
  read -p 'Enter new size (512-4096) in megabytes (1024): ' NEW_SIZE
  if [ -z "${NEW_SIZE//[0-9]}" ]; then
    if [ -z "${NEW_SIZE}" ]; then
      NEW_SIZE=1024
    fi
    if ((${NEW_SIZE} >= 512 && ${NEW_SIZE} <= 4096)); then
      sudo -A sed -i 's/zram-size='${CURRENT_SIZE}'/zram-size='${NEW_SIZE}'/g' ${CONFIG}
      echo 'Current size: '${NEW_SIZE}'. Please reboot.'
    else
      echo 'Error: Input out of range (512-4096). Running again.'
      just resize-zram
    fi
  else
    echo 'Error: Input is not an integer. Running again.'
    just resize-zram
  fi

_auth:
  export SUDO_ASKPASS='/usr/bin/ksshaskpass'
