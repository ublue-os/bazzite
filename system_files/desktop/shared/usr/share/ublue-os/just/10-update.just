# vim: set ft=make :

alias upgrade := update

# Update system, flatpaks, and containers all at once
update:
    /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --yes

# Update device firmware
[no-exit-message]
update-firmware:
    /usr/bin/fwupdmgr refresh --force
    /usr/bin/fwupdmgr get-updates
    /usr/bin/fwupdmgr update
