# vim: set ft=make :

alias configure-waydroid := setup-waydroid

# Launch Waydroid configuration helper
setup-waydroid ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    IMAGE_NAME=$(jq -r '."image-name"' < $IMAGE_INFO)
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-waydroid <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'init' to select Initialize Waydroid"
      echo "  Use 'configure' to select Configure Waydroid"
      echo "  Use 'gpu' to choose Select GPU for Waydroid"
      echo "  Use 'reset' to select Configure Waydroid"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Waydroid Setup${normal}"
      echo "Please read the $(Urllink "https://universal-blue.discourse.group/docs?topic=32" "Waydroid setup documentation") before continuing"
      OPTION=$(Choose "Initialize Waydroid" "Configure Waydroid" "Select GPU for Waydroid" "Reset Waydroid (also removes waydroid-related files from user folder)")
    fi
    if [[ "${OPTION,,}" =~ ^init ]]; then
      if [[ ! $IMAGE_NAME =~ "deck" && ! $IMAGE_NAME =~ "ally" && ! $IMAGE_NAME =~ "framegame" ]]; then
        sudo systemctl enable --now waydroid-container
      fi
      sudo waydroid init -c 'https://ota.waydro.id/system' -v 'https://ota.waydro.id/vendor'
      echo "Waydroid has been initialized, please run waydroid once before you Configure Waydroid"
    elif [[ "${OPTION,,}" =~ ^configure ]]; then
      git clone https://github.com/ublue-os/waydroid_script.git --depth 1 /tmp/waydroid_script
      python -m venv /tmp/waydroid_script/venv
      source /tmp/waydroid_script/venv/bin/activate
      sudo pip install -r /tmp/waydroid_script/requirements.txt
      sudo /tmp/waydroid_script/main.py
      deactivate
      sudo rm -rf /tmp/waydroid_script
    elif [[ "${OPTION,,}" =~ gpu ]]; then
      /usr/bin/waydroid-choose-gpu
    elif [[ "${OPTION,,}" =~ ^reset ]]; then
      echo "Resetting Waydroid"
      bash -c 'sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid'
      echo "Waydroid has been reset"
    fi
