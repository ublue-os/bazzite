# Game Launchers

# **Steam Setup**

Steam can run Windows games on Linux. It utilizes a wide range of projects and patches all packed into a piece of software built-in to Steam called [Proton](https://github.com/ValveSoftware/Proton) for Windows compatibility.

## Enabling Proton For All Steam Games

> **Note**: Skip this section if you're using a [_Handheld/HTPC_](https://universal-blue.discourse.group/docs?topic=37) image.

- Currently Steam only allows whitelisted games to run by default on the desktop Steam client.
- You can change this by going into the Steam **Settings** > **Compatibility** > Check **Enable Steam Play for all other titles**

![Steam Settings|256x267, 75%](../img/steam_settings.png)
![Compatibility|589x499, 75%](../img/compatibility.png)

## Forcing A Specific Proton / Steam Play Tool Version

- Games with a Linux port will be used by default on Desktop images.
- Valve selects the default runner on _Handheld/HTPC_ images.
- Some games run better with a specific version of Proton or forcing the Linux runtime.
  - Run that specific version by going into the game's **Properties** > **Compatibility** > **Force the use of a specific Steam Play compatibility tool**

![Cog Icon > Properties|690x284, 75%](upload://zo1TyrRxr8Fu48ACJg34pWKvF7P.png)
![Compatibility tab|690x492, 75%](upload://iiTx9285kbPupqLDGX4ak4RIvdm.png)

# **Non-Steam Games**

- **It is recommended to use [Lutris](https://lutris.net/games?q=&ordering=-popularity&paginate_by=100) for _most_ non-steam games**.
- [Heroic Games Launcher](https://heroicgameslauncher.com) is intended as a suitable replacement for the Epic Games Launcher.
- [Bottles](https://usebottles.com/) is an alternative to Lutris and great for non-gaming Windows software.
- Other games and launchers are also available in the software center (_Discover_ or _GNOME Software_) like itch.io.

## Lutris Setup

![Lutris|617x500, 75%](upload://3s2iqYP1Q1ZeCpMaQapqhG4gR1V.png)

![Example of Lutris installers|623x500, 75%](upload://1WR6qGSLGJ0oRkdwvCFwhCZllq0.png)

Lutris is game management software that doubles as a WINE front-end for Windows games. Several games and launchers can be installed by searching for the title and using one of the installer scripts for it.

### Manually adding a Windows game to Lutris

However if your game is not listed or doesn't work with the provided script, then manually add the executable. Add locally installed game and make sure to configure it properly within the game and runner options.

![manually|632x496, 75%](upload://9NC0GjEllRMgpuaLmB2d5pcihgz.png)

![Lutris manually adding games|690x342, 75%](upload://yszYNbYIAwCw4otGldSK6C29Jus.png)

### Lutris Shortcuts

![Lutris_Right_Click_Menu|421x447, 75%](upload://qvbF55nS5md6nMp7L5w0V97EBLR.png)

Right clicking a game on Lutris gives the option to add it as a non-Steam game (useful for Steam Gaming Mode), create a desktop shortcut, or an application menu shortcut.

## Gamepass / Microsoft Store Games (Cloud Streaming)

Games installed from the Microsoft Store do **not** run on desktop Linux unless you use a xCloud client like [Greenlight](https://github.com/unknownskl/greenlight).

# Auto-Mounting Secondary Gaming Drives

View this [guide](https://universal-blue.discourse.group/docs?topic=970) for forcing secondary drives to automatically mount on boot. This is useful if you have games on this drive and do not want to manually mount it before starting Steam on Desktop images.

<hr>

[**<-- Back to Gaming Guide**](index.md)
