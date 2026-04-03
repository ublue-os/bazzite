# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host
[group("gaming")]
setup-sunshine ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    BETA="No"
    SERVICE_STATE="$(systemctl --user is-enabled homebrew.sunshine.service)"
    BETA_SERVICE_STATE="$(systemctl --user is-enabled homebrew.sunshine-beta.service)"
    if [[ $BETA_SERVICE_STATE == "enabled" ]]; then
      SERVICE_STATE="enabled"
      BETA="Yes"
    fi
    OPTION={{ ACTION }}
    if [ "$SERVICE_STATE" == "enabled" ]; then
        SERVICE_STATE="${green}${b}Enabled${n}"
    else
        if [[ "$BETA_SERVICE_STATE" == "enabled" ]]; then
            SERVICE_STATE="${green}${b}Enabled (Beta)${n}"
        else
          if [[ -z $(brew list | grep sunshine) ]]; then
            SERVICE_STATE="${red}${b}Not Installed${n}"
          else
            SERVICE_STATE="${yellow}${b}Disabled${n}"
          fi
        fi
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to enable the Sunshine service"
      echo "  Use 'enable-beta' to enable the Sunshine beta service"
      echo "  Use 'disable' to disable the Sunshine service"
      echo "  Use 'portal' to open the Sunshine management portal"
      echo "  Use 'exit' to exit without making changes"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Enable" "Enable-Beta" "Disable" "Uninstall" "Open Portal" "Exit")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      brew tap LizardByte/homebrew
      if [[ "${OPTION,,}" =~ ^enable-beta ]]; then
        brew install sunshine-beta
        brew services start sunshine-beta
      else
        brew install sunshine
        brew services start sunshine
      fi
      sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      if [[ "$BETA" == "Yes" ]]; then
        brew services stop sunshine-beta
      else
        brew services stop sunshine
      fi
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall) ]]; then
      if [[ "$BETA" == "Yes" ]]; then
        brew services stop sunshine-beta
        brew uninstall sunshine-beta
      else
        brew services stop sunshine
        brew uninstall sunshine
      fi
    elif [[ "${OPTION,,}" =~ ^(portal|open) ]]; then
      echo "Opening Sunshine management portal..."
      xdg-open https://localhost:47990
    elif [[ "${OPTION,,}" =~ ^exit ]]; then
      echo "Exiting without making changes."
      exit 0
    fi
