<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=574", "fetched_at": "2024-09-03 16:43:19.212243+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Customizing KDE Plasma

>Resource on KDE themes can be found [here](https://itsfoss.com/properly-theme-kde-plasma/) for more information.

KDE Plasma is the default Bazzite desktop environment and is highly customizable.  One of the various customization that can be done is installing custom styles, cursors, and icons to your system with custom themes made by the community.

Do **not** install themes with the built-in KDE system settings installer since it may not install properly because the filesystem is slightly different than most Linux operating systems.  Install themes manually into your Home directory and follow instructions from the author if necessary.

![Directory|401x207, 75%](https://universal-blue.discourse.group/uploads/short-url/8N6JKQAYxVv6dcSCsUmMmKtR1Lm.png)

## Universal instructions for most custom themes

Step-by-step instructions to install custom themes on KDE Plasma.

1. Download the theme manually from the [KDE Store](https://store.kde.org/browse/)
2. Extracting the contents to `~/.local/share/plasma/` (you may need to make this directory)
3. Open the system settings and select your theme, style, cursor etc. as it now should appear


### Theme Extraction Locations

The location where specific KDE Plasma components will be extracted on the desktop.

#### Global Themes
Global themes are placed in `~/.local/share/plasma/look-and-feel/` (*you may need to make this directory*).

#### Plasma Themes
"Plasma themes" are placed in `~/.local/share/plasma/desktoptheme/` (*you may need to make this directory*).

#### SDDM (Login Manager) Themes
SDDM themes are placed in `/etc/sddm/themes` (*you may need to make this directory*).

SDDM themes can also be layered at your own risk if they are available as RPM packages.

#### Icon / Cursor Themes

"Icon/Cursor themes" are placed in `~/.icons`

#### Application Permissions to Use Themes
Some Flatpaks need filesystem permissions for applications that have issues with cursor themes.

**Example**: (`~/.icons/:ro` in "Filesystem" in each problematic application or globally in Flatseal).

#### Themes that require `kvantum`

Some themes require [`kvantum`](https://github.com/tsujan/Kvantum/blob/master/Kvantum/README.md) to be installed on the host system.

Install it with this **command**:

```
rpm-ostree install kvantum
```

## Wallpaper Engine Guide (*Only on KDE Images*)

>**Note**: Not all wallpapers are compatible and may even cause issues since most are not intended for use on the Linux desktop.

![KDE Wallpaper Settings|682x500, 75%](https://universal-blue.discourse.group/uploads/short-url/1zYRH67Nhl9JRUovBbeBDQDGzxT.jpeg)

**[Wallpaper Engine](https://www.wallpaperengine.io/en) is a live wallpaper application intended for Windows.**

![Wallpaper settings|549x500, 75%](https://universal-blue.discourse.group/uploads/short-url/fw4SsMtgkTiQulwjCZoTfnWqfMq.png)


Read this [guide](https://github.com/catsout/wallpaper-engine-kde-plugin/blob/main/README.md#usage) on how to set it up on KDE Plasma.

<hr>

# Manage GNOME Extensions (`-gnome` Images)

View the [Bluefin documentation](https://docs.projectbluefin.io/administration#managing-extensions) since most of the information will be relevant to Bazzite as well.

<hr>

# Steam Gaming Mode Tweaks (`-deck` Images)

>Decky Loader will sometimes have issues with new Steam and Gamescope updates, and may need to be uninstalled temporarily.

Install [Decky Loader](https://decky.xyz/) then install [CSS Loader](https://docs.deckthemes.com/) to customize how Steam Gaming Mode looks.  Be aware that third-party plugins may cause issues.  Read Bazzite's [Steam Gaming Mode documentation](https://universal-blue.discourse.group/docs?topic=37) to resolve common issues if you run into them after using Decky Loader.

<hr>

[**<-- View all Bazzite documentation**](https://docs.bazzite.gg)