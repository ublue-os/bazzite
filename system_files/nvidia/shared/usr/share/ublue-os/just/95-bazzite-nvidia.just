# vim: set ft=make :

# Enable Supergfxctl, a GPU switcher for hybrid laptops. Options: status | enable | disable
enable-supergfxctl ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    get_status_token() {
        local service_state
        service_state="$(systemctl is-enabled supergfxd.service 2>/dev/null || true)"
        if [[ -z "$service_state" ]]; then
            return 1
        elif [[ "$service_state" == "enabled" ]]; then
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
    enable_supergfxctl() {
        systemctl enable --now supergfxd.service
        echo "Supergfxctl is now enabled."
    }
    disable_supergfxctl() {
        systemctl disable --now supergfxd.service
        echo "Supergfxctl is now disabled."
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust enable-supergfxctl <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'enable' to enable Supergfxctl"
        echo "  Use 'disable' to disable Supergfxctl"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit $?
    elif [[ -z "$OPTION" ]]; then
        echo "${bold}Supergfxctl${normal}"
        echo "Current status: $(get_current_status)"
        OPTION=$(ugum choose "Enable" "Disable" "Exit without changes")
        case "$OPTION" in
            "Enable")
                enable_supergfxctl
                ;;
            "Disable")
                disable_supergfxctl
                ;;
            *)
                echo "No changes made."
                ;;
        esac
        exit 0
    elif [[ "$OPTION" == "disable" ]]; then
        disable_supergfxctl
        exit 0
    fi
    enable_supergfxctl
