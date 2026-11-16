
# Configure automatic HDR switching for HTPCs in Steam Gaming Mode
configure-htpc-auto-hdr action="":
    #!/usr/bin/env bash
    set -euo pipefail

    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/environment.d"
    CONFIG_FILE="$CONFIG_DIR/90-gamescope-hdr.conf"
    choice="{{action}}"
    changed=false

    # Return current state for Bazzite Portal
    if [[ "$choice" == "status" ]]; then
        if [[ -f "$CONFIG_FILE" ]] &&
           grep -qx 'gamescope_hdr_content_driven=true' "$CONFIG_FILE"; then
            echo "enable"
        else
            echo "disable"
        fi
        exit 0
    fi

    if [[ -z "$choice" ]]; then
        echo ""
        echo "=========================================="
        echo "   Bazzite HTPC Automatic HDR Switching"
        echo "=========================================="
        echo ""
        echo "This feature enables automatic HDR switching in Steam"
        echo "Gaming Mode on HTPCs. HDR activates when supported"
        echo "content requests it and returns to SDR otherwise."
        echo ""
        echo "IMPORTANT:"
        echo " - May not work on all hardware or display types."
        echo " - Tested on systems with AMD discrete GPUs."
        echo " - Not intended for handhelds or laptops unless"
        echo "   using an external display."
        echo " - Not meant for internal handheld/laptop screens."
        echo " - May cause unexpected regressions on internal handheld/laptop screens."
        echo " - Steam's QAM HDR toggle may remain visible but"
        echo "   may not function as expected while enabled."
        echo " - Some displays may briefly blank during HDR"
        echo "   transitions."
        echo ""

        if [[ -f "$CONFIG_FILE" ]] &&
           grep -qx 'gamescope_hdr_content_driven=true' "$CONFIG_FILE"; then
            echo "Current status: ENABLED"
        else
            echo "Current status: DISABLED"
        fi

        echo ""
        echo "1) Enable Automatic HDR"
        echo "2) Disable Automatic HDR"
        echo "3) Cancel"
        echo ""

        read -r -p "Select an option [1-3]: " choice || exit 0
    fi

    case "$choice" in
        1|enable)
            if [[ -f "$CONFIG_FILE" ]] &&
               grep -qx 'gamescope_hdr_content_driven=true' "$CONFIG_FILE"; then
                echo ""
                echo "Automatic HDR switching is already enabled."
            else
                mkdir -p "$CONFIG_DIR"
                printf '%s\n' 'gamescope_hdr_content_driven=true' > "$CONFIG_FILE"
                echo ""
                echo "Automatic HDR switching has been ENABLED."
                changed=true
            fi
            ;;
        2|disable)
            if [[ -f "$CONFIG_FILE" ]]; then
                rm "$CONFIG_FILE"
                echo ""
                echo "Automatic HDR switching has been DISABLED."
                changed=true
            else
                echo ""
                echo "Automatic HDR switching is already disabled."
            fi
            ;;
        3|cancel)
            echo "No changes made."
            exit 0
            ;;
        *)
            echo "Invalid selection: $choice"
            echo "Valid options: enable, disable, status"
            exit 1
            ;;
    esac

    if [[ "$changed" == true ]]; then
        echo ""
        echo "IMPORTANT: Restart your Steam Gaming Mode session"
        echo "for this change to take effect."
        echo "Restarting Steam alone is not sufficient."
    fi
    echo ""
