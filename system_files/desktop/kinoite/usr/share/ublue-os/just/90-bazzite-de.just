# vim: set ft=make :

# Restore Bazzite Breeze GTK4 theme
restore-bazzite-breeze-gtk-theme:
    rm -f $HOME/.config/gtk-4.0/gtk.css
    rm -f $HOME/.config/gtk-4.0/kde_window_geometry.css
    cp /etc/skel/.config/gtk-4.0/gtk.css $HOME/.config/gtk-4.0/gtk.css
    cp /etc/skel/.config/gtk-4.0/kde_window_geometry.css $HOME/.config/gtk-4.0/kde_window_geometry.css

# Automatically download Bluefin's monthly dinosaur wallpapers
[group("system")]
toggle-dinosaurs hemisphere="north":
    #!/bin/bash
    source /usr/lib/ujust/ujust.sh

    if [[ "{{ hemisphere }}" != "north" && "{{ hemisphere }}" != "south" ]]; then
        echo "Error: Invalid hemisphere '{{ hemisphere }}'. Must be 'north' or 'south'."
        exit 1
    fi

    DINOSAUR_STATUS="$(systemctl --user is-enabled bluefin-wallpaper@{{ hemisphere }}.service 2>/dev/null || echo 'disabled')"

    echo "Bluefin dinosaur wallpapers ({{ hemisphere }}ern hemisphere) are currently: $DINOSAUR_STATUS"

    if [ "$DINOSAUR_STATUS" == "enabled" ]; then
        echo "Disable Bluefin dinosaur wallpapers?"
        OPTION=$(Choose Disable Cancel)
        if [ "$OPTION" = "Disable" ]; then
            systemctl --user disable --now bluefin-wallpaper@{{ hemisphere }}.service
            echo "${b}${red}Bluefin dinosaur wallpapers ({{ hemisphere }}ern hemisphere) disabled.${n}"
            echo "Wallpaper files remain in ~/.local/share/wallpapers/Bluefin/"
        fi
    else
        echo "Enable Bluefin dinosaur wallpapers for the {{ hemisphere }}ern hemisphere?"
        OPTION=$(Choose Enable Cancel)
        if [ "$OPTION" = "Enable" ]; then
            mkdir -p ~/.local/share/wallpapers/Bluefin
            systemctl --user enable --now bluefin-wallpaper@{{ hemisphere }}.service

            sleep 1
            if systemctl --user is-active --quiet bluefin-wallpaper@{{ hemisphere }}.service; then
                echo "${b}${green}Bluefin dinosaur wallpapers ({{ hemisphere }}ern hemisphere) enabled!${n}"
                echo "Wallpapers will be downloaded to ~/.local/share/wallpapers/Bluefin/"
                echo "The wallpaper will update automatically each month."
                filename="$HOME/.local/share/wallpapers/Bluefin/{{ hemisphere }}.avif"

                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                    var allDesktops = desktops();
                    for (var i = 0; i < allDesktops.length; i++) {
                        var d = allDesktops[i];
                        d.wallpaperPlugin = \"com.github.zzag.dynamic\";
                        d.currentConfigGroup = Array(\"Wallpaper\", \"com.github.zzag.dynamic\", \"General\");
                        d.writeConfig(\"Image\", \"file:///${filename}\");
                    }
                "
            else
                echo "${b}${red}Failed to start bluefin-wallpaper service.${n}"
                echo "Check the service status with:"
                echo "  systemctl --user status bluefin-wallpaper@{{ hemisphere }}.service"
            fi
        fi
    fi
