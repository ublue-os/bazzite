#!/usr/bin/env bash
#
# Orchestration script for the Nvidia build of Bazzite.
#
set -xeuo pipefail

echo "--- Starting nvidia build ---"

cp --archive --verbose --force \
    /tmp/system_files/nvidia/shared/* \
    /tmp/system_files/nvidia/"$BASE_IMAGE_NAME"/* \
    /

/ctx/bazzite-nvidia/01-remove-nvidia-conflicts.sh
/ctx/bazzite-nvidia/02-install-nvidia-driver.sh
/ctx/bazzite-nvidia/03-finalize.sh
