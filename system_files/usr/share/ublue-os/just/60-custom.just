# Copy the Mango dotfiles, themes and wallpapers into ~/.config/mango
mango-setup:
    /usr/bin/bazzite-mango-setup

# Install the Flatpak apps the Mango keybindings launch (Firefox, GIMP, OBS, Discord)
mango-apps:
    flatpak install --user -y flathub org.mozilla.firefox org.gimp.GIMP com.obsproject.Studio com.discordapp.Discord
