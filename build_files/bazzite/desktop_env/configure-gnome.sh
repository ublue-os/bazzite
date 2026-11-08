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
# oo7 replaced gnome-keyring on GNOME images, but /etc/pam.d/passwd
# (owned by shadow-utils) only hooks pam_gnome_keyring, so changing
# the account password with passwd never re-encrypts the oo7 login
# keyring and it stays locked at the next login. Add the same
# pam_oo7 line the gdm-password stack already uses, right after the
# pam_gnome_keyring line. Skip if upstream already ships it.
echo "==> Hooking pam_oo7 into the passwd PAM stack..."
if [[ -f /etc/pam.d/passwd ]] && ! grep -q "pam_oo7" /etc/pam.d/passwd; then
    sed -i \
        '/pam_gnome_keyring.so use_authtok$/a -password   optional\tpam_oo7.so use_authtok' \
        /etc/pam.d/passwd
fi

# -- Enable dconf-update service --
# Enable the dconf-update service for configuration persistence.
echo "==> Enabling dconf-update service..."
systemctl enable dconf-update.service
