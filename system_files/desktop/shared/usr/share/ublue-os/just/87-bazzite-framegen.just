# vim: set ft=make :

# set up DLSS-Enabler upscaling and framegen mod. Allows FSR3 upscaling and framegen via DLSS equivalents in supported games
get-framegen:
    #!/usr/bin/bash
    TMP_DIR=$(mktemp -d) && cd "$TMP_DIR" && git clone https://github.com/xXJSONDeruloXx/fgmod-bazzite.git . && chmod +x prepare.sh && ./prepare.sh