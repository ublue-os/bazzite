#!/bin/bash
# Bazzite DX + MangoWC: the package set of drew's mangowc-setup
# (https://justaguy.dev/drew/mangowc-setup), translated from Debian to Fedora,
# plus Paul's dotfiles. KDE Plasma from the base image stays as a fallback.

set -ouex pipefail

### COPRs — the packages Fedora doesn't carry (or carries too old)
# mango + scenefx, quickshell 0.3 (Fedora has 0.2), awww, nwg-look/displays.
COPRS=(
    gregoryloscombe/mangowc
    errornointernet/quickshell
    dpavle/wallpaper-utils
    yselkowitz/nwg-shell
)
for c in "${COPRS[@]}"; do dnf5 -y copr enable "$c"; done

### Packages, grouped like mangowc-setup's install.sh
PACKAGES=(
    # core
    mangowc awww xorg-x11-server-Xwayland
    # bar (power-profiles-daemon is left out: Bazzite's tuned-ppd provides it)
    quickshell rofi dunst libnotify
    pamixer playerctl brightnessctl wlsunset network-manager-applet
    # wayland
    grim slurp wl-clipboard cliphist wlr-randr swayidle swaylock wlopm
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    # ui
    nwg-look nwg-displays wdisplays xsettingsd lxpolkit
    # file manager
    nautilus gvfs-smb gvfs-fuse udiskie
    # audio
    pavucontrol
    # utilities
    acpi fd-find eog blueman gnome-pomodoro geany kitty
    # fonts
    fontawesome4-fonts google-noto-color-emoji-fonts
    # theme build deps (removed again below)
    sassc
)
dnf5 -y install "${PACKAGES[@]}"

# Disable COPRs so they don't end up enabled on the final image
for c in "${COPRS[@]}"; do dnf5 -y copr disable "$c"; done

### Nerd Fonts used by the dotfiles (bar, rofi, dunst, kitty)
NF=/usr/share/fonts/nerd-fonts
mkdir -p "$NF"
for font in JetBrainsMono FiraCode SourceCodePro; do
    mkdir -p "$NF/$font"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz" |
        tar -xJ -C "$NF/$font"
done
fc-cache -f "$NF"

### GTK + icon themes (vinceliuice), same variants as butterscripts'
### install_wallpaper_theme.sh. wallpaper-theme recolours Orchis-Dark-Nord.
SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vinceliuice/Orchis-theme.git "$SRC/orchis"
(cd "$SRC/orchis" && ./install.sh -d /usr/share/themes -c dark -t default --tweaks nord)
rm -rf /usr/share/themes/Orchis-Dark-Nord-{hdpi,xhdpi} /usr/share/themes/Orchis-Dark-Compact-Nord*

git clone --depth 1 https://github.com/vinceliuice/Colloid-icon-theme.git "$SRC/colloid"
cd "$SRC/colloid"
./install.sh -d /usr/share/icons -s default
./install.sh -d /usr/share/icons -t orange
./install.sh -d /usr/share/icons -s gruvbox
./install.sh -d /usr/share/icons -s everforest
./install.sh -d /usr/share/icons -s nord
./install.sh -d /usr/share/icons -s dracula
./install.sh -d /usr/share/icons -s catppuccin
./install.sh -d /usr/share/icons -t grey -s dracula
cd /
# keep only the dark variants the theme script picks from
find /usr/share/icons -maxdepth 1 -name 'Colloid*' ! -name '*-Dark' -exec rm -rf {} +

### Wallpapers + Omarchy themes, shipped read-only and copied to
### ~/.config/mango by `ujust mango-setup`
DATA=/usr/share/bazzite-mango
git clone --depth 1 https://github.com/drewgrif/wallpapers.git "$DATA/wallpaper"
rm -rf "$DATA/wallpaper/.git"
git clone --depth 1 --filter=blob:none --sparse https://github.com/basecamp/omarchy.git "$SRC/omarchy"
git -C "$SRC/omarchy" sparse-checkout set themes
cp -a "$SRC/omarchy/themes" "$DATA/omarchy-themes"

rm -rf "$SRC"
dnf5 -y remove sassc

### System files: mango-session wrapper, portals, ujust recipe, dotfiles.
### Copied last so they win over anything the packages ship.
cp -avf /ctx/system_files/. /
chmod +x /usr/bin/mango-session /usr/bin/bazzite-mango-setup "$DATA"/config/scripts/*

### Sanity checks: fail the build rather than ship a broken session
mango -v
mango -p -c "$DATA/config/config.conf"
command -v qs awww awww-daemon mmsg
