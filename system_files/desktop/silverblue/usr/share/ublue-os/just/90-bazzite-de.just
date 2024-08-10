# vim: set ft=make :

# Restore Bazzite customized DE settings
restore-gnome-de-settings:
    dconf load / < /etc/dconf/db/local.d/02-bazzite-global
    dconf load / < /etc/dconf/db/local.d/03-bazzite-dash
    dconf load / < /etc/dconf/db/local.d/05-bazzite-extensions
    dconf load / < /etc/dconf/db/local.d/06-bazzite-theme

# Restore Bazzite customized applications folders
restore-gnome-folders:
    dconf load / < /etc/dconf/db/local.d/04-bazzite-folders

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
