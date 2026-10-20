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
RPM_OSTREE_TMPFILES=/usr/lib/rpm-ostree/tmpfiles.d
setfattr -n user.component -v "rpm-ostree-tmpfiles.d" "${RPM_OSTREE_TMPFILES}"
setfattr -n user.update-interval -v "quarterly" "${RPM_OSTREE_TMPFILES}"

UBLUE_OS_FILES=/usr/share/ublue-os
setfattr -n user.component -v "ublue-os" "${UBLUE_OS_FILES}"
setfattr -n user.update-interval -v "quarterly" "${UBLUE_OS_FILES}"
setfattr -n user.component -v "ublue-os" "/usr/bin/ujust-picker"
setfattr -n user.update-interval -v "quarterly" "/usr/bin/ujust-picker"
setfattr -n user.component -v "ublue-os" "/etc/distrobox/docker.ini"
setfattr -n user.update-interval -v "quarterly" "/etc/distrobox/docker.ini"
setfattr -n user.component -v "ublue-os" "/etc/distrobox/incus.ini"
setfattr -n user.update-interval -v "quarterly" "/etc/distrobox/incus.ini"
setfattr -n user.component -v "ublue-os" "/usr/share/bash-prexec"
setfattr -n user.update-interval -v "quarterly" "/usr/share/bash-prexec"

BAZZITE_CONFIG=(/usr/libexec/bazzite-* /usr/libexec/hwsupport /usr/share/bazzite-cli)
setfattr -n user.component -v "bazzite-init" "${BAZZITE_CONFIG[@]}"
setfattr -n user.update-interval -v "monthly" "${BAZZITE_CONFIG[@]}"

for BAZZITE_HELPER in /usr/bin/bazzite-* /usr/bin/cec-control /usr/bin/startplasma-steamos-oneshot; do
    if [[ -f "${BAZZITE_HELPER}" ]]; then
        setfattr -n user.component -v "bazzite-init" "${BAZZITE_HELPER}"
        setfattr -n user.update-interval -v "monthly" "${BAZZITE_HELPER}"
    fi
done

BAZZITE_JUST=/usr/share/ublue-os/just
setfattr -n user.component -v "bazzite-just" "${BAZZITE_JUST}"
setfattr -n user.update-interval -v "quarterly" "${BAZZITE_JUST}"

BAZZITE_YAFTI=/usr/share/yafti
setfattr -n user.component -v "bazzite-yafti" "${BAZZITE_YAFTI}"
setfattr -n user.update-interval -v "quarterly" "${BAZZITE_YAFTI}"

BAZZITE_BAZAAR=/usr/share/ublue-os/bazaar
setfattr -n user.component -v "bazzite-bazaar" "${BAZZITE_BAZAAR}"
setfattr -n user.update-interval -v "quarterly" "${BAZZITE_BAZAAR}"

for GNOME_EXTENSION in /usr/share/gnome-shell/extensions/*; do
    if [[ -d "${GNOME_EXTENSION}" ]]; then
        setfattr -n user.component -v "gnome-extension-${GNOME_EXTENSION##*/}" "${GNOME_EXTENSION}"
        setfattr -n user.update-interval -v "weekly" "${GNOME_EXTENSION}"
    fi
done

for WALLPAPERS in /usr/share/wallpapers /usr/share/backgrounds /usr/share/gnome-background-properties; do
    if [[ -d "${WALLPAPERS}" ]]; then
        setfattr -n user.component -v "bazzite-wallpapers" "${WALLPAPERS}"
        setfattr -n user.update-interval -v "quarterly" "${WALLPAPERS}"
    fi
done

BAZZITE_ASSETS=(
    /etc/favicon.png
    /usr/share/pixmaps/faces
    /usr/share/pixmaps/bootloader
    /usr/share/pixmaps/fedora*
    /usr/share/pixmaps/system-logo-white.png
    /usr/share/plasma/avatars
    /usr/share/plymouth/themes/spinner/watermark.png
    /usr/share/ublue-os/bazaar/*.jxl
    /usr/share/ublue-os/bazzite/*.webm
)
setfattr -n user.component -v "bazzite-assets" "${BAZZITE_ASSETS[@]}"
setfattr -n user.update-interval -v "yearly" "${BAZZITE_ASSETS[@]}"
WAYDROID_ASSETS=/usr/share/applications/Waydroid
if [[ -d "${WAYDROID_ASSETS}" ]]; then
    setfattr -n user.component -v "bazzite-assets" "${WAYDROID_ASSETS}"
    setfattr -n user.update-interval -v "yearly" "${WAYDROID_ASSETS}"
fi

for AUDIO_PROFILES in /usr/share/{pipewire,wireplumber}/hardware-profiles; do
    if [[ -d "${AUDIO_PROFILES}" ]]; then
        setfattr -n user.component -v "bazzite-audio-config" "${AUDIO_PROFILES}"
        setfattr -n user.update-interval -v "quarterly" "${AUDIO_PROFILES}"
        # Impulse responses are large and rarely change alongside profile tuning.
        find "${AUDIO_PROFILES}" -type f -name '*.wav' \
            -exec setfattr -n user.component -v "bazzite-audio-config" {} + \
            -exec setfattr -n user.update-interval -v "quarterly" {} +
    fi
done

find /usr/share/icons/hicolor -type f \
    \( -name 'bazzite-logo*' -o -name 'distributor-logo*' -o -name 'framework.svg' \) \
    -exec setfattr -n user.component -v "bazzite-icons" {} + \
    -exec setfattr -n user.update-interval -v "yearly" {} +

FRAMEWORK_ICC=(/usr/share/color/icc/colord/framework{13,16}.icc)
setfattr -n user.component -v "bazzite-color-profiles" "${FRAMEWORK_ICC[@]}"
setfattr -n user.update-interval -v "yearly" "${FRAMEWORK_ICC[@]}"
for HANDHELD_ICC in /usr/share/color/icc/colord/{Legion_GO_BT1886,Steam_Deck,Steam_Deck_Matte}.icc; do
    if [[ -f "${HANDHELD_ICC}" ]]; then
        setfattr -n user.component -v "bazzite-color-profiles" "${HANDHELD_ICC}"
        setfattr -n user.update-interval -v "yearly" "${HANDHELD_ICC}"
    fi
done

FONTCONFIG_CACHE=/usr/lib/fontconfig/cache
setfattr -n user.component -v "fontconfig-cache" "${FONTCONFIG_CACHE}"
setfattr -n user.update-interval -v "daily" "${FONTCONFIG_CACHE}"

JUPITER_DOCK_UPDATER_FILES=/usr/libexec/jupiter-dock-updater
if [[ -d "${JUPITER_DOCK_UPDATER_FILES}" ]]; then
    setfattr -n user.component -v "jupiter-dock-updater" "${JUPITER_DOCK_UPDATER_FILES}"
    setfattr -n user.update-interval -v "quarterly" "${JUPITER_DOCK_UPDATER_FILES}"
fi

DOCS_FILES=/usr/share/ublue-os/docs
setfattr -n user.component -v "ublue-docs" "${DOCS_FILES}"
setfattr -n user.update-interval -v "quarterly" "${DOCS_FILES}"

setfattr -n user.component -v "extest" "/usr/lib/extest/libextest.so"
setfattr -n user.component -v "extest" "/usr/lib64/extest/libextest.so"
setfattr -n user.update-interval -v "quarterly" "/usr/lib/extest/libextest.so"
setfattr -n user.update-interval -v "quarterly" "/usr/lib64/extest/libextest.so"

setfattr -n user.component -v "winetricks" "/usr/bin/winetricks"
setfattr -n user.update-interval -v "yearly" "/usr/bin/winetricks"

STEAM_BOOTSTRAP=/usr/share/gamescope-session-plus/bootstrap_steam.tar.gz
if [[ -f "${STEAM_BOOTSTRAP}" ]]; then
    setfattr -n user.component -v "steam-bootstrap" "${STEAM_BOOTSTRAP}"
    setfattr -n user.update-interval -v "yearly" "${STEAM_BOOTSTRAP}"
fi

# Catch files changed since the last stage's reset (initramfs, image-info, overrides).
/ctx/reset-mtimes
