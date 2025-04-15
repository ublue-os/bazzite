# vim: set ft=make :

# Reenable rmlint trim feature
enable-rmlint ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    STATUS="$(cat /etc/conf.d/btrfs-dedup | grep RMLINT_SKIP=\"1\")"
    if [[ $STATUS != "" ]]; then
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
      rpm-ostree install --apply-live -y rmlint
      sudo sed -i 's@RMLINT_SKIP="1"@RMLINT_SKIP="0"@g' /etc/conf.d/btrfs-dedup
      echo "rmlint has been reenabled!"
    elif [[ "${OPTION,,}" =~ ^(disable|uninstall) ]]; then
      if [[ "${RMLINT_STATE,,}" =~ "^not" ]]; then
        echo "${red} rmlint has already been disabled!"
        exit 0
      fi
      rpm-ostree remove -y rmlint
      sudo sed -i 's@RMLINT_SKIP="0"@RMLINT_SKIP="1"@g' /etc/conf.d/btrfs-dedup
      echo "rmlint has been disabled."
    fi
