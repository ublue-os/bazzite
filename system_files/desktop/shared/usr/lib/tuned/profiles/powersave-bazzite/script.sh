#!/bin/bash

. /usr/lib/tuned/functions

start() {
    [ "$USB_AUTOSUSPEND" = 1 ] && enable_usb_autosuspend
    [ "$(/usr/bin/systemctl is-enabled scx_loader.service)" = "enabled" ] && /usr/bin/scxctl switch -m powersave
    enable_wifi_powersave
    return 0
}

stop() {
    [ "$USB_AUTOSUSPEND" = 1 ] && disable_usb_autosuspend
    disable_wifi_powersave
    return 0
}

process $@
