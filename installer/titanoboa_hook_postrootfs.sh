#!/usr/bin/env bash

set -exo pipefail

source /etc/os-release

# Remove all versionlocks, in order to avoid dependency issues
dnf -qy versionlock clear

# Install Anaconda
dnf install -qy --enable-repo=fedora-cisco-openh264 --allowerasing firefox anaconda-live libblockdev-{btrfs,lvm,dm}

mkdir -p /var/lib/rpm-state # Needed for Anaconda Web UI

# Utilities for displaying a dialog prompting users to review secure boot documentation
dnf install -qy --setopt=install_weak_deps=0 qrencode yad

# Install conky to display hardware information on the desktop
dnf install -qy --setopt=install_weak_deps=0 conky

# Variables
imageref="$(podman images --format '{{ index .Names 0 }}\n' 'bazzite*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"
imagetag="$(podman images --format '{{ .Tag }}\n' "$imageref" | head -1)"
sbkey='https://github.com/ublue-os/akmods/raw/main/certs/public_key.der'
SECUREBOOT_KEY="/usr/share/ublue-os/sb_pubkey.der"
SECUREBOOT_DOC_URL="https://docs.bazzite.gg/sb"
SECUREBOOT_DOC_URL_QR="/usr/share/ublue-os/secure_boot_qr.png"

# Bazzite anaconda profile
: ${VARIANT_ID:?}

echo "Bazzite release $VERSION_ID ($VERSION_CODENAME)" >/etc/system-release

# Get Artwork
git clone --depth 1 --quiet https://github.com/ublue-os/bazzite.git /root/packages
case "${PRETTY_NAME,,}" in
"bazzite"*)
    mkdir -p /usr/share/anaconda/pixmaps/silverblue
    cp -r /root/packages/installer/branding/* /usr/share/anaconda/pixmaps/
    ;;
esac

# Installer icon
_icon=/root/packages/installer/branding/bazzite-installer.svg
_icon_symbol=/root/packages/installer/branding/bazzite-installer-symbolic.svg
if [[ -f $_icon ]]; then
    for f in \
        /usr/share/icons/hicolor/48x48/apps/org.fedoraproject.AnacondaInstaller.svg \
        /usr/share/icons/hicolor/scalable/apps/org.fedoraproject.AnacondaInstaller.svg; do
        cp "$_icon" "$f"
    done
    cp "$_icon_symbol" /usr/share/icons/hicolor/symbolic/apps/org.fedoraproject.AnacondaInstaller-symbolic.svg
fi
unset -v _icon
unset -v _icon_symbol
rm -rf /root/packages

# Secureboot Key Fetch
mkdir -p /usr/share/ublue-os
curl -Lo /usr/share/ublue-os/sb_pubkey.der "$sbkey"

# Default Kickstart
cat <<EOF >>/usr/share/anaconda/interactive-defaults.ks

# Create log directory
%pre
mkdir -p /tmp/anacoda_custom_logs
%end

# Check if there is a bitlocker partition and ask the user to disable it
%pre --erroronfail --log=/tmp/anacoda_custom_logs/detect_bitlocker.log
DOCS_QR=/tmp/detect_bitlocker_qr.png
IS_BITLOCKER=\$(lsblk -o FSTYPE --json | jq '.blockdevices | map(select(.fstype == "BitLocker")) | . != []')
{ WARNING_MSG="\$(</dev/stdin)"; } << 'WARNINGEOF'
<span size="x-large">Windows Bitlocker partition detected</span>

It might interrupt the installation process.
In such case, please, do <b>one</b> of the following:
    a) Disconnect its storage drive.
    b) Disable Bitlocker in Windows.
    c) Delete it in GNOME Disks.

Do you wish to continue?
WARNINGEOF

if [[ \$IS_BITLOCKER =~ true ]]; then
    qrencode -o \$DOCS_QR "https://www.wikihow.com/Turn-Off-BitLocker"
    _EXITLOCK=1
    _RETCODE=0
    while [[ \$_EXITLOCK -ne 0 ]]; do
        run0 --user=liveuser yad \
            --on-top \
            --timeout=10 \
            --image=\$DOCS_QR \
            --text="\$WARNING_MSG" \
            --button="Yes, I'm aware, continue":0 --button="Cancel installation":10
        _RETCODE=\$?
        case \$_RETCODE in
            0) _EXITLOCK=0; ;;
            10) _EXITLOCK=0; pkill liveinst; pkill firefox; exit 0 ;;
        esac
    done
fi
%end

# Remove the efi dir, must match efi_dir from the profile config
%pre-install --erroronfail
rm -rf /mnt/sysroot/boot/efi/EFI/fedora
%end

# Relabel the boot partition for the
%pre-install --erroronfail --log=/tmp/anacoda_custom_logs/repartitioning.log
set -x
xboot_dev=\$(findmnt -o SOURCE --nofsroot --noheadings -f --target /mnt/sysroot/boot)
if [[ -z \$xboot_dev ]]; then
  echo "ERROR: xboot_dev not found"
  exit 1
fi
e2label "\$xboot_dev" "bazzite_xboot"
%end

# Open a dialog with the installation logs
%onerror
run0 --user=liveuser yad \
    --timeout=0 \
    --text-info \
    --no-buttons \
    --width=600 \
    --height=400 \
    --text="An error occurred during installation. Please report this issue to the developers." \
    < /tmp/anaconda.log
%end

$(
    if [[ $imageref == *-deck* ]]; then
        cat <<EOCAT
# Set default user
user --name=bazzite --password=bazzite --plaintext --groups=wheel
EOCAT
    fi
)

ostreecontainer --url=$imageref:$imagetag --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
%include /usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
%include /usr/share/anaconda/post-scripts/secureboot-docs.ks

EOF

# Signed Images
cat <<EOF >>/usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%post --erroronfail --log=/tmp/anacoda_custom_logs/bootc-switch.log
# bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry $imageref:$imagetag

# DELETEME: This is a nasty hack. Remove whenever http://github.com/bootc-dev/bootc/commit/f7b41cc1ebfc823e9de848b55773faddc59ecf88 makes it into a release
sed -i 's|container-image-reference=.*|container-image-reference=ostree-image-signed:docker://$imageref:$imagetag|' /ostree/deploy/default/deploy/*.origin
%end
EOF

# Enroll Secureboot Key
cat <<EOF >>/usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
%post --erroronfail --nochroot --log=/tmp/anacoda_custom_logs/secureboot-enroll-key.log
set -oue pipefail

readonly ENROLLMENT_PASSWORD="universalblue"
readonly SECUREBOOT_KEY="$SECUREBOOT_KEY"

if [[ ! -d "/sys/firmware/efi" ]]; then
	echo "EFI mode not detected. Skipping key enrollment."
	exit 0
fi

if [[ ! -f "\$SECUREBOOT_KEY" ]]; then
	echo "Secure boot key not provided: \$SECUREBOOT_KEY"
	exit 0
fi

SYS_ID="\$(cat /sys/devices/virtual/dmi/id/product_name)"
if [[ ":Jupiter:Galileo:" =~ ":\$SYS_ID:" ]]; then
	echo "Steam Deck hardware detected. Skipping key enrollment."
	exit 0
fi

mokutil --timeout -1 || :
echo -e "\$ENROLLMENT_PASSWORD\n\$ENROLLMENT_PASSWORD" | mokutil --import "\$SECUREBOOT_KEY" || :
%end
EOF

cat <<EOF >>/usr/share/anaconda/post-scripts/secureboot-docs.ks
%post --nochroot --log=/tmp/anacoda_custom_logs/secureboot-docs.log
SECUREBOOT_KEY="$SECUREBOOT_KEY"
SECUREBOOT_DOC_URL="$SECUREBOOT_DOC_URL"
SECUREBOOT_DOC_URL_QR="$SECUREBOOT_DOC_URL_QR"

LC_ALL=C mokutil -t "\$SECUREBOOT_KEY" | grep -q "is already in the enrollment request" && \
    run0 --user=liveuser yad --timeout=0 --on-top --button=Ok:0 --image="\$SECUREBOOT_DOC_URL_QR" --text="<b>Secure Boot Key added:</b>\nPlease check the documentation to finish enrolling the key\n\$SECUREBOOT_DOC_URL"
%end
EOF

qrencode -o "$SECUREBOOT_DOC_URL_QR" "$SECUREBOOT_DOC_URL"

# TODO (@Zeglius): Hide grub by default and set timeout to 5 seconds
# # Hide grub by default and set timeout to 5 seconds
# mkdir -p /boot/grub2
# cat >>/boot/grub2/grub.cfg <<'EOF'

# # Setup for liveisos
# set menu_auto_hide=2
# set timeout_style=hidden
# set timeout=5
# EOF

### Livecds runtime tweaks ###

# Disable services
(
    set +e
    for s in \
        rpm-ostree-countme.service \
        tailscaled.service \
        bazzite-hardware-setup.service \
        bootloader-update.service \
        brew-upgrade.timer \
        brew-update.timer \
        brew-setup.service \
        rpm-ostreed-automatic.timer \
        uupd.timer \
        ublue-guest-user.service \
        ublue-os-media-automount.service \
        ublue-system-setup.service \
        check-sb-key.service; do
        systemctl disable $s
    done

    for s in \
        ublue-flatpak-manager.service \
        podman-auto-update.timer \
        ublue-user-setup.service; do
        systemctl --global disable $s
    done
)

### Desktop-enviroment specific tweaks ###
# Setup script to show dialog popups at login

# Use GSK_RENDERER=gl for nvidia, workaround for GTK apps not opening.
if [[ $imageref == *-nvidia* ]]; then
    mkdir -p /etc/environment.d /etc/skel/.config/environment.d
    echo "GSK_RENDERER=gl" >>/etc/environment.d/99-nvidia-fix.conf
    echo "GSK_RENDERER=gl" >>/etc/skel/.config/environment.d/99-nvidia-fix.conf
fi

# Reenable noveau.
if [[ $imageref == *-nvidia* ]]; then
    for pkg in nvidia-gpu-firmware mesa-vulkan-drivers; do
        dnf -yq reinstall --allowerasing $pkg ||
            dnf -yq install --allowerasing $pkg
    done
    # Ensure noveau vulkan icds exist
    (
        shopt -u nullglob
        ls /usr/share/vulkan/icd.d/nouveau_icd.*.json >/dev/null
    ) || {
        echo >&2 "::error::No nouveau vulkan icds found at /usr/share/vulkan/icd.d/nouveau_icd.*.json"
        exit 1
    }
fi

# Determine desktop environment. Must match one of /usr/libexec/livesys/sessions.d/livesys-{desktop_env}
# See https://github.com/ublue-os/titanoboa/blob/6c2e8ba58c7534b502081fe24363d2a60e7edca9/Justfile#L199-L213
desktop_env=""
_session_file="$(find /usr/share/wayland-sessions/ /usr/share/xsessions \
    -maxdepth 1 -type f -not -name '*gamescope*.desktop' -and -name '*.desktop' -printf '%P' -quit)"
case $_session_file in
budgie*) desktop_env=budgie ;;
cosmic*) desktop_env=cosmic ;;
gnome*) desktop_env=gnome ;;
plasma*) desktop_env=kde ;;
sway*) desktop_env=sway ;;
xfce*) desktop_env=xfce ;;
esac

# Dont start Steam at login
rm -vf /etc/skel/.config/autostart/steam*.desktop

# Remove packages that shouldnt be used in a live session
dnf -yq remove steam lutris bazaar || :

(
    wallpaper_url=https://github.com/ublue-os/bazzite/raw/refs/heads/main/press_kit/art/Convergence_Wallpaper_DX.jxl
    wallpaper_file=/usr/share/wallpapers/convergence.jxl
    wget -nv -O "$wallpaper_file" "$wallpaper_url"
    rm -f /usr/share/backgrounds/default.xml
)

echo "Copying shared system files..."
cp -a /src/system_files/shared/. /

if [[ "$desktop_env" == "gnome" ]]; then
    echo "Copying GNOME-specific system files..."
    cp -a /src/system_files/gnome/. /
elif [[ "$desktop_env" == "kde" ]]; then
    echo "Copying KDE-specific system files..."
    cp -a /src/system_files/kde/. /
fi

# Enable on-screen keyboard
if [[ $imageref == *-deck* ]]; then
    # Enable keyboard here
    if [[ $desktop_env == gnome ]]; then
        echo >>/etc/skel/.bash_profile \
            "gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true >/dev/null 2>&1 || :"
        rm -rf /usr/share/gnome-shell/extensions/block-caribou-36@lxylxy123456.ercli.dev
    elif [[ $desktop_env == kde ]]; then
        mv /usr/share/ublue-os/backup/com.github.maliit.keyboard.desktop \
            /usr/share/applications/com.github.maliit.keyboard.desktop || :
    fi
fi

# Don't start the fedora-welcome app (gnome only)
if [[ $desktop_env == gnome ]]; then
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/anaconda/gnome/org.fedoraproject.welcome-screen.desktop || :
fi

# Set new background for GNOME
if [[ $desktop_env == gnome ]]; then
    glib-compile-schemas /usr/share/glib-2.0/schemas
fi

# Install Gparted
dnf -yq install gparted

###############################
