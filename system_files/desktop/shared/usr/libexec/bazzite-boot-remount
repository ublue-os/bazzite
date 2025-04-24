#!/bin/bash
set -eo pipefail

# Boolean variable to track if /boot was initially mounted as read-only
# Ensure compatibility with rpm-ostree where /boot is rw but in bootc /boot is ro
boot_was_ro=false

# Remount /boot as read-only if it was mounted as read-only ealier
function remount_boot_ro {
    if $boot_was_ro; then
        mount -o remount,ro /boot || exit 13
    fi
    return
}

# Remount /boot as read-write if it was mounted as read-only
function remount_boot_rw {
    if grep -q " /boot .* ro," /proc/mounts; then
        mount -o remount,rw /boot || exit 13
        boot_was_ro=true
    fi
    return
}
