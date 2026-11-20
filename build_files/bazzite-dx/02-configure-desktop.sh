#!/usr/bin/env bash
set -xeuo pipefail

echo "::group::Configure desktop environments (DX)"
trap 'echo "::endgroup::"' EXIT

sed -i 's@^NoDisplay=true@NoDisplay=false@' /usr/share/applications/input-remapper-gtk.desktop
systemctl enable input-remapper.service
systemctl enable uupd.timer
systemctl mask powerstation.service
systemctl enable tuned.service tuned-ppd.service

systemctl disable sddm.service bazzite-autologin.service
rm -f \
    /etc/sddm.conf.d/steamos.conf \
    /etc/sddm.conf.d/virtualkbd.conf \
    /etc/sddm.conf.d/zz-steamos-autologin.conf
# DX keeps the sessions but does not need the Deck first-boot Steam archive.
rm -f /usr/share/gamescope-session-plus/bootstrap_steam.tar.zst
dnf5 remove -y sddm steamos-manager-powerstation
dnf5 install --enable-repo="copr:copr.fedorainfracloud.org:ublue-os:bazzite" -y ds-inhibit
systemctl enable ds-inhibit.service

if [[ "${BASE_IMAGE_NAME}" == "silverblue" ]]; then
    systemctl enable gdm.service
else
    dnf5 install -y plasma-login-manager
    systemctl enable plasmalogin.service
    sed -i -E \
        -e 's/^(action\/switch_user)=false/\1=true/' \
        -e 's/^(action\/start_new_session)=false/\1=true/' \
        -e 's/^(action\/lock_screen)=false/\1=true/' \
        -e 's/^(kcm_sddm\.desktop)=false/\1=true/' \
        -e 's/^(kcm_plymouth\.desktop)=false/\1=true/' \
        /etc/xdg/kdeglobals

    variant="Developer Experience"
    if [[ "${BUILD_NVIDIA}" == "TRUE" ]]; then
        variant+=" (NVIDIA)"
    fi
    sed -i \
        -e 's|^Website=.*|Website=https://dev.bazzite.gg|' \
        -e "s|^Variant=.*|Variant=${variant}|" \
        /etc/xdg/kcm-about-distrorc
fi
