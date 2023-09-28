# vim: set ft=make :

# Remove all waydroid-related files in your user folders
reset-waydroid:
  bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'

# Quickly initialize a waydroid image
init-waydroid:
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

# Install CoreCtrl for overclocking & undervolting AMD GPUs
install-corectrl:
  echo 'Installing CoreCtrl...'
  ublue-update --wait
  rpm-ostree install corectrl
  echo 'Setting needed kargs for CoreCtrl...'
  rpm-ostree kargs --append="amdgpu.ppfeaturemask=0xffffffff"

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

# Enable Supergfxctl, a Nvidia GPU switcher for hybrid laptops
enable-supergfxctl: 
  #!/usr/bin/env bash
  IMAGE_INFO="/usr/share/ublue-os/image-info.json"
  IMAGE_FLAVOR=$(jq -r '."image-flavor"' < $IMAGE_INFO)
  if [[ ${IMAGE_FLAVOR} == 'nvidia' ]]; then
    systemctl enable --now supergfxd.service
  else
    echo "This requires an Nvidia image."
  fi

# Patch a bug in TF2 that causes it to crash at startup
patch-tf2-tcmalloc:
  #!/usr/bin/env bash
  podman run \
  -v $HOME/.steam/steam/steamapps/common/Team\ Fortress\ 2/bin:/hl2_linux:Z \
  ghcr.io/maisatanel/tcmalloc-hl2-fixer:main
  echo "TF2 patch complete."

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

# Fix an error that occurs after installing SteamVR in Bazzite-Arch
patch-steam-vr:
  #!/usr/bin/env bash
  sudo setcap CAP_SYS_NICE+ep $HOME/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher

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
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
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
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
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
      echo 'Please install Decky Loader & CSS Loader first'
    fi
  else 
    echo "This is only supported under GNOME."
  fi

# Set system to boot without showing the grub screen with options
hide-grub:
  #!/usr/bin/env bash
  sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
  echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
  echo 'GRUB_HIDDEN_TIMEOUT=1' | sudo tee -a /etc/default/grub 1>/dev/null
  if [ -d /sys/firmware/efi ]; then
    sudo grub2-mkconfig -o /etc/grub2-efi.cfg
  else
    sudo grub2-mkconfig -o /etc/grub2.cfg
  fi

# Set system to boot with the grub screen showing options (Default)
unhide-grub:
  #!/usr/bin/env bash
  sudo sed -i '/GRUB_HIDDEN_TIMEOUT=1/d' /etc/default/grub
  sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
  if [ -d /sys/firmware/efi ]; then
    sudo grub2-mkconfig -o /etc/grub2-efi.cfg
  else
    sudo grub2-mkconfig -o /etc/grub2.cfg
  fi

# Enable Flatpak Theming
enable-flatpak-theming:
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=~/.icons:ro --filesystem=~/.themes:ro

# Enable XwaylandVideoBridge for screensharing on KDE
fix-screenshare:
  #!/usr/bin/env bash
  IMAGE_INFO="/usr/share/ublue-os/image-info.json"
  BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
  if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
    mkdir -p $HOME/.config/autostart
    cp /usr/share/applications/org.kde.xwaylandvideobridge.desktop $HOME/.config/autostart/
  else
    echo "This is only supported under KDE."
  fi

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
  #!/usr/bin/env bash
  getent group input || sudo groupadd input
  sudo usermod -a -G input $USER
