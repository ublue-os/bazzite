#!/bin/sh

if systemctl --quiet is-active var-home-linuxbrew.mount; then
    HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_AUTO_UPDATE
fi
