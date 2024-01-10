#!/usr/bin/bash

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)

if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
  SUDO_ASKPASS='/usr/bin/ksshaskpass'
elif [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
  SUDO_ASKPASS='/usr/libexec/openssh/gnome-ssh-askpass'
fi
export SUDO_ASKPASS
