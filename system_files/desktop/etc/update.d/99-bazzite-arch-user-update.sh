#!/usr/bin/bash

if [[ $(distrobox list | grep bazzite-arch) ]]; then
	/usr/bin/distrobox-enter -n bazzite-arch -- '  paru -Syu --noconfirm'
else
	echo "Update skipped: bazzite-arch not installed"
fi
