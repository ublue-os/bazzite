#!/usr/bin/env bash

# Source Bazzite defaults
source /etc/default/bazzite

# Simply launches the "yafti" GUI with the uBlue image's configuration.
/usr/bin/yafti /usr/share/ublue-os/firstboot/yafti.yml

# Open Steam so that it can update
/usr/bin/steam
