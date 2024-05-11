# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host
setup-sunshine ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    SUNSHINE_STATE="$(rpm -qa sunshine)"
    SERVICE_STATE="$(systemctl is-enabled --user sunshine.service)"
    OPTION={{ ACTION }}
    if [ "$SUNSHINE_STATE" == "" ]; then
        SUNSHINE_STATE="${red}${b}Not Installed${n}"
    else
        SUNSHINE_STATE="${green}${b}Installed${n}"
    fi
    if [ "$SERVICE_STATE" == "enabled" ]; then
        SERVICE_STATE="${green}${b}Enabled${n}"
    else
        SERVICE_STATE="${red}${b}Disabled${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'install' to select Install Sunshine"
      echo "  Use 'remove' to select Remove Sunshine"
      echo "  Use 'autostart' to select Toggle Autostart"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Sunshine setup and configuration${normal}"
      echo "Sunshine is $SUNSHINE_STATE"
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Install Sunshine" "Remove Sunshine" "Toggle Autostart")
    fi
    if [[ "${OPTION,,}" =~ ^install ]]; then
      systemctl enable sunshine-workaround.service
      ublue-update --wait
      rpm-ostree install --apply-live -y sunshine
      echo "Sunshine is installed!"
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall) ]]; then
      systemctl disable sunshine-workaround.service
      ublue-update --wait
      rpm-ostree remove -y sunshine
      echo "Sunshine has been uninstalled."
    elif [[ "${OPTION,,}" =~ autostart ]]; then
      if [[ "${SERVICE_STATE,,}" =~ disabled ]]; then
        systemctl enable --user --now sunshine.service
      else
        systemctl disable --user --now sunshine.service 
      fi
    fi
