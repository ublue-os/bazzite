nicknamenamenick | 2024-07-31 15:11:34 UTC | #1

# Linux Package Formats

> **Package formats ranked from most recommended for daily usage**:
>
> _(Click the name of each package format for more information on how to use it on Bazzite.)_
>
> 1. [Flatpak](Flatpak.md) - Universal package format using a permissions-based model; use for most graphical applications.
> 2. [`ujust`](ujust.md) - Custom scripts that can install applications maintained by Bazzite & Universal Blue
> 3. [Homebrew](Homebrew.md) - Install applications intended to run inside of the terminal.
> 4. [Distrobox](Distrobox.md) - Intended for legacy applications that do not support Flatpak and Homebrew, or for use as development boxes.
> 5. [AppImage](AppImage.md) - Portable universal package format that relies on specific host libraries at a system-level.
> 6. [`rpm-ostree`](rpm-ostree.md) - Layer Fedora packages at a system-level (**not recommended, use as a last resort**)!

# How do I run Windows applications?

> **Use a [WINE](https://www.winehq.org/) front-end**:
>
> _(Click the name of each WINE front-end to be taken to the project's website.)_
>
> - [Steam](https://store.steampowered.com/) (_pre-installed_) has a Windows compatibility layer built-in.
>   - Read the [Gaming Guide](https://universal-blue.discourse.group/docs?topic=31) for more information on setting up and using Proton.
> - [Lutris](https://lutris.net/about) (_pre-installed_) for non-Steam video games.
> - [Heroic](https://heroicgameslauncher.com/) for Epic Games, GOG, and Amazon Games integration.
> - [Bottles](https://usebottles.com/) for general-purpose applications or as an alternative to Lutris.
> - [itch](https://flathub.org/apps/io.itch.itch) for games on itch.io.
>   - Also comes pre-installed with a Windows compatibility layer.
> - [WineZGUI](https://github.com/fastrizwaan/WineZGUI) (_pre-installed_) for Windows applications that don’t require special considerations for their prefix.

# How do I install Android applications?

Follow the [Waydroid Setup Guide](Waydroid_Setup_Guide.md) to install Android applications on Bazzite.

> **Note**: Waydroid is **not supported** on other Universal Blue images like Aurora and Bluefin.

# Tutorials for Installing Other Software

- [Plex Media Server](https://universal-blue.discourse.group/t/video-tutorial-how-to-install-plex-media-server-using-distrobox-on-bazzite/1999) (**Note**: Podman or Docker is recommended over Distrobox)
- [Flash Games](https://universal-blue.discourse.group/t/how-to-run-old-browser-games-with-web-apps/486)

<hr>

# Video Showcase of Installing Software

> **Note**: This video is missing Homebrew.

<https://www.youtube.com/watch?v=ITuT23YrgPs>

<hr>

**Documentation Contributors**: [HikariKnight](https://github.com/HikariKnight)

**See also**: [Updates, Rollbacks, & Rebasing](Updates_Rollbacks_&_Rebasing.md)
