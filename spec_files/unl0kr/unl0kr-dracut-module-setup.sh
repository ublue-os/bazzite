#!/usr/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later

check() {
    require_binaries unl0kr udevadm || return 1

    return 255
}

depends() {
    return 0
}

install() {
    inst_multiple -o \
         $systemdsystemunitdir/unl0kr-ask-password.path \
         $systemdsystemunitdir/unl0kr-ask-password.service \
         $systemdsystemunitdir/sysinit.target.wants/unl0kr-ask-password.path \
         /lib/systemd/systemd-reply-password \
         /etc/unl0kr.conf \
         /etc/unl0kr.conf.d/* \
         /lib/udev/rules.d/* \
         /etc/udev/rules.d/* \
         /etc/libinput/* \
         /etc/xkb/* \
         /bin/unl0kr \
         /bin/udevadm \
         /bin/grep \
         cut

    for file in $(find /usr/share/libinput* -name '*.quirks'; find /usr/share/X11/xkb); do
      inst "$file"
    done

    inst_simple "$moddir/unl0kr-ask-password.sh" /usr/bin/unl0kr-ask-password

    # Enable the systemd service unit for unl0kr-ask-password.
    $SYSTEMCTL -q --root "$initdir" add-wants unl0kr-ask-password.service systemd-vconsole-setup.service

    # Disable conflicting services
    $SYSTEMCTL -q --root "$initdir" mask systemd-ask-password-console.service || :
    $SYSTEMCTL -q --root "$initdir" mask systemd-ask-password-plymouth.service || :
    $SYSTEMCTL -q --root "$initdir" mask systemd-ask-password-console.path || :
    $SYSTEMCTL -q --root "$initdir" mask systemd-ask-password-plymouth.path || :
}
