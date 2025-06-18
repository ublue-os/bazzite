# vim: set ft=make :

# Restore Bazzite customized DE settings
restore-gnome-de-settings:
    #!/bin/bash
    shopt -s nullglob
    for file in /usr/share/ublue-os/dconfs/desktop-silverblue/*; do
      echo "Loading dconf settings from: $file"
      dconf load / < "$file"
    done
    for file in /usr/share/ublue-os/dconfs/deck-silverblue/*; do
      echo "Loading dconf settings from: $file"
      dconf load / < "$file"
    done

# Restore Bazzite customized applications folders
restore-gnome-folders:
    dconf load / < /usr/share/ublue-os/dconfs/desktop-silverblue/zz0-02-bazzite-desktop-silverblue-folders
    dconf load / < /usr/share/ublue-os/dconfs/desktop-silverblue/01-bazzite-desktop-silverblue-folders
