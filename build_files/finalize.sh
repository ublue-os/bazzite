#!/usr/bin/env bash
#
# Finalize the system image: clean caches, relocate accounts, and remove
# stale lock files to produce a minimal, portable root filesystem.
#
set -xeuo pipefail

echo "::group::Finalize image"
trap 'echo "::endgroup::"' EXIT

# Tell DNF5 not to keep downloaded package cache after installation.
dnf5 config-manager setopt keepcache=0

# -- Restore DNF fallback after all package transactions --
echo "==> Restoring DNF fallback..."
dnf5 config-manager unsetopt '*terra*.skip_if_unavailable'
dnf5 config-manager setopt skip_if_unavailable=1

# -- Disable rpm-ostree stage --
echo "==> Disabling rpm-ostree stage..."
sed -i \
    's/stage/none/g' \
    /etc/rpm-ostreed.conf

# -- Disable repositories --
echo "==> Disabling repositories..."
dnf5 config-manager disable \
    tailscale-stable \
    copr:copr.fedorainfracloud.org:ublue-os:akmods \
    'fedora-multimedia*' \
    fedora-cisco-openh264 \
    terra \
    terra-extras \
    terra-mesa \
    terra-source

# -- Disable Copr repositories --
echo "==> Disabling Copr repositories..."
for copr in \
    ublue-os/bazzite \
    ublue-os/bazzite-multilib \
    ublue-os/staging \
    ublue-os/packages \
    ycollet/audinux \
    che/nerd-fonts; do
    dnf5 -y copr disable "${copr}"
done

# Move user/group entries from /etc to /usr/lib so they persist across
# chroots and container mounts.
relocate_accounts() {
    local etc="$1" lib="$2" shadow="$3" keep="$4" reset="$5"
    local out line name

    [ -f "$etc" ] || return 0
    out=$(grep -vE -- "${keep}" "${etc}") || true
    [ -n "$out" ] || return 0

    echo
    echo "Moving the following entries from ${etc} to ${lib}"
    echo "${out}"

    { cat "${lib}" 2>/dev/null || true; echo "${out}"; } > "${lib}.new"
    mv -f "${lib}.new" "${lib}"

    # Fail the build rather than ship an image where these went missing.
    while IFS= read -r line; do
        if ! grep -qxF -- "${line}" "${lib}"; then
            echo "ERROR: '${line}' did not persist in ${lib}" >&2
            return 1
        fi
    done <<< "${out}"

    printf '%s\n' "${reset}" > "${etc}"

    if [ -f "${shadow}" ]; then
        while IFS= read -r line; do
            name="${line%%:*}"
            sed -i "/^${name}:/d" "${shadow}"
        done <<< "${out}"
    fi
}

relocate_accounts /etc/passwd /usr/lib/passwd /etc/shadow \
    'root' 'root:x:0:0:root:/root:/bin/bash'
relocate_accounts /etc/group /usr/lib/group /etc/gshadow \
    'root|wheel' 'root:x:0:
wheel:x:10:'

# Delete any remaining unnecessary files.
rm -rf \
    /etc/.pwd.lock \
    /etc/passwd- \
    /etc/group- \
    /etc/shadow- \
    /etc/gshadow- \
    /etc/subuid- \
    /etc/subgid-

# Chunkah
# See: https://github.com/coreos/chunkah#customizing-the-layers
assign_chunk() {
    local component="$1" interval="$2" path
    shift 2
    for path in "$@"; do
        if [[ -e "${path}" && ! -L "${path}" ]]; then
            setfattr -n user.component -v "${component}" "${path}"
            setfattr -n user.update-interval -v "${interval}" "${path}"
        fi
    done
}
export -f assign_chunk

assign_chunk rpm-ostree-tmpfiles.d quarterly /usr/lib/rpm-ostree/tmpfiles.d

assign_chunk ublue-os quarterly \
    /usr/share/ublue-os \
    /usr/bin/ujust-picker \
    /etc/distrobox/{docker,incus}.ini \
    /usr/share/bash-prexec

assign_chunk ublue-os-config yearly \
    /etc/flatpak/remotes.d/flathub.flatpakrepo \
    /usr/lib/dracut/dracut.conf.d/10-compression.conf \
    /usr/lib/systemd/system/bootc-update-ca-trust.service \
    /usr/lib/systemd/system/bootc-update-crypto-policies.service \
    /usr/lib/systemd/system/flatpak-add-fedora-repos.service \
    /usr/lib/systemd/system-generators/coreos-sulogin-force-generator \
    /usr/lib/tmpfiles.d/coredump.conf \
    /usr/share/dnf/plugins/copr.vendor.conf

assign_chunk bazzite-just quarterly /usr/share/ublue-os/just
assign_chunk bazzite-yafti quarterly /usr/share/yafti
assign_chunk bazzite-bazaar quarterly /usr/share/ublue-os/bazaar

for GNOME_EXTENSION in /usr/share/gnome-shell/extensions/*; do
    if [[ -d "${GNOME_EXTENSION}" ]]; then
        assign_chunk "gnome-extension-${GNOME_EXTENSION##*/}" weekly "${GNOME_EXTENSION}"
    fi
done

assign_chunk bazzite-wallpapers quarterly \
    /usr/share/wallpapers \
    /usr/share/backgrounds \
    /usr/share/gnome-background-properties

assign_chunk bazzite-assets yearly \
    /etc/favicon.png \
    /usr/share/pixmaps/faces \
    /usr/share/pixmaps/bootloader \
    /usr/share/pixmaps/fedora* \
    /usr/share/pixmaps/system-logo-white.png \
    /usr/share/plasma/avatars \
    /usr/share/plymouth/themes/spinner/watermark.png \
    /usr/share/ublue-os/bazaar/*.jxl \
    /usr/share/ublue-os/bazzite/*.webm \
    /usr/share/applications/Waydroid

for AUDIO_PROFILES in /usr/share/{pipewire,wireplumber}/hardware-profiles; do
    if [[ -d "${AUDIO_PROFILES}" ]]; then
        assign_chunk bazzite-audio-config quarterly "${AUDIO_PROFILES}"
        # Impulse responses are large and rarely change alongside profile tuning.
        find "${AUDIO_PROFILES}" -type f -name '*.wav' \
            -exec bash -euc 'assign_chunk bazzite-audio-config quarterly "$@"' -- {} +
    fi
done

find /usr/share/icons/hicolor -type f \
    \( -name 'bazzite-logo*' -o -name 'distributor-logo*' -o -name 'framework.svg' \) \
    -exec bash -euc 'assign_chunk bazzite-icons yearly "$@"' -- {} +

assign_chunk bazzite-color-profiles yearly \
    /usr/share/color/icc/colord/framework{13,16}.icc \
    /usr/share/color/icc/colord/{Legion_GO_BT1886,Steam_Deck,Steam_Deck_Matte}.icc

assign_chunk fontconfig-cache daily /usr/lib/fontconfig/cache
assign_chunk jupiter-dock-updater quarterly /usr/libexec/jupiter-dock-updater
assign_chunk ublue-docs quarterly /usr/share/ublue-os/docs

assign_chunk extest quarterly /usr/{lib,lib64}/extest/libextest.so
assign_chunk winetricks yearly /usr/bin/winetricks

assign_chunk steam-bootstrap yearly /usr/share/gamescope-session-plus/bootstrap_steam.tar.gz

assign_chunk bazzite-init monthly \
    /usr/libexec/bazzite-* \
    /usr/libexec/hwsupport \
    /usr/share/bazzite-cli \
    /usr/bin/bazzite-* \
    /usr/bin/cec-control \
    /usr/bin/startplasma-steamos-oneshot \
    /usr/lib/systemd/system/bazzite-{flatpak-manager,hardware-setup,iwd-migration,libvirtd-setup}.service \
    /usr/lib/systemd/user/bazzite-{dynamic-fixes,user-setup}.service \
    /usr/share/polkit-1/actions/org.bazzite.privileged.user.setup.policy \
    /usr/share/polkit-1/rules.d/20-privileged-ruser.rules

assign_chunk bazzite-system-config quarterly \
    /etc/environment \
    /etc/greenboot/greenboot.conf \
    /etc/security/limits.d/memlock.conf \
    /etc/security/rules.d/15-proton-nice.conf \
    /etc/systemd/system.conf.d/timeout.conf \
    /etc/systemd/user.conf.d/timeout.conf \
    /etc/systemd/zram-generator.conf \
    /usr/lib/bootc/install/20-bazzite.toml \
    /usr/lib/sysctl.d/{60-kernel,65-memory,70-gaming,75-networking,80-inotify}.conf \
    /usr/lib/systemd/journald.conf.d/00-journal-{persistent,size}.conf \
    /usr/lib/systemd/system/mcelog.service.d/override.conf \
    /usr/lib/sysusers.d/00-plugdev.conf \
    /usr/lib/tmpfiles.d/dmi-product-serial.conf

assign_chunk bazzite-hardware-config monthly \
    /etc/default/cec-control \
    /etc/inputplumber/capability_maps.d/acer*.yaml \
    /etc/inputplumber/devices.d/{60-cec,70-acer_atlas8}.yaml \
    /etc/modprobe.d/{deck-blacklist,default-disable-broadcom-wl}.conf \
    /etc/modules-load.d/hid-steaminput-preload.conf \
    /usr/lib/modprobe.d/{fw-charge-control,mt7921,new-lg4ff}.conf \
    /usr/lib/modules-load.d/wine-ntsync.conf \
    /usr/lib/systemd/system/cec-{onboot,onpoweroff,onsleep}.service \
    /usr/lib/systemd/system/kmod-sleep-workaround@.service \
    /usr/lib/udev/hwdb.d/60-keyboard.hwdb \
    /usr/lib/udev/rules.d/{30-steamdeck,40-backlights,50-ally-fingerprint,50-ally-x-controller}.rules \
    /usr/lib/udev/rules.d/{50-gpd-win-4-fingerprint,50-gpd-wm2-fingerprint}.rules \
    /usr/lib/udev/rules.d/{60-schedulers,70-steam-jupiter-leds,80-gpu-reset,90-dolphin-motion}.rules \
    /usr/lib/udev/rules.d/{99-cec-bluetooth,99-powertargets,99-steamcontroller-wakeup}.rules

assign_chunk bazzite-desktop-config quarterly \
    /etc/dconf/db/distro.d/*bazzite* \
    /etc/dconf/db/distro.d/locks/*bazzite* \
    /etc/polkit-1/rules.d/50-efibootmgr.rules \
    /etc/skel/.config/gnome-initial-setup-done \
    /etc/skel/.config/gtk-4.0/{gtk,kde_window_geometry}.css \
    /etc/skel/.config/kcminputrc \
    /etc/skel/.config/autostart/bazzite-portal.desktop \
    /etc/skel/.local/share/org.gnome.Ptyxis/palettes/{vapor,vgui2}.palette \
    /etc/skel/.var/app/com.ranfdev.DistroShelf/config/glib-2.0/settings/keyfile \
    /etc/xdg/QtProject/qtlogging.ini \
    /etc/xdg/autostart/bazzite-announcement.desktop \
    /etc/xdg/kcm-about-distrorc \
    /etc/xdg/{mimeapps,mineapps}.list \
    /etc/xdg/weston/weston.ini \
    /usr/lib/plasmalogin/defaults.conf \
    /usr/lib/systemd/system/dconf-update.service \
    /usr/share/applications/{bazzite-documentation,discourse,gnome-ssh-askpass}.desktop \
    /usr/share/glib-2.0/schemas/zz0-*.gschema.override \
    /usr/share/kde-settings/kde-profile/default/xdg/{kicker-extra-favoritesrc,krunnerrc} \
    /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/bazzite-pins.js \
    /usr/share/templates/{MangoHud,dxvk,vkBasalt}.desktop

assign_chunk bazzite-desktop-helpers monthly \
    /usr/bin/{custom-resolution-helper,distroshelf-helper,kde-ptyxis,missioncenter-helper,warehouse-helper} \
    /usr/bin/dconf-override-converter \
    /usr/bin/switcherooctl \
    /usr/libexec/sunshine-{start,stop}-vmon

assign_chunk bazzite-shell-config quarterly \
    /etc/profile.d/{askpass,bazzite-neofetch,open,verify_motd}.sh \
    /usr/libexec/ublue-motd \
    /usr/share/fish/functions/fish_{greeting,prompt}.fish \
    /usr/share/fish/vendor_conf.d/bazzite-neofetch.fish

assign_chunk bazzite-package-management monthly \
    /etc/distrobox/distrobox.ini \
    /etc/dnf/dnf.conf \
    /etc/profile.d/dnf-dummy.sh \
    /etc/uupd/config.json \
    /usr/bin/{bbrew-helper,bruh,copr,dnf} \
    /usr/libexec/uupd-update \
    /usr/libexec/ogc/os-update \
    /usr/libexec/os-branch-select \
    /usr/share/applications/bbrew.desktop

assign_chunk bazzite-gaming-helpers monthly \
    /usr/bin/{gameclass,mesa-git,protontricks,protontricks-launch,sd0,steam-tweaks}

assign_chunk bazzite-gaming-config quarterly \
    /etc/default/steamos-{btrfs,nested-desktop} \
    /etc/skel/.config/user-tmpfiles.d/discord-rpc.conf \
    /usr/lib/systemd/user/steam-icons-cleanup.service \
    /usr/share/applications/bazzite-steam-bpm.desktop

assign_chunk bazzite-gamescope-session monthly \
    /etc/dbus-1/system.d/org.opengamingcollective.cardwire.bazzite.conf \
    /etc/default/steam-hardware-control \
    /etc/sddm.conf.d/virtualkbd.conf \
    /etc/systemd/logind.conf.d/deck.conf \
    /etc/xdg/autostart/bazzite-desktop-bootstrap.desktop \
    /usr/bin/{return-to-gamemode,steamos-logger} \
    /usr/lib/sddm/sddm.conf.d/holo.conf \
    /usr/lib/systemd/logind.conf.d/killuserprocesses.conf \
    /usr/lib/systemd/system/{ac,battery}.target \
    /usr/lib/systemd/system/bazzite-autologin.service \
    /usr/lib/systemd/system/steam-web-debug-portforward.{service,socket} \
    /usr/lib/systemd/user/bazzite-native-steam-input.service \
    /usr/libexec/os-session-select \
    /usr/share/applications/gamescope.desktop \
    /usr/share/gamescope/scripts/00-gamescope/displays/gpd.win4.lcd.lua \
    /usr/share/polkit-1/actions/org.bazzite.policykit.gamescope-session.policy \
    /usr/share/polkit-1/rules.d/{10-gamescope-session,bazzite-autologin}.rules

assign_chunk bazzite-audio-config quarterly \
    /usr/lib/systemd/system/{pipewire,wireplumber}-workaround.service \
    /usr/lib/tmpfiles.d/wireplumber-workaround.conf \
    /usr/share/alsa/ucm2/codecs/tas2783/init.conf \
    /usr/share/alsa/ucm2/sof-soundwire/tas2783.conf \
    /usr/share/alsa/ucm2/USB-Audio/Sony/DualSense-PS5.conf \
    /usr/share/wireplumber/wireplumber.conf.d/{alsa-card0,alsa-card1,alsa-ps-controller,bluez}.conf

assign_chunk bazzite-power-config quarterly \
    /etc/scx_loader/config.toml \
    /usr/lib/tuned/profiles/{balanced,balanced-battery,powersave,powersave-battery,throughput-performance}-bazzite

assign_chunk bazzite-network-config quarterly \
    /etc/NetworkManager/conf.d/99-valve-wifi-backend.conf \
    /etc/bluetooth/main.conf \
    /etc/geoclue/conf.d/99-beacondb.conf \
    /usr/lib/systemd/system/force-wol.service \
    /usr/lib/udev/rules.d/{50-intel-ax200-ax210-disable-d3cold-state,50-wifi-sleep}.rules \
    /usr/libexec/force-wol

assign_chunk bazzite-storage monthly \
    /etc/systemd/system/beesd@.service.d/override.conf \
    /usr/bin/boot-windows \
    /usr/lib/systemd/system/beesd@.timer \
    /usr/lib/systemd/system/fstrim.service.d/workaround-no-root-trim.conf \
    /usr/lib/systemd/user/ntfs-nag.service \
    /usr/libexec/ntfs-exfat-monitor-script

assign_chunk bazzite-waydroid monthly \
    /etc/default/waydroid-launcher \
    /usr/bin/waydroid-launcher \
    /usr/libexec/waydroid-container-{restart,start,stop} \
    /usr/libexec/waydroid-fix-controllers \
    /usr/share/applications/waydroid-container-restart.desktop \
    /usr/share/polkit-1/actions/org.bazzite.waydroid.policy \
    /usr/share/polkit-1/rules.d/30-waydroid.rules

assign_chunk bazzite-virtualization-config quarterly \
    /etc/skel/.var/app/org.virt_manager.virt-manager/config/glib-2.0/settings/keyfile \
    /usr/lib/dracut/dracut.conf.d/80-vfio.conf \
    /usr/lib/systemd/system/{cockpit,incus-workaround}.service \
    /usr/lib/systemd/system/dev-hugepages1G.mount \
    /usr/lib/tmpfiles.d/{bazzite-libvirt,incus-workaround}.conf \
    /usr/share/containers/systemd/cockpit-container.container

assign_chunk bazzite-nvidia monthly \
    /usr/bin/dlss-swapper{,-dll} \
    /usr/lib/modprobe.d/nvidia-{deck,power}.conf \
    /usr/lib/systemd/system/ublue-nvctk-cdi.service \
    /usr/lib/systemd/system/ublue-nvidia-flatpak-runtime-{sync,verify}.service \
    /usr/lib/udev/rules.d/80-nvidia-pm.rules \
    /usr/libexec/ublue-nvidia-flatpak-runtime-{notify,sync} \
    /usr/share/selinux/packages/nvidia-container.pp

# Catch files changed since the last stage's reset (initramfs, image-info, overrides).
/ctx/reset-mtimes.sh
