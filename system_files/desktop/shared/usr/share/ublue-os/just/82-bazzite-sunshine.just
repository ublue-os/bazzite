# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host
setup-sunshine ACTION="":
    #!/usr/bin/bash
    # set -eo pipefail
    if [[ $UID -eq 0 ]]; then
        echo >&2 "This script must not run as root"
        exit 1
    fi
    source /usr/lib/ujust/ujust.sh
    SERVICE_STATE="$(systemctl is-enabled --user sunshine.service)"
    OPTION={{ ACTION }}
    if [ "$SERVICE_STATE" == "enabled" ]; then
        SERVICE_STATE="{{ GREEN + BOLD }}Enabled{{ NORMAL }}"
    else
        SERVICE_STATE="{{ RED + BOLD }}Disabled{{ NORMAL }}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "    'enable' to enable the Sunshine service"
      echo "    'disable' to disable the Sunshine service"
      echo "    'portal' to open the Sunshine management portal"
      echo "    'toggle-inhibit' to toggle the Sunshine service inhibit. \
    This prevents the system from powering off while sunshine is running."
      echo "    'exit' to exit without making changes"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Enable" "Disable" "Open Portal" "Toggle-Inhibit" "Exit")
    fi
    if [[ "${OPTION,,}" =~ ^toggle-inhibit ]]; then
      if systemctl -q is-enabled --user sunshine-inhibit.service; then
        systemctl disable -q --user sunshine-inhibit.service &&
        echo "Sunshine-inhibit service inhibit was {{ RED }}disabled{{ NORMAL }}."
      else
        systemctl enable -q --user sunshine-inhibit.service &&
        echo "Sunshine-inhibit service was {{ GREEN }}enabled{{ NORMAL }}."
      fi
    elif [[ "${OPTION,,}" =~ ^enable ]]; then
      systemctl enable --user --now sunshine.service
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall|disable) ]]; then
      systemctl disable --user --now sunshine.service
    elif [[ "${OPTION,,}" =~ ^(portal|open) ]]; then
      echo "Opening Sunshine management portal..."
      xdg-open https://localhost:47990
    elif [[ "${OPTION,,}" =~ ^exit ]]; then
      echo "Exiting without making changes."
      exit 0
    fi
