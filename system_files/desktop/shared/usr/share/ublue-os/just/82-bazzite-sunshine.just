# Setup and configure Sunshine Game Streaming host. Options: status | enable | enable-deck | update | disable | uninstall | portal | virtual-monitor
[group("gaming")]
setup-sunshine ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    confirm() {
      local msg="$1"
      echo -n "$msg ${yellow}(Y/n)${normal} "
      read -r reply
      [[ -z "$reply" || "${reply,,}" =~ ^y ]]
    }

    press_any_key() {
      echo "Press Enter to continue..."
      read -r
    }

    sunshine_installed() {
      flatpak info dev.lizardbyte.app.Sunshine >/dev/null 2>&1
    }

    deck_sunshine_installed() {
      rpm -q sunshine >/dev/null 2>&1
    }
    # deck_sunshine refers to the layered installs of sunshine, as it is primarily for deck users who do not have access to xdg portal capture.

    brew_sunshine_installed() {
      [[ -e /home/linuxbrew/.linuxbrew/opt/sunshine ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine ||
        -e /home/linuxbrew/.linuxbrew/opt/sunshine-beta ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine-beta ]]
    }

    get_status_token() {
      local service_state
      service_state="$(systemctl is-enabled --user app-dev.lizardbyte.app.Sunshine 2>/dev/null || true)"

      if sunshine_installed; then
        local status="enable"
      elif deck_sunshine_installed; then
        local status="enable-deck"
      elif brew_sunshine_installed; then
        local status="enable-brew"
      else
        echo "uninstall"
        return
      fi

      if [[ "$service_state" == "enabled" ]]; then
        echo "$status"
      else
        echo "disable"
      fi
    }

    virtual-monitor() {
      local FLATPAK_VMON_APP='{
        "auto-detach": true,
        "cmd": "",
        "elevated": false,
        "exclude-global-prep-cmd": false,
        "exit-timeout": 5,
        "image-path": "",
        "name": "Virtual Monitor",
        "output": "",
        "prep-cmd": [
            {
                "do": "sh -c \"flatpak-spawn --host --env=SUNSHINE_CLIENT_WIDTH=\\\"${SUNSHINE_CLIENT_WIDTH}\" --env=SUNSHINE_CLIENT_HEIGHT=\\\"${SUNSHINE_CLIENT_HEIGHT}\" --env=SUNSHINE_CLIENT_FPS=\\\"${SUNSHINE_CLIENT_FPS}\\\" --env=QT_QPA_PLATFORM=wayland --env=WAYLAND_DISPLAY=wayland-0 --env=XDG_RUNTIME_DIR=/run/user/1000 --env=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /usr/libexec/sunshine-start-vmon\"",
                "undo": "sh -c \"flatpak-spawn --host env QT_QPA_PLATFORM=wayland WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /usr/libexec/sunshine-stop-vmon\""
            }
        ],
        "wait-all": true
      }'
      local NORMAL_VMON_APP='{
        "auto-detach": true,
        "cmd": "",
        "elevated": false,
        "exclude-global-prep-cmd": false,
        "exit-timeout": 5,
        "image-path": "",
        "name": "Virtual Monitor",
        "output": "",
        "prep-cmd": [
            {
                "do": "sh -c \"/usr/libexec/sunshine-start-vmon\"",
                "undo": "sh -c \"/usr/libexec/sunshine-stop-vmon\""
            }
        ],
        "wait-all": true
      }'
      local FLATPAK_APP_CONF="$HOME/.var/app/dev.lizardbyte.app.Sunshine/config/sunshine/apps.json"
      local NORMAL_APP_CONF="$HOME/.config/sunshine/apps.json"
      if [[ -f "$FLATPAK_APP_CONF" ]]; then
        local APP_CONF="$FLATPAK_APP_CONF"
        local VMON_APP="$FLATPAK_VMON_APP"
      elif [[ -f "$NORMAL_APP_CONF" ]]; then
        local APP_CONF="$NORMAL_APP_CONF"
        local VMON_APP="$NORMAL_VMON_APP"
      else
        echo "No app config found! Is Sunshine installed?"
        exit 1
      fi
      local IMAGE_INFO="/usr/share/ublue-os/image-info.json"
      local BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
      local IMAGE_NAME=$(jq -r '."image-name"' < $IMAGE_INFO)
      if [[ "$BASE_IMAGE_NAME" != "kinoite" ]]; then
        echo "Virtual monitors are only supported in KDE's KWin compositor!"
        echo "See ${bold}https://docs.bazzite.gg/Advanced/custom_resolution/${normal} for more information."
        press_any_key
        return 0
      fi
      if [[ "$IMAGE_NAME" =~ "deck" ]]; then
        echo "Virtual monitors are only supported in KDE's KWin compositor!"
        echo "See ${bold}https://docs.bazzite.gg/Advanced/custom_resolution/${normal} for more information."
        press_any_key
        return 0
      fi
      local MON_OPTION=$(Choose "Add Virtual Monitor" "Fix Error 503" "Go Back" "Exit")
      case "$MON_OPTION" in
        "Add Virtual Monitor")
          TMP_FILE=$(mktemp)
          jq --argjson VMON_APP "$VMON_APP" '
            if .apps then
              if any(.apps[]; .name == $VMON_APP.name) then
                .apps |= map(if .name == $VMON_APP.name then $VMON_APP else . end)
              else
                .apps += [$VMON_APP]
              end
            else
              .apps = [$VMON_APP]
            end
          ' "$APP_CONF" > "$TMP_FILE"
          mv "$TMP_FILE" "$APP_CONF"
          echo "Successfully added/updated 'Virtual Monitor' in $APP_CONF"
          echo -e "[Service]\nExecStopPost=/usr/libexec/sunshine-stop-vmon" | systemctl --user edit app-dev.lizardbyte.app.Sunshine --stdin
          systemctl daemon-reload
          echo "Remember to set the Capture Method to ${bold}KWin Screencast${normal}."
          echo "${bold}Restart Sunshine${normal} for changes to takes effect."
          xdg-open "https://localhost:47990/troubleshooting"
          press_any_key
        ;;
        "Fix Error 503")
          echo "KWIN_WAYLAND_NO_PERMISSION_CHECKS=1" > $HOME/.config/environment.d/98-kwin-no-permission-checks.conf
          echo -n "Wrote in $HOME/.config/environment.d/98-kwin-no-permission-checks.conf: "
          cat $HOME/.config/environment.d/98-kwin-no-permission-checks.conf
        ;;
        "Go Back")
          return 0
        ;;
        *)
          exit 0
        ;;
      esac
    }

    yeet_brew() {
      echo "${b}You may ignore the following errors as they are just cosmetic.${n}"
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      brew trust LizardByte/homebrew
      brew tap LizardByte/homebrew
      brew services stop sunshine 2>/dev/null || true
      brew unpin sunshine 2>/dev/null || true
      brew uninstall sunshine 2>/dev/null || true
      brew services stop sunshine-beta 2>/dev/null || true
      brew unpin sunshine-beta 2>/dev/null || true
      brew uninstall sunshine-beta 2>/dev/null || true
      brew untap LizardByte/homebrew 2>/dev/null || true
    }

    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal status"
      echo "  Use 'enable' to enable the Sunshine service"
      echo "  Use 'disable' to disable the Sunshine service"
      echo "  Use 'uninstall' to uninstall the Sunshine Homebrew packages"
      echo "  Use 'portal' to open the Sunshine management portal"
      echo "  Use 'virtual-monitor' to configure virtual monitors"
      echo "  Use 'exit' to exit without making changes"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit $?
    fi
      while true; do
      if [ "$OPTION" == "" ]; then
        case "$(get_status_token)" in
          "enable-deck")
            SERVICE_STATE="${yellow}${b}Enabled (Deck)${n}"
            ;;
          "enable")
            SERVICE_STATE="${green}${b}Enabled${n}"
            ;;
          "uninstall")
            SERVICE_STATE="${red}${b}Not Installed${n}"
            ;;
          *)
            SERVICE_STATE="${yellow}${b}Disabled${n}"
            ;;
        esac
        echo "Service is $SERVICE_STATE"
        OPTION=$(Choose "Enable" "Enable-Deck" "Disable Service" "Uninstall" "Open Portal" "Configure Virtual Monitor" "Exit")
      fi
      OPTION="${OPTION,,}"

      case "$OPTION" in
        enable-deck|"enable deck"|enable_deck)
          if [[ "$(get_status_token)" =~ "disable" ]]; then
            echo "Enabling service..."
            systemctl --user enable --now app-dev.lizardbyte.app.Sunshine
            press_any_key
            exit 0
          fi
          if [[ $(cat /etc/bazzite/image_name) =~ deck ]]; then
            echo "You are about to layer the ${yellow}Sunshine${n} package via rpm-ostree."
            echo "If you encounter issues with ${b}system updates${n}, reset ostree and try layering it again."
            echo "Read ${b}https://docs.bazzite.gg/Advanced/sunshine/#__tabbed_1_2${n} to learn more."
          else
            echo "This option is primarily intended for users of the Deck image as the flatpak package does not support capture via Kernel Mode Setting."
            echo "Installing ${yellow}Sunshine${n} stable with the normal ${b}'Enable Sunshine'${n} option will be better unless you encounter issues with XDG Portal/KWin Screencast capture options or need HDR."
            echo "Only proceed if you know what you are doing. Read ${b}https://docs.bazzite.gg/Advanced/sunshine/#__tabbed_1_2${n} to learn more."
          fi
          echo ""
          if confirm "Confirm to proceed with layering ${yellow}Sunshine${n}? (This will remove all existing Sunshine installations!)"; then
            echo "Disabling any previous ${yellow}Sunshine${n} services..."
            systemctl --user disable --now app-dev.lizardbyte.app.Sunshine || true
            echo "${b}Cleaning${n} up any existing stable ${yellow}Sunshine${n} installs before layering..."
            yeet_brew
            flatpak run --command=remove-additional-install.sh dev.lizardbyte.app.Sunshine || true
            flatpak uninstall -y dev.lizardbyte.app.Sunshine || true
            rpm-ostree install sunshine
            if [[ $(cat /etc/bazzite/image_name) =~ deck ]]; then
              echo "${b}Deck Image detected.${n} Automatically configuring options for streaming on Game Mode..."
              SUNSHINE_CONF="$HOME/.config/sunshine/sunshine.conf"
              mkdir -p "$(dirname "$SUNSHINE_CONF")"
              if grep -q "^capture" "$SUNSHINE_CONF" 2>/dev/null; then
                sed -i 's/^capture=.*/capture = kms/' "$SUNSHINE_CONF"
              else
                echo "capture = kms" >> "$SUNSHINE_CONF"
              fi
              if grep -q "^system_tray" "$SUNSHINE_CONF" 2>/dev/null; then
                sed -i 's/^system_tray=.*/system_tray = disabled/' "$SUNSHINE_CONF"
              else
                echo "system_tray = disabled" >> "$SUNSHINE_CONF"
              fi
            fi
            echo "Reboot to apply changes."
            echo "Note that the ${yellow}Sunshine${n} service may not be enabled automatically. Run this entry through Bazzite Portal ${b}again${n} or run ${b}systemctl --user enable --now sunshine${n} to start it on next boot."
            press_any_key
          fi
          exit 0
          ;;

        enable)
          if deck_sunshine_installed; then
            echo "You already have ${yellow}Sunshine${n} installed via layering. To avoid conflicts, ${b}remove${n} it first before installing the flatpak version."
            press_any_key
            exit 0
          fi
          if [[ $(cat /etc/bazzite/image_name) =~ deck ]]; then
            echo "Deck Images make use of Valve's gamescope microcompositor while in Game Mode."
            echo "To stream on Game Mode, capture using ${b}Kernel Mode Setting${n} must be used, which is not supported by the Flatpak package."
            echo "Read ${b}https://docs.bazzite.gg/Advanced/sunshine/#limitations-of-the-flatpak-package${n} to learn more."
            if ! confirm "You may still stream on Desktop Mode by installing the flatpak. Continue?"; then
              echo "Exiting..."
              exit 0
            fi
          fi
          echo "Disabling any previous Flatpak ${yellow}Sunshine${n} service..."
          systemctl --user disable --now app-dev.lizardbyte.app.Sunshine || true
          if [[ "$(get_status_token)" == "enable-brew" ]]; then
            yeet_brew
          fi
          flatpak install --system -y dev.lizardbyte.app.Sunshine
          flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine
          systemctl --user enable --now app-dev.lizardbyte.app.Sunshine
          exit 0
          ;;

        disable|"disable service")
          systemctl --user disable --now app-dev.lizardbyte.app.Sunshine || true
          exit 0
          ;;

        uninstall)
          systemctl --user disable --now app-dev.lizardbyte.app.Sunshine || true
          if brew_sunshine_installed; then
            yeet_brew
          fi
          if deck_sunshine_installed; then
            rpm-ostree remove sunshine
          fi
          if sunshine_installed; then
            flatpak run --command=remove-additional-install.sh dev.lizardbyte.app.Sunshine || true
            if confirm "Also delete ${yellow}Sunshine${n} configurations?"; then
              flatpak uninstall --delete-data -y dev.lizardbyte.app.Sunshine || true
            else
              flatpak uninstall -y dev.lizardbyte.app.Sunshine || true
            fi
          fi
          echo "${yellow}Sunshine${n} is now uninstalled."
          echo "Reboot to apply changes."
          press_any_key
          exit 0
          ;;

        virtual-monitor|"configure virtual monitor")
          virtual-monitor
          OPTION=""
          ;;

        portal|open|"open portal")
          echo "Opening ${yellow}Sunshine${n} management portal..."
          xdg-open https://localhost:47990
          exit 0
          ;;

        exit)
          echo "Exiting without making changes."
          exit 0
          ;;

        *)
          echo "Unknown option: $OPTION"
          exit 1
          ;;
      esac
    done
