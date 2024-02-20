#!/bin/bash
# This file runs during sleep/resume events. It will read the list of modules
# in /etc/device-quirks/systemd-suspend-mods.conf and rmmod them on suspend,
# insmod them on resume.
# Originally created by ChimeraOS

MOD_LIST=$(grep -v ^\# /etc/device-quirks/systemd-suspend-mods.conf)

case $1 in
    pre)
        for mod in $MOD_LIST; do
            modprobe -r $mod
        done
    ;;
    post)
        for mod in $MOD_LIST; do
            modprobe $mod
        done
    ;;
esac
