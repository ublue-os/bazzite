#!/bin/bash

. /usr/lib/tuned/functions

start() {
    [ "$(/usr/bin/systemctl is-enabled scx_loader.service)" = "enabled" ] && /usr/bin/scxctl switch -m gaming
    return 0
}

stop() {
    return 0
}

process $@
