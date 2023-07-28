# Set up symlinks found in SteamOS
ln -s /usr/bin/steamos-logger /usr/bin/steamos-info
ln -s /usr/bin/steamos-logger /usr/bin/steamos-notice
ln -s /usr/bin/steamos-logger /usr/bin/steamos-warning

# Setup Copr repos
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-multilib-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-$(rpm -E %fedora)/kylegospo-LatencyFleX-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo

# Install Valve's Steam Deck drivers as kmods and 
# mesa-va-drivers shim (Needed due to dependency issues in Steam package)
rpm-ostree install \
    /tmp/akmods-rpms/kmods/*steamdeck*.rpm \
    mesa-va-drivers

# Install gamescope-limiter patched Mesa
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
    mesa-dri-drivers \
    mesa-libEGL \
    mesa-libgbm \
    mesa-libGL \
    mesa-libglapi \
    mesa-vulkan-drivers

# Install patched udisks2 (Needed for SteamOS SD card mounting)
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite \
    udisks2
    
# Remove unneeded packages
rpm-ostree override remove \
    ublue-os-wallpapers \
    steamdeck-kde-presets-desktop \
    krfb \
    krfb-libs

# Install new packages
rpm-ostree install \
    steam \
    lutris \
    gamescope \
    gamescope-session \
    jupiter-fan-control \
    jupiter-hw-support-btrfs \
    steamdeck-kde-presets \
    vpower \
    ds-inhibit \
    ryzenadj \
    gamemode \
    latencyflex-vulkan-layer \
    vkBasalt \
    mangohud \
    sdgyrodsu \
    f3 \
    python-vdf \
    python-crcmod

# Install dock updater, this is done manually due to proprietary parts preventing it from being on Copr
git clone https://gitlab.com/evlaV/jupiter-dock-updater-bin.git --depth 1 /tmp/jupiter-dock-updater-bin
mv -v /tmp/jupiter-dock-updater-bin/packaged/usr/lib/jupiter-dock-updater /usr/lib/jupiter-dock-updater

# Cleanup & Finalize
sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' /etc/systemd/logind.conf
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo
mv /etc/sddm.conf /etc/sddm.conf.d/steamos.conf
systemctl enable plasma-autologin.service
systemctl enable jupiter-fan-control.service
systemctl enable vpower.service
systemctl enable ds-inhibit.service
systemctl disable input-remapper.service
systemctl --global disable ublue-update.timer
