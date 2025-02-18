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

get-webapp:
    #!/usr/bin/bash
    # Load ugum for interactive menu
    source /usr/lib/ujust/ujust.sh
    # Set default path for saving scripts
    default_path=~/Documents
    mkdir -p "$default_path"
    cd "$default_path" || exit
    # Display menu
    echo -e "\n${bold}Select a web app to add to Steam:${normal}"
    CHOICE=$(ugum choose "Xbox Cloud Gaming" "YouTube" "Amazon Luna" "Netflix" "Exit")
    # Function to create webapp script and add to Steam
    create_webapp() {
        app_name="$1"
        app_url="$2"
        script_path="$default_path/$app_name.sh"
        # Create the script
        echo -e "#!/bin/bash\n/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=firefox org.mozilla.firefox --kiosk '$app_url'" > "$script_path"
        # Make script executable
        chmod +x "$script_path"
        # Add to Steam
        steamos-add-to-steam "$script_path"
        echo -e "${bold}${app_name}${normal} successfully added to Steam! 🚀"
    }
    # Process user choice
    case "$CHOICE" in
        "Xbox Cloud Gaming")
            create_webapp "Xbox" "https://www.xbox.com/play"
            ;;
        "YouTube")
            create_webapp "YouTube" "https://www.youtube.com"
            ;;
        "Amazon Luna")
            create_webapp "Amazon_Luna" "https://www.amazon.com/luna"
            ;;
        "Netflix")
            create_webapp "Netflix" "https://www.netflix.com"
            ;;
        "Exit")
            echo -e "${bold}Exiting...${normal}"
            exit 0
            ;;
        *)
            echo -e "${red}Invalid choice. Exiting.${normal}"
            exit 1
            ;;
    esac
