#!/usr/bin/env bash
source /etc/default/bazzite
if [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
  SUDO_ASKPASS='/usr/bin/ksshaskpass'
elif [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
  SUDO_ASKPASS='/usr/libexec/openssh/gnome-ssh-askpass'
fi
export SUDO_ASKPASS
