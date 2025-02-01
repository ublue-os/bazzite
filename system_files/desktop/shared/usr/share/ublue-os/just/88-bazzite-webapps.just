# vim: set ft=make :

# add xbox cloud gaming to steam as a non-Steam game
setup-gamepass:
    #!/bin/bash
    default_path=~/Documents
    cd $default_path || exit
    echo -e '#!/bin/bash
    /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=firefox org.mozilla.firefox --kiosk 'https://www.xbox.com/play'' > "Xbox.sh"
    chmod +x ./$app_name.sh
    steamos-add-to-steam $(pwd)/Xbox.sh
    echo Xbox successfully created!
