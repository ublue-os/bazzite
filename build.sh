# Add Copr repos
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/repo/fedora-$(rpm -E %fedora)/kylegospo-hl2linux-selinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/repo/fedora-$(rpm -E %fedora)/kylegospo-obs-vkcapture-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-$(rpm -E %fedora)/kylegospo-wallpaper-engine-kde-plugin-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo
wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
wget https://copr.fedorainfracloud.org/coprs/ycollet/audinux/repo/fedora-$(rpm -E %fedora)/ycollet-audinux-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ycollet-audinux.repo

# Install new packages
rpm-ostree install \
    /tmp/akmods-rpms/kmods/*gcadapter_oc*.rpm \
    /tmp/akmods-rpms/kmods/*openrgb*.rpm \
    /tmp/rpms/ublue-update.noarch.rpm \
    /tmp/rpms/ublue-os-wallpapers.rpm \
    python3-pip \
    libadwaita \
    distrobox \
    steamdeck-kde-presets-desktop \
    sddm-sugar-steamOS \
    wallpaper-engine-kde-plugin \
    duperemove \
    rmlint \
    compsize \
    kdeconnectd \
    ddccontrol \
    ddccontrol-gtk \
    input-remapper \
    system76-scheduler \
    hl2linux-selinux \
    libobs_glcapture \
    libobs_vkcapture \
    obs-vkcapture \
    ladspa-noise-suppression-for-voice \
    btop \
    neofetch \
    fish

# Install ROCM on non-Nvidia images
if grep -v "nvidia" <<< "${IMAGE_NAME}"; then \
    rpm-ostree install \
        rocm-hip \
        rocm-opencl \
; fi 

# Remove unneeded packages
rpm-ostree override remove \
    firefox \
    firefox-langpacks \
    plasma-welcome \
    toolbox \
    htop \
    qt5-qdbusviewer \
    ublue-os-update-services

# Install newer Xwayland
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr xorg-x11-server-Xwayland

# Set up systemd services
systemctl disable rpm-ostreed-automatic.timer
systemctl --global enable ublue-update.timer
systemctl enable input-remapper.service

# Cleanup & Finalize
mkdir -p "/usr/etc/profile.d/"
ln -s "/usr/share/ublue-os/firstboot/launcher/login-profile.sh" \
      "/usr/etc/profile.d/ublue-firstboot.sh"
pip install --prefix=/usr yafti
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-hl2linux-selinux.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-obs-vkcapture.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf
