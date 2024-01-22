# vim: set ft=make :

# Enable Supergfxctl, a GPU switcher for hybrid laptops
enable-supergfxctl:
    systemctl enable --now supergfxd.service
