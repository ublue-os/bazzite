#!/usr/bin/env bash

set -xeuo pipefail

echo "--- Starting core build ---"

/ctx/bazzite/01-copy-brew-files.sh

cp --archive --verbose --force \
    /tmp/system_files/desktop/shared/* \
    /tmp/system_files/desktop/"$BASE_IMAGE_NAME"/* \
    /

/ctx/bazzite/02-install-nonfree-firmware-blobs.sh
/ctx/bazzite/03-install-kernel-akmods.sh
/ctx/bazzite/04-initialize.sh
/ctx/bazzite/05-valve-patches.sh
/ctx/bazzite/06-global-remove.sh
/ctx/bazzite/07-install-packages.sh
/ctx/bazzite/08-install-steam-lutris.sh
/ctx/bazzite/09-install-ujust-picker.sh
/ctx/bazzite/10-configure-desktops.sh
/ctx/bazzite/11-ublue-os-media-automount-udev.sh
/ctx/bazzite/12-finalize.sh

cp --archive --verbose --force \
    /tmp/system_files/overrides/* \
    /
