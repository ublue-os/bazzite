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
    source /usr/lib/ujust/ujust.sh
    INTERFACE=$(ip link show | awk '/state UP/ {print $2}' | tr -d ':' | grep -E '^(en|eth)')
    if [[ -z "$INTERFACE" ]]; then
      echo -e "${bold}No active Ethernet interface found.${normal}"
      echo "Please ensure your Ethernet connection is enabled or connected."
      echo "Exiting without making any changes."
      exit 0
    fi
    CONFIG_FILE="/etc/udev/rules.d/81-wol.rules"
    SERVICE_FILE="/etc/systemd/system/force-wol.service"
    WOL_STATUS=$(sudo ethtool $INTERFACE | grep -P "^\s+Wake-on" | awk '{print $2}')
    CURRENT_STATE="Disabled"
    if [[ "$WOL_STATUS" == "g" ]]; then
      CURRENT_STATE="Enabled"
    fi
    echo "Wake-on-LAN is currently: ${bold}${CURRENT_STATE}${normal}"
    echo "Enable, Disable Wake-on-LAN, Force-Enable, or Exit without saving?"
    echo "Note: Force-Enable will make WOL persist across reboots"
    OPTION=$(ugum choose Enable Disable Force-Enable Exit)
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
      if systemctl is-enabled force-wol.service &>/dev/null; then
        sudo systemctl disable force-wol.service
        echo "Force-WOL service has been disabled."
      fi
      echo "Wake-on-LAN has been ${red}${bold}disabled${normal}."
    elif [[ "${OPTION,,}" == "force-enable" ]]; then
      echo "You chose to force-enable wake on LAN."
      echo "Requesting root privileges..."
      if [ -f "/etc/systemd/system/force-wol.service" ]; then
        echo "Removing deprecated service file"
        sudo rm "/etc/systemd/system/force-wol.service"
      fi
      sudo systemctl daemon-reload
      sudo systemctl enable --now force-wol.service
      echo "Wake on LAN force-enabled: ${green}${bold}force-wol.service${normal}"
    else
      echo "No changes were made."
    fi

toggle-i915-sleep-fix:
    #!/usr/bin/bash
    # Explain the purpose of the script
    echo -e "This script manages the i915.enable_dc kernel parameter, which controls a power-saving feature for Intel graphics"
    echo -e "Enabling this setting can reduce power consumption, but may cause issues like random reboots or failed suspend on certain devices"
    echo -e "Disabling it ensures stability at the cost of slightly higher power usage"
    # Get the current i915.enable_dc setting
    get_current_status() {
      local karg_status
      karg_status=$(cat /proc/cmdline | grep -o 'i915.enable_dc=[-0-9]' | cut -d= -f2)
      if [[ -z "$karg_status" ]]; then
        echo "Not Set"
      else
        echo "$karg_status"
      fi
    }
    # Toggle i915.enable_dc kernel parameter
    update_karg() {
      local new_value=$1
      if [[ $new_value -ge 0 && $new_value -le 4 ]]; then
        echo -e "\nYou are setting power-saving mode (i915.enable_dc=$new_value).\n"
        if [[ $new_value -eq 0 ]]; then
          echo -e "This disables power-saving mode and prioritizes stability.\n"
        elif [[ $new_value -eq 1 ]]; then
          echo -e "This enables basic power-saving mode but may cause minor stability issues.\n"
        elif [[ $new_value -ge 2 ]]; then
          echo -e "This enables higher levels of power-saving mode, which may impact stability further.\n"
        fi
      elif [[ $new_value -eq -1 ]]; then
        echo -e "\nYou are setting power-saving mode to auto (i915.enable_dc=-1).\n"
      else
        echo -e "\nInvalid value for i915.enable_dc. Please choose a valid value.\n"
        return
      fi
      sudo rpm-ostree kargs --replace "i915.enable_dc=$new_value"
      echo -e "Kernel parameter updated. Reboot required to apply changes."
    }
    # Display current status
    current_status=$(get_current_status)
    echo -e "\nCurrent i915.enable_dc setting: $current_status\n"
    # Prompt user for action
    CHOICE=$(ugum choose "Set to Auto (i915.enable_dc=-1)" "Disable Power Saving (i915.enable_dc=0)" "Set to Level 1 (i915.enable_dc=1)" "Set to Level 2 (i915.enable_dc=2)" "Set to Level 3 (i915.enable_dc=3)" "Set to Level 4 (i915.enable_dc=4)" "Unset Parameter" "Exit without changes")
    case "$CHOICE" in
      "Set to Auto (i915.enable_dc=-1)")
        echo "Setting power-saving mode to auto (i915.enable_dc=-1)..."
        update_karg -1
        ;;
      "Disable Power Saving (i915.enable_dc=0)")
        echo "Disabling power-saving mode (i915.enable_dc=0)..."
        update_karg 0
        ;;
      "Set to Level 1 (i915.enable_dc=1)")
        echo "Setting power-saving mode to level 1 (i915.enable_dc=1)..."
        update_karg 1
        ;;
      "Set to Level 2 (i915.enable_dc=2)")
        echo "Setting power-saving mode to level 2 (i915.enable_dc=2)..."
        update_karg 2
        ;;
      "Set to Level 3 (i915.enable_dc=3)")
        echo "Setting power-saving mode to level 3 (i915.enable_dc=3)..."
        update_karg 3
        ;;
      "Set to Level 4 (i915.enable_dc=4)")
        echo "Setting power-saving mode to level 4 (i915.enable_dc=4)..."
        update_karg 4
        ;;
      "Unset Parameter")
        echo "Unsetting i915.enable_dc..."
        sudo rpm-ostree kargs --delete "i915.enable_dc=[-0-9]"
        echo -e "Kernel parameter unset. Reboot required to apply changes."
        ;;
      "Exit without changes")
        echo "No changes made."
        ;;
      *)
        echo "Invalid choice. Exiting without changes."
        ;;
    esac


# Configure a controller button to wake the system from suspend
setup-controller-wake:
	#!/usr/bin/bash
	source /usr/lib/ujust/ujust.sh
  
	echo "Detecting USB input devices..."
	sleep 1

	# List all USB devices
	echo "Available USB devices:"
	lsusb | nl -w2 -s
	
	echo -e "\nEnter the number of your controller from the list above, or 'auto' to detect automatically: "
	read -r selection

	if [ "$selection" = "auto" ]; then
		echo "Auto-detection mode: Press a button on your controller..."
		sleep 2
		
		# Try to detect the controller
		detected_device=""
		for dev in /dev/input/event*; do
			(sudo timeout 0.5 evtest "$dev" 2>&1 | grep -q "Event:.*EV_KEY") && detected_device="$dev" && break
		done

		if [ -z "$detected_device" ]; then
			echo "No controller detected. Exiting."
			exit 1
		fi
		
		echo "Detected input device: $detected_device"
		# Find USB info for this input device
		device_path=$(readlink -f "/sys/class/input/$(basename "$detected_device")/device")
		
		# Find the USB bus and device
		usb_path=$(find "$device_path" -maxdepth 4 -name "idVendor" -exec dirname {} \; | head -n 1)
		if [ -z "$usb_path" ]; then
			echo "Could not determine USB path for device. Trying alternative approach..."
			# Try using dmesg to find device
			sudo dmesg | grep -i controller
			echo "Look for your controller in the above output and note the USB identifier (like 1-1.2)"
			echo "Enter the USB identifier for your controller (e.g., 1-1.2): "
			read -r usb_id
			usb_path="/sys/bus/usb/devices/$usb_id"
		fi
	else
		# User selected a device from lsusb output
		usb_info=$(lsusb | sed -n "${selection}p")
		if [ -z "$usb_info" ]; then
			echo "Invalid selection. Exiting."
			exit 1
		fi
		
		# Extract bus and device numbers
		bus=$(echo "$usb_info" | awk '{print $2}')
		device=$(echo "$usb_info" | awk '{print $4}' | sed 's/://')
		
		# Convert to path format
		vendor_id=$(echo "$usb_info" | grep -o "ID [0-9a-f]*:[0-9a-f]*" | awk '{print $2}' | cut -d: -f1)
		product_id=$(echo "$usb_info" | grep -o "ID [0-9a-f]*:[0-9a-f]*" | awk '{print $2}' | cut -d: -f2)
		
		# Find the USB path
		usb_path=$(find /sys/bus/usb/devices -name "idVendor" -exec cat {} \; -exec dirname {} \; 2>/dev/null | grep -i "$vendor_id" | head -n 1)
	fi

	echo "USB device path: $usb_path"
	
	# Get device information
	device_name=$(cat "$usb_path/product" 2>/dev/null || echo "Unknown device")
	vendor_id=$(cat "$usb_path/idVendor" 2>/dev/null)
	product_id=$(cat "$usb_path/idProduct" 2>/dev/null)
	
	echo -e "Device: $device_name"
	echo -e "Vendor ID: $vendor_id"
	echo -e "Product ID: $product_id"
	
	# Find all parent devices that need wakeup enabled
	parent_devices=()
	current_path="$usb_path"
	
	while [[ "$current_path" != "/" && "$current_path" != "" ]]; do
		if [[ -f "$current_path/power/wakeup" ]]; then
			parent_devices+=("$current_path")
		fi
		
		# Move up one directory to the parent
		current_path=$(dirname "$current_path")
		
		# Stop if we reach the usb bus level
		if [[ "$current_path" == "/sys/bus/usb" ]]; then
			break
		fi
	done
	
	echo -e "\nFound ${#parent_devices[@]} devices in the chain that support wakeup:"
	for i in "${!parent_devices[@]}"; do
		echo "$(($i+1)): ${parent_devices[$i]}"
	done
	
	# Create udev rules file
	rule_path="/etc/udev/rules.d/99-controller-wakeup.rules"
	
	echo -e "\nCreating udev rules to enable wakeup on all relevant devices..."
	
	# Start with a clean file
	sudo sh -c "echo '# Automatically generated controller wakeup rules' > $rule_path"
	
	# Add a rule for main device
	if [ -n "$vendor_id" ] && [ -n "$product_id" ]; then
		echo "ACTION==\"add|change\", SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"$vendor_id\", ATTRS{idProduct}==\"$product_id\", RUN+=\"/bin/sh -c 'for d in /sys/bus/usb/devices/*/idVendor; do if [ \\\"\$(cat \\\$d)\\\" = \\\"$vendor_id\\\" ]; then p=\\\$(dirname \\\$d); if [ -f \\\$p/power/wakeup ]; then echo enabled > \\\$p/power/wakeup; fi; fi; done'\"" | sudo tee -a "$rule_path" > /dev/null
	fi
	
	# Add rules for parent devices
	for path in "${parent_devices[@]}"; do
		device_name=$(basename "$path")
		echo "ACTION==\"add|change\", SUBSYSTEM==\"usb\", KERNELS==\"$device_name\", RUN+=\"/bin/sh -c 'echo enabled > $path/power/wakeup'\"" | sudo tee -a "$rule_path" > /dev/null
	done
	
	# Add rule for top-level USB controller if needed
	usb_controller=$(echo "$usb_path" | grep -o "^/sys/bus/usb/devices/usb[0-9]*")
	if [ -n "$usb_controller" ] && [ -f "$usb_controller/power/wakeup" ]; then
		usb_num=$(basename "$usb_controller")
		echo "ACTION==\"add|change\", SUBSYSTEM==\"usb\", KERNELS==\"$usb_num\", RUN+=\"/bin/sh -c 'echo enabled > $usb_controller/power/wakeup'\"" | sudo tee -a "$rule_path" > /dev/null
	fi

	# Apply rules now
	echo -e "\nApplying rules and enabling wakeup..."
	sudo udevadm control --reload-rules
	sudo udevadm trigger
	
	# Enable wakeup manually for immediate effect
	for path in "${parent_devices[@]}"; do
		if [ -f "$path/power/wakeup" ]; then
			echo "enabled" | sudo tee "$path/power/wakeup" > /dev/null
			echo "Enabled wakeup on $(basename "$path")"
		fi
	done
	
	# Enable wakeup for the top-level controller if it exists
	if [ -n "$usb_controller" ] && [ -f "$usb_controller/power/wakeup" ]; then
		echo "enabled" | sudo tee "$usb_controller/power/wakeup" > /dev/null
		echo "Enabled wakeup on $(basename "$usb_controller")"
	fi
	
	echo -e "\nSetup complete! Your controller should now be able to wake the system from sleep."
	echo -e "You can test by suspending the system with: ${bold}sudo systemctl suspend${normal}"
	echo -e "Then use your controller to wake the system."
