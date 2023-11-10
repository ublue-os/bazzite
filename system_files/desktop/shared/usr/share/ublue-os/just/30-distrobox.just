# vim: set ft=make :

# Create an Arch container
distrobox-arch:
  echo 'Creating Arch distrobox ...'
  distrobox-create --nvidia --image ghcr.io/ublue-os/arch-distrobox:latest -n arch -Y

# Create an Alpine boxkit container
distrobox-boxkit:
  echo 'Creating Boxkit distrobox ...'
  distrobox-create --nvidia --image ghcr.io/ublue-os/boxkit -n boxkit -Y

# Create a Debian container
distrobox-debian:
  echo 'Creating Debian distrobox ...'
  distrobox-create --nvidia --image quay.io/toolbx-images/debian-toolbox:unstable -n debian -Y

# Create a Fedora container
distrobox-fedora:
  echo 'Creating Fedora distrobox ...'
  distrobox-create --nvidia --image ghcr.io/ublue-os/fedora-distrobox:latest -n fedora -Y

# Create an openSUSE container
distrobox-opensuse:
  echo 'Creating openSUSE distrobox ...'
  distrobox-create --nvidia --image quay.io/toolbx-images/opensuse-toolbox:tumbleweed -n opensuse -Y

# Create an Ubuntu container
distrobox-ubuntu:
  echo 'Creating Ubuntu distrobox ...'
  distrobox-create --nvidia --image quay.io/toolbx-images/ubuntu-toolbox:22.04 -n ubuntu -Y

# Install obs-studio-portable from wimpysworld, which bundles an extensive collection of 3rd party plugins 
install-obs-studio-portable:
  if grep -qz "obs-studio-portable" <<< $(distrobox list); then \
    echo 'Removing existing obs-studio-portable install...' && \
    distrobox rm obs-studio-portable --force; \
  fi && \
  echo 'Installing obs-studio-portable...' && \
  distrobox-create --no-entry --name obs-studio-portable --image ghcr.io/ublue-os/obs-studio-portable --nvidia --yes && \
  distrobox-enter -n obs-studio-portable -- 'bash -c "distrobox-export --app obs"' && \
  echo 'Install complete'

# Set up Bazzite-Arch container
distrobox-bazzite-arch:
  echo 'Creating Bazzite-Arch distrobox ...'
  distrobox-create --unshare-netns --nvidia --image ghcr.io/ublue-os/bazzite-arch -n bazzite-arch -Y

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
  cp ~/.local/share/applications/fedora-solaar.desktop ~/.config/autostart/fedora-solaar.desktop

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
  systemctl enable --user --now arch-opentabletdriver.service

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
  #!/bin/env bash
  if grep -qvz "fedora" <<< $(distrobox list); then
    echo "Setting up Fedora distrobox"
    /usr/bin/ujust distrobox-fedora
  fi
