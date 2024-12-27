# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host
setup-sunshine ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    SERVICE_STATE="$(systemctl is-enabled --user sunshine.service)"
    OPTION={{ ACTION }}
    if [ "$SERVICE_STATE" == "enabled" ]; then
        SERVICE_STATE="${green}${b}Enabled${n}"
    else
        SERVICE_STATE="${red}${b}Disabled${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to enable the Sunshine service"
      echo "  Use 'disable' to disable the Sunshine service"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Enable" "Disable")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      systemctl enable --user --now sunshine.service
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall|disable) ]]; then
      systemctl disable --user --now sunshine.service 
    fi
