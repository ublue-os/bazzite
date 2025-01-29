# vim: set ft=make :

# set up DLSS-Enabler upscaling and framegen mod. Allows FSR3 upscaling and framegen via DLSS equivalents in supported games
get-framegen ACTION="prompt":
  #!/usr/bin/bash
  source /usr/lib/ujust/ujust.sh

  OPTION={{ ACTION }}

  if [ "$OPTION" == "prompt" ]; then
    echo "What would you like to do with FGmod?"
    OPTION=$(ugum choose "Install Decky Framegen plugin" "Install FGmod" "Uninstall FGmod" "Exit without changes")
  elif [ "$OPTION" == "help" ]; then
    echo "Usage: ujust get-framegen <option>"
    echo "  <option>: Specify an action - 'install', 'install-decky-plugin', or 'uninstall'"
    echo "  Use 'install' to install FGmod."
    echo "  Use 'install-decky-plugin' to install the Decky Framegen plugin."
    echo "  Use 'uninstall' to remove FGmod."
    exit 0
  fi

  if [ "${OPTION,,}" == "install fgmod" ]; then
    echo "Installing FGmod..."
    TMP_DIR=$(mktemp -d) && cd "$TMP_DIR"
    git clone https://github.com/xXJSONDeruloXx/fgmod-bazzite.git .
    chmod +x prepare.sh
    ./prepare.sh
    echo "FGmod installed successfully!"
    echo "Add launch option '~/fgmod/fgmod %COMMAND%' to the game you want to patch"

  elif [ "${OPTION,,}" == "install decky framegen plugin" ]; then
    echo "Installing Decky Framegen plugin..."

    # Get the latest release URL dynamically
    API_URL="https://api.github.com/repos/xXJSONDeruloXx/Decky-Framegen/releases/latest"
    PLUGIN_URL=$(curl -s "$API_URL" | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)

    if [ -z "$PLUGIN_URL" ]; then
      echo "Failed to fetch the latest Decky Framegen release. Exiting..."
      exit 1
    fi

    PLUGIN_NAME="Decky-Framegen"
    PLUGIN_DIR="$HOME/homebrew/plugins"

    if [ ! -d "$PLUGIN_DIR" ]; then
      echo "Creating plugins directory with sudo..."
      sudo mkdir -p "$PLUGIN_DIR"
    fi

    cd "$PLUGIN_DIR" || { echo "Failed to navigate to plugins directory"; exit 1; }

    if [ -d "$PLUGIN_NAME" ]; then
      echo "Removing existing $PLUGIN_NAME directory with sudo..."
      sudo rm -rf "$PLUGIN_NAME"
    fi

    echo "Downloading $PLUGIN_NAME from $PLUGIN_URL..."
    sudo curl -L -o "${PLUGIN_NAME}.zip" "$PLUGIN_URL"

    if [ $? -ne 0 ]; then
      echo "Download failed!"
      exit 1
    fi

    echo "Extracting $PLUGIN_NAME..."
    sudo unzip -o "${PLUGIN_NAME}.zip" -d .

    if [ $? -ne 0 ]; then
      echo "Extraction failed!"
      exit 1
    fi

    if [ -d "./${PLUGIN_NAME}/${PLUGIN_NAME}" ]; then
      echo "Fixing folder structure..."
      sudo mv ./${PLUGIN_NAME}/${PLUGIN_NAME}/* ./${PLUGIN_NAME}/
      sudo rm -rf ./${PLUGIN_NAME}/${PLUGIN_NAME}
    fi

    echo "Cleaning up..."
    sudo rm -f "${PLUGIN_NAME}.zip"
    echo "$PLUGIN_NAME has been installed successfully to $PLUGIN_DIR!"
    echo "Please restart Decky Loader to activate the plugin."

  elif [ "${OPTION,,}" == "uninstall fgmod" ]; then
    echo "Uninstalling FGmod..."

    if [[ -d "$HOME/fgmod" ]]; then
      rm -rf "$HOME/fgmod"
    fi

    downloads_dir="$HOME/Downloads"
    files_to_remove=("prepare.sh" "fgmod.sh" "fgmod-uninstaller.sh")

    for file in "${files_to_remove[@]}"; do
      if [[ -f "$downloads_dir/$file" ]]; then
        rm "$downloads_dir/$file"
      fi
    done

    echo "FGmod removed successfully!"

  elif [ "${OPTION,,}" == "exit without changes" ]; then
    echo "No changes made. Exiting..."
    exit 0
  else
    echo "Invalid option. Exiting..."
    exit 1
  fi