---
title: Desktop Environment Tweaks

---

# Customizing KDE Plasma

>A fantastic resource on KDE themes can be found [here](https://itsfoss.com/properly-theme-kde-plasma/) for more information.

KDE Plasma is the default Bazzite desktop environment and is highly customizable.  One of the various customization that can be done is installing custom styles, cursors, and icons to your system with custom themes made by the community.

Do **not** install themes with the built-in KDE system settings installer since it may not install properly because the filesystem is slightly different than most Linux operating systems.  Install themes manually into your Home directory and follow instructions from the author if necessary.

## Universal instructions for most custom themes

1. Download the theme manually from the [KDE Store](https://store.kde.org/browse/)
2. Extract the contents to `~/.local/share/plasma/` (**you may need to make this directory**)
2a. "Global themes" are placed in `~/.local/share/plasma/look-and-feel/` (**you may need to make this directory**)
2b. "Plasma themes" are placed in `~/.local/share/plasma/desktoptheme/` (**you may need to make this directory**)
2c.  SDDM* themes are placed in `/etc/sddm/themes` (**you may need to make this directory**)
2c1. SDDM* themes can also be layered at your own risk if they are available as RPM packages
2d. "Icon/Cursor themes" are placed in `~/.icons`
2da. Some Flatpaks need filesystem permissions for applications that have issues with cursor themes (`~/.icons/:ro` in "Filesystem" in each problematic application or globally in Flatseal)
3. Open system settings and select your theme, style, cursor, etc. as it now should appear

**SDDM is the login manager*.

### Themes that require `kvantum`

Some themes require [`kvantum`](https://github.com/tsujan/Kvantum/blob/master/Kvantum/README.md) to be installed on the host system.

Install it with this **command**:

```
rpm-ostree install kvantum
```

## Wallpaper Engine Guide (*Only on KDE Images*)

>**Note**: Not all wallpapers are compatible and may even cause issues since most are not intended for use on the Linux desktop.

[Wallpaper Engine](https://www.wallpaperengine.io/en) is a live wallpaper application intended for Windows.

Read this [guide](https://github.com/catsout/wallpaper-engine-kde-plugin/blob/main/README.md#usage) on how to set it up on KDE Plasma.

<hr>

# Manage GNOME Extensions(`-gnome`)

>**Note**: If your session crashes, then all of your extensions will be disabled.

Bazzite's GNOME variant uses [Extension Manager](https://flathub.org/apps/com.mattjakeman.ExtensionManager) by Matthew Jakeman to manage the desktop extensions. The application is included by default. You can access it via the [Logo Menu](https://github.com/Aryan20/Logomenu) (thanks Aryan Kaushik!)

## Upstream GNOME Experience:

- Turn off the AppIndicator extension and the Dash to Dock extension.

- Hide the GSConnect and/or Tailscale extensions by toggling them on/off as well. 

<hr>

# Steam Gaming Mode Tweaks (`-deck`)

Install [Decky Loader](https://decky.xyz/) then install [CSS Loader](https://docs.deckthemes.com/) to customize how Steam Gaming Mode looks.  Be aware that third-party plugins may cause issues.

<hr>

**Documentation Contributors**: [Jorge Castro](https://github.com/castrojo)

[**<-- View online Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=574)