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

# Restore the "Return to Gaming Mode" shortcut on the Desktop
restore-gamemode-shortcut:
    #!/usr/bin/bash
    # Define paths
    SHORTCUT_FILE="$HOME/Desktop/Return.desktop"
    SKEL_FILE="/etc/skel/Desktop/Return.desktop"
    # Check if the shortcut already exists
    if [ -f "$SHORTCUT_FILE" ]; then
        echo "The shortcut 'Return to Gaming Mode' already exists at $SHORTCUT_FILE."
        echo "No changes were made."
        exit 0
    fi
    # Check if the original file exists in skel
    if [ ! -f "$SKEL_FILE" ]; then
        echo "Error: The original file does not exist at $SKEL_FILE."
        echo "Unable to restore the shortcut."
        exit 1
    fi
    # Copy the file from skel to the desktop
    echo "Restoring the 'Return to Gaming Mode' shortcut from $SKEL_FILE..."
    mkdir -p "$HOME/Desktop"  # Ensure the Desktop directory exists
    cp "$SKEL_FILE" "$SHORTCUT_FILE"
    # Ensure the file is executable
    chmod +x "$SHORTCUT_FILE"
    echo "Shortcut restored successfully at $SHORTCUT_FILE."
    echo "Note: The first time you use the shortcut, it may ask you to trust it. Please accept."