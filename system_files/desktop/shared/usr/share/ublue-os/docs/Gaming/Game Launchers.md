---
title: Game Launchers

---

# **Steam Setup**

Steam can run Windows games on Linux.  It utilizes a wide range of projects and patches all packed into a piece of software built-in to Steam called [Proton](https://github.com/ValveSoftware/Proton) for Windows compatibility.

## Enabling Proton For All Steam Games

>**Note**: Skip this section if you're using a *Handheld/HTPC* image.

* Currently Steam only allows whitelisted games to run by default on the desktop Steam client.
* You can change this by going into the Steam **Settings** > **Compatibility** > Check **Enable Steam Play for all other titles**

## Forcing A Specific Proton / Steam Play Tool Version

* Games with a Linux port will be used by default on Desktop images.
* Valve selects the default runner on *Handheld/HTPC* images.
* Some games run better with a specific version of Proton or forcing the Linux runtime.
    * Run that specific version by going into the game's **Properties** > **Compatibility** > **Force the use of a specific Steam Play compatibility tool**

# **Non-Steam Games**

* **It is recommended to use [Lutris](https://lutris.net/games?q=&ordering=-popularity&paginate_by=100) for _most_ non-steam games**.
* [Heroic Games Launcher](https://heroicgameslauncher.com) is intended as a suitable replacement for the Epic Games Launcher.
* [Bottles](https://usebottles.com/) is an alternative to Lutris and great for non-gaming Windows software.
* Other games and launchers are also available in the software center (_Discover_ or _GNOME Software_) like itch.io.

## Lutris Setup

Lutris is game management software that doubles as a WINE front-end for Windows games.  Several games and launchers can be installed by searching for the title and using one of the installer scripts for it.

### Manually adding a Windows game to Lutris

However if your game is not listed or doesn't work with the provided script, then manually add the executable.  Add locally installed game and make sure to configure it properly within the game and runner options.

### Lutris Shortcuts

Right clicking a game on Lutris gives the option to add it as a non-Steam game (useful for Steam Gaming Mode), create a desktop shortcut, or an application menu shortcut.

## Gamepass / Microsoft Store Games (Cloud Streaming)

Games installed from the Microsoft Store do **not** run on desktop Linux unless you use a xCloud client like [Greenlight](https://github.com/unknownskl/greenlight).

<hr>

**Documentation Contributors**: [Kyle Gospodnetich](https://github.com/KyleGospo), [RJ Trujillo](https://github.com/EyeCantCU), [Benjamin Shermin](https://github.com/bsherman), [Nathaniel Warburton](https://github.com/storyaddict), and [Jorge Castro](https://github.com/castrojo)

[**<-- View online documentation**](https://universal-blue.discourse.group/docs?topic=2656)