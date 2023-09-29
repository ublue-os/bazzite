# vim: set ft=make :

# Create an Arch container
distrobox-arch:
  echo 'Creating Arch distrobox ...'
  distrobox create --nvidia --image ghcr.io/ublue-os/arch-distrobox:latest -n arch -Y

# Create an Alpine boxkit container
distrobox-boxkit:
  echo 'Creating Boxkit distrobox ...'
  distrobox create --nvidia --image ghcr.io/ublue-os/boxkit -n boxkit -Y

# Create a Debian container
distrobox-debian:
  echo 'Creating Debian distrobox ...'
  distrobox create --nvidia --image quay.io/toolbx-images/debian-toolbox:unstable -n debian -Y

# Create a Fedora container
distrobox-fedora:
  echo 'Creating Fedora distrobox ...'
  distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y

# Create an openSUSE container
distrobox-opensuse:
  echo 'Creating openSUSE distrobox ...'
  distrobox create --nvidia --image quay.io/toolbx-images/opensuse-toolbox:tumbleweed -n opensuse -Y

# Create an Ubuntu container
distrobox-ubuntu:
  echo 'Creating Ubuntu distrobox ...'
  distrobox create --nvidia --image quay.io/toolbx-images/ubuntu-toolbox:22.04 -n ubuntu -Y

# Install obs-studio-portable from wimpysworld, which bundles an extensive collection of 3rd party plugins 
install-obs-studio-portable:
  if grep -qz "obs-studio-portable" <<< $(distrobox list); then \
    echo 'Removing existing obs-studio-portable install...' && \
    distrobox rm obs-studio-portable --force; \
  fi && \
  echo 'Installing obs-studio-portable...' && \
  distrobox create --no-entry --name obs-studio-portable --image ghcr.io/ublue-os/obs-studio-portable --nvidia --yes && \
  distrobox-enter -n obs-studio-portable -- 'bash -c "distrobox-export --app obs"' && \
  echo 'Install complete'

# Set up Bazzite-Arch Distrobox container
install-bazzite-arch:
  IMAGE_INFO="/usr/share/ublue-os/image-info.json" && \
  BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO) && \
  if grep -qz "bazzite-arch" <<< $(distrobox list); then \
    echo 'Removing existing Bazzite Arch install...' && \
    distrobox rm bazzite-arch --force; \
  fi && \
  echo 'Installing Bazzite Arch...' && \
  if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then \
    distrobox create --name bazzite-arch --image ghcr.io/ublue-os/bazzite-arch --nvidia --yes; \
  else \
    distrobox create --name bazzite-arch --image ghcr.io/ublue-os/bazzite-arch-gnome --nvidia --yes; \
  fi && \
  echo 'Exporting applications...' && \
  distrobox-enter -n bazzite-arch -- 'bash -c "sudo locale-gen && distrobox-export --app steam && distrobox-export --app lutris && distrobox-export --app protontricks && mkdir -p $HOME/.steam && distrobox-export --bin /usr/bin/steamcmd --export-path ~/.steam && mv $HOME/.steam/steamcmd $HOME/.steam/steamcmd.sh"' && \
  echo 'Starting Steam...' && \
  distrobox-enter -n bazzite-arch -- '  /usr/bin/steam-runtime --silent &>/dev/null &' && \
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

# Remove container image for bazzite-arch and reinstall it
reset-bazzite-arch:
  IMAGE_INFO="/usr/share/ublue-os/image-info.json" && \
  BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO) && \
  distrobox stop bazzite-arch && \
  distrobox rm bazzite-arch --force && \
  if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then \
    podman image rm bazzite-arch --force; \
  else \
    podman image rm bazzite-arch-gnome --force; \
  fi && \
  /usr/bin/just --unstable install-bazzite-arch

# Install Webapp manager
install-webapp-manager:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox-enter -n fedora -- bash -c "sudo dnf copr enable -y kylegospo/webapp-manager && \
    sudo dnf install -y webapp-manager && \
    distrobox-export --app webapp-manager"

# Install Oversteer for Logitech steering wheels
install-oversteer:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox enter -n fedora -- bash -c 'sudo dnf copr enable -y kylegospo/oversteer && \
    sudo dnf install -y oversteer && \
    distrobox-export --app oversteer'

# Install OpenRazer for Razer gaming hardware
install-openrazer:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox-enter -n fedora -- bash -c 'sudo wget https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo -O /etc/yum.repos.d/hardware:razer.repo && \
    sudo dnf install -y \
      openrazer-meta'

# Install Solaar for Logitech Mice, Keyboards, and Trackpads
install-solaar:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox-enter -n fedora -- bash -c 'sudo dnf install -y \
    solaar && \
    distrobox-export --app solaar' && \
  mkdir -p ~/.config/autostart && \
  rm -f ~/.config/autostart/fedora-solaar.desktop && \
  cp ~/.local/share/applications/fedora-solaar.desktop ~/.config/autostart/fedora-solaar.desktop

# Install Resilio Sync, a file synchronization utility powered by BitTorrent
install-resilio-sync:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox-enter -n fedora -- 'sudo rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc' && \
  distrobox-enter -n fedora -- 'sudo wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/resilio-sync.repo -O /etc/yum.repos.d/resilio-sync.repo' && \
  distrobox-enter -n fedora -- 'sudo dnf install -y resilio-sync' && \
  mkdir -p ~/.config/systemd/user/ && \
  rm -f ~/.config/systemd/user/fedora-resilio-sync.service && \
  wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/fedora-resilio-sync.service -O ~/.config/systemd/user/fedora-resilio-sync.service && \
  systemctl --user daemon-reload && \
  systemctl enable --user --now fedora-resilio-sync.service

# Install scrcpy, a utility that mirrors Android devices (video and audio) connected via USB or over TCP/IP
install-scrcpy:
  if grep -qvz "fedora" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y; \
  fi && \
  distrobox enter -n fedora -- bash -c 'sudo dnf copr enable -y zeno/scrcpy && \
    sudo dnf install -y scrcpy && \
    distrobox-export --app scrcpy'

# Install OpenTabletDriver, an open source, cross-platform, user-mode tablet driver
install-opentabletdriver:
  if grep -qvz "arch" <<< $(distrobox list); then \
    distrobox create --nvidia --image ghcr.io/ublue-os/arch-distrobox:latest -n arch -Y; \
  fi && \
  distrobox enter -n arch -- ' paru -S opentabletdriver' && \
  wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/OpenTabletDriver/opentabletdriver.service -O ~/.config/systemd/user/arch-opentabletdriver.service && \
  systemctl --user daemon-reload && \
  systemctl enable --user --now arch-opentabletdriver.service
