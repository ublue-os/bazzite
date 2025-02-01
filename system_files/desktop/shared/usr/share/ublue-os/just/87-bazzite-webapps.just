# vim: set ft=make :

# template for installing webapps as non-Steam games
_setup-example:
    #!/bin/bash
    # Global variables for script
    app_name='ex'
    site_url='example.com'
    default_path=~/Documents
    # Default path
    cd $default_path || exit
    # Create the script file
    echo -e '#!/bin/bash
    /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=firefox org.mozilla.firefox --kiosk '"$site_url"'' > "$app_name.sh"
    # Make script runnable
    chmod +x ./$app_name.sh
    echo $app_name successfully created!
    # Add our script file to Steam as non-Steam game
    steamos-add-to-steam $(pwd)/$app_name.sh
