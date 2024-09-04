<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2657", "fetched_at": "2024-09-03 16:43:07.954041+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Compatibility Layers

Windows games need to run through a **compatibility layer** (like Proton) on Bazzite.  KDE Plasma and GNOME images pre-install different, but similar compatibility layer managers.

>**KDE Plasma Images**: [**ProtonUp-Qt**](https://davidotek.github.io/protonup-qt/)

>**GNOME Images**: [**ProtonPlus**](https://github.com/Vysp3r/protonplus)

## Using ProtonUp-Qt/ProtonPlus

![ProtonUp-Qt Interface|690x388](https://universal-blue.discourse.group/uploads/short-url/axJP5hL63tKqadGDtjPveDan9YO.png)


Install and update to the latest [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom), [Luxtorpeda](https://github.com/luxtorpeda-dev/luxtorpeda), and other useful [SteamPlay tools](https://steamcommunity.com/games/221410/announcements/detail/1696055855739350561). 

> View the tested games with [**GE-Proton**](https://github.com/GloriousEggroll/proton-ge-custom/blob/master/README.md#tested-games).

>View the compatible games with [**Luxtorpeda**](https://luxtorpeda-dev.github.io/packages).

## Protontricks / Winetricks

![Protontricks|660x500](https://universal-blue.discourse.group/uploads/short-url/dZzL4IXXIlssBn0e8qtP7ikolBO.png)

Some games require [Protontricks](https://github.com/Matoking/protontricks) (pre-installed) or [Winetricks](https://github.com/Winetricks/winetricks) (for non-Steam games, included with Lutris) to function properly.

# Hidden Files in File Manager

Desktop Linux contains hidden files and directories that may include important files related to gaming.

**Show hidden files** by clicking the **hamburger menu** (*3 horizontal lines in the file manager*) and selecting "Show Hidden Files" to see every directory and file that is hidden by default

These directories and files all start with a `.` before it

# What is a Proton/WINE Prefix?

It's the glue that holds everything together when you run a game through Proton and also is responsible for containing any of the files the game would drop outside of the installation folder.

>*This installation folder for Steam games is usually in*:
`.../steamapps/common/<game>`


## Equivalent Windows Folders

Many PC games drop files in Windows folders like "My Documents" or "AppData" and both can be found in your prefix directory.  This prefix directory may be useful for modding your games, backing up your saves, or configuration files.

![AppID|690x482, 75%](https://universal-blue.discourse.group/uploads/short-url/1CPDDhgFLERDqt72yoH39J8Fgds.png)

For games on Steam, they are located in your `~/.steam/root/steamapps/compatdata/` folder, and then the **AppID number of the game**:
  -  This ID by going into the game's properties on Steam in the games `Properties > Updates > App ID`
  - Continue to `.../pfx/drive_c/` and wherever the game drops the file on Windows.  

## Broken Proton Prefix?

![Delete Proton Prefix|382x341, 75%](https://universal-blue.discourse.group/uploads/short-url/rrMIcHTej5uysXqsYegFA0xyAti.png)

> **Note**: Save files are located in the prefix, so backup the save file in there before deleting especially if the game does not support cloud saving.

1. Steam allows users to delete and reset their prefix only in Big Picture Mode (and Gaming  Mode) by going into the game's "Developer" settings (accessed with the 'cog' / game settings icon)
2. Select **Delete Proton files**

## Non-Steam Games Prefix Management

Non-Steam games can have the prefix folder anywhere you specify:
- By default Lutris uses `~/.wine` as the main folder.
  - However, sometimes it's also in `~/Games`.
- WineZGUI creates a prefix in `~/.var/app/io.github.fastrizwaan.WineZGUI/data/winezgui/Prefixes`.

# Modding Quick-Start

Steam Workshop is the easiest way to obtain mods, but is not supported for every title and requires you to own the game on Steam.  Some mod managers have Linux ports like [r2modman.](https://github.com/ebkr/r2modmanPlus)

[Steam Tinker Launch](https://github.com/sonic2kk/steamtinkerlaunch) may have useful settings for modding certain titles.  It can be installed via ProtonUp-Qt (for KDE images) or ProtonPlus (for GNOME images).  

Replace files and directories is still supported in both the game directory and prefix, but there may be some extra steps involved.  

Some mods require a "WINE DLL OVERRIDE" environment variable in the Steam launch options.

>**Example for DirectInput8 DLL Override**:
`WINEDLLOVERRIDES="dinput8=n,b" %command%` 

# Enhancements Pre-Installed on Bazzite

- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX) - Vendor agnostic alternative to Nvidia Reflex
- [vkBasalt](https://github.com/DadSchoorse/vkBasalt) - Vulkan post-processing layer with ReShade FX support
- [Mangohud](https://github.com/flightlessmango/Mangohud) - Hardware and frame-rate monitoring overlay

## Configuration Templates for DXVK, MangoHud, & vkBasalt

![Template|690x334, 50%](https://universal-blue.discourse.group/uploads/short-url/wDOFMQ8U5c7xqOSOEfZNt492RB5.png)

Bazzite users can use templates for some of the pre-installed tools which can be accessed by right clicking anywhere in the file manager.

<hr>

[**<-- Back to Gaming Guide**](https://universal-blue.discourse.group/docs?topic=31)