# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host. Options: status | enable | disable | portal
[group("gaming")]
setup-sunshine ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    get_status_token() {
      local service_state
      service_state="$(systemctl is-enabled --user app-dev.lizardbyte.app.Sunshine.service 2>/dev/null || true)"
      if [[ "$service_state" == "enabled" ]]; then
        echo "enable"
      elif [[ -n "$service_state" ]]; then
        echo "disable"
      else
        return 1
      fi
    }
    get_current_status() {
      if [[ "$(get_status_token)" == "enable" ]]; then
        echo "${green}${b}Enabled${n}"
      else
        echo "${red}${b}Disabled${n}"
      fi
    }
    OPTION={{ ACTION }}
    SERVICE_STATE="$(get_current_status)"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal current status"
      echo "  Use 'enable' to enable the Sunshine service"
      echo "  Use 'disable' to disable the Sunshine service"
      echo "  Use 'portal' to open the Sunshine management portal"
      echo "  Use 'exit' to exit without making changes"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit $?
    elif [ "$OPTION" == "" ]; then
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Enable" "Disable" "Open Portal" "Exit")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      systemctl enable --user --now app-dev.lizardbyte.app.Sunshine.service
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall|disable) ]]; then
      systemctl disable --user --now app-dev.lizardbyte.app.Sunshine.service 
    elif [[ "${OPTION,,}" =~ ^(portal|open) ]]; then
      echo "Opening Sunshine management portal..."
      xdg-open https://localhost:47990
    elif [[ "${OPTION,,}" =~ ^exit ]]; then
      echo "Exiting without making changes."
      exit 0
    fi
