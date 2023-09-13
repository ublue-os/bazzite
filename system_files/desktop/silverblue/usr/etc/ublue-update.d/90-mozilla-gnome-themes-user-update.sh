#!/usr/bin/bash
shopt -s nullglob

# Flatpak Firefox
for firefox_gnome_theme in "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/"*".default"*"/chrome/firefox-gnome-theme/"; do
  if [ -d "$firefox_gnome_theme" ]; then
    cd "$firefox_gnome_theme"
    git pull
  fi
done

# Flatpak Thunderbird
for thunderbird_gnome_theme in "$HOME/.var/app/org.mozilla.Thunderbird/.thunderbird/"*".default"*"/chrome/thunderbird-gnome-theme/"; do
  if [ -d "$thunderbird_gnome_theme" ]; then
    cd "$thunderbird_gnome_theme"
    git pull
  fi
done
