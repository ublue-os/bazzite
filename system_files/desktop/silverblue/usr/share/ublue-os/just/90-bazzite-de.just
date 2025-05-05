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

# Change automatic power profile switching behavior
configure-auto-power-profile ACTION="help":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-auto-power-profile <option>"
      echo "  Use 'enable' to allow automatic power profile switching based on power state
      echo "  Use 'disable' to prevent automatic power profile switching based on power state
      exit 0
    elif [[ "${OPTION,,}" =~ enable ]]; then
      gnome-extensions enable auto-power-profile@dmy3k.github.io
    elif [[ "${OPTION,,}" =~ disable ]]; then
      gnome-extensions disable auto-power-profile@dmy3k.github.io
    fi
