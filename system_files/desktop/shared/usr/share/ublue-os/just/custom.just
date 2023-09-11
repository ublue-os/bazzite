_default:
  @just --list --list-heading $'Available commands:\n' --list-prefix $' - ' --justfile /usr/share/ublue-os/just/custom.just

# Update entire system
update-system:
  /usr/bin/ublue-update

# Clean up old containers and flatpaks
clean-system:
  podman system prune -a
  flatpak uninstall --unused
  rpm-ostree cleanup -bm

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

# Set up Bazzite-Arch Distrobox container
install-bazzite-arch:
  source /etc/default/bazzite && \
  echo 'Installing Bazzite Arch...' && \
  if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then \
    distrobox create --name bazzite-arch --image ghcr.io/ublue-os/bazzite-arch --nvidia --yes --volume /usr/lib/extest/libextest.so:/usr/lib/extest/libextest.so:ro --volume /usr/share/icons:/usr/share/icons:ro --volume /usr/share/themes:/usr/share/themes:ro; \
  else \
    distrobox create --name bazzite-arch --image ghcr.io/ublue-os/bazzite-arch-gnome --nvidia --yes --volume /usr/lib/extest/libextest.so:/usr/lib/extest/libextest.so:ro --volume /usr/share/icons:/usr/share/icons:ro --volume /usr/share/themes:/usr/share/themes:ro; \
  fi && \
  echo 'Exporting applications...' && \
  distrobox-enter -n bazzite-arch -- 'bash -c "sudo locale-gen && distrobox-export --app steam && distrobox-export --app lutris && distrobox-export --app protontricks && mkdir -p $HOME/.steam && distrobox-export --bin /usr/bin/steamcmd --export-path ~/.steam && mv $HOME/.steam/steamcmd $HOME/.steam/steamcmd.sh"' && \
  echo 'Starting Steam...' && \
  distrobox-enter -n bazzite-arch -- '  /usr/bin/bazzite-steam-runtime --silent &>/dev/null &' && \
  if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then \
    echo 'Creating desktop shortcuts...' && \
    cp ~/.local/share/applications/bazzite-arch-steam.desktop ~/Desktop/bazzite-arch-steam.desktop && \
    sed -i 's@  (on bazzite-arch)@@g' ~/Desktop/bazzite-arch-steam.desktop && \
    cp ~/.local/share/applications/bazzite-arch-net.lutris.Lutris.desktop ~/Desktop/bazzite-arch-net.lutris.Lutris.desktop && \
    sed -i 's@  (on bazzite-arch)@@g' ~/Desktop/bazzite-arch-net.lutris.Lutris.desktop; \
  fi && \
  echo 'Finalizing...' && \
  sleep 10 && \
  rm -f ~/Desktop/steam.desktop

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

# Install Oversteer for Logitech steering wheels
install-oversteer:
  sudo wget https://copr.fedorainfracloud.org/coprs/kylegospo/oversteer/repo/fedora-$(rpm -E %fedora)/kylegospo-oversteer-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-oversteer.repo
  ublue-update --wait
  rpm-ostree install oversteer

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

# Enable Supergfxctl, a Nvidia GPU switcher for hybrid laptops
enable-supergfxctl: 
  #!/usr/bin/env bash
  source /etc/default/bazzite
  if [[ ${IMAGE_FLAVOR} == 'nvidia' ]]; then
    systemctl enable --now supergfxd.service
  else
    echo "This requires an Nvidia image."
  fi

# Fix a bug in TF2 that causes it to crash at startup
fix-tf2-tcmalloc:
  #!/usr/bin/env bash
  podman run \
  -v $HOME/.steam/steam/steamapps/common/Team\ Fortress\ 2/bin:/hl2_linux:Z \
  ghcr.io/maisatanel/tcmalloc-hl2-fixer:main

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
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
    gradience-cli apply -p /usr/share/ublue-os/bazzite/themes/vgui2.json
  else 
    echo "This is only supported under GNOME."
  fi

# Set system to boot without showing the grub screen with options
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

# Set system to boot with the grub screen showing options (Default)
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
