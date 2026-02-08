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
cat >/etc/anaconda/profile.d/bazzite.conf <<EOF
# Anaconda configuration file for bazzite

[Profile]
# Define the profile.
profile_id = bazzite

[Profile Detection]
# Match os-release values
os_id = bazzite

[Network]
default_on_boot = FIRST_WIRED_WITH_LINK

[Bootloader]
efi_dir = fedora
menu_auto_hide = True

[Storage]
default_scheme = BTRFS
btrfs_compression = zstd:1
default_partitioning =
    /     (min 1 GiB, max 70 GiB)
    /home (min 500 MiB, free 50 GiB)
    /var  (btrfs)

[User Interface]
custom_stylesheet = /usr/share/anaconda/pixmaps/fedora.css
hidden_spokes =
    NetworkSpoke
    PasswordSpoke

hidden_webui_pages =
    root-password
    network

[Localization]
use_geolocation = False
EOF

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

# Install Flatpaks
cat <<'EOF' >>/usr/share/anaconda/post-scripts/install-flatpaks.ks
%post --erroronfail --nochroot --log=/tmp/anacoda_custom_logs/install-flatpaks.log
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP /var/lib/flatpak "$target"
%end
EOF

# Disable Fedora Flatpak Repo
cat <<EOF >>/usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%post --erroronfail --log=/tmp/anacoda_custom_logs/disable-fedora-flatpak.log
systemctl disable flatpak-add-fedora-repos.service || :
%end
EOF

# Set Anaconda Payload to use flathub
cat <<EOF >>/etc/anaconda/conf.d/anaconda.conf
[Payload]
flatpak_remote = flathub https://dl.flathub.org/repo/
EOF

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

# Add bootloader restoring script
cat >/usr/bin/bootloader_restore.sh <<'SCRIPTEOF'
#!/usr/bin/env -S /usr/bin/pkexec --keep-cwd /usr/bin/bash

set -o pipefail
if [[ $DEBUG -eq 1 ]]; then
    set -x
fi
exec > >(tee -a /tmp/bootloader_restore.log) 2>&1
echo >&2 "### START LOG $(date -u) ###"

######################################################

yad() {
    command run0 --user="$PKEXEC_UID" -- command yad \
        --title="$_APP_NAME" \
        --separator=$'\n' \
        --timeout=0 \
        "$@"
}

info() {
    echo >&2 "INFO [${0##*/}:${BASH_LINENO[0]}]: $*"
}

error() {
    echo >&2 "ERROR [${0##*/}:${BASH_LINENO[0]}]: $*"
}

die() {
    error "$*"
    exit 1
}

die_gui() {
    yad --title="Error" --text="$(error "$*" 2>&1)" --button="OK:0"
    die "$*"
}

######################################################

if [[ $PKEXEC_UID -eq 0 ]]; then
    die "You must not execute this script as root."
fi

_APP_NAME="Bazzite Bootloader Restoring Tool"
DRY_RUN=${DRY_RUN:-0}
MNT=/tmp/mnt
trap 'umount --recursive $MNT/boot 2>/dev/null' EXIT

DISK_PATH=$(lsblk -d -n -o NAME,SIZE,MODEL | while read -r name size model; do
    echo "$name"
    echo "$size"
    echo "$model"
done | yad --list --no-buttons \
    --text="Double-click the disk where you installed Bazzite:" --width=500 --height=300 \
    --column="Device" \
    --column="Size" \
    --column="Model" \
    --print-column=1) || {
    info "User cancelled during disk selection"
    exit 0
}
: "${DISK_PATH:?}"
DISK_PATH=/dev/${DISK_PATH}

efi_dev=$(systemd-repart --json=short "$DISK_PATH" 2>/dev/null |
    jq -r '.[] | select(.type == "esp").node')
[[ -n ${efi_dev} ]] || { die_gui "EFI partition not found"; }
xboot_dev=$(
    lsblk -J -p -f -o NAME,LABEL,SIZE,FSTYPE "$DISK_PATH" 2>/dev/null |
        jq -r '.blockdevices[0].children[] | select(.fstype == "ext4") | "\(.name)\n\(.label // "")\n\(.size)"' |
        yad --list --no-buttons \
            --text="Double-click the XBOOT partition:" --width=500 --height=300 \
            --column="Device" \
            --column="Label" \
            --column="Size" \
            --print-column=1
) || {
    info "User cancelled during XBOOT partition selection"
    exit 0
}
[[ -n "${xboot_dev}" ]] || die_gui "You must select an XBOOT partition."

yad --text="This will restore the boot in the device $DISK_PATH, using $xboot_dev as the XBOOT partition. Proceed?" || {
    info "User cancelled during restoration confirmation"
    exit 0
}

mount --mkdir "$xboot_dev" "$MNT"/boot || die "Failed to mount XBOOT partition"
mount "$efi_dev" "$MNT"/boot/efi || die "Failed to mount EFI partition"

if [[ $DRY_RUN -eq 1 ]]; then
    info "Script was executed with ${DRY_RUN@A}, skipping bootloader restoration..."
    yad --text="Script was executed with ${DRY_RUN@A}, skipping bootloader restoration...." --button="OK:0"
else
    if [[ -f $MNT/boot/bootupd-state.json ]]; then
        rm -vf $MNT/boot/bootupd-state.json &&
            info "Removed existing bootupd-state.json"
    fi
    run0 --user="$PKEXEC_UID" -- \
        ptyxis --title="$_APP_NAME - Restoring bootloader" -- \
        pkexec bash -c "bootupctl backend install \
        -vvvv \
        --auto \
        --write-uuid \
        --update-firmware \
        --device \"$DISK_PATH\" \"$MNT\"" &&
        info "Bootloader restored successfully." &&
        yad --text "Bootloader restored successfully." --button="OK:0"
fi

SCRIPTEOF
chmod +x /usr/bin/bootloader_restore.sh
cat >/usr/share/applications/bazzite_bootloader_restoring_tool.desktop <<'EOF'
[Desktop Entry]
Type=Application
Icon=tools-wizard-symbolic
Name=Bazzite Bootloader Restoring Tool BETA
Comment=Restore the bootloader of an installation if has been overriden by Windows
Keywords=bootloader;fix;grub;windows
Categories=System;Utility
Exec=/usr/bin/bootloader_restore.sh
Hidden=false
NoDisplay=false
StartupNotify=true
Terminal=false
EOF

### Desktop-enviroment specific tweaks ###
# Setup script to show dialog popups at login
echo '#!/usr/bin/bash' >/usr/bin/on_gui_login.sh
chmod +x /usr/bin/on_gui_login.sh
mkdir -p /etc/skel/.config/autostart
cat >>/usr/bin/on_gui_login.sh <<'EOF'
# if CSM/Legacy show blocking message and power off
if [[ ! -d /sys/firmware/efi ]]; then
    yad --undecorated --on-top --timeout=0 --button=Shutdown:0 \
        --text="Bazzite does not support CSM/Legacy Boot. Please boot into your UEFI/BIOS settings, disable CSM/Legacy Mode, and reboot." || true
    systemctl poweroff || shutdown -h now || true
fi
EOF
#serve docs in live session
cat >>/usr/bin/on_gui_login.sh <<'EOF'
serve_docs(){
  ADDRESS=127.0.0.1
  PORT=1290
  { python -m http.server -b $ADDRESS $PORT -d "$(dirname "$0")"/html; } >/dev/null 2>&1 &
  if [[ $- == *i* ]]; then
      fg >/dev/null 2>&1 || true
  fi
}
EOF
# Warn about limited capabilities of live sessions, and also show buttons to:
#   - Install Bazzite
#   - Launch Bootloader Restoring tool
#   - Close dialog
cat >>/usr/bin/on_gui_login.sh <<'EOF'
welcome_dialog() {
_EXITLOCK=1
_RETVAL=0
while [[ $_EXITLOCK -eq 1 ]]; do
    yad \
        --no-escape \
        --on-top \
        --timeout-indicator=bottom \
        --text-align=center \
        --buttons-layout=center \
        --title="Welcome" \
        --text="\nWelcome to the Live ISO for Bazzite\!\n\nThe Live ISO is designed for installation and troubleshooting.\nIt does <b>not</b> have drivers and is <b>not capable of playing games.</b>\n\nPlease <b>do not use it in benchmarks</b> as it\ndoes not represent the installed experience.\n" \
         --button="Install Bazzite":10 \
        --button="Launch Bootloader Restoring tool":20 \
        --button="Close dialog":0
    _RETVAL=$?
    case $_RETVAL in
        10)
            liveinst & disown $!
            _EXITLOCK=0
            ;;
        20)
            /usr/bin/bootloader_restore.sh & disown $!
            _EXITLOCK=0
            ;;
        0) _EXITLOCK=0 ;;
    esac
done
unset -v _EXITLOCK
unset -v _RETVAL
}
EOF
# Warn the user if they're using an unsupported nvidia card, or trying to install the wrong image for nvidia
cat >>/usr/bin/on_gui_login.sh <<'EOF'
nvidia_hardware_helper () {
timeout_seconds=15
gpuinfo="$(timeout $timeout_seconds lspci -nn | grep '\[03')"
if [ $? -ne 0 ]; then
  return 124
fi
image_name=$(timeout $timeout_seconds sudo podman images --format '{{ index .Names 0 }}\n' 'bazzite*')
if [ -z "$image_name" ]; then
  return 124
fi
#call NVIDIA detection script TODO: change path
if [[ -f "/usr/libexec/bazzite_detect_nvidia_support_status"  ]]; then
output=$("/usr/libexec/bazzite_detect_nvidia_support_status")
ret_val=$?
# handle exit codes
if [ $ret_val -eq 0 ] && [ "$output" == "" ]
  then
    echo "no NVIDIA GPU"
    return 0
fi
if [ $ret_val  -eq 124 ]
  then
    return 124
fi
support_status=$output
echo "support status: $support_status"
if [ "$support_status" == "legacy" ]; then
  correct_image="\"<b>Nvidia (GTX 9xx-10xx Series)</b>\""
fi
if [ "$support_status" == "supported" ]; then
  correct_image="\"<b>Nvidia (RTX Series | GTX 16xx Series+)</b>\""
fi
# parse image information
echo "image name: ""$image_name"
  if [[ $image_name == *-nvidia-open* ]] || [[ $image_name == *-deck-nvidia* ]]; then
    echo "modern nvidia image detected!"
    image="modern"
  elif [[ $image_name == *-nvidia:* ]]; then
    echo "legacy nvidia image detected!"
    image="legacy"
  else
    echo "AMD/Intel image detected!"
    image="amd_intel"
  fi
#user facing text
title="Bazzite Hardware Helper"
heading_unsupported="<b>Unsupported Graphics Card</b>\n"
detected_unsupported="We've detected you're using a now unsupported NVIDIA GPU.\nUnfortunately, we cannot provide good support for your hardware ourselves.\n\n"
recommend_unsupported="Please read our <a href=\"http://127.0.0.1:1290/General/FAQ/#will-you-add-support-for-even-older-nvidia-graphics-cards\"><b>documentation</b></a> for more information.\n"
heading_unknown="<b>Unknown Graphics Card</b>\n"
detected_unknown="We could not identify your NVIDIA graphics card.\n\n"
recommend_unknown="It is not recommended to install Bazzite as we cannot guarantee your hardware will work."
heading_wrong_image="<b>WRONG IMAGE DETECTED</b>\n"
detected_wrong_image="Your $support_status NVIDIA graphics card needs a different version of Bazzite.\n\n"
recommend_wrong_image="Pick $correct_image as \"vendor of your primary GPU\" on the website to download and install the correct version instead."
button1="I KNOW WHAT I AM DOING. Install Bazzite Anyway:0"
button2="Power Off:1"
heading2="Detected Graphics Adapter"
button3="GPU Information:2"
if [[ "$support_status" = "unsupported" ]]; then
  serve_docs
  heading="$heading_unsupported"
  gpu_detected="$detected_unsupported"
  recommendation="$recommend_unsupported"
elif [[ "$support_status" = "unknown" ]]; then
  heading="$heading_unknown"
  gpu_detected="$detected_unknown"
  recommendation="$recommend_unknown"
elif [[ "$support_status" = "legacy" ]] && [[ "$image" = "legacy" ]]; then
  echo "legacy GPU matches legacy image. Nothing to do. Exiting…"
  return 0
elif [[ "$support_status" = "supported" ]] && [[ "$image"  = "modern"  ]]; then
  echo "supported GPU matches modern image. Nothing to do. Exiting…"
  return 0
elif [[ "$support_status" = "supported" ]] && [[ "$image"  != "modern" ]]; then
  heading="$heading_wrong_image"
  correct_image=
  gpu_detected="$detected_wrong_image"
  recommendation="$recommend_wrong_image"
elif [[ "$support_status" = "legacy" ]] && [[ "$image" != "legacy" ]]; then
  heading="$heading_wrong_image"
  gpu_detected="$detected_wrong_image"
  recommendation="$recommend_wrong_image"
fi
  while true; do
#YAD dialog
  yad --warning --buttons-layout=center --text-align=center --title="$title" --text="$heading""$gpu_detected""$recommendation"\
      --button="$button1" \
      --button="$button2" \
      --button="$button3"
      case $? in
           0) return 0;;
           1) systemctl poweroff || shutdown -h now || true
             break;;
           2) yad --info --title="$heading2" --text="$gpuinfo" ;;
      esac
  done
  fi
}
nvidia_hardware_helper
result=$?
if [ $result -eq 0 ] || [ $result -eq 1 ] || [ $result -eq 124 ]
then
  echo 'launch welcome dialog'
    welcome_dialog
fi
EOF

cat >/etc/skel/.config/autostart/on_gui_login.desktop <<'EOF'
[Desktop Entry]
Exec=/usr/bin/on_gui_login.sh
Icon=application-x-shellscript
Type=Application
EOF

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
    cp 2>/dev/null "$wallpaper_file" /usr/share/backgrounds/convergence.jxl || :
    cp 2>/dev/null "$wallpaper_file" /usr/share/backgrounds/convergence/convergence_morn.jxl || :
    rm -f /usr/share/backgrounds/default.xml
)

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

# Tweak the fedora-welcome app (gnome only) with our own text/icons
if [[ $desktop_env == gnome ]]; then
    sed -i 's| Fedora| Bazzite|' /usr/share/anaconda/gnome/fedora-welcome || :
    cp -f /usr/share/pixmaps/{fedora-logo-sprite,fedora-logo-icon}.png || :
fi

# Let only browser/installer in the task-bar/dock
if [[ $desktop_env == kde ]]; then
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:liveinst.desktop,preferred:\/\/filemanager<\/default>/' \
        /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
elif [[ $desktop_env == gnome ]]; then
    cat >/usr/share/glib-2.0/schemas/zz2-org.gnome.shell.gschema.override <<EOF
[org.gnome.shell]
welcome-dialog-last-shown-version='4294967295'
favorite-apps = ['liveinst.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop']
EOF
    glib-compile-schemas /usr/share/glib-2.0/schemas
fi

# Disable kde wallet
if [[ $desktop_env == kde ]]; then
    mkdir -p /etc/skel/.config
    cat >/etc/skel/.config/kwalletrc <<'EOF'
[Wallet]
Enabled=false
EOF
fi

# Install Gparted
dnf -yq install gparted

###############################
