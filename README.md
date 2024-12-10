<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [🇨🇳](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---

# Table of Contents
- [About \& Features](#about--features)
  - [Desktop](#desktop)
  - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
    - [Alternative Handhelds](#alternative-handhelds)
  - [GNOME](#gnome)
  - [Features from Upstream](#features-from-upstream)
    - [Universal Blue](#universal-blue)
    - [Features from Fedora Linux (Kinoite \& Silverblue)](#features-from-fedora-linux-kinoite--silverblue)
- [Why](#why)
- [Showcase](#showcase)
- [Documentation](#documentation)
- [Custom Packages](#custom-packages)
- [Verification](#verification)
- [Secure Boot](#secure-boot)
- [Contributor Metrics](#contributor-metrics)
- [Star History](#star-history)
- [Special Thanks](#special-thanks)
- [Build Your Own](#build-your-own)
- [Join The Community](#join-the-community)
---

## About & Features

[Please see our website](https://bazzite.gg/) for a newcomer-friendly explanation of Bazzite. This readme will cover everything in-depth.

[Bazzite](https://bazzite.gg/) is an OCI image that serves as an alternative operating system for the [Steam Deck](https://www.steamdeck.com/), and a ready-to-game SteamOS-like for desktop computers and living room home theater PCs.

Bazzite is built from [ublue-os/main](https://github.com/ublue-os/main) and [ublue-os/nvidia](https://github.com/ublue-os/nvidia) using [Fedora](https://fedoraproject.org/) technology, which means expanded hardware support and built in drivers are included. Additionally, Bazzite adds the following features:

- Uses the [bazzite kernel](https://github.com/hhd-dev/kernel-bazzite) to achieve HDR and expanded hardware support, among numerous other included patches - based off of the [fsync kernel](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/).
- HDR available in Game mode.
- NVK available on non-Nvidia builds.
- Full hardware accelerated codec support for H264 decoding.
- Full support for AMD's ROCM OpenCL/HIP run-times.
- [xone](https://github.com/medusalix/xone) driver for Xbox controllers.
- Full support for [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Includes Valve's KDE themes from SteamOS.
- Features optional Valve-inspired GTK3/4 themes matching Vapor and VGUI2 from SteamOS. Install [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience) to make use of them.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), and [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) installed and available by default
- [Patched Switcheroo-Control](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) fixing default-broken iGPU/dGPU switching.
- Support for [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Only on KDE)</sup></sub>
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) included.
- Full support for [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) preinstalled with automatic updates for created containers.
- Simplified Davinci Resolve installation with [davincibox](https://github.com/zelikos/davincibox) (`ujust install-resolve`)
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) used as the default in all images. This terminal is specifically designed for the container workflow you'll use in Bazzite. KDE Konsole and GNOME Console can be installed as flatpaks if required.
- Automated `duperemove` service for reducing the disk space used by wine prefix contents.
- Support for HDMI CEC via [libCEC](https://libcec.pulse-eight.com/).
- Uses [Google's BBR TCP congestion control](https://github.com/google/bbr) by default.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) preinstalled and enabled. <sub><sup>(Available but default-disabled on the Deck variant, may be enabled with `ujust restore-input-remapper`)</sup></sub>
- Bazzite Portal provides an easy way to install numerous applications and tweaks, including installing [LACT](https://github.com/ilya-zlobintsev/LACT).
- [Waydroid](https://waydro.id/) preinstalled for running Android apps. Set it up with this [quick guide](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/).
- Manage applications using [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), and [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 and i2c-nct6775 drivers for controlling RGB on certain motherboards.
- [OpenRazer](https://openrazer.github.io) drivers built in, Select OpenRazer in Bazzite Portal or run `ujust install-openrazer` in a terminal to begin using it.
- [OpenTabletDriver](https://opentabletdriver.net/) udev rules built in, with the full software suite installable via Bazzite Portal or by running `ujust install-opentabletdriver` in a terminal.
- Out of the box support for [Wooting](https://wooting.io/) keyboards.
- Built in support for Southern Islands <sub><sup>(HD 7000)</sup></sub> and Sea Islands <sub><sup>(HD 8000)</sup></sub> AMD GPUs under the `amdgpu` driver.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) is available for Discord screensharing on Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) is available for creating applications from websites for a variety of browsers, including Firefox.

### Desktop

Common variant available as `bazzite`, suitable for desktop computers.

- Automatic updates for the OS, Flatpaks, and all Distrobox containers - powered by [ublue-update](https://github.com/ublue-os/ublue-update) and [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]  
> **ISOs can be downloaded from our [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image if you want **Open Source GPU Drivers**:
(Please note: Mesa's Open Source option for NVIDIA GPUs, NVK is still prone to errors at the time of writing, for any issues relating to NVK [please submit a report with Mesa]([url](https://docs.mesa3d.org/bugs.html)), not Ublue/Bazzite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

or for devices with Nvidia GPUs wanting the **NVIDIA Proprietary Drivers**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**For users with Secure Boot enabled:** Follow our [secure boot documentation](#secure-boot) prior to rebasing.

### Steam Deck/Home Theater PCs (HTPCs)
> [!IMPORTANT]  
Devices that are NOT the Steam Deck can still use the `bazzite-deck` images, but must use a modern AMD GPU. Intel Arc GPUs also have been confirmed to work.

Variant designed for usage as an alternative to SteamOS on the Steam Deck, and for a console-like experience on HTPCs, available as `bazzite-deck`:

- Directly boots to Game mode matching SteamOS's behavior.
- **Automatic `duperemove` greatly trims the size of compatdata.**
- **Latest version of Mesa creates smaller shader caches and does not require them to prevent stutter.**
- **Able to be booted even if the drive is full.**
- **Support for every language supported by upstream Fedora.**
- **Uses Wayland on the desktop with [support for Steam input](https://github.com/Supreeeme/extest).**
- Includes [HHD](https://github.com/hhd-dev/hhd) for expanded input support on non-Valve handhelds.
- Features ported versions of most SteamOS packages, including drivers, firmware updaters, and fan controllers [from the evlaV repository](https://gitlab.com/evlaV).
- Patched Mesa for proper framerate control from Gamescope.
- Comes with patches from [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) for full BTRFS support for the SD card by default.
- Ships with a ported copy of [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), enabled by default.
- Option to install [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), and [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), among numerous other useful packages on installation.
- Custom update system allows for the OS, Flatpaks, and Distrobox images to be updated directly from the Game mode UI powered by [ublue-update](https://github.com/ublue-os/ublue-update) and [topgrade](https://github.com/topgrade-rs/topgrade).
- Built in support for Windows dual-boot thanks to Fedora's installation of GRUB being left intact.
- Update break something? Easily roll back to the previous version of Bazzite thanks to `rpm-ostree`'s rollback functionality. You can even select previous images at boot.
- Steam and Lutris preinstalled on the image as layered packages.
- [Discover Overlay](https://github.com/trigg/Discover) for Discord pre-installed and automatically launches in both Game mode and on the Desktop if Discord is installed. [View the official documentation here](https://trigg.github.io/Discover/bazzite).
- Uses ZRAM<sub><sup>(4GB)</sup></sub> with the ZSTD compression algorithm by default with the option to switch back to a 1GB swap file and set a custom size for it if desired.
- [LAVD](https://crates.io/crates/scx_lavd) and [BORE](https://github.com/firelzrd/bore-scheduler) CPU Schedulers for smooth and responsive gameplay.
- Kyber I/O scheduler to prevent I/O starvation when installing games or during background `duperemove` process.
- Applies SteamOS's kernel parameters.
- Color calibrated display profiles for matte and reflective Steam Deck screens included.
- Default-disabled power-user features, including:
    - Service for low-risk undervolting of the Steam Deck as well as AMD Framework Laptops via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) and [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), see `ryzenadj.service` and `/etc/default/ryzenadj`.
    - Service for limiting the max charge level of the battery, see `batterylimit.service` and `/etc/default/batterylimit`. <sup><sub>(Works even when the device is off)</sub></sup>
    - Built in support for display overclocking. For example, add `CUSTOM_REFRESH_RATES=30-68` to `/etc/environment`. Minimum and maximum refresh rates differ per handheld!
    - 32GB RAM mod your Steam Deck? Enjoy double the maximum VRAM amount, automatically applied. <sup><sub>(Can you share your soldering skills?)</sub></sup>
- Steam Deck hardware-specific services can be disabled by running `ujust disable-bios-updates` and `ujust disable-firmware-updates` in the terminal. These are automatically disabled on non-Deck hardware, and on Decks with DeckHD displays or 32GB RAM mods.
- More information can be found [here](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/) on the Bazzite Steam Deck images.

> [!WARNING]  
> **Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time. Upgrading the storage resolves the issue.**

> [!IMPORTANT]  
> **ISOs can be downloaded from our [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Alternative Handhelds

Please refer to our [Handheld Wiki](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/) for required setting changes and Decky Loader plugins for Steam Gaming Mode on your specific Handheld.

**Be sure to also read the [hhd documentation](https://github.com/hhd-dev/hhd#after-install), some handhelds require specific setting changes/tweaks to function properly.**

We also ship `ujust` commands to install various [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) themes that can't be found on the CSS Loader store. These will be automatically updated with Bazzite if installed.
```bash
# Install Handheld Controller Theme (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

Builds with the GNOME desktop environment are available in both desktop and deck flavors. These builds come with the following additional features:

- [Variable refresh rate support and fractional scaling enabled under Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Custom menu in the top bar for returning to game mode, launching Steam, and opening a number of useful utilities.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) preinstalled and ready to use.
- [Hanabi extension](https://github.com/jeffshee/gnome-ext-hanabi) included to offer similar features to Wallpaper Engine in KDE.
- Numerous optional extensions pre-installed, including [important user experience fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatic updates for the [Firefox GNOME theme](https://github.com/rafaelmardojai/firefox-gnome-theme) and [Thunderbird GNOME theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(If installed)</sub></sup>

> [!IMPORTANT]  
> **ISOs can be downloaded from our [website](https://download.bazzite.gg), and a helpful install guide can be found [here](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebase from an existing upstream Fedora Atomic to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

To rebase an existing ostree system to a Desktop Environment with the **Proprietary NVIDIA Drivers** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]  
> **Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time.**

To rebase an existing ostree system to the **Steam Deck/HTPC** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**For users with Secure Boot enabled:** Follow our [secure boot documentation](#secure-boot) prior to rebasing.

### Features from Upstream

#### Universal Blue

- Proprietary Nvidia drivers pre-installed. <sub><sup>(Only for Nvidia images)</sup></sub>
- Flathub is enabled by default.
- [`ujust`](https://github.com/casey/just) commands for convenience.
- Multi-media codecs out of the box.
- Rollback Bazzite from any build within the last 90 days.

#### Features from Fedora Linux (Kinoite & Silverblue)

- A rock solid and stable base.
- System packages stay relatively up to date.
- Can layer Fedora packages to the image without losing them between updates.
- Security focused with [SELinux](https://github.com/SELinuxProject/selinux) preinstalled and configured out of the box.
- The ability to rebase to different Fedora Atomic images, if desired, without losing user data.
- Printing support thanks to [CUPS](https://www.cups.org/) being preinstalled.

## Why

Bazzite started as a project to resolve some of the issues that plague SteamOS, mainly out of date packages (despite an Arch base) and the lack of a functional package manager.

Despite this project also being image-based, you are able to install any Fedora package straight from the command line. These packages will persist across updates <sub><sup>(So go ahead and install that obscure VPN software you spent an hour trying to get working in SteamOS)</sup></sub>. Additionally, Bazzite is updated multiple times a week with packages from upstream Fedora, giving you the best possible performance and latest features - all on a stable base.

Bazzite ships with the latest Linux kernel and SELinux enabled by default with full support for secure boot <sub><sup>(Run `ujust enroll-secure-boot-key` and enter the password `universalblue` if prompted to enroll our key)</sup></sub> and disk encryption, making this a sensible solution for general computing. <sup><sub>(Yes, you can print from Bazzite)</sub></sup>

Read the [FAQ](https://docs.bazzite.gg/General/FAQ/) for details on what makes Bazzite stand out from other Linux based operating systems.

## Showcase

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentation

- [Installing and Managing Applications](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Updates, Rollbacks, and Rebasing](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [Gaming Guide](https://docs.bazzite.gg/Gaming/)

View [additional documentation](http://docs.bazzite.gg/) surrounding the project.

## Custom Packages

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) and [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

| Package                                                                                             | Status                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ds-inhibit                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)                                  |
| [extest](https://github.com/Supreeeme/extest)                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/extest/status_image/last_build.png?)                             |
| gamescope                                                                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/gamescope/status_image/last_build.png?)                          |
| [gamescope-session-plus](https://github.com/ChimeraOS/gamescope-session)                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-plus/status_image/last_build.png?)                      |
| [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam)                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-steam/status_image/last_build.png?)                     |
| gamescope-shaders                                                                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-shaders/status_image/last_build.png?)                           |
| galileo-mura                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/galileo-mura/status_image/last_build.png?)                                |
| [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-randr-rust/status_image/last_build.png?)                            |
| gnome-shell                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/gnome-shell/status_image/last_build.png?)                                  |
| gnome-shell-extension-bazzite-menu                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)          |
| [gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)       |
| [gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?) |
| [gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)                |
| [gnome-shell-extension-hotedge](https://github.com/jdoda/hotedge)                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hotedge/status_image/last_build.png?)               |
| [joystickwake](https://github.com/foresto/joystickwake)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/joystickwake/status_image/last_build.png?)                                |
| jupiter-fan-control                                                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)                         |
| jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| jupiter-sd-mounting-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| kf6-kio                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/kf6-kio/status_image/last_build.png?)                                      |
| [mangohud](https://github.com/flightlessmango/MangoHud)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)                           |
| mesa                                                                                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)                               |
| pipewire                                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/pipewire/status_image/last_build.png?)                           |
| powerbuttond                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/powerbuttond/status_image/last_build.png?)                                |
| [python3-hid](https://github.com/apmorton/pyhidapi)                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)                                 |
| [ryzenadj](https://github.com/FlyGoat/RyzenAdj)                                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)                                    |
| [scx-scheds](https://github.com/sched-ext/scx)                                                      | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/scx-scheds/status_image/last_build.png?)                                  |
| [sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)                                   |
| steamdeck-dsp                                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-dsp/status_image/last_build.png?)                               |
| steamdeck-gnome-presets                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-gnome-presets/status_image/last_build.png?)                     |
| steamdeck-kde-presets                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)                       |
| steamdeck-kde-presets-desktop                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)               |
| steam_notif_daemon                                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)                          |
| [ublue-update](https://github.com/ublue-os/ublue-update)                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ublue-update/status_image/last_build.png?)                                |
| udisks2                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)                                     |
| [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher)                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/umu-launcher/status_image/last_build.png?)                                |
| upower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/upower/status_image/last_build.png?)                                      |
| vpower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)                                      |
| [xwiimote-ng](https://github.com/dev-0x7C6/xwiimote-ng)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/xwiimote-ng/status_image/last_build.png?)                                 |

Additionally, the following packages are used from other Copr repos:

| Package                                                                                                       | Status                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [discover-overlay](https://github.com/trigg/Discover)                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/mavit/discover-overlay/package/discover-overlay/status_image/last_build.png?)                           |
| [hhd](https://github.com/hhd-dev/hhd)                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/package/hhd/status_image/last_build.png?)                                                   |
| [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/)                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/package/kernel/status_image/last_build.png?)                                        |
| [latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)                    |
| [nerd-fonts](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/package/nerd-fonts/status_image/last_build.png?)                                         |
| [noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)                       |
| [obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)                             |
| [ptyxis](https://gitlab.gnome.org/chergert/ptyxis)                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/ptyxis/status_image/last_build.png?)                                           |
| [rom-properties](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/package/rom-properties/status_image/last_build.png?)                           |
| [wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?) |
| [webapp-manager](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/package/webapp-manager/status_image/last_build.png?)                           |

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]  
> **Steam Deck Users: The Steam Deck does not come with secure boot enabled and does not ship with any keys enrolled by default. Do not enable this unless you absolutely know what you're doing.**

Secure boot is supported with our custom key. The pub key can be found in the root of this repository [here](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
If you'd like to enroll this key prior to installation or rebase, download the key and run the following:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

For users already on a Universal Blue image, you may instead run `ujust enroll-secure-boot-key`.

If asked for a password, use `universalblue`.

### Contributor Metrics

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

#### Star History

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Special Thanks

Bazzite is a community effort and wouldn't exist without everyone's support. Below are some of the people who've helped us along the way:

- [rei.svg](https://github.com/reisvg) - For creating our logo and overall branding.
- [SuperRiderTH](https://github.com/SuperRiderTH) - For creating our Steam game mode startup video.
- [evlaV](https://gitlab.com/evlaV) - For making Valve's code available and for being [this person](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - For gamescope-session and for valuable support along the way.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - For supporting us with technical issues and for creating a similar project. Seriously, go check it out. It's our Nix-based cousin.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - For assistance with needed kernel patches and for creating the [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) we now use.
- [nicknamenamenick](https://github.com/nicknamenamenick) - For being the MVP nearly single-handedly upkeeping our documentation and support literature, and countless cases of helping users.
- [Steam Deck Homebrew](https://deckbrew.xyz) - For choosing to support distributions other than SteamOS despite the extra work, and a special thanks to [PartyWumpus](https://github.com/PartyWumpus) for getting Decky Loader working with SELinux for us.
- [cyrv6737](https://github.com/cyrv6737) - For the initial inspiration and the base that became bazzite-arch.

## Build Your Own

Bazzite is built entirely in GitHub and creating your own custom version of it is as easy as forking this repository, adding a private signing key, and enabling GitHub actions.

[Familiarize yourself](https://docs.github.com/en/actions/security-guides/encrypted-secrets) on keeping secrets in github. You'll need to [generate a new keypair](https://docs.sigstore.dev/cosign/overview/) with cosign. The public key can be in your public repo <sub><sup>(Your users need it to check the signatures)</sup></sub>, and you can paste the private key in `Settings -> Secrets -> Actions` with the name `SIGNING_SECRET`.

We also ship a config for the popular [pull app](https://github.com/apps/pull) if you'd like to keep your fork in sync with upstream. Enable this app on your repo to keep track of Bazzite changes while also making your own modifications.

## Join The Community

- You can find us on the [Universal Blue Discord](https://discord.gg/f8MUghG5PB)
  - View the [archive](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) of support threads without an account.

- Discuss and create user guides over at the [Universal Blue Discourse Forums](https://universal-blue.discourse.group/c/bazzite/5).

- Follow Universal Blue on [Mastodon](https://fosstodon.org/@UniversalBlue).

[**View the full list of Bazzite resources and social presence**](https://docs.bazzite.gg/Resources/).
