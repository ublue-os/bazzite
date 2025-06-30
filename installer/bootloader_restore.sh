#!/usr/bin/env -S /usr/bin/pkexec --keep-cwd /usr/bin/bash

set -o pipefail
exec > >(tee -a "$PWD"/bootloader_restore.log) 2>&1
echo >&2 "### START LOG $(date -u) ###"

######################################################

yad() {
    command run0 --user="$PKEXEC_UID" -- command yad \
        --title="$_APP_NAME" \
        --separator=$'\n' \
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
DRY_RUN=${DRY_RUN:-1}
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
    systemd-repart --json=short "$DISK_PATH" 2>/dev/null |
        jq -r '. as $a | [range(0;length) | select($a[.].type == "esp")][0] as $idx | $a[$idx+1].node'
)
[[ -n ${xboot_dev} ]] || { die_gui "XBOOT partition not found"; }

yad --text="This will restore the boot in the device $DISK_PATH, Proceed?" || {
    info "User cancelled during restoration confirmation"
    exit 0
}

mount --mkdir "$xboot_dev" "$MNT"/boot || die "Failed to mount XBOOT partition"
mount "$efi_dev" "$MNT"/boot/efi || die "Failed to mount EFI partition"

if [[ $DRY_RUN -ne 1 ]]; then
    info "Script was executed with ${DRY_RUN@A}, skipping bootloader restoration..."
else
    run0 --user="$PKEXEC_UID" -- \
        ptyxis --title="$_APP_NAME - Restoring bootloader" -- \
        pkexec bash -c "bootupctl backend install \
        -vvvv \
        --auto \
        --write-uuid \
        --update-firmware \
        --device \"$DISK_PATH\" \"$MNT\""
fi
