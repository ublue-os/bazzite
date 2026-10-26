#!/usr/bin/env bash
#
# Orchestration script for the deck build of Bazzite.
#
set -xeuo pipefail

echo "--- Starting deck build ---"

cp --archive --verbose --force \
    /tmp/system_files/deck/shared/* \
    /tmp/system_files/deck/"$BASE_IMAGE_NAME"/* \
    /

/ctx/bazzite-deck/01-configure-desktop.sh
/ctx/bazzite-deck/02-install-patched-upower.sh
/ctx/bazzite-deck/03-install-packages.sh
/ctx/bazzite-deck/04-install-gamescope-session.sh
/ctx/bazzite-deck/05-finalize.sh
