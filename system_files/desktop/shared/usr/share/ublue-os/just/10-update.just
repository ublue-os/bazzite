# vim: set ft=make :

alias upgrade := update

# Update system, flatpaks, and containers all at once
update:
    #!/usr/bin/bash
    /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --keep
