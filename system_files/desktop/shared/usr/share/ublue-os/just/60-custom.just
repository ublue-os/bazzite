# vim: set ft=make :

# Remove all waydroid-related files in your user folders
reset-waydroid:
    bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'

# Quickly initialize a waydroid image
init-waydroid:
    #!/usr/bin/env bash
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

# Install OpenRazer for Razer gaming hardware
install-openrazer:
    sudo wget https://download.opensuse.org/repositories/hardware:/razer/Fedora_$(rpm -E %fedora)/hardware:razer.repo -O /etc/yum.repos.d/hardware:razer.repo && \
    ublue-update --wait && \
    rpm-ostree install openrazer-meta razergenie && \
    if ! grep -q "plugdev" /etc/group; then \
      sudo bash -c 'grep "plugdev" /lib/group >> /etc/group' \
    ; fi && \
    sudo usermod -a -G plugdev $USER && \
    echo "Please reboot to apply needed changes."

# Install Nix with the Determinate Nix Installer
install-nix:
    #!/usr/bin/env bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo bash -s -- install --no-confirm

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
      echo "Install nix with ujust install-nix before running ujust install-fleek."
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
      echo "Install fleek with ujust install-fleek before running ujust install-fleek-themes."
    fi

# Install Greenlight xCloud and xHome streaming AppImage
get-greenlight:
    #!/usr/bin/env bash
    if grep -q 'it.mijorus.gearlever' <<< $(flatpak list); then
      wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta14/Greenlight-2.0.0-beta14.AppImage -O $HOME/Downloads/Greenlight.AppImage
      flatpak run it.mijorus.gearlever $HOME/Downloads/Greenlight.AppImage
    else
      wget https://github.com/unknownskl/greenlight/releases/download/v2.0.0-beta14/Greenlight-2.0.0-beta14.AppImage -O $HOME/Desktop/Greenlight.AppImage
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

# Patch a bug in some 32-bit Source 1.x titles that causes them to crash at startup
patch-source1-tcmalloc:
    echo 'Add the following as a launch option in Steam:'
    echo 'LD_PRELOAD=/usr/lib/libtcmalloc_and_profiler.so.4 %command%'
    echo "Delete libtcmalloc_minimal.so.x in the game's bin folder if present."

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
      flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience flatpak-overrides -e both
      sudo flatpak override --filesystem=xdg-config/gtk-4.0
      sudo flatpak override --filesystem=xdg-config/gtk-3.0
      flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience apply -n "Vapor"
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
      flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience flatpak-overrides -e both
      sudo flatpak override --filesystem=xdg-config/gtk-4.0
      sudo flatpak override --filesystem=xdg-config/gtk-3.0
      flatpak run --command=gradience-cli com.github.GradienceTeam.Gradience apply -n "VGUI2"
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

# Enable XwaylandVideoBridge for screensharing under Wayland
fix-screenshare:
    cp /usr/share/applications/org.kde.xwaylandvideobridge.desktop $HOME/.config/autostart/

# Add user to "input" group required by certain controller drivers
add-user-to-input-group:
    #!/usr/bin/env bash
    if ! grep -q "input" /etc/group; then
      sudo bash -c 'grep "input" /lib/group >> /etc/group'
    fi
    sudo usermod -a -G input $USER

# Enable Virtualization and add workaround for a specific windows VM crash
enable-virtualization:
    echo "Installing QEMU and virt-manager..."
    rpm-ostree install virt-manager edk2-ovmf qemu
    rpm-ostree kargs \
    --append-if-missing="kvm.ignore_msrs=1" \
    --append-if-missing="kvm.report_ignored_msrs=0"

# Enable VFIO on the system if virtualization is enabled
enable-vfio:
    #!/usr/bin/env bash
    echo "Enabling VFIO..."
    VIRT_TEST=$(rpm-ostree kargs)
    CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
    VENDOR_KARG="unset"
    if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
      rpm-ostree initramfs \
        --enable \
        --arg="--add-drivers" \
        --arg="vfio vfio_iommu_type1 vfio-pci"
      if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
        VENDOR_KARG="amd_iommu=on"
      elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
        VENDOR_KARG="intel_iommu=on"  
      fi
      if [[ ${VENDOR_KARG} == "unset" ]]; then
        echo "Failed to get CPU vendor, exiting..."
        exit 1
      else
        rpm-ostree kargs \
          --append-if-missing="${VENDOR_KARG}" \
          --append-if-missing="iommu=pt" \
          --append-if-missing="rd.driver.pre=vfio_pci" \
          --append-if-missing="vfio_pci.disable_vga=1"
        echo "VFIO enabled, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
        echo "Please understand that since this is such a niche use case, support will be very limited!"
        echo "To add your unused/second GPU device ids to the vfio driver by running"
        echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
        echo "NOTE: Your second GPU will not be usable by the host after you do this!"
      fi
    else
      echo "Enable virtualization with ujust enable-virtualization before running ujust enable-vfio."
    fi

# Enable watchdog (default, recovers the system in the event of a malfunction, possible impact to performance due to interrupts)
enable-watchdog:
    #!/usr/bin/env bash
    CPU_MODEL=$(lscpu --json | jq -r '."lscpu"[7]."data"')
    WATCHDOG_KARGS="--delete-if-present=nowatchdog"
    if [[ "$CPU_MODEL" =~ "Intel" ]]; then
      WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=iTCO_wdt"
    elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
      WATCHDOG_KARGS="$WATCHDOG_KARGS --delete-if-present=modprobe.blacklist=sp5100_tco"
    fi
    rpm-ostree kargs $WATCHDOG_KARGS

# Disable watchdog (potential performance improvement due to fewer interrupts)
disable-watchdog:
    #!/usr/bin/env bash
    CPU_MODEL=$(lscpu --json | jq -r '."lscpu"[7]."data"')
    WATCHDOG_KARGS="--append-if-missing=nowatchdog"
    if [[ "$CPU_MODEL" =~ "Intel" ]]; then
      WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=iTCO_wdt"
    elif [[ "$CPU_MODEL" =~ "AMD" ]]; then
      WATCHDOG_KARGS="$WATCHDOG_KARGS --append-if-missing=modprobe.blacklist=sp5100_tco"
    fi
    rpm-ostree kargs $WATCHDOG_KARGS

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
    systemctl enable --user --now arch-opentabletdriver.service && \
    distrobox enter -n arch -- 'distrobox-export --app otd-gui'

# Add SELinux file context for default looking-glass shm file so that libvirt can create it when needed
selinux-looking-glass:
    sudo semanage fcontext -a -t svirt_tmpfs_t /dev/shm/looking-glass

# Add virtual audio channels/sinks named Game, Voice, Browser and Music which you can split audio to using qpwgraph, helvum, carla or other pipewire patchbays for use in OBS and other use cases
setup-virtual-channels:
    #!/bin/bash
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    cat << 'EOL' > ~/.config/pipewire/pipewire.conf.d/virtual-channels.conf
    context.modules = [
        { name = libpipewire-module-loopback
            args = {
                node.description = "Game"
                capture.props = {
                    node.name      = "game_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    node.name      = "playback.game_output"
                    audio.position = [ FL FR ]
                    node.passive   = true
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Voice"
                capture.props = {
                    node.name      = "voice_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    node.name      = "playback.voice_output"
                    audio.position = [ FL FR ]
                    node.passive   = true
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Browser"
                capture.props = {
                    node.name      = "browser_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    node.name      = "playback.browser_output"
                    audio.position = [ FL FR ]
                    node.passive   = true
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Music"
                capture.props = {
                    node.name      = "music_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    node.name      = "playback.music_output"
                    audio.position = [ FL FR ]
                    node.passive   = true
                }
            }
        }
    ]
    EOL
    echo "Next time you log in, you will have audio channels for Game, Voice, Browser, Music that you can route game audio to"
    echo "using programs like qpwgraph, helvum or carla."
    echo "You can also add these channels to OBS audio mixer for separate audio control for yourself and your viewers."
    echo "NOTE: It is recommended to mute the virtual channels so you do not have to listen to them twice if you are not exclusively routing the audio through said channel instead of splitting audio to them."

# Remove the virtual audio sinks
remove-virtual-channels:
    rm ~/.config/pipewire/pipewire.conf.d/virtual-channels.conf
    echo "Virtual audio channels config removed, the channels will be removed next time you login."

# Setup a simple Virtual Surround 7.1 sink using the ASH Control Room 1 convolver file (you can change this yourself after setup)
setup-virtual-surround-71:
    #!/bin/bash
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    mkdir -p ~/.config/pipewire/hrir_hesuvi
    echo "Downloading HeSuVi convolver profile Control Room 1 from https://github.com/ShanonPearce/ASH-Listening-Set"
    wget -O ~/.config/pipewire/hrir_hesuvi/Control_Room_1.wav https://github.com/ShanonPearce/ASH-Listening-Set/raw/main/HeSuVi/hrir/_Control_Room_1.wav
    cat << HESUVI > ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf
    context.modules = [
        { name = libpipewire-module-filter-chain
            flags = [ nofail ]
            args = {
                node.description = "Virtual Surround 7.1"
                media.name       = "Virtual Surround 7.1"
                filter.graph = {
                    nodes = [
                        # Duplicate inputs
                        { type = builtin label = copy name = copyFL  }
                        { type = builtin label = copy name = copyFR  }
                        { type = builtin label = copy name = copyFC  }
                        { type = builtin label = copy name = copyRL  }
                        { type = builtin label = copy name = copyRR  }
                        { type = builtin label = copy name = copySL  }
                        { type = builtin label = copy name = copySR  }
                        { type = builtin label = copy name = copyLFE }

                        # Apply hrir - HeSuVi 14-channel WAV (not the *-.wav variants) (note: */44/* in HeSuVi are the same, but resampled to 44100)
                        # The file paths HAS to be absolute paths
                        { type = builtin label = convolver name = convFL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  0 } }
                        { type = builtin label = convolver name = convFL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  1 } }
                        { type = builtin label = convolver name = convSL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  2 } }
                        { type = builtin label = convolver name = convSL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  3 } }
                        { type = builtin label = convolver name = convRL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  4 } }
                        { type = builtin label = convolver name = convRL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  5 } }
                        { type = builtin label = convolver name = convFC_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  6 } }
                        { type = builtin label = convolver name = convFR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  7 } }
                        { type = builtin label = convolver name = convFR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  8 } }
                        { type = builtin label = convolver name = convSR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  9 } }
                        { type = builtin label = convolver name = convSR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 10 } }
                        { type = builtin label = convolver name = convRR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 11 } }
                        { type = builtin label = convolver name = convRR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 12 } }
                        { type = builtin label = convolver name = convFC_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 13 } }

                        # Treat LFE as FC
                        { type = builtin label = convolver name = convLFE_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  6 } }
                        { type = builtin label = convolver name = convLFE_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 13 } }

                        # Stereo output
                        { type = builtin label = mixer name = mixL }
                        { type = builtin label = mixer name = mixR }
                    ]
                    links = [
                        # Input
                        { output = "copyFL:Out"  input="convFL_L:In"  }
                        { output = "copyFL:Out"  input="convFL_R:In"  }
                        { output = "copySL:Out"  input="convSL_L:In"  }
                        { output = "copySL:Out"  input="convSL_R:In"  }
                        { output = "copyRL:Out"  input="convRL_L:In"  }
                        { output = "copyRL:Out"  input="convRL_R:In"  }
                        { output = "copyFC:Out"  input="convFC_L:In"  }
                        { output = "copyFR:Out"  input="convFR_R:In"  }
                        { output = "copyFR:Out"  input="convFR_L:In"  }
                        { output = "copySR:Out"  input="convSR_R:In"  }
                        { output = "copySR:Out"  input="convSR_L:In"  }
                        { output = "copyRR:Out"  input="convRR_R:In"  }
                        { output = "copyRR:Out"  input="convRR_L:In"  }
                        { output = "copyFC:Out"  input="convFC_R:In"  }
                        { output = "copyLFE:Out" input="convLFE_L:In" }
                        { output = "copyLFE:Out" input="convLFE_R:In" }

                        # Output
                        { output = "convFL_L:Out"  input="mixL:In 1" }
                        { output = "convFL_R:Out"  input="mixR:In 1" }
                        { output = "convSL_L:Out"  input="mixL:In 2" }
                        { output = "convSL_R:Out"  input="mixR:In 2" }
                        { output = "convRL_L:Out"  input="mixL:In 3" }
                        { output = "convRL_R:Out"  input="mixR:In 3" }
                        { output = "convFC_L:Out"  input="mixL:In 4" }
                        { output = "convFC_R:Out"  input="mixR:In 4" }
                        { output = "convFR_R:Out"  input="mixR:In 5" }
                        { output = "convFR_L:Out"  input="mixL:In 5" }
                        { output = "convSR_R:Out"  input="mixR:In 6" }
                        { output = "convSR_L:Out"  input="mixL:In 6" }
                        { output = "convRR_R:Out"  input="mixR:In 7" }
                        { output = "convRR_L:Out"  input="mixL:In 7" }
                        { output = "convLFE_R:Out" input="mixR:In 8" }
                        { output = "convLFE_L:Out" input="mixL:In 8" }
                    ]
                    inputs  = [ "copyFL:In" "copyFR:In" "copyFC:In" "copyLFE:In" "copyRL:In" "copyRR:In", "copySL:In", "copySR:In" ]
                    outputs = [ "mixL:Out" "mixR:Out" ]
                }
                capture.props = {
                    node.name      = "effect_input.virtual-surround-7.1-hesuvi"
                    media.class    = Audio/Sink
                    audio.channels = 8
                    audio.position = [ FL FR FC LFE RL RR SL SR ]
                }
                playback.props = {
                    node.name      = "effect_output.virtual-surround-7.1-hesuvi"
                    node.passive   = true
                    audio.channels = 2
                    audio.position = [ FL FR ]
                }
            }
        }
    ]
    HESUVI
    echo "Virtual Surround 7.1 has now been set up with a basic convolver file, either restart pipewire or reboot for it to take effect."
    echo "Then select the Virtual Surround 7.1 audio output as your default audio output."
    echo "If you want something like DTS, Atmos or OpenAL, you will have to aquire those convolver wav files yourself and edit ~/.config/pipewire/pipewire.conf.d/virtual-surround.conf to point to the one you want to use."

# Remove Virtual Surround 7.1 sink
remove-virtual-surround-71:
    rm ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf
    rm ~/.config/pipewire/hrir_hesuvi/Control_Room_1.wav
    echo "Virtual Surround 7.1 removed, please reboot or restart pipewire for it to take effect."

# Create fedora distrobox if it doesn't exist
[private]
distrobox-check-fedora:
    #!/bin/env bash
    if grep -qvz "fedora" <<< $(distrobox list); then
      echo "Setting up Fedora distrobox"
      /usr/bin/ujust distrobox-fedora
    fi
