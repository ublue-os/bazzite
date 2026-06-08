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
      flatpak info dev.lizardbyte.app.Sunshine >/dev/null 2>&1
    }
    brew_sunshine_installed() {
      [[ -e /home/linuxbrew/.linuxbrew/opt/sunshine ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine ||
        -e /home/linuxbrew/.linuxbrew/opt/sunshine-beta ||
        -d /home/linuxbrew/.linuxbrew/Cellar/sunshine-beta ]]
    }
    get_status_token() {
      local flatpak_service_state beta_service_state service_state
      flatpak_service_state="$(systemctl is-enabled --user app-dev.lizardbyte.app.Sunshine 2>/dev/null || true)"
      if [[ "$flatpak_service_state" == "enabled" ]]; then
        echo "enable"
      elif brew_sunshine_installed; then
        echo "enable-brew"
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
        systemctl --user edit --stdin homebrew.sunshine-beta <<< "$servicefile"
      fi
    }
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-sunshine <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal status"
      echo "  Use 'enable' to enable the Sunshine service"
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
        "enable-brew")
          SERVICE_STATE="${yellow}${b}Enabled (Brew)${n}"
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
      if [[ $(cat /etc/bazzite/image_name) =~ deck ]]; then
        echo "You are about to install the experimental ${yellow}Sunshine Beta${n} package via brew."
        echo "If you encounter issues with the ${yellow}Sunshine Beta${n} brew package, consider layering from either the official or community-maintained COPR."
        echo "Read ${b}http://docs.bazzite.gg/Advanced/sunshine/#setting-up-sunshine-on-deck-images${n} to learn more."
      else
        echo "This option is primarily intended for users of the Deck image as the flatpak package does not support capture via Kernel Mode Setting."
        echo "Installing ${yellow}Sunshine${n} stable with the ${b}'Enable Sunshine'${n} option is going to be better for just about everyone else."
        echo "You may also use this to install ${yellow}Sunshine Beta${n} as Sunshine does not provide a beta repo for their flatpak."
        echo "Alternatively, you may also install sunshine by: "
        echo "  1) obtaining and installing the beta flatpak manually from their GitHub repository;"
        echo "  2) layering from either the official or community-maintained COPR."
        echo "Only proceed if you know what you are doing. Read ${b}http://docs.bazzite.gg/Advanced/sunshine/#installing-sunshine-beta${n} to learn more."
      fi
      echo ""
      if confirm "Confirm to proceed with installing the ${b}experimental${n} ${yellow}Sunshine Beta${n} package via brew? (This will remove any existing Sunshine installation!)"; then
        echo "Disabling any previous ${yellow}Sunshine${n} services..."
        systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
        if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
          echo "Setting up Homebrew environment..."
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        brew tap LizardByte/homebrew
        echo "${b}Cleaning${n} up any existing stable ${yellow}Sunshine${n} install before installing beta..."
        flatpak run --command=remove-additional-install.sh dev.lizardbyte.app.Sunshine || true
        flatpak uninstall -y dev.lizardbyte.app.Sunshine || true
        brew services stop sunshine || true
        brew unpin sunshine || true
        brew uninstall sunshine || true
        brew install sunshine-beta
        brew pin sunshine-beta
        if ! sunshine_bin="$(command -v sunshine)"; then
          echo "${yellow}Sunshine${n} was not found on PATH after installation." >&2
          exit 1
        fi
        sudo /usr/libexec/sunshine-postinst
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
        brew services start sunshine-beta
        override_service
      fi
    elif [[ "${OPTION,,}" =~ ^enable ]]; then
      if [[ $(cat /etc/bazzite/image_name) =~ deck ]]; then
        echo "Deck Images make use of Valve's gamescope microcompositor while in Game Mode."
        echo "To stream on Game Mode, capture using ${b}Kernel Mode Setting${n} must be used, which is not supported by the Flatpak package."
        echo "Read ${b}http://docs.bazzite.gg/Advanced/sunshine/#setting-up-sunshine-on-deck-images${n} to learn more."
        if ! confirm "You may still stream on Desktop Mode by installing the flatpak. Continue?"; then
          echo "Exiting..."
          exit 0
        fi
      fi
      echo "Disabling any previous Flatpak ${yellow}Sunshine${n} service..."
      systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
      if [[ "$(get_status_token)" == "enable-brew" ]]; then
        if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
          echo "Setting up Homebrew environment..."
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        brew tap LizardByte/homebrew
        echo "Cleaning up any existing brew ${yellow}Sunshine${n} installs"
        brew services stop sunshine-beta || true
        brew unpin sunshine-beta || true
        brew uninstall sunshine-beta || true
        brew services stop sunshine || true
        brew unpin sunshine || true
        brew uninstall sunshine || true
      fi
      flatpak install --system -y dev.lizardbyte.app.Sunshine
      flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine
      systemctl --user enable --now app-dev.lizardbyte.app.Sunshine

    elif [[ "${OPTION,,}" =~ ^(update|upgrade) ]]; then
      if [[ "$(get_status_token)" == "uninstall" ]]; then
        echo "An upgrade was attempted but ${yellow}Sunshine${n} was not installed." >&2
        exit 1
      fi
      if [[ "$(journalctl --no-hostname -b 0 -g 'Setting default sink to:')" != "-- No entries --" ]]; then
        if ! confirm "Updating ${yellow}Sunshine${n} while streaming may leave you with a broken stream if you don't have physical access to the machine! Continue anyways?"; then
          echo "Exiting..."
          exit 0
        fi
      fi
      if [[ "$(get_status_token)" == "enable-brew" ]]; then
        if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
          echo "Setting up Homebrew environment..."
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        brew services stop sunshine-beta || true
        brew unpin sunshine-beta || true
        brew upgrade sunshine-beta || true
        brew pin sunshine-beta
        sudo /usr/libexec/sunshine-postinst
        brew services start sunshine-beta
        override_service
      elif [[ "$(get_status_token)" == "enable" ]]; then
        flatpak update dev.lizardbyte.app.Sunshine
      fi
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      if [[ "$(get_status_token)" == "enable-brew" ]]; then
        if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
          echo "Setting up Homebrew environment..."
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        brew services stop sunshine || true
        brew services stop sunshine-beta || true
      fi
      systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
    elif [[ "${OPTION,,}" =~ ^uninstall ]]; then
      if [[ "$(get_status_token)" == "enable-brew" ]]; then
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
      else
        systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service || true
        flatpak run --command=remove-additional-install.sh dev.lizardbyte.app.Sunshine || true
        if confirm "Also delete ${yellow}Sunshine${n} configurations?"; then
          flatpak uninstall --delete-data -y dev.lizardbyte.app.Sunshine || true
        else
          flatpak uninstall -y dev.lizardbyte.app.Sunshine || true
        fi
      fi
      echo "${yellow}Sunshine${n} is now uninstalled."
    elif [[ "${OPTION,,}" =~ ^(portal|open) ]]; then
      echo "Opening ${yellow}Sunshine${n} management portal..."
      xdg-open https://localhost:47990
    elif [[ "${OPTION,,}" =~ ^exit ]]; then
      echo "Exiting without making changes."
      exit 0
    fi
