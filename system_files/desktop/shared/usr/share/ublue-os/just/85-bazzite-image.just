# vim: set ft=make :

# Re-enable input remapper feature on non-desktop images
restore-input-remapper:
    systemctl enable --now input-remapper.service && \
    cp /usr/share/applications/input-remapper-gtk.desktop ~/.local/share/applications/input-remapper-gtk.desktop && \
    sed -i '/NoDisplay=true/d' ~/.local/share/applications/input-remapper-gtk.desktop
