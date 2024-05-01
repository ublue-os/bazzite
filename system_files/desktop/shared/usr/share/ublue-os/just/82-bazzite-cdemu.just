# vim: set ft=make :

# Setup and configure CDEmu Daemon and Client plus GUI Apps
setup-cdemu ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    CDEMU_STATE="$(rpm -qa cdemu-daemon)"
    GUI_EDITION="$(cat /etc/os-release | grep VARIANT_ID | sed 's/^.*=//')"
    OPTION={{ ACTION }}
    if [ "$CDEMU_STATE" == "" ]; then
        CDEMU_STATE="${red}${b}Not Installed${n}"
    else
        CDEMU_STATE="${green}${b}Installed${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-cdemu <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'install' to select Install CDEmu"
      echo "  Use 'remove' to select Remove CDEmu"
      echo "  Use 'remove-gui-helper' if you don't want to have the GUI"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}CDEmu setup and configuration${normal}"
      echo "CDEmu is $CDEMU_STATE"
      OPTION=$(Choose "Install CDEmu" "Remove CDEmu" "Remove GUI Helper")
    fi
    if [[ "${OPTION,,}" =~ ^install ]]; then
      if [[ "$CDEMU_STATE" != "" ]]; then
        echo "${red} CDEmu has already been installed!"
        exit 0
      fi
      ublue-update --wait
      if [[ "$GUI_EDITION" == "kinoite" ]]; then
            # Install packages for KDE 6
            rpm-ostree install --apply-live -y cdemu-daemon cdemu-client kde-cdemu-manager-kf6
      else
            # Install packages for GNOME
            rpm-ostree install --apply-live -y cdemu-daemon cdemu-client gcdemu
      fi
      # Kickstart the service manually on first install, it doesn't seem to be doing that by default.
      systemctl start --user cdemu-daemon.service
      echo "CDEmu is installed!"
    elif [[ "${OPTION,,}" =~ ^(remove|uninstall) ]]; then
      if [[ "$CDEMU_STATE" == "" ]]; then
        echo "${red} CDEmu has already been removed!"
        exit 0
      fi
      ublue-update --wait
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
    elif [[ "${OPTION,,}" =~ helper ]]; then
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
