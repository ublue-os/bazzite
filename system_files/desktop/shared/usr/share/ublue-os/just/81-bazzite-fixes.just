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

toggle-i915-sleep-fix:
    #!/usr/bin/bash

    # Explain the purpose of the script
    echo -e "# This script manages the i915.enable_dc kernel parameter, which controls a power-saving feature for Intel graphics"
    echo -e "Enabling this setting can reduce power consumption, but may cause issues like random reboots or failed suspend on certain devices"
    echo -e "Disabling it ensures stability at the cost of slightly higher power usage"
    # Get the current i915.enable_dc setting
    get_current_status() {
      local karg_status
      karg_status=$(cat /proc/cmdline | grep -o 'i915.enable_dc=[0-9]' | cut -d= -f2)
      if [[ -z "$karg_status" ]]; then
        echo "Not Set"
      else
        echo "$karg_status"
      fi
    }
    # Toggle i915.enable_dc kernel parameter
    update_karg() {
      local new_value=$1
      if [[ $new_value -eq 1 ]]; then
        echo -e "\nYou are enabling power-saving mode (i915.enable_dc=1). This may help reduce power usage but could lead to stability issues on some devices.\n"
      elif [[ $new_value -eq 0 ]]; then
        echo -e "\nYou are disabling power-saving mode (i915.enable_dc=0). This prioritizes stability but may slightly increase power consumption.\n"
      fi
      sudo rpm-ostree kargs --replace "i915.enable_dc=$new_value"
      echo -e "Kernel parameter updated. Reboot required to apply changes."
    }
    # Display current status
    current_status=$(get_current_status)
    echo -e "\nCurrent i915.enable_dc setting: $current_status\n"
    # Prompt user for action
    CHOICE=$(ugum choose "Enable Power Saving (i915.enable_dc=1)" "Disable Power Saving (i915.enable_dc=0)" "Unset Parameter" "Exit without changes")
    case "$CHOICE" in
      "Enable Power Saving (i915.enable_dc=1)")
        echo "Enabling power-saving mode (i915.enable_dc=1)..."
        update_karg 1
        ;;
      "Disable Power Saving (i915.enable_dc=0)")
        echo "Disabling power-saving mode (i915.enable_dc=0)..."
        update_karg 0
        ;;
      "Unset Parameter")
        echo "Unsetting i915.enable_dc..."
        sudo rpm-ostree kargs --delete "i915.enable_dc=[0-9]"
        echo -e "Kernel parameter unset. Reboot required to apply changes."
        ;;
      "Exit without changes")
        echo "No changes made."
        ;;
      *)
        echo "Invalid choice. Exiting without changes."
        ;;
    esac
