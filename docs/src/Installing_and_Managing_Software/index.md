<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=35", "fetched_at": "2024-09-03 16:43:05.697052+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Linux Package Formats

> **Package formats ranked from most recommended for daily usage**:
> 
> 1. [Flatpak](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/Flatpak/) - Universal package format using a permissions-based model; use for most graphical applications.
> 2. [`ujust`](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/ujust/) - Custom scripts maintained by Bazzite & Universal Blue contributors that can install applications.
> 3.  [Homebrew](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/Homebrew/) - Install applications intended to run inside of the terminal (CLI/TUI).
> 4. [Distrobox](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/Distrobox/) - Intended for legacy applications that do not support Flatpak and Homebrew, or for use as development boxes.
> 5. [AppImage](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/AppImage/) - Portable universal package format that relies on specific host libraries at a system-level, usually obtained from a project's website.
> 6. [`rpm-ostree`](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/rpm-ostree/) - Layer Fedora packages at a system-level (**not recommended, use as a last resort**)


# How do I run Windows applications?

> **Use a [WINE](https://www.winehq.org/) front-end**:
>
> * [Steam](https://store.steampowered.com/) (*pre-installed*) has a Windows compatibility layer built-in.
> * [Lutris](https://lutris.net/about) (*pre-installed*) for non-Steam video games.
> * [Heroic](https://heroicgameslauncher.com/) for Epic Games, GOG, and Amazon Games integration.
> * [Bottles](https://usebottles.com/) for general-purpose applications or as an alternative to Lutris.
> * [itch](https://flathub.org/apps/io.itch.itch) for games on itch.io. 
> * [WineZGUI](https://github.com/fastrizwaan/WineZGUI) (*pre-installed*) for Windows applications that don’t require special considerations for their prefix.

# How do I install Android applications?


Follow the [Waydroid Setup Guide](https://universal-blue.discourse.group/docs?topic=32) to install Android applications on Bazzite.

>**Note**: Waydroid is **not supported** on other Universal Blue images like Aurora and Bluefin.

# Tutorials for Installing Other Software

- [Plex Media Server](https://universal-blue.discourse.group/t/video-tutorial-how-to-install-plex-media-server-using-distrobox-on-bazzite/1999) (**Note**: Podman or Docker is recommended over Distrobox)
- [Flash Games](https://universal-blue.discourse.group/t/how-to-run-old-browser-games-with-web-apps/486)


<hr>

# Video Showcase of Installing Software

>**Note**: This video is missing Homebrew.

https://www.youtube.com/watch?v=ITuT23YrgPs

<hr>

**Documentation Contributors**: [HikariKnight](https://github.com/HikariKnight)

**See also**: [Updates, Rollbacks, & Rebasing](https://universal-blue.discourse.group/docs?topic=36)

<-- [**View all Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=561)