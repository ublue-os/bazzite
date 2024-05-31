# vim: set ft=make :

# Reenable rmlint trim feature
enable-rmlint ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    if [[ ! -f "/etc/systemd/system/btrfs-dedup@.service.d/override.conf" ]]; then
        RMLINT_STATE="${red}${b}not enabled${n}"
    else
        RMLINT_STATE="${green}${b}already enabled${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust enable-rmlint <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to reenable rmlint functionality"
      echo "  Use 'disable' to revert to UBlue stock configuration (only duperemove is executed)"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}rmlint configuration${normal}"
      echo "rmlint conf is $RMLINT_STATE"
      OPTION=$(Choose "Enable rmlint" "Disable rmlint")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      if [[ "${RMLINT_STATE,,}" =~ "^already" ]]; then
        echo "${red} rmlint has already been enabled!"
        exit 0
      fi
      ublue-update --wait
      rpm-ostree install --apply-live -y rmlint
      sudo mkdir /etc/systemd/system/btrfs-dedup@.service.d/
      sudo cp /usr/share/ublue-os/just/rmlint-override.conf /etc/systemd/system/btrfs-dedup@.service.d/override.conf
      echo "rmlint has been reenabled!"
    elif [[ "${OPTION,,}" =~ ^(disable|uninstall) ]]; then
      if [[ "${RMLINT_STATE,,}" =~ "^not" ]]; then
        echo "${red} rmlint has already been disabled!"
        exit 0
      fi
      ublue-update --wait
      rpm-ostree remove -y rmlint
      sudo rm /etc/systemd/system/btrfs-dedup@.service.d/override.conf
      sudo rmdir /etc/systemd/system/btrfs-dedup@.service.d/
      echo "rmlint has been disabled."
    fi
