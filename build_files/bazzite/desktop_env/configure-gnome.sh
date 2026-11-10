#!/usr/bin/env bash
#
# Apply GNOME-specific modifications for Bazzite.
#
# Configure GNOME desktop environment: install packages, remove
# unnecessary ones, build extensions, and enable services.
#
set -xeuo pipefail

# -- Install GNOME packages --
# Install GNOME desktop packages including extensions, themes, and tools.
echo "==> Installing GNOME packages..."
dnf5 -y install \
    nautilus-gsconnect \
    steamdeck-backgrounds \
    steamdeck-gnome-presets \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-gsconnect \
    gnome-search-yafti \
    rom-properties-gtk4 \
    ibus-mozc \
    openssh-askpass \
    firewall-config

# -- Remove unnecessary GNOME packages --
# Remove GNOME packages not needed for the target desktop experience.
echo "==> Removing unnecessary GNOME packages..."
dnf5 -y remove \
    gnome-software \
    gnome-classic-session \
    gnome-tour \
    gnome-extensions-app \
    gnome-system-monitor \
    gnome-initial-setup \
    gnome-shell-extension-background-logo \
    gnome-shell-extension-apps-menu \
    gnome-shell-extension-launch-new-instance \
    gnome-shell-extension-places-menu \
    gnome-shell-extension-window-list

# -- Build and install GNOME extensions --
# Build and install custom GNOME shell extensions from source.
echo "==> Building GNOME extensions..."
/ctx/bazzite/desktop_env/build-gnome-extensions.sh

# -- Hook pam_oo7 into the passwd PAM stack --
# passwd only hooks pam_gnome_keyring, so a password change never
# re-encrypts the oo7 keyring. Add the gdm-password pam_oo7 line.
echo "==> Hooking pam_oo7 into the passwd PAM stack..."
if [[ -f /etc/pam.d/passwd ]] && ! grep -q "pam_oo7" /etc/pam.d/passwd; then
    sed -i \
        '/pam_gnome_keyring.so use_authtok$/a -password   optional\tpam_oo7.so use_authtok' \
        /etc/pam.d/passwd
fi
grep -q "pam_oo7" /etc/pam.d/passwd || { echo "ERROR: pam_oo7 not hooked into /etc/pam.d/passwd"; exit 1; }

# -- Enable dconf-update service --
# Enable the dconf-update service for configuration persistence.
echo "==> Enabling dconf-update service..."
systemctl enable dconf-update.service
