# vim: set ft=make :

# Setup and configure Sunshine Game Streaming host. Options: status | enable | enable-beta | update | disable | uninstall | portal
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
    sunshine_installed() {
      [[ -e /home/linuxbrew/.linuxbrew/opt/sunshine ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine ||
        -e /home/linuxbrew/.linuxbrew/opt/sunshine-beta ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine-beta ]]
    }
    get_status_token() {
      local beta_service_state service_state
      beta_service_state="$(systemctl is-enabled --user homebrew.sunshine-beta.service 2>/dev/null || true)"
      service_state="$(systemctl is-enabled --user homebrew.sunshine.service 2>/dev/null || true)"
      if [[ "$beta_service_state" == "enabled" ]]; then
        echo "enable-beta"
      elif [[ "$service_state" == "enabled" ]]; then
        echo "enable"
      elif sunshine_installed; then
        echo "disable"
      else
        echo "uninstall"
      fi
    }
    override_service() {
      servicefile="[Unit]
    After=graphical-session.target xdg-desktop-autostart.target xdg-desktop-portal.service

    [Service]
    ExecStartPre=/bin/sleep 5
    Restart=on-failure
    RestartSec=5s
    "
      if [[ $(systemctl --user cat homebrew.sunshine-beta | grep sleep 2>/dev/null || true) == "" ||  $(systemctl --user cat homebrew.sunshine-beta | grep sleep 2>/dev/null || true) == "" ]]; then
        if [[ "$(get_status_token)" == "enable" ]]; then
          systemctl --user edit --stdin homebrew.sunshine <<< "$servicefile"
        elif [[ "$(get_status_token)" == "enable-beta" ]]; then
          systemctl --user edit --stdin homebrew.sunshine-beta <<< "$servicefile"
        fi
      fi
    }
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal status"
      echo "  Use 'enable' to enable the Sunshine service"
      echo "  Use 'enable-beta' to enable the Sunshine beta service"
      echo "  Use 'disable' to disable the Sunshine service"
      echo "  Use 'uninstall' to uninstall the Sunshine Homebrew packages"
      echo "  Use 'portal' to open the Sunshine management portal"
      echo "  Use 'exit' to exit without making changes"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit $?
    elif [ "$OPTION" == "" ]; then
      case "$(get_status_token)" in
        "enable-beta")
          SERVICE_STATE="${green}${b}Enabled (Beta)${n}"
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
      OPTION=$(Choose "Enable" "Enable Beta" "Update" "Disable Service" "Uninstall" "Open Portal" "Exit")
    fi
    if [[ "${OPTION,,}" =~ ^enable[-[:space:]]beta ]]; then
      echo "Disabling any previous Flatpak Sunshine service..."
      systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        echo "Setting up Homebrew environment..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      brew tap LizardByte/homebrew
      echo "Cleaning up any existing stable Sunshine install before installing beta..."
      brew services stop sunshine || true
      brew unpin sunshine || true
      brew uninstall sunshine || true
      brew install sunshine-beta
      brew pin sunshine-beta
      if ! sunshine_bin="$(command -v sunshine)"; then
        echo "sunshine was not found on PATH after installation." >&2
        exit 1
      fi
      sudo /usr/libexec/sunshine-postinst
      brew services start sunshine-beta
      override_service
    elif [[ "${OPTION,,}" =~ ^enable ]]; then
      echo "Disabling any previous Flatpak Sunshine service..."
      systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        echo "Setting up Homebrew environment..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      brew tap LizardByte/homebrew
      echo "Cleaning up any existing beta Sunshine install before installing stable..."
      brew services stop sunshine-beta || true
      brew unpin sunshine-beta || true
      brew uninstall sunshine-beta || true
      brew install sunshine
      brew pin sunshine
      if ! sunshine_bin="$(command -v sunshine)"; then
        echo "sunshine was not found on PATH after installation." >&2
        exit 1
      fi
      sudo /usr/libexec/sunshine-postinst
      brew services start sunshine
      override_service
    elif [[ "${OPTION,,}" =~ ^(update|upgrade) ]]; then
      if [[ "$(get_status_token)" == "uninstall" ]]; then
        echo "An upgrade was attempted but Sunshine was not installed." >&2
        exit 1
      fi
      if [[ "$(journalctl --no-hostname -b 0 -g 'Setting default sink to:')" != "-- No entries --" ]]; then
        if ! confirm "Updating Sunshine while stream may leave you with a broken stream if you don't have physical access to the machine! Continue anyways?"; then
          echo "Exiting..."
          exit 0
        fi
      fi
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        echo "Setting up Homebrew environment..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      if [[ "$(get_status_token)" == "enable-beta" ]]; then
        brew services stop sunshine-beta || true
        brew unpin sunshine-beta || true
        brew upgrade sunshine-beta || true
        brew pin sunshine-beta
        sudo /usr/libexec/sunshine-postinst
        brew services start sunshine-beta
        override_service
      elif [[ "$(get_status_token)" == "enable" ]]; then
        brew services stop sunshine || true
        brew unpin sunshine || true
        brew upgrade sunshine || true
        brew pin sunshine
        sudo /usr/libexec/sunshine-postinst
        brew services start sunshine
        override_service
      fi
      if ! sunshine_bin="$(command -v sunshine)"; then
        echo "sunshine was not found on PATH after installation." >&2
        exit 1
      fi
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        echo "Setting up Homebrew environment..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      brew services stop sunshine || true
      brew services stop sunshine-beta || true
    elif [[ "${OPTION,,}" =~ ^uninstall ]]; then
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        echo "Setting up Homebrew environment..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      brew services stop sunshine || true
      brew services stop sunshine-beta || true
      brew unpin sunshine || true
      brew unpin sunshine-beta || true
      brew uninstall sunshine || true
      brew uninstall sunshine-beta || true
      echo "Sunshine is now uninstalled."
    elif [[ "${OPTION,,}" =~ ^(portal|open) ]]; then
      echo "Opening Sunshine management portal..."
      xdg-open https://localhost:47990
    elif [[ "${OPTION,,}" =~ ^exit ]]; then
      echo "Exiting without making changes."
      exit 0
    fi
