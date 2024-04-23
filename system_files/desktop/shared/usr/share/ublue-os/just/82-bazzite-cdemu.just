# vim: set ft=make :

# Setup and configure CDEmu Daemon and Client plus GUI Apps
setup-cdemu ACTION="":
    #!/bin/bash
    source /usr/lib/ujust/ujust.sh
    CDEMU_STATE="$(rpm -qa cdemu-daemon)"
    SERVICE_STATE="$(systemctl is-enabled --user cdemu-daemon.service)"
    GUI_EDITION="$(cat /etc/os-release | grep VARIANT_ID | sed 's/^.*=//')"
    OPTION={{ ACTION }}
    if [ "$CDEMU_STATE" == "" ]; then
        CDEMU_STATE="${red}${b}Not Installed${n}"
    else
        CDEMU_STATE="${green}${b}Installed${n}"
    fi
    if [ "$SERVICE_STATE" == "enabled" ]; then
        SERVICE_STATE="${green}${b}Enabled${n}"
    else
        SERVICE_STATE="${red}${b}Disabled${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-cdemu <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'install' to select Install CDEmu"
      echo "  Use 'remove' to select Remove CDEmu"
      echo "  Use 'autostart' to select Toggle Autostart"
      echo "  Use 'remove-gui-helper' if you don't want to have the GUI"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}CDEmu setup and configuration${normal}"
      echo "CDEmu is $CDEMU_STATE"
      echo "Service is $SERVICE_STATE"
      OPTION=$(Choose "Install CDEmu" "Remove CDEmu" "Toggle Autostart")
    fi
    if [[ "${OPTION,,}" =~ ^install ]]; then
      ublue-update --wait
      if [[ "$GUI_EDITION" == "kinoite" ]]; then
            # Install packages for KDE 6
            rpm-ostree install --apply-live -y cdemu-daemon cdemu-client kde-cdemu-manager-kf6
      else
            # Install packages for GNOME
            rpm-ostree install --apply-live -y cdemu-daemon cdemu-client gcdemu
      fi
      systemctl enable --user --now cdemu-daemon.service
      echo "CDEmu is installed!"
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall) ]]; then
      ublue-update --wait
      systemctl disable --user cdemu-daemon.service
      if [[ "$GUI_EDITION" == "kinoite" ]]; then
        # Remove packages for KDE 6
        GUI_STATE="$(rpm -qa kde-cdemu-manager-kf6)"
        #GUI already removed
        if [[GUI_STATE == ""]]; then
          rpm-ostree remove -y cdemu-daemon cdemu-client
        else
          rpm-ostree remove -y cdemu-daemon cdemu-client kde-cdemu-manager-kf6
        fi
      else
        # Remove packages for GNOME
        GUI_STATE="$(rpm -qa gcdemu)"
        #GUI already removed
        if [["${GUI_STATE,,}" == ""]]; then
          rpm-ostree remove -y cdemu-daemon cdemu-client
        else
          rpm-ostree remove -y cdemu-daemon cdemu-client gcdemu
        fi
      fi
      echo "CDEmu has been uninstalled."
    elif [[ "${OPTION,,}" =~ autostart ]]; then
      if [[ "${SERVICE_STATE,,}" =~ disabled ]]; then
        systemctl enable --user --now cdemu-daemon.service
      else
        systemctl disable --user --now cdemu-daemon.service
      fi
      elif [[ "${OPTION,,}" =~ remove-gui-helper ]]; then
      if [[ "$GUI_EDITION" == "kinoite" ]]; then
        GUI_STATE="$(rpm -qa kde-cdemu-manager-kf6)"
        if [["$GUI_STATE" == ""]]; then
          echo "GUI has already been removed or the package is not yet installed!"
        else
          rpm-ostree remove -y kde-cdemu-manager-kf6
          echo "GUI has been removed, you can still mount images using the CLI with the cdemu command."
        fi
      else
        GUI_STATE="$(rpm -qa gcdemu)"
        if [["$GUI_STATE" == ""]]; then
          echo "GUI has already been removed or the package is not yet installed!"
        else
          rpm-ostree remove -y gcdemu
          echo "GUI has been removed, you can still mount images using the CLI with the cdemu command."
        fi
      fi
    fi
