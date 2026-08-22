# vim: set ft=make :

# Manage input remapper feature on non-desktop images. Options: status | enable | disable
restore-input-remapper ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    DESKTOP_FILE="$HOME/.local/share/applications/input-remapper-gtk.desktop"
    get_status_token() {
        if systemctl is-enabled --quiet input-remapper.service && [[ -f "$DESKTOP_FILE" ]]; then
            echo "enable"
        else
            echo "disable"
        fi
    }
    get_current_status() {
        if [[ "$(get_status_token)" == "enable" ]]; then
            echo "Enabled"
        else
            echo "Disabled"
        fi
    }
    enable_input_remapper() {
        systemctl enable --now input-remapper.service
        mkdir -p "$HOME/.local/share/applications"
        cp /usr/share/applications/input-remapper-gtk.desktop "$DESKTOP_FILE"
        sed -i '/NoDisplay=true/d' "$DESKTOP_FILE"
        echo "Input Remapper has been enabled."
    }
    disable_input_remapper() {
        systemctl disable --now input-remapper.service
        rm -f "$DESKTOP_FILE"
        echo "Input Remapper has been disabled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust restore-input-remapper <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'enable' to enable Input Remapper"
        echo "  Use 'disable' to disable Input Remapper"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit 0
    elif [[ "$OPTION" == "enable" ]]; then
        enable_input_remapper
        exit 0
    elif [[ "$OPTION" == "disable" ]]; then
        disable_input_remapper
        exit 0
    elif [[ -z "$OPTION" ]]; then
        current_status=$(get_current_status)
        echo "${bold}Input Remapper${normal}"
        echo "Current status: $current_status"
        OPTION=$(ugum choose "Enable" "Disable" "Exit without changes")
        case "$OPTION" in
            "Enable")
                enable_input_remapper
                ;;
            "Disable")
                disable_input_remapper
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    fi
