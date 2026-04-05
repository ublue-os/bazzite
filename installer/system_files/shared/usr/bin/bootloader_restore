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

DISK_PATH=$(
    lsblk -d -n -o NAME,SIZE,MODEL | while read -r name size model; do
        echo "$name"
        echo "$size"
        echo "$model"
    done | yad --list --no-buttons \
        --text="Double-click the disk where you installed Bazzite:" --width=500 --height=300 \
        --column="Device" \
        --column="Size" \
        --column="Model" \
        --print-column=1
) || {
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
        jq -r '.blockdevices[0].children[] | select(.fstype == "ext4") | "\(.name)
\(.label // "")
\(.size)"' |
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
    run0 --user="$PKEXEC_UID" --
    ptyxis --title="$_APP_NAME - Restoring bootloader" -- \
        pkexec bash -c "bootupctl backend install
            -vvvv
        --auto
        --write-uuid
        --update-firmware
        --device \"$DISK_PATH\" \"$MNT\"" &&
        info "Bootloader restored successfully." &&
        yad --text "Bootloader restored successfully." --button="OK:0"
fi
