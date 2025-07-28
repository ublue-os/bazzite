# vim: set ft=make :

# Install an appimage file from a local file or URL
_install_appimage_file $APPIMAGE_SRC $filename="":
    #!/usr/bin/bash
    set -eo pipefail
    DOWNLOAD_DIR="{{ cache_directory() }}/ujust/appimages"
    mkdir -p "$DOWNLOAD_DIR"
    trap "rm -rf $DOWNLOAD_DIR" EXIT

    appimage_file="$DOWNLOAD_DIR/${filename:-${APPIMAGE_SRC##*/}}"

    if ! grep -q 'it.mijorus.gearlever' < <(flatpak list --columns application); then
        flatpak install --system -y flathub it.mijorus.gearlever <&-
    fi
    if [[ $APPIMAGE_SRC =~ ^https?:// ]]; then
        echo "Downloading $APPIMAGE_SRC to $appimage_file"
        wget -nv "$APPIMAGE_SRC" -O "$appimage_file" && echo "Download complete"
    else
        cp "$APPIMAGE_SRC" "$appimage_file"
    fi
    chmod +x "$appimage_file"
    echo "Click {{ BOLD }}Unlock{{ NORMAL }} then {{ BLUE + BOLD }}Move to the app menu{{ NORMAL }} and close window to finish installation."
    sleep 3
    LC_ALL=C flatpak run it.mijorus.gearlever "$appimage_file" <&-

# Install LACT to control your AMD, Nvidia or Intel GPU on a Linux system.
install-lact:
    #!/usr/bin/bash
    rpm-ostree kargs --append-if-missing=$(printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))")
    flatpak --system install -y flathub io.github.ilya_zlobintsev.LACT
    echo 'Complete, please reboot to apply changes.'

# Install CoolerControl, a GUI for viewing all your system's sensors and for creating custom fan and pump profiles based on any available temperature sensor28
install-coolercontrol:
    #!/usr/bin/bash
    echo 'Enabling Terra Repository.'
    sudo sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/terra.repo
    echo 'Installing Cooler Control'
    rpm-ostree install -y liquidctl coolercontrol
    echo 'Complete, please reboot to apply changes.'

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    echo "Get latest JetBrains Toolbox version"
    # Get the json with latest releases
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    # Extract information
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    echo "Launching JetBrains Toolbox"
    ./jetbrains-toolbox-"${BUILD_VERSION}"/jetbrains-toolbox

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

alias get-emudeck := install-emudeck

# Install EmuDeck (https://www.emudeck.com/)
install-emudeck:
    #!/usr/bin/bash
    set -eo pipefail
    remote_appimage_url="$(
        curl -s https://api.github.com/repos/EmuDeck/emudeck-electron/releases/latest | \
        jq -r ".assets[] | select(.name | test(\".*AppImage\")) | .browser_download_url"
    )"
    just _install_appimage_file "$remote_appimage_url"

# Install OpenRGB (https://openrgb.org/)
install-openrgb: (_install_appimage_file "https://openrgb.org/releases/release_0.9/OpenRGB_0.9_x86_64_b5f46e3.AppImage")

# Install Boxtron, a Steam Play compatibility tool to run DOS games using native Linux DOSBox
install-boxtron: distrobox-check-fedora
    distrobox enter -n fedora -- bash -c '\
      sudo dnf install dosbox-staging inotify-tools timidity++ fluid-soundfont-gm -y && \
      cd ~/.steam/root/compatibilitytools.d/ && \
      curl -L https://github.com/dreamer/boxtron/releases/download/v0.5.4/boxtron.tar.xz | tar xJf - && \
      distrobox-export --bin /usr/bin/dosbox'

alias get-wootility := install-wootility

# Install Wootility for configuring Wooting Keyboards
install-wootility: (_install_appimage_file "https://api.wooting.io/public/wootility/download?os=linux" "wootility.Appimage")

# Install Adwaita-for-Steam theme for CSS Loader (https://github.com/tkashkin/Adwaita-for-Steam)
install-adwaita-for-steam:
    #!/usr/bin/bash
    if [ -d "$HOME/homebrew/themes" ]; then
        rm -rf "$HOME/homebrew/themes/Adwaita-for-Steam"
        git clone https://github.com/tkashkin/Adwaita-for-Steam.git --single-branch "$HOME/homebrew/themes/Adwaita-for-Steam"
    else
        echo 'Please install Decky Loader by running "ujust setup-decky install" first, then install CSS Loader from the Decky Plugin Store.'
    fi

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
    curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest \
    | jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("opentabletdriver.*tar.gz$")) | .browser_download_url' \
    | wget -qi - -O /tmp/OpenTabletDriver/opentabletdriver.tar.gz && \
    tar --strip-components=1 -xvzf /tmp/OpenTabletDriver/opentabletdriver.tar.gz -C /tmp/OpenTabletDriver && \
    sudo cp /tmp/OpenTabletDriver/etc/udev/rules.d/70-opentabletdriver.rules /etc/udev/rules.d/71-opentabletdriver.rules && \
    rm -rf /tmp/OpenTabletDriver && \
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak --system install -y flathub net.opentabletdriver.OpenTabletDriver && \
    mkdir -p $HOME/.config/OpenTabletDriver && \
    flatpak override --user --filesystem=xdg-config/OpenTabletDriver net.opentabletdriver.OpenTabletDriver && \
    mkdir -p $HOME/.config/systemd/user && \
    curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service > $HOME/.config/systemd/user/opentabletdriver.service  && \
    systemctl --user daemon-reload && \
    systemctl enable --user --now opentabletdriver.service

# Remove OpenTabletDriver
remove-opentabletdriver:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Uninstalling OpenTabletDriver..."
    sudo -A rm /etc/udev/rules.d/71-opentabletdriver.rules && \
    flatpak --system remove -y flathub net.opentabletdriver.OpenTabletDriver && \
    systemctl disable --user --now opentabletdriver.service

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      Assemble noconfirmcreate "" "fedora"
    fi
