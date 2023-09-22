# vim: set ft=make :

# Create an Arch container
distrobox-arch:
  echo 'Creating Arch distrobox ...'
  distrobox create --nvidia --image quay.io/toolbx-images/archlinux-toolbox:latest -n arch -Y

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

# Set up Bazzite-Arch container
distrobox-bazzite-arch:
  echo 'Creating Bazzite-Arch distrobox ...'
  distrobox create --nvidia --image ghcr.io/ublue-os/bazzite-arch -n bazzite-arch -Y

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