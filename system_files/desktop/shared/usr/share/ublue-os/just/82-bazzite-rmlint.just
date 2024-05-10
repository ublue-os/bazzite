# vim: set ft=make :

# Reenable rmlint trim feature
enable-rmlint ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    if [[ ! -f "/etc/systemd/system/btrfs-dedup@.service.d/override.conf" ]]; then
        RMLINT_STATE="${red}${b}not enabled{n}"
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
      mkdir /etc/systemd/system/btrfs-dedup@.service.d/
      bash -c 'cat << EOL > /etc/systemd/system/btrfs-dedup@.service.d/override.conf
      [Unit]
      Description=Btrfs deduplication on %f
      ConditionPathIsMountPoint=%f
      RequiresMountsFor=%f

      [Service]
      Type=oneshot
      MemoryHigh=1G
      ExecCondition=sh -c '[ "$(stat -f -c "%%T" "$1")" = btrfs ]' _ %f/
      ExecStartPre=-find %f/ -mindepth 1 -maxdepth 1 -mtime +14 -name .duperemove.hash -exec rm -f '{}' \;
      ExecStartPre=-cp -a %f/.duperemove.hash duperemove.hash
      ExecStartPre=-compsize %f/
      ExecStart=rmlint --hidden --types="duplicates" --config=sh:handler=clone %f/
      ExecStart=sh -c 'exec ./rmlint.sh -d -p -r -k'
      ExecStart=-compsize %f/
      ExecStart=-sh -c '[ "$(sqlite3 -readonly duperemove.hash "SELECT keyval FROM config where keyname=''version_major''")" -ge 4 ] || rm -f duperemove.hash'
      ExecStart=duperemove -r -d -h -q --hashfile=duperemove.hash --skip-zeroes --exclude="%f/.duperemove.hash" --exclude="%f/@swapfile/swapfile" %f/
      ExecStartPost=-compsize %f/
      ExecStopPost=-cp -a duperemove.hash %f/.duperemove.hash
      TimeoutStartSec=4h
      RuntimeDirectory=%p/%i
      WorkingDirectory=%t/%p/%i
      Nice=19
      CPUSchedulingPolicy=batch
      IOSchedulingClass=best-effort
      IOSchedulingPriority=7
      OOMScoreAdjust=1000
      CPUWeight=30
      CPUQuota=300%
      IOWeight=30
    EOL'
      echo "rmlint has been reenabled!"
    elif [[ "${OPTION,,}" =~ ^(disable|uninstall) ]]; then
      if [[ "${RMLINT_STATE,,}" =~ "^not" ]]; then
        echo "${red} rmlint has already been disabled!"
        exit 0
      fi
      ublue-update --wait
      rpm-ostree remove -y rmlint
      rm /etc/systemd/system/btrfs-dedup@.service.d/override.conf
      rmdir /etc/systemd/system/btrfs-dedup@.service.d/
      echo "rmlint has been disabled."
    fi
