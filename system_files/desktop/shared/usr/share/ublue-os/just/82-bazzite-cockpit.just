# vim: set ft=make :

# Manage Cockpit, a web-based graphical interface for servers. Options: status | enable | disable
[group("apps")]
cockpit ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION="{{ ACTION }}"

    if [ "$OPTION" == "status" ]; then
      systemctl is-enabled cockpit.service
      exit $?
    fi

    if [ "$OPTION" == "" ]; then
      echo "${bold}Cockpit${normal}"
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
