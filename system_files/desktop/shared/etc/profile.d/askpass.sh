#!/usr/bin/env bash
if grep -qv "gnome" <<< $(cat /etc/default/bazzite); then
  SUDO_ASKPASS='/usr/bin/ksshaskpass'
else
  SUDO_ASKPASS='/usr/libexec/openssh/gnome-ssh-askpass'
fi
export SUDO_ASKPASS
