# vim: set ft=make :

# set up DLSS-Enabler upscaling and framegen mod. Allows FSR3 upscaling and framegen via DLSS equivalents in supported games
get-framegen ACTION="prompt":
  #!/usr/bin/bash
  source /usr/lib/ujust/ujust.sh

  OPTION={{ ACTION }}

  if [ "$OPTION" == "prompt" ]; then
    echo "What would you like to do with FGmod?"
    OPTION=$(ugum choose "Install FGmod" "Uninstall FGmod" "Exit without changes")
  elif [ "$OPTION" == "help" ]; then
    echo "Usage: ujust get-framegen <option>"
    echo "  <option>: Specify an action - 'install' or 'uninstall'"
    echo "  Use 'install' to install FGmod."
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
  elif [ "${OPTION,,}" == "uninstall fgmod" ]; then
    echo "Uninstalling FGmod..."

    # Remove ~/fgmod directory if it exists
    if [[ -d "$HOME/fgmod" ]]; then
      rm -rf "$HOME/fgmod"
    fi

    # Remove specific files from ~/Downloads if they exist
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