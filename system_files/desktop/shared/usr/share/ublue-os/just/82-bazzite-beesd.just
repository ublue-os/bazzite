# Configure beesd for BTRFS filesystems
[group("system")]
configure-beesd ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    while true; do
        # Get btrfs filesystem uuids
        mapfile -t btrfs_devices < <(lsblk --fs --list --noheadings --output "NAME,UUID,SIZE" --filter 'FSTYPE == "btrfs"')

        if [ ${#btrfs_devices[@]} -eq 0 ]; then
          echo "No BTRFS filesystems found."
          exit 0
        fi

        # Check for existing configurations
        unset configured_uuids
        declare -A configured_uuids
        if [ -d "/etc/bees" ]; then
            for config in /etc/bees/*.conf; do
                if [ -f "$config" ]; then
                    filename=$(basename "$config" .conf)
                    configured_uuids["$filename"]=1
                fi
            done
        fi

        # Create menu options
        menu_options=()
        for device in "${btrfs_devices[@]}"; do
            uuid=$(echo "$device" | awk '{print $2}')
            if [[ -n "${configured_uuids[$uuid]}" ]]; then
                menu_options+=("$device (Configured)")
            else
                menu_options+=("$device")
            fi
        done
        menu_options+=("Exit")

        echo "Select a BTRFS filesystem:"
        CHOICE=$(ugum choose "${menu_options[@]}")

        if [ "$CHOICE" == "Exit" ] || [ -z "$CHOICE" ]; then
            exit 0
        fi

        UUID=$(echo "$CHOICE" | awk '{print $2}')

        if [[ -f "/etc/bees/${UUID}.conf" ]]; then
            echo "Configuration already exists for UUID: ${UUID}"
            ACTION=$(ugum choose "Remove configuration" "Reinstall/Overwrite" "Back")
            if [ "$ACTION" == "Remove configuration" ]; then
                echo "Removing configuration..."
                sudo systemctl disable --now "beesd@${UUID}.service"
                sudo rm "/etc/bees/${UUID}.conf"
                echo "Removed /etc/bees/${UUID}.conf and disabled service."
                continue
            elif [ "$ACTION" == "Back" ]; then
                continue
            elif [ -z "$ACTION" ]; then
                exit 0
            fi
        else
            ACTION=$(ugum choose "Create configuration" "Back")
            if [ "$ACTION" == "Back" ]; then
                continue
            elif [ -z "$ACTION" ]; then
                exit 0
            fi
        fi

        sudo mkdir -p /etc/bees
        sudo cp /usr/etc/bees/beesd.conf.sample "/etc/bees/${UUID}.conf"
        # https://github.com/Zygo/bees/blob/master/docs/options.md#load-management-options
        sudo sed -i "s/^UUID=.*/UUID=${UUID}/" "/etc/bees/${UUID}.conf"
        sudo sed -i "s/# DB_SIZE=.*/DB_SIZE=\$((128*1024*1024))/" "/etc/bees/${UUID}.conf"
        sudo sed -i "s/# OPTIONS=.*/OPTIONS=\"--strip-paths --no-timestamps --throttle-factor 10\"/" "/etc/bees/${UUID}.conf"
        echo "Created /etc/bees/${UUID}.conf"
        sudo systemctl enable --now "beesd@${UUID}.service"
    done
