# vim: set ft=make :

# Restore Bazzite customized DE settings
restore-gnome-de-settings:
    #!/usr/bin/bash
    for file in /usr/share/ublue-os/dconfs/desktop-silverblue/*; do
      echo "Loading dconf settings from: ${file}"
      dconf load -f / < "${file}"
    done
    echo You may need to log out and log in again for the changes to take effect.

# Restore Bazzite customized applications folders
restore-gnome-folders:
    dconf load / < /usr/share/ublue-os/dconfs/desktop-silverblue/zz0-02-bazzite-desktop-silverblue-folders
    dconf load / < /usr/share/ublue-os/dconfs/desktop-silverblue/01-bazzite-desktop-silverblue-folders
