#!/usr/bin/bash

source /usr/lib/ublue/setup-services/libsetup.sh

version-script vscode-extensions-dx user 1 || exit 1

set -x

# Setup VSCode
if test ! -e "$HOME"/.config/Code/User/settings.json; then
	mkdir -p "$HOME"/.config/Code/User
	cp -f /etc/skel/.config/Code/User/settings.json "$HOME"/.config/Code/User/settings.json
fi

code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-azuretools.vscode-containers
