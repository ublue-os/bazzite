# Install ProtonPlus from Flathub
get-protonplus:
    #!/usr/bin/bash
    flatpak install -y flathub com.vysp3r.ProtonPlus

# Add ProtonPlus to Steam Big Picture as a Non-Steam application
add-protonplus-to-steam:
    #!/usr/bin/bash
    /usr/bin/steamos-add-to-steam /var/lib/flatpak/exports/share/applications/com.vysp3r.ProtonPlus.desktop
