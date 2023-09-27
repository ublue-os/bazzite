#!/usr/bin/bash

if [[ $(podman ps -a --no-trunc --format {{.Names}} | grep -E '(^|\s)bazzite-arch($|\s)') ]]; then
	/usr/bin/distrobox-enter -n bazzite-arch -- '  paru -Sua --noconfirm'
else
	echo "Update skipped: bazzite-arch not installed"
fi
