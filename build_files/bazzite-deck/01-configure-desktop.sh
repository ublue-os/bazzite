#!/usr/bin/env bash
#
# Configure display manager and desktop environment for Bazzite Deck.
#
# Installs sddm, removes conflicting packages, applies KDE or GNOME
# presets based on the base image, and enables sddm as the default.
#
set -xeuo pipefail

echo "::group::Configure desktop environments (Deck)"
trap 'echo "::endgroup::"' EXIT

# -- Install sddm display manager --
# Replace the default display manager with sddm for Bazzite.
echo "==> Installing sddm display manager..."
dnf5 -y install sddm

# -- Remove conflicting packages --
# Remove packages that conflict with the Bazzite desktop experience.
echo "==> Removing conflicting packages..."
dnf5 -y remove \
    jupiter-sd-mounting-btrfs \
    ds-inhibit \
    plasma-login-manager

# -- Configure KDE or GNOME presets --
# Apply image-specific desktop presets: KDE on Kinoite, GNOME defaults otherwise.
echo "==> Configuring desktop presets..."
if [[ "${BASE_IMAGE_NAME}" == "kinoite" ]]; then
    dnf5 -y remove steamdeck-kde-presets-desktop
    # Temporarily replace KWin 6.8.1's conflicting rules with the Deck presets.
    (
        presets_dir=$(mktemp -d)
        trap 'rm -f "${presets_dir}"/*.rpm; rmdir "${presets_dir}"' EXIT
        dnf5 download --destdir="${presets_dir}" steamdeck-kde-presets
        rpm -Uvh --replacefiles "${presets_dir}"/steamdeck-kde-presets-*.noarch.rpm
    )
else
    ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default.jxl
    ln -sf /usr/share/wallpapers/convergence.jxl /usr/share/backgrounds/default-dark.jxl
    rm -f /usr/share/backgrounds/default.xml
    dnf5 -y remove malcontent-control
fi

# -- Disable GDM on Silverblue --
# GDM conflicts with sddm; disable it on Silverbase-derived images.
echo "==> Disabling GDM on Silverblue..."
if [[ "${BASE_IMAGE_NAME}" == "silverblue" ]]; then
    systemctl disable gdm.service
fi

# -- Enable sddm --
# Activate sddm as the default display manager.
echo "==> Enabling sddm..."
systemctl enable sddm.service
