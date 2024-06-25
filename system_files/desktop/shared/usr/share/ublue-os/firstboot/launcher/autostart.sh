#!/usr/bin/bash

# Show a warning to people that need gamescope-sdl-workaround
# Only runs if the script file from the deck image exists
if [ -f "/usr/libexec/bazzite-sdl-gpu-warn" ]; then
    # This will only show a warning if the user has not accepted the warning
    /usr/libexec/bazzite-sdl-gpu-warn &
fi

# Simply launches the "yafti" GUI with the uBlue image's configuration.
/usr/bin/yafti /usr/share/ublue-os/firstboot/yafti.yml
