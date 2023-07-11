#!/bin/bash

set -euo pipefail

# Originally from https://serverfault.com/a/767079

# This script is called from our systemd unit file to mount or unmount
# a USB drive.

usage()
{
    echo "Usage: $0 {add|remove} device_name (e.g. sdb1)"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"

# Wait N seconds for steam
wait_steam()
{
    local i=0
    local wait=$1
    echo "Waiting up to $wait seconds for steam to load"
    while ! pgrep -x steamwebhelper &>/dev/null && (( i++ < wait )); do
        sleep 1
    done
}

send_steam_url()
{
  local command="$1"
  local arg="$2"
  local encoded=$(urlencode "$arg")
  if pgrep -x "steam" > /dev/null; then
      # TODO use -ifrunning and check return value - if there was a steam process and it returns -1, the message wasn't sent
      # need to retry until either steam process is gone or -ifrunning returns 0, or timeout i guess
      systemd-run -M 1000@ --user --collect --wait sh -c "./.steam/root/ubuntu12_32/steam steam://${command}/${encoded@Q}"
      echo "Sent URL to steam: steam://${command}/${arg} (steam://${command}/${encoded})"
  else
      echo "Could not send steam URL steam://${command}/${arg} (steam://${command}/${encoded}) -- steam not running"
  fi
}

# From https://gist.github.com/HazCod/da9ec610c3d50ebff7dd5e7cac76de05
urlencode()
{
    [ -z "$1" ] || echo -n "$@" | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g'
}

do_mount()
{
    # Prior to talking to udisks, we need all udev hooks (we were started by one) to finish, so we know it has knowledge
    # of the drive.  Our own rule starts us as a service with --no-block, so we can wait for rules to settle here
    # safely.
    if ! udevadm settle; then
        echo "Failed to wait for \`udevadm settle\`"
        exit 1
    fi

    mount_point=/mnt/sdcard
    if [[ ! -d "${mount_point}" ]]; then
        mkdir -p "${mount_point}"
        /bin/mount "${DEVICE}" "${mount_point}"
        if [[ $? -ne 0 ]]; then
            echo "Error mounting ${DEVICE}"
            exit 1
        fi
    fi

    # Workaround for for Steam compression bug
    for d in "${mount_point}"/steamapps/{downloading,temp} ; do
        if ! btrfs subvolume show "$d" &>/dev/null; then
            mkdir -p "$d"
            rm -rf "$d"
            btrfs subvolume create "$d"
            chattr +C "$d"
            chown 1000:1000 "${d%/*}" "$d"
        fi
    done

    # backwards compatibility
    if [[ "${DEVBASE}" == 'mmcblk0p1' ]]; then
        mkdir -p /run/media
        ln -sfT "${mount_point}" /run/media/mmcblk0p1
    fi

    chown 1000:1000 -- "${mount_point}"

    echo "**** Mounted ${DEVICE} at ${mount_point} ****"

    # If Steam is running, notify it
    send_steam_url "addlibraryfolder" "${mount_point}"
}

do_unmount()
{
    # If Steam is running, notify it
    local mount_point=/mnt/sdcard
    send_steam_url "removelibraryfolder" "${mount_point}"
    # Remove symlink to the mount point that we're unmounting
    find /run/media -maxdepth 1 -xdev -type l -lname "${mount_point}" -exec rm -- {} \;
    if [[ -L /run/media/mmcblk0p1 && "$(realpath /run/media/mmcblk0p1)" == "$(realpath "${mount_point}")" ]]; then
        rm -f /run/media/mmcblk0p1
    fi
    if mountpoint -q "${mount_point}"/steamapps/compatdata; then
        /bin/umount -l -R "${mount_point}"/steamapps/compatdata
    fi
    /bin/umount "${mount_point}"
}

do_retrigger()
{
    local mount_point=/mnt/sdcard
    [[ -n $mount_point ]] || return 0

    # In retrigger mode, we want to wait a bit for steam as the common pattern is starting in parallel with a retrigger
    wait_steam 10
    # This is a truly gnarly way to ensure steam is ready for commands.
    # TODO literally anything else
    sleep 6
    send_steam_url "addlibraryfolder" "${mount_point}"
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_unmount
        ;;
    retrigger)
        do_retrigger
        ;;
    *)
        usage
        ;;
esac
