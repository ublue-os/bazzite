if test "$(id -u)" -gt "0" && test -d "$HOME"; then
    # Add default settings when there are no settings
    if test ! -e "$HOME"/.config/Code/User/settings.json; then
        mkdir -p "$HOME"/.config/Code/User
        cp -f /etc/skel.d/.config/Code/User/settings.json "$HOME"/.config/Code/User/settings.json
    fi
fi
