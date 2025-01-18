# vim: set ft=make :

alias patch-gmod := fix-gmod

# Patch GMod's 64-bit beta to work properly on Linux (https://github.com/solsticegamestudios/GModCEFCodecFix)
fix-gmod:
    #!/usr/bin/bash
    mkdir -p /tmp/patch-gmod
    wget \
      $(curl -s https://api.github.com/repos/solsticegamestudios/GModCEFCodecFix/releases/latest | \
      jq -r ".assets[] | select(.name | test(\"GModCEFCodecFix-Linux\")) | .browser_download_url") \
      -P /tmp/patch-gmod
    chmod +x /tmp/patch-gmod/GModCEFCodecFix-Linux
    /tmp/patch-gmod/GModCEFCodecFix-Linux
    rm -rf /tmp/patch-gmod

# Kills all processes related to wine and proton. This forces it to restart next time you launch the game (you might still have to press STOP in steam to kill the game binary)
fix-proton-hang:
    #!/usr/bin/bash
    PROTONCORE=(pv-bwrap pressure-vessel reaper explorer.exe rpcss.exe plugplay.exe services.exe svchost.exe winedevice.exe winedevice.exe wineserver)
    for PROG in "${PROTONCORE[@]}"; do
      killall -9 "$PROG"
    done

# Reset the Steam folder back to a fresh state
fix-reset-steam:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    STEAMPATH="$HOME/.local/share/Steam"
    # Get a list of the contents of steams top level directory except a list of folders/files we can skip to avoid losing data
    STEAMFILES=$(ls ~/.local/share/Steam/ | grep -vP "(userdata|compatibilitytools\.d|config|controller_base|steamapps|music)")
    echo "This script will ${b}remove${n} a bunch of files from $STEAMPATH and sign you out of steam!"
    echo "However your games, music, saves, controller profiles and compatibilitytools/custom-proton will not be touched."
    echo "To cancel and abort this operation press CTRL+C now, to continue press ENTER."
    read i
    killall -9 steam
    sleep 1
    echo "Resetting Steam to a freshly installed state."
    # Loop through each file and process it
    for STEAMFILE in $STEAMFILES
    do
      if [ -d "$STEAMPATH/$STEAMFILE" ]; then
        rm -rv "$STEAMPATH/$STEAMFILE"
      elif [ -f "$STEAMPATH/$STEAMFILE" ]; then
        rm -v "$STEAMPATH/$STEAMFILE"
      fi
    done
    sleep 1
    bazzite-steam &
    exit 0

# Toggle Bluetooth headset profile mode. If enabled, mic will be disabled on the Bluetooth device preventing the switch to headset profile, which has poor audio quality. Disable to restore mic functionality.
toggle-bt-mic:
    #!/usr/bin/bash
    CONFIG_FILE="/etc/wireplumber/wireplumber.conf.d/51-mitigate-annoying-profile-switch.conf"
    # Check current status
    CURRENT_STATE="Disabled"
    if [ -f "$CONFIG_FILE" ]; then
      CURRENT_STATE="Enabled"
    fi
    # Prompt user for action
    echo "Bluetooth headset profile mitigation is currently: ${bold}${CURRENT_STATE}${normal}"
    echo "Enable or Disable Bluetooth headset profile mitigation?"
    OPTION=$(ugum choose Enable Disable)
    if [[ "${OPTION,,}" == "enable" ]]; then
      echo "You chose to enable mitigation. This will disable headset mic functionality."
      echo "Requesting root privileges..."
      sudo mkdir -p "$(dirname "$CONFIG_FILE")"
      echo 'wireplumber.settings = {' | sudo tee "$CONFIG_FILE" > /dev/null
      echo '  bluetooth.autoswitch-to-headset-profile = false' | sudo tee -a "$CONFIG_FILE" > /dev/null
      echo '}' | sudo tee -a "$CONFIG_FILE" > /dev/null
      echo '' | sudo tee -a "$CONFIG_FILE" > /dev/null
      echo 'monitor.bluez.properties = {' | sudo tee -a "$CONFIG_FILE" > /dev/null
      echo '  bluez5.roles = [ a2dp_sink a2dp_source ]' | sudo tee -a "$CONFIG_FILE" > /dev/null
      echo '}' | sudo tee -a "$CONFIG_FILE" > /dev/null
      systemctl --user restart wireplumber
      echo "Mitigation has been ${green}${b}enabled${n}. Headset profile switching is now disabled."
    elif [[ "${OPTION,,}" == "disable" ]]; then
      echo "You chose to disable mitigation. This will restore headset mic functionality."
      echo "Requesting root privileges..."
      if sudo rm -f "$CONFIG_FILE"; then
        systemctl --user restart wireplumber
        echo "Mitigation has been ${red}${b}disabled${n}. Headset profile switching is now allowed."
      else
        echo "Failed to disable mitigation. Ensure you have sufficient permissions."
      fi
    else
      echo "No changes were made."
    fi

# enable or disable wake-on-lan functionality
toggle-wol:
    #!/usr/bin/bash
    INTERFACE=$(ip link show | awk '/state UP/ {print $2}' | tr -d ':' | grep -E '^(en|eth)')
    if [[ -z "$INTERFACE" ]]; then
      echo -e "${bold}No active Ethernet interface found.${normal}"
      echo "Please ensure your Ethernet connection is enabled or connected."
      echo "Exiting without making any changes."
      exit 0
    fi
    CONFIG_FILE="/etc/udev/rules.d/81-wol.rules"
    WOL_STATUS=$(sudo ethtool $INTERFACE | grep "Wake-on" | awk '{print $2}')
    CURRENT_STATE="Disabled"
    if [[ "$WOL_STATUS" == "g" ]]; then
      CURRENT_STATE="Enabled"
    fi
    echo "Wake-on-LAN is currently: ${bold}${CURRENT_STATE}${normal}"
    echo "Enable or Disable Wake-on-LAN, or Exit without saving?"
    OPTION=$(ugum choose Enable Disable Exit)
    if [[ "${OPTION,,}" == "enable" ]]; then
        echo "You chose to enable Wake-on-LAN."
        echo "Requesting root privileges..."
        sudo ethtool -s $INTERFACE wol g
        if ! grep -q "$INTERFACE" "$CONFIG_FILE" 2>/dev/null; then
          echo "Creating udev rule to make this setting persistent..."
          echo "ACTION==\"add\", SUBSYSTEM==\"net\", NAME==\"$INTERFACE\", RUN+=\"/usr/bin/ethtool -s \$name wol g\"" | sudo tee "$CONFIG_FILE" > /dev/null
        fi
        echo "Wake-on-LAN has been ${green}${bold}enabled${normal}."
    elif [[ "${OPTION,,}" == "disable" ]]; then
        echo "You chose to disable Wake-on-LAN."
        echo "Requesting root privileges..."
        sudo ethtool -s $INTERFACE wol d
        if [[ -f "$CONFIG_FILE" ]]; then
          echo "Removing udev rule to disable persistence..."
          sudo rm -f "$CONFIG_FILE"
        fi
        echo "Wake-on-LAN has been ${red}${bold}disabled${normal}."
    else
        echo "No changes were made."
    fi
