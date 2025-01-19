# vim: set ft=make :

# Install LACT for overclocking & undervolting AMD GPUs
install-lact:
    #!/usr/bin/bash
    ublue-update --wait
    rpm-ostree kargs --append-if-missing=$(printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))")
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        rpm-ostree install -y lact-libadwaita
    else
        rpm-ostree install -y lact
    fi
    echo 'Complete, please reboot to apply changes.'

# Install CoolerControl, a GUI for viewing all your system's sensors and for creating custom fan and pump profiles based on any available temperature sensor28
install-coolercontrol:
    #!/usr/bin/bash
    ublue-update --wait
    sudo wget https://copr.fedorainfracloud.org/coprs/codifryed/CoolerControl/repo/fedora-$(rpm -E %fedora)/codifryed-CoolerControl-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_codifryed-CoolerControl.repo
    rpm-ostree install -y liquidctl coolercontrol
    echo 'Complete, please reboot to apply changes.'

alias get-steamcmd := install-steamcmd

# Install SteamCMD (https://developer.valvesoftware.com/wiki/SteamCMD)
install-steamcmd:
    echo 'Installing SteamCMD...'
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
    mkdir -p ~/.steam
    tar -xvzf /tmp/steamcmd.tar.gz -C ~/.steam
    rm /tmp/steamcmd.tar.gz

# Install OpenRazer for Razer gaming hardware
install-openrazer:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPENRAZER_CONFIGURATOR_APP="None of openrazer frontend apps"
    sudo curl -Lo /etc/yum.repos.d/hardware:razer.repo https://openrazer.github.io/hardware:razer.repo && \
    ublue-update --wait && \
    rpm-ostree install -y openrazer-daemon && \
        if ! grep -q "plugdev" /etc/group; then \
      sudo bash -c 'grep "plugdev" /lib/group >> /etc/group' \
    ; fi && \
    sudo usermod -a -G plugdev $USER && \
    echo "${bold}Select OpenRazer Frontend Apps${normal}"
    OPTION=$(Choose "Razer Genie" "Polychromatic" "None")
    if [[ "${OPTION,,}" =~ ^razer[[:space:]]genie ]]; then
        echo "Installing Razer Genie..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak --system install -y flathub xyz.z3ntu.razergenie
        OPENRAZER_CONFIGURATOR_APP="Razer Genie"
    elif [[ "${OPTION,,}" =~ ^polychromatic ]]; then
        echo "Installing Polychromatic..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak --system install -y flathub app.polychromatic.controller
        OPENRAZER_CONFIGURATOR_APP="Polychromatic"
    else
        echo "Not Selecting GUI Frontend"
    fi
    echo "$OPENRAZER_CONFIGURATOR_APP is installed"
    echo "Please reboot to apply needed changes."

# Install EmuDeck (https://www.emudeck.com/)
install-emudeck:
    #!/usr/bin/bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget \
        $(curl -s https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest | \
        jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url") \
        -O $HOME/Downloads/EmuDeck.AppImage
      chmod +x $HOME/Downloads/EmuDeck.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/EmuDeck.AppImage
    else
      wget \
        $(curl -s https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest | \
        jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url") \
        -O $HOME/Desktop/EmuDeck.AppImage
      chmod +x $HOME/Desktop/EmuDeck.AppImage
    fi

# Install OpenRGB (https://openrgb.org/)
install-openrgb:
    #!/usr/bin/bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget https://openrgb.org/releases/release_0.9/OpenRGB_0.9_x86_64_b5f46e3.AppImage \
        -O $HOME/Downloads/OpenRGB.AppImage
      chmod +x $HOME/Downloads/OpenRGB.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/OpenRGB.AppImage
    else
      wget https://openrgb.org/releases/release_0.9/OpenRGB_0.9_x86_64_b5f46e3.AppImage \
        -O $HOME/Desktop/OpenRGB.AppImage
      chmod +x $HOME/Desktop/OpenRGB.AppImage
    fi

# Install Boxtron, a Steam Play compatibility tool to run DOS games using native Linux DOSBox
install-boxtron: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c '\
      sudo dnf install dosbox-staging inotify-tools timidity++ fluid-soundfont-gm -y && \
      cd ~/.steam/root/compatibilitytools.d/ && \
      curl -L https://github.com/dreamer/boxtron/releases/download/v0.5.4/boxtron.tar.xz | tar xJf - && \
      distrobox-export --bin /usr/bin/dosbox'

alias get-wootility := install-wootility

# Install Wootility for configuring Wooting Keyboards
install-wootility:
    #!/usr/bin/bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Downloads/wootility.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/wootility.AppImage
    else
      wget "https://api.wooting.io/public/wootility/download?os=linux&branch=lekker" -O $HOME/Desktop/wootility.AppImage
      chmod +x $HOME/Desktop/wootility.AppImage
    fi

# Install Adwaita-for-Steam theme for CSS Loader (https://github.com/tkashkin/Adwaita-for-Steam)
install-adwaita-for-steam:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/Adwaita-for-Steam"
        git clone https://github.com/tkashkin/Adwaita-for-Steam.git --single-branch "$HOME/homebrew/themes/Adwaita-for-Steam"
    else
        echo 'Please install Decky Loader by running "ujust setup-decky install" first, then install CSS Loader from the Decky Plugin Store.'
    fi

# Install Oversteer for Logitech steering wheels
install-oversteer: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c 'sudo dnf copr enable -y kylegospo/oversteer && \
      sudo dnf install -y oversteer && \
      distrobox-export --app oversteer'

# Install Resilio Sync, a file synchronization utility powered by BitTorrent
install-resilio-sync: distrobox-check-fedora
    distrobox-enter -n fedora -- bash -c 'sudo rpm --import https://linux-packages.resilio.com/resilio-sync/key.asc' && \
    distrobox-enter -n fedora -- bash -c 'sudo wget https://raw.githubusercontent.com/ublue-os/bazzite/main/post_install_files/resilio_sync/resilio-sync.repo -O /etc/yum.repos.d/resilio-sync.repo' && \
    distrobox-enter -n fedora -- bash -c 'sudo dnf install -y resilio-sync' && \
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
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Installing OpenTabletDriver..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak --system install -y flathub net.opentabletdriver.OpenTabletDriver && \
    mkdir -p $HOME/.config/OpenTabletDriver && \
    flatpak override --user --filesystem=xdg-config/OpenTabletDriver net.opentabletdriver.OpenTabletDriver && \
    mkdir -p $HOME/.config/systemd/user && \
    curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service > $HOME/.config/systemd/user/opentabletdriver.service  && \
    systemctl --user daemon-reload && \
    systemctl enable --user --now opentabletdriver.service

# Install Docker, a platform designed to help developers build, share, and run container applications
install-docker:
    #!/usr/bin/bash
    sudo mkdir -p /var/lib/docker
    echo 'Creating Docker group.'
    sudo groupadd --gid 252 docker
    echo 'Setting up Docker Distrobox Container.'
    distrobox assemble create --replace --file /etc/distrobox/docker.ini --name docker
    echo 'Installing docker-cli for the host.'
    brew install docker
    echo 'Complete.'

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      Assemble noconfirmcreate "" "fedora"
    fi
