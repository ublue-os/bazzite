#!/usr/bin/env bash

set -exo pipefail

source /etc/os-release

# Install Anaconda webui
dnf install -qy anaconda-live libblockdev-{btrfs,lvm,dm}
mkdir -p /var/lib/rpm-state # Needed for Anaconda Web UI
# TODO: Enable Anaconda Web UI whenever locale switching in kde lands
# dnf install -qy anaconda-webui

# Utilities for displaying a dialog prompting users to review secure boot documentation
dnf install -qy --setopt=install_weak_deps=0 qrencode yad

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
git clone https://github.com/ublue-os/packages.git /root/packages
case "${PRETTY_NAME,,}" in
"bazzite"*)
    mkdir -p /usr/share/anaconda/pixmaps/silverblue
    cp -r /root/packages/bazzite/fedora-logos/* /usr/share/anaconda/pixmaps/
    ;;
esac
rm -rf /root/packages

# Variables
imageref="$(podman images --format '{{ index .Names 0 }}\n' 'bazzite*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"
imagetag="$(podman images --format '{{ .Tag }}\n' "$imageref" | head -1)"
sbkey='https://github.com/ublue-os/akmods/raw/main/certs/public_key.der'
SECUREBOOT_KEY="/usr/share/ublue-os/sb_pubkey.der"
SECUREBOOT_DOC_URL="https://docs.bazzite.gg/sb"
SECUREBOOT_DOC_URL_QR="/usr/share/ublue-os/secure_boot_qr.png"

# Secureboot Key Fetch
mkdir -p /usr/share/ublue-os
curl -Lo /usr/share/ublue-os/sb_pubkey.der "$sbkey"

# Default Kickstart
cat <<EOF >>/usr/share/anaconda/interactive-defaults.ks

# Check if there is a bitlocker partition and ask the user to disable it
%pre --erroronfail --log=/tmp/detect_bitlocker.log
DOCS_QR=/tmp/detect_bitlocker_qr.png
IS_BITLOCKER=\$(lsblk -o FSTYPE --json | jq '.blockdevices | map(select(.fstype == "BitLocker")) | . != []')
if [[ \$IS_BITLOCKER =~ true ]]; then
    qrencode -o \$DOCS_QR "https://www.wikihow.com/Turn-Off-BitLocker"
    run0 --user=liveuser yad --timeout=0 --image=\$DOCS_QR \
        --text="<b>Windows Bitlocker partition detected</b>\nPlease, disable it in Windows or delete it in GNOME Disks\nor disconnect its storage drive." || :
    exit 1
fi
%end

# Remove the efi dir, must match efi_dir from the profile config
%pre-install --erroronfail
rm -rf /mnt/sysroot/boot/efi/EFI/fedora
%end

# Relabel the boot partition for the
%pre-install --erroronfail --log=/tmp/repartitioning.log
set -x
xboot_dev=\$(findmnt -o SOURCE --nofsroot --noheadings -f --target /mnt/sysroot/boot)
if [[ -z \$xboot_dev ]]; then
  echo "ERROR: xboot_dev not found"
  exit 1
fi
e2label "\$xboot_dev" "bazzite_xboot"
%end
ostreecontainer --url=$imageref:$imagetag --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
%include /usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
%include /usr/share/anaconda/post-scripts/secureboot-docs.ks
EOF

# Signed Images
cat <<EOF >>/usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%post --erroronfail
bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry $imageref:$imagetag
%end
EOF

# Enroll Secureboot Key
cat <<EOF >>/usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
%post --erroronfail --nochroot
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
%post --nochroot
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
%post --erroronfail --nochroot
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP /var/lib/flatpak "$target"
%end
EOF

# Disable Fedora Flatpak Repo
cat <<EOF >>/usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%post --erroronfail
systemctl disable flatpak-add-fedora-repos.service
%end
EOF

# Set Anaconda Payload to use flathub
cat <<EOF >>/etc/anaconda/conf.d/anaconda.conf
[Payload]
flatpak_remote = flathub https://dl.flathub.org/repo/
EOF

### Livecds runtime tweaks ###

# Disable services
(
    set +e
    for s in \
        rpm-ostree-countme.service \
        tailscaled.service \
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

### Nvidia specific tweaks ###

# Warn the user about non functional Nvidia drivers
if [[ $imageref == *-nvidia* ]]; then
    cat <<'EOF' >>/etc/skel/.bash_profile
{ yad --title="Warning" --text="$(</dev/stdin)" || true; } <<'WARNINGEOF'
Nvidia drivers might not be functional on live isos.
Please do not use them in benchmarks.
WARNINGEOF
EOF
fi

### Desktop-enviroment specific tweaks ###

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
dnf -yq remove steam lutris || :

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

# Add support for controllers
_tmp=$(mktemp -d)
(
    set -eo pipefail
    dnf -yq install python-evdev python-rich
    git clone https://github.com/hhd-dev/jkbd "$_tmp"
    cd "$_tmp"
    python -m venv .venv
    #shellcheck disable=1091
    source .venv/bin/activate
    pip install build installer setuptools wheel
    python -m build --wheel --no-isolation
    python -m installer --prefix=/usr --destdir=/ dist/*.whl
    sed -i '1s|.*|#!/usr/bin/python|' /usr/bin/jkbd
    mkdir -p /usr/lib/systemd/system/
    install -m644 usr/lib/systemd/system/jkbd.service /usr/lib/systemd/system/jkbd.service
    systemctl enable jkbd.service
) || :
rm -rf "$_tmp"
unset -v _tmp

###############################
