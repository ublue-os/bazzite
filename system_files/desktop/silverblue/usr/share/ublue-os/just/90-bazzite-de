# vim: set ft=make :

# Restore Bazzite customized DE settings
restore-gnome-de-settings:
    dconf load / < /usr/etc/dconf/db/local.d/02-bazzite-global
    dconf load / < /usr/etc/dconf/db/local.d/03-bazzite-dash
    dconf load / < /usr/etc/dconf/db/local.d/05-bazzite-extensions
    dconf load / < /usr/etc/dconf/db/local.d/06-bazzite-theme

# Restore Bazzite customized applications folders
restore-gnome-folders:
    dconf load / < /usr/etc/dconf/db/local.d/04-bazzite-folders
