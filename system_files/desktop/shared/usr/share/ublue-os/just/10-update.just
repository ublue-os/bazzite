# vim: set ft=make :

alias upgrade := update

# Update system, flatpaks, and containers all at once
[group("system")]
update:
    #!/usr/bin/bash

    # Source brew if we are not in an interactive session
    [[ $- != *i* ]] && source <(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    /usr/bin/topgrade --config /usr/share/ublue-os/topgrade.toml --keep

# Turn automatic updates on or off
_toggle-updates ACTION="prompt":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_STATE="$(systemctl is-enabled uupd.timer)"
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
      echo "Automatic updates are currently: ${bold}${CURRENT_STATE^}${normal}"
      echo "Enable or Disable automatic updates?"
      OPTION=$(ugum choose Enable Disable)
    elif [ "$OPTION" == "help" ]; then
      echo "Usage: ujust toggle-updates <option>"
      echo "  <option>: Specify the quick option - 'enable' or 'disable'"
      echo "  Use 'enable' to Enable automatic updates."
      echo "  Use 'disable' to Disable automatic updates."
      exit 0
    fi
    if [ "${OPTION,,}" == "enable" ]; then
      sudo systemctl enable uupd.timer
    elif [ "${OPTION,,}" == "disable" ]; then
      sudo systemctl disable uupd.timer
    fi

alias changelog := changelogs

# Show the stable changelog
[group("system")]
changelogs:
    #!/usr/bin/bash
    CONTENT=$(curl -s https://api.github.com/repos/ublue-os/bazzite/releases/latest | jq -r '.body')
      echo "$CONTENT" | glow -

# Show the testing (pre-release) changelog
[group("system")]
changelogs-testing:
    #!/usr/bin/bash
    CONTENT=$(curl -s https://api.github.com/repos/ublue-os/bazzite/releases | jq -r 'map(select(.prerelease)) | .[0].body')
       echo "$CONTENT" | glow -
