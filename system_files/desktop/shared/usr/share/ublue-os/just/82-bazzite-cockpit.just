# vim: set ft=make :

# Manage Cockpit, a web-based graphical interface for servers. Options: status | enable | disable
[group("apps")]
cockpit ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION="{{ ACTION }}"

    get_status_token() {
      if systemctl is-enabled --quiet cockpit.service; then
        echo "enable"
      else
        echo "disable"
      fi
    }

    get_current_status() {
      if [[ "$(get_status_token)" == "enable" ]]; then
        echo "${green}${bold}Enabled${normal}"
      else
        echo "${yellow}${bold}Disabled${normal}"
      fi
    }

    if [ "$OPTION" == "status" ]; then
      get_status_token
      exit 0
    fi

    if [ "$OPTION" == "" ]; then
      echo "${bold}Cockpit${normal}"
      echo "Current status: $(get_current_status)"
      OPTION=$(ugum choose "Enable" "Disable" "Exit without changes")
    fi

    case "$OPTION" in
      Enable|enable)
        sudo systemctl enable --now cockpit.service
        ;;
      Disable|disable)
        sudo systemctl disable --now cockpit.service
        sudo systemctl stop cockpit-container.service
        sudo podman rm -f cockpit-ws
        ;;
      *)
        echo "No changes made."
        ;;
    esac
