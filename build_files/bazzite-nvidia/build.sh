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

# Append the NVIDIA category on top of the selected desktop or Deck base.
printf '\n' >> /usr/share/bazzite-portal/tools.yml
cat /ctx/portal-tools/tools-nvidia.yml >> /usr/share/bazzite-portal/tools.yml

/ctx/bazzite-nvidia/01-remove-nvidia-conflicts.sh
/ctx/bazzite-nvidia/02-install-nvidia-driver.sh
/ctx/bazzite-nvidia/03-finalize.sh
