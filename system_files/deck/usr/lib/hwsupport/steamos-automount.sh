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

# Shared between this and the auto-mount script to ensure we're not double-triggering nor automounting while formatting
# or vice-versa.
MOUNT_LOCK="/var/run/jupiter-automount-${DEVBASE//\/_}.lock"

# Obtain lock
exec 9<>"$MOUNT_LOCK"
if ! flock -n 9; then
    echo "$MOUNT_LOCK is active: ignoring action $ACTION"
    # Do not return a success exit code: it could end up putting the service in 'started' state without doing the mount
    # work (further start commands will be ignored after that)
    exit 1
fi

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
    # Get info for this drive: $ID_FS_LABEL, and $ID_FS_TYPE
    dev_json=$(lsblk -o PATH,LABEL,FSTYPE --json -- "$DEVICE" | jq '.blockdevices[0]')
    ID_FS_LABEL=$(jq -r '.label | select(type == "string")' <<< "$dev_json")
    ID_FS_TYPE=$(jq -r '.fstype | select(type == "string")' <<< "$dev_json")

    UDISKS2_ALLOW='compress,compress-force,datacow,nodatacow,datasum,nodatasum,autodefrag,noautodefrag,degraded,device,discard,nodiscard,subvol,subvolid,space_cache'
    OPTS="rw,noatime,lazytime,compress-force=zstd,space_cache=v2,autodefrag,ssd_spread"
    FSTYPE="btrfs"
    # check for main subvol
    mount_point_tmp="${MOUNT_LOCK%.*}.tmp"
    mkdir -p "${mount_point_tmp}"
    if /bin/mount -t btrfs -o ro "${DEVICE}" "${mount_point_tmp}"; then
        if [[ -d "${mount_point_tmp}/@" ]] && \
            btrfs subvolume show "${mount_point_tmp}/@" &>/dev/null; then
            OPTS+=",subvol=@"
        fi
        /bin/umount -l "${mount_point_tmp}"
        rmdir "${mount_point_tmp}"
    fi

    # Prior to talking to udisks, we need all udev hooks (we were started by one) to finish, so we know it has knowledge
    # of the drive.  Our own rule starts us as a service with --no-block, so we can wait for rules to settle here
    # safely.
    if ! udevadm settle; then
      echo "Failed to wait for \`udevadm settle\`"
      exit 1
    fi

    # Ask udisks to auto-mount. This needs a version of udisks that supports the 'as-user' option.
    ret=0
    reply=$(busctl call --allow-interactive-authorization=false --expect-reply=true --json=short   \
                org.freedesktop.UDisks2                                                            \
                /org/freedesktop/UDisks2/block_devices/"${DEVBASE}"                                \
                org.freedesktop.UDisks2.Filesystem                                                 \
                Mount 'a{sv}' 4                                                                    \
                  as-user s deck                                                                   \
                  auth.no_user_interaction b true                                                  \
                  fstype                   s "btrfs"                                             \
                  options                  s "$OPTS") || ret=$?

    if [[ $ret -ne 0 ]]; then
        echo "Error mounting ${DEVICE} (status = $ret)"
        exit 1
    fi

    # Expected reply is of the format
    #  {"type":"s","data":["/run/media/deck/home"]}
    mount_point=$(jq -r '.data[0] | select(type == "string")' <<< "$reply" || true)
    if [[ -z $mount_point ]]; then
        echo "Error when mounting ${DEVICE}: udisks returned success but could not parse reply:"
        echo "---"$'\n'"$reply"$'\n'"---"
        exit 1
    fi

    # Create a symlink from /run/media to keep compatibility with apps
    # that use the older mount point (for SD cards only).
    case "${DEVBASE}" in
        mmcblk0p*)
            if [[ -z "${ID_FS_LABEL}" ]]; then
                old_mount_point="/run/media/${DEVBASE}"
            else
                old_mount_point="/run/media/${mount_point##*/}"
            fi
            if [[ ! -d "${old_mount_point}" ]]; then
                rm -f -- "${old_mount_point}"
                ln -s -- "${mount_point}" "${old_mount_point}"
            fi
            ;;
    esac

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
        rm -f /run/media/mmcblk0p1
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
    local mount_point=$(findmnt -fno TARGET "${DEVICE}" || true)
    if [[ -n $mount_point ]]; then
        send_steam_url "removelibraryfolder" "${mount_point}"
        # Remove symlink to the mount point that we're unmounting
        find /run/media -maxdepth 1 -xdev -type l -lname "${mount_point}" -exec rm -- {} \;
    else
        # If we don't know the mount point then remove all broken symlinks
        find /run/media -maxdepth 1 -xdev -xtype l -exec rm -- {} \;
    fi
    if [[ -L /run/media/mmcblk0p1 && "$(realpath /run/media/mmcblk0p1)" == "$(realpath "${mount_point}")" ]]; then
        rm -f /run/media/mmcblk0p1
    fi
    if mountpoint -q "${mount_point}"/steamapps/compatdata; then
        /bin/umount -l -R "${mount_point}"/steamapps/compatdata
    fi
    systemd-run --uid=1000 --pipe                                                          \
      busctl call --allow-interactive-authorization=false --expect-reply=true --json=short \
        org.freedesktop.UDisks2                                                            \
        /org/freedesktop/UDisks2/block_devices/"${DEVBASE}"                                \
        org.freedesktop.UDisks2.Filesystem                                                 \
        Unmount 'a{sv}' 2                                                                  \
          auth.no_user_interaction b true                                                  \
          force                    b true
}

do_retrigger()
{
    local mount_point=$(findmnt -fno TARGET "${DEVICE}" || true)
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
