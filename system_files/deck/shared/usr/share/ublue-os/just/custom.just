_default:
  @just --list --list-heading $'Available commands:\n' --list-prefix $' - ' --justfile /usr/share/ublue-os/just/custom.just

# Update entire system
update-system:
  /usr/bin/ublue-update

# Clean up old containers and flatpaks
clean-system:
  #!/usr/bin/env bash
  podman system prune -a
  flatpak uninstall --unused
  rpm-ostree cleanup -bm
  if [ -x "$(command -v nix-store)" ]; then
    nix-store --gc
    nix-store --optimise
  fi

# Boot into this device's BIOS/UEFI screen
boot-to-bios:
  systemctl reboot --firmware-setup

# Enroll Nvidia driver & KMOD signing key for secure boot
enroll-secure-boot-keys:
    sudo mokutil --import /etc/pki/akmods/certs/akmods-ublue.der

# Enable VAAPI in Firefox for Nvidia GPUs
setup-firefox-vaapi-nvidia:
    flatpak override \
        --user \
        --filesystem=host-os \
        --env=LIBVA_DRIVER_NAME=nvidia \
        --env=LIBVA_DRIVERS_PATH=/run/host/usr/lib64/dri \
        --env=LIBVA_MESSAGING_LEVEL=1 \
        --env=MOZ_DISABLE_RDD_SANDBOX=1 \
        --env=NVD_BACKEND=direct \
        --env=MOZ_ENABLE_WAYLAND=1 \
        org.mozilla.firefox

# Toggle between desktop/gamescope autologin
toggle-autologin:
  #!/usr/bin/env bash
  DESKTOP_AUTOLOGIN="/etc/bazzite/desktop_autologin"
  if [[ -f $DESKTOP_AUTOLOGIN ]]; then
    sudo rm -f $DESKTOP_AUTOLOGIN
  else
    sudo touch $DESKTOP_AUTOLOGIN
  fi

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
  curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_prerelease.sh | sh
  sudo chcon -R -t bin_t $HOME/homebrew/services/PluginLoader

# Install EmuDeck (https://www.emudeck.com/)
get-emudeck:
  #!/usr/bin/env bash
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

# Install Oversteer for Logitech steering wheels
install-oversteer:
  sudo wget https://copr.fedorainfracloud.org/coprs/kylegospo/oversteer/repo/fedora-$(rpm -E %fedora)/kylegospo-oversteer-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-oversteer.repo
  ublue-update --wait
  rpm-ostree install oversteer

# Install OpenRazer (https://openrazer.github.io)
install-openrazer:
  sudo wget https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo -O /etc/yum.repos.d/hardware:razer.repo
  ublue-update --wait
  rpm-ostree install openrazer-meta

# Install Nix with the Determinate Nix Installer
install-nix:
  #!/usr/bin/env bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo bash -s -- install --no-confirm
  nix_systemd_file_location='/nix/var/nix/profiles/default'
  sudo rm -f /etc/systemd/system/nix-daemon.service
  sudo rm -f /etc/systemd/system/nix-daemon.socket
  sudo cp $nix_systemd_file_location/lib/systemd/system/nix-daemon.service /etc/systemd/system/nix-daemon.service
  sudo cp $nix_systemd_file_location/lib/systemd/system/nix-daemon.socket /etc/systemd/system/nix-daemon.socket

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
    echo "Install nix with just install-nix before running just install-fleek."
  fi

# Integrate Nix/Fleek applications with system theme
install-fleek-themes:
  #!/usr/bin/env bash
  if [[ -x "/var/usrlocal/bin/fleek" ]]; then
    source /etc/default/bazzite
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
      fleek add adw-gtk3 --apply
    else
      fleek add breeze-icons
      fleek add libsForQt5.breeze-qt5
      fleek apply
    fi
  else
    echo "Install fleek with just install-fleek before running just install-fleek-themes."
  fi

# Install Greenlight xCloud and xHome streaming AppImage
get-greenlight:
  #!/usr/bin/env bash
  if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
    wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta12/Greenlight-2.0.0-beta12.AppImage -O $HOME/Downloads/Greenlight.AppImage
    flatpak run it.mijorus.gearlever $HOME/Downloads/Greenlight.AppImage
  else
    wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta12/Greenlight-2.0.0-beta12.AppImage -O $HOME/Desktop/Greenlight.AppImage
    chmod +x $HOME/Desktop/Greenlight.AppImage
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

# Fix a bug in TF2 that causes it to crash at startup
fix-tf2-tcmalloc:
  #!/usr/bin/env bash
  if [ -f "$HOME/.steam/steam/steamapps/common/Team\ Fortress\ 2/bin/hl2_linux" ]; then
    echo "Found TF2 on internal SSD"
    podman run \
    -v $HOME/.steam/steam/steamapps/common/Team\ Fortress\ 2/bin:/hl2_linux:Z \
    ghcr.io/maisatanel/tcmalloc-hl2-fixer:main
    echo "TF2 patch complete."
  fi
  if [ -f "/run/media/mmcblk0p1/steamapps/common/Team\ Fortress\ 2/bin/hl2_linux" ]; then
    echo "Found TF2 on SD card"
    podman run \
    -v /run/media/mmcblk0p1/steamapps/common/Team\ Fortress\ 2/bin:/hl2_linux:Z \
    ghcr.io/maisatanel/tcmalloc-hl2-fixer:main
    echo "TF2 patch complete."
  fi

# Patch GMod's 64-bit beta to work properly on Linux
patch-gmod:
  #!/usr/bin/env bash
  mkdir -p /tmp/patch-gmod
  wget \
    $(curl -s https://api.github.com/repos/solsticegamestudios/GModCEFCodecFix/releases/latest | \
    jq -r ".assets[] | select(.name | test(\"GModCEFCodecFix-Linux\")) | .browser_download_url") \
    -P /tmp/patch-gmod/GModCEFCodecFix-Linux
  chmod +x /tmp/patch-gmod/GModCEFCodecFix-Linux
  /tmp/patch-gmod/GModCEFCodecFix-Linux
  rm -rf /tmp/patch-gmod

# Activate Valve-inspired Vapor theme on GNOME
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
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans Medium 11"
    gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 11"
    gsettings set org.gnome.desktop.interface font-name "Noto Sans 11"
    gradience-cli flatpak-overrides -e both
    gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vapor.json
  else 
    echo "This is only supported under GNOME."
  fi

# Activate Valve-inspired VGUI2 theme on GNOME
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
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans Medium 11"
    gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 11"
    gsettings set org.gnome.desktop.interface font-name "Noto Sans 11"
    gradience-cli flatpak-overrides -e both
    gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vgui2.json
  else 
    echo "This is only supported under GNOME."
  fi

# Enable legacy swapfile (Not recommended)
deckswap-on:
  #!/usr/bin/env bash
  STATUS=$(systemctl status deckswap.service)
  if grep -q 'inactive' <<< ${STATUS}; then
    systemctl enable deckswap.service
    echo 'deckswap enabled. Please reboot.'
  else
    echo 'deckswap is already enabled.'
  fi

# Disable legacy swapfile
deckswap-off:
  #!/usr/bin/env bash
  STATUS=$(systemctl status deckswap.service)
  if grep -qv 'inactive' <<< ${STATUS}; then
    systemctl disable deckswap.service
    echo 'deckswap disabled. Please reboot.'
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

# Use EXT4 for SD Cards, allows use of SteamOS formatted SD cards
switch-to-ext4:
  sudo sed -i 's@STEAMOS_BTRFS_SDCARD_FORMAT_FS="btrfs"@STEAMOS_BTRFS_SDCARD_FORMAT_FS="ext4"@g' /etc/default/steamos-btrfs

# Enable ZRAM (Enabled by default)
zram-on:
  #!/usr/bin/env bash
  ublue-update --wait
  KARGS=$(rpm-ostree kargs)
  if grep -q 'zram' <<< ${KARGS}; then
    rpm-ostree kargs --delete=zram
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
    rpm-ostree kargs --append=zram=0
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

# Set system to boot without showing the grub screen with options
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

# Set system to boot with the grub screen showing options (Default)
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

# Use stock gamepad drivers
use-stock-gamepads:
  #!/usr/bin/env bash
  sudo bash -c '> /etc/modprobe.d/xone.conf'
  sudo bash -c '> /etc/modprobe.d/xpadneo.conf'
  sudo bash -c '> /etc/modprobe.d/xpad-noone-blacklist.conf'
  sudo bash -c '> /etc/modules-load.d/xpad-noone.conf'

# Use uBlue gamepad drivers (Default)
use-ublue-gamepads:
  #!/usr/bin/env bash
  sudo rm -f /etc/modprobe.d/xone.conf
  sudo rm -f /etc/modprobe.d/xpadneo.conf
  sudo rm -f /etc/modprobe.d/xpad-noone-blacklist.conf
  sudo rm -f /etc/modules-load.d/xpad-noone.conf

# Disable Broadcom WL driver (Default - WL breaks numerous other Wi-Fi adapters)
disable-broadcom-wl:
  #!/usr/bin/env bash
  sudo bash -c '> /etc/modules-load.d/broadcom-wl-blacklist.conf'
  sudo bash -c 'echo "wl" > /etc/modules-load.d/default-disable-broadcom-wl.conf'

# Use Broadcom WL driver
use-broadcom-wl:
  #!/usr/bin/env bash
  sudo rm -f /etc/modprobe.d/broadcom-wl-blacklist.conf
  sudo rm -f /etc/modprobe.d/default-disable-broadcom-wl.conf

# Enable Flatpak Theming
enable-flatpak-theming:
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=~/.icons:ro --filesystem=~/.themes:ro

# Sign the current OCI OSTree Image (If unsigned)
sign-image:
  source /etc/default/bazzite && \
  ublue-update --wait && \
  if grep -qvz "/var/${IMAGE_VENDOR}/image" <<< $(rpm-ostree status); then \
    rpm-ostree rebase ostree-image-signed:$(just --unstable _get-image); \
  else \
    rpm-ostree rebase ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}:${FEDORA_MAJOR_VERSION}; \
  fi

_get-image:
  #!/usr/bin/env python
  from json import loads
  from subprocess import PIPE, run

  """Pull deployment status via rpm-ostree"""
  status = "rpm-ostree status --json"
  out = run(status, shell=True, stdout=PIPE).stdout

  """Parse current image"""
  deployments = loads(out)["deployments"][0]
  current_image = deployments["container-image-reference"].split(":", 1)

  """Dissect current image to form URL to latest image"""
  protocol = "docker://"
  url = current_image[1]

  """Add protocol if URL doesn't contain it"""
  if protocol not in url:
    url = protocol + url

  print(url)
