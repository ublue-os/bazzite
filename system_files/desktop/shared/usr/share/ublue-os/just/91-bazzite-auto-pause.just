# vim: set ft=make :

# Configure auto-pause on suspend/resume for running games. Can fix audio crackling on wake. May cause problems with some games. Check out Pause Games Decky plugin for finer control.
[group("gaming")]
setup-auto-pause ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    SERVICE_FILE="$HOME/.config/systemd/user/bazzite-auto-pause.service"

    if systemctl --user is-enabled bazzite-auto-pause.service &>/dev/null; then
      echo "Current status: ${green}${bold}enabled${normal}"
      CHOICE=$(ugum choose "Disable auto-pause" "Exit without changes")
      if [[ "$CHOICE" == "Disable auto-pause" ]]; then
        systemctl --user disable --now bazzite-auto-pause.service 2>/dev/null || true
        rm -f "$SERVICE_FILE"
        systemctl --user daemon-reload
        echo "Auto-pause service ${red}${bold}disabled${normal} and service file removed."
      else
        echo "No changes made."
      fi
    else
      echo "Current status: ${red}${bold}disabled${normal}"
      CHOICE=$(ugum choose "Enable auto-pause" "Exit without changes")
      if [[ "$CHOICE" == "Enable auto-pause" ]]; then
        mkdir -p "$(dirname "$SERVICE_FILE")"
        {
          echo "[Unit]"
          echo "Description=Bazzite Auto-Pause Service"
          echo "After=graphical-session.target"
          echo ""
          echo "[Service]"
          echo "Type=simple"
          echo "ExecStart=/usr/libexec/bazzite-auto-pause/auto-pause-daemon"
          echo "Restart=on-failure"
          echo "RestartSec=5"
          echo ""
          echo "[Install]"
          echo "WantedBy=default.target"
        } > "$SERVICE_FILE"
        systemctl --user daemon-reload
        systemctl --user enable --now bazzite-auto-pause.service
        echo "Auto-pause service ${green}${bold}enabled${normal}."
        echo "Games will now automatically pause before system suspend and resume after wake."
      else
        echo "No changes made."
      fi
    fi
