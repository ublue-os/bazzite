# vim: set ft=make :

# Configure auto-pause on suspend/resume for running games. Can fix audio crackling on wake. May cause problems with some games. Check out Pause Games Decky plugin for finer control.
[group("gaming")]
setup-auto-pause ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    
    is_enabled() {
        if systemctl --user is-enabled bazzite-auto-pause.service &>/dev/null; then
            return 0
        else
            return 1
        fi
    }
    
    get_status() {
        if is_enabled; then
            echo -e "${bold}Auto-pause on suspend/resume:${normal} ${green}Enabled${normal}"
            if systemctl --user is-active bazzite-auto-pause.service &>/dev/null; then
                echo -e "${bold}Service status:${normal} ${green}Running${normal}"
            else
                echo -e "${bold}Service status:${normal} ${yellow}Stopped${normal}"
            fi
        else
            echo -e "${bold}Auto-pause on suspend/resume:${normal} ${yellow}Disabled${normal}"
        fi
    }
    
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "" ]; then
        echo -e "${bold}Bazzite Auto-Pause Configuration${normal}"
        echo
        get_status
        echo
        echo "Choose an option:"
        if is_enabled; then
            OPTION=$(ugum choose "Disable auto-pause" "Show status" "Exit")
        else
            OPTION=$(ugum choose "Enable auto-pause" "Show status" "Exit")
        fi
    fi
    
    case "$OPTION" in
        "Enable auto-pause"|enable)
            echo "Enabling auto-pause on suspend/resume..."
            systemctl --user enable --now bazzite-auto-pause.service
            echo -e "${green}Auto-pause service enabled and started${normal}"
            echo "Games will now automatically pause before system suspend and resume after wake."
            ;;
        "Disable auto-pause"|disable)
            echo "Disabling auto-pause on suspend/resume..."
            systemctl --user disable --now bazzite-auto-pause.service 2>/dev/null || true
            echo -e "${yellow}Auto-pause service disabled${normal}"
            ;;
        "Show status"|status)
            get_status
            ;;
        "Exit"|*)
            echo "No changes made."
            ;;
    esac
