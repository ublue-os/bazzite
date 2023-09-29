<p align="center">
  <img src="/repo_content/logo.png?raw=true" alt="Bazzite Logo"/>
</p>
<p align="center">
  <img src="/repo_content/text_logo.png?raw=true" alt="Bazzite"/>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml)
[![build-bazzite-arch](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml)

---
# Table of Contents
- [Features for **All** Bazzite Images](https://github.com/ublue-os/bazzite#about--features)
  - [Features for **Desktop** Images](https://github.com/ublue-os/bazzite#desktop)
  - [Features for **Steam Deck / HTPC** Images](https://github.com/ublue-os/bazzite#steam-deckhome-theater-pcs-htpcs)
  - [Features for **GNOME** Images](https://github.com/ublue-os/bazzite#gnome)
- [Why & Frequently Asked Questions](https://github.com/ublue-os/bazzite#why)
- [Showcase & Newsletter](https://github.com/ublue-os/bazzite#showcase)
- [Custom Packages](https://github.com/ublue-os/bazzite#custom-packages)
- [Verification & Metrics](https://github.com/ublue-os/bazzite#verification)
- [Special Thanks](https://github.com/ublue-os/bazzite#special-thanks)
- [Building Your Own](https://github.com/ublue-os/bazzite#build-your-own)
- [Community](https://github.com/ublue-os/bazzite#join-the-community)
---

## About & Features

Bazzite is an OCI image that serves as an alternative operating system for the [Steam Deck](https://www.steamdeck.com/), and a ready-to-game SteamOS-like for desktop computers and living room home theater PCs.

Bazzite is built from [ublue-os/main](https://github.com/ublue-os/main) and [ublue-os/nvidia](https://github.com/ublue-os/nvidia) using [Fedora](https://fedoraproject.org/) technology, which means expanded hardware support and built in drivers are included. Additionally, Bazzite adds the following features:

- Proprietary Nvidia drivers pre-installed.
- Full hardware accelerated codec support for H264 decoding.
- Full support for AMD's ROCM OpenCL/HIP run-times.
- [xone](https://github.com/medusalix/xone), [xpadneo](https://github.com/atar-axis/xpadneo), and [xpad-noone](https://github.com/ublue-os/xpad-noone) drivers for Xbox controllers.
- Full support for [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Includes Valve's KDE themes from SteamOS.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), and [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) installed and available by default
- Support for [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Only on KDE)</sup></sub>
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) included.
- [Distrobox](https://github.com/89luca89/distrobox) preinstalled with automatic updates for created containers.
- Automated `duperemove` and `rmlint` services for reducing the disk space used by wine prefix contents.
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) preinstalled, providing automatic process priority tweaks to your focused application and keeping CPU time for background processes to a minimum.
- Customized System76-Scheduler config with additional rules and CFS parameters from [Linux-TKG](https://github.com/Frogging-Family/linux-tkg).
- Uses [Google's BBR TCP congestion control](https://github.com/google/bbr) by default.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) preinstalled and enabled. <sub><sup>(Available but default-disabled on the Deck variant)</sup></sub>
- Bazzite Portal provides an easy way to install numerous applications and tweaks, including installing [CoreCtrl](https://gitlab.com/corectrl/corectrl) and [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- [Nix](https://nixos.org/) package manager with [Fleek](https://getfleek.dev/) optionally available for install via Bazzite Portal.
- [Brew](https://brew.sh/) package manager optionally available for install via Bazzite Portal.
- [Waydroid](https://waydro.id/) preinstalled for running Android apps. Future releases will offer to set this up for you through Bazzite Portal. <sub><sup>(Not available on Nvidia builds)</sup></sub>
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 and i2c-nct6775 drivers for controlling RGB on certain motherboards.
- [OpenRazer](https://openrazer.github.io) drivers built in, Select OpenRazer in Bazzite Portal or run `just install-openrazer` in a terminal to begin using it.
- [OpenTabletDriver](https://opentabletdriver.net/) udev rules built in, with the full software suite installable via Bazzite Portal or by running `just install-opentabletdriver` in a terminal.
- [GCAdapter_OC](https://github.com/hannesmann/gcadapter-oc-kmod) driver for overclocking Nintendo's Gamecube Controller Adapter to 1000hz polling.
- Out of the box support for [Wooting](https://wooting.io/) keyboards.
- Built in support for Southern Islands <sub><sup>(HD 7000)</sup></sub> and Sea Islands <sub><sup>(HD 8000)</sup></sub> AMD GPUs under the `amdgpu` driver.
- A fix is available for [a TF2 bug](https://github.com/ValveSoftware/Source-1-Games/issues/5043) that makes the game crash on launch - `just patch-tf2-tcmalloc`
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) is available for Discord screensharing on Wayland. <sub><sup>(Only on KDE)</sup></sub>
### Desktop

Common variant available as `bazzite`, suitable for desktop computers.

- Runs Steam and Lutris in a [custom Arch Linux OCI](https://github.com/ublue-os/bazzite-arch/) via Distrobox.
- Automatic updates for the OS, Flatpaks, Nix packages <sup><sub>(Via Fleek)</sub></sup>, and all Distrobox containers.

> [!IMPORTANT]  
> **ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.org/images/bazzite/installation/).**

If you're on an existing Universal Blue image follow [these instructions](https://universal-blue.org/images/#image-list). To rebase an existing upstream Fedora Silverblue/Kinoite ostree system to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:latest
```

or for devices with Nvidia GPUs:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:latest
```

**For users with Secure Boot enabled:** Once you've installed or rebased to a Nvidia build, [be sure to follow step 3 from the ublue-os/nvidia guide](https://universal-blue.org/images/nvidia/#3-enable-secure-boot-support).

### Steam Deck/Home Theater PCs (HTPCs)
> [!IMPORTANT]  
Devices that are NOT the Steam Deck can still use the bazzite-deck images, but must use an AMD/Intel GPU.

Variant designed for usage as an alternative to SteamOS on the Steam Deck, and for a console-like experience on HTPCs, available as `bazzite-deck`:

- Directly boots to Gamemode matching SteamOS's behavior.
- **Automatic `duperemove` greatly trims the size of compatdata.**
- **Latest version of Mesa creates smaller shader caches and does not require them to prevent stutter.**
- **Able to be booted even if the drive is full.**
- **Support for every language supported by upstream Fedora.**
- Optionally use Wayland on the desktop with [full support for Steam input](https://github.com/Supreeeme/extest).
- Features ported versions of most SteamOS packages, including drivers, firmware updaters, and fan controllers [from the evlaV repository](https://gitlab.com/evlaV).
- Patched Mesa for proper framerate control from Gamescope.
- Comes with patches from [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) for full BTRFS support for the SD card by default.
- Ships with a ported copy of [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), enabled by default.
- Option to install [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), and [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), among numerous other useful packages on installation.
- Custom update system allows for the OS, Flatpaks, Nix packages <sup><sub>(Via Fleek)</sub></sup>, and Distrobox images to be updated directly from the Gamemode UI.
- Built in support for Windows dual-boot thanks to Fedora's installation of GRUB being left intact.
- Update break something? Easily roll back to the previous version of Bazzite thanks to `rpm-ostree`'s rollback functionality. You can even select previous images at boot.
- Steam and Lutris preinstalled on the image as layered packages.
- [Discover Overlay](https://github.com/trigg/Discover) for Discord pre-installed and automatically launches in both Gamemode and on the Desktop if Discord is installed. [View the official documentation here](https://trigg.github.io/Discover/bazzite).
- Exclusively uses ZRAM by default with the option to switch back to a swap file and set a custom size if desired. <sub><sup>(1GB by default)</sup></sub>
- BFQ I/O scheduler to prevent I/O starvation when installing games or during background `duperemove` and `rmlint` processes.
- TLS/SSL secured DNS and NTP by default. <sup><sub>(This is a handheld PC you're likely to use on random public networks after all)</sub></sup>
- Applies SteamOS's kernel parameters.
- Color calibrated display profiles for matte and reflective Steam Deck screens included.
- Default-disabled power-user features, including:
    - Service for low-risk undervolting of the Steam Deck via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) and [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), see `ryzenadj.service` and `/etc/default/ryzenadj`.
    - Service for limiting the max charge level of the battery, see `batterylimit.service` and `/etc/default/batterylimit`. <sup><sub>(Works even when the device is off)</sub></sup>
    - Built in support for display overclocking. For example, add `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` to `/etc/environment`.
    - Ability to enable Wayland on the desktop if desired by editing `/etc/default/desktop-wayland`.
    - 32GB RAM mod your Steam Deck? Enjoy double the maximum VRAM amount, automatically applied. <sup><sub>(Can you share your soldering skills?)</sub></sup>
- Steam Deck hardware-specific services can be disabled by running `just disable-deck-services` in the terminal, useful for trying this image on other handhelds or for use on HTPCs.

> [!WARNING]  
> **Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time.**

> [!IMPORTANT]  
> **ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.org/images/bazzite/installation/).**

If you're on an existing Universal Blue image follow [these instructions](https://universal-blue.org/images/#image-list). To rebase an existing upstream Fedora Silverblue/Kinoite ostree system to this image: 

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:latest
```

### GNOME

Builds with the GNOME desktop environment are available in both desktop and deck flavors. These builds come with the following additional features:

- [Variable refresh rate support and fractional scaling enabled under Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Custom menu in the top bar for returning to game mode, launching Steam, and opening a number of useful utilities. <sub><sup>(Only on Steam Deck builds)</sup></sub>
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) preinstalled and ready to use.
- Features optional Valve-inspired themes matching Vapor and VGUI2 from SteamOS.
- [Hanabi extension](https://github.com/jeffshee/gnome-ext-hanabi) included to offer similar features to Wallpaper Engine in KDE.
- Numerous optional extensions pre-installed, including [important user experience fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatic updates for the [Firefox GNOME theme](https://github.com/rafaelmardojai/firefox-gnome-theme) and [Thunderbird GNOME theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(If installed)</sub></sup>

> [!IMPORTANT]  
> **ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.org/images/bazzite/installation/).**

To rebase an existing ostree system to the **desktop** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:latest
```

To rebase an existing ostree system to the **desktop with Nvidia drivers** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:latest
```

> [!WARNING]  
> **Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time.**

To rebase an existing ostree system to the **Steam Deck/HTPC** release: 

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:latest
```

## Why

Bazzite started as a project to resolve some of the issues that plague SteamOS, mainly out of date packages (despite an Arch base) and the lack of a functional package manager.

Despite this project also being image-based, you are able to install any Fedora package straight from the command line. These packages will persist across updates <sub><sup>(So go ahead and install that obscure VPN software you spent an hour trying to get working in SteamOS)</sup></sub>. Additionally, Bazzite is updated multiple times a week with packages from upstream Fedora, giving you the best possible performance and latest features - all on a stable base.

Bazzite ships with the latest Linux kernel and SELinux enabled by default with full support for secure boot <sub><sup>(Run `just enroll-secure-boot-keys` and enter the password `ublue-os` if prompted to enroll our key)</sup></sub> and disk encryption, making this a sensible solution for general computing. <sup><sub>(Yes, you can print from Bazzite)</sub></sup>

Check out the [FAQ](https://universal-blue.org/images/bazzite/FAQ/) for other topics surrounding the project.

## Showcase

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")

Check out our [newsletters](https://universal-blue.org/blog/category/bazzite/) that get published on a regular basis for updates on the project.

## Custom Packages

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) and [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

|Package|Status|
|---|---|
|[discover-overlay](https://github.com/trigg/Discover)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/discover-overlay/status_image/last_build.png?)|
|ds-inhibit|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)|
|duperemove|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/duperemove/status_image/last_build.png?)|
|[extest](https://github.com/Supreeeme/extest)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/extest/status_image/last_build.png?)|
|gamescope|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope/status_image/last_build.png?)|
|[gamescope-session](https://github.com/ChimeraOS/gamescope-session)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session/status_image/last_build.png?)|
|[gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-randr-rust/status_image/last_build.png?)|
|gnome-shell-extension-bazzite-menu|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)|
|[gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)|
|[gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)|
|[gnome-shell-extension-search-light](https://extensions.gnome.org/extension/5489/search-light/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-search-light/status_image/last_build.png?)|
|[gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?)|
|jupiter-fan-control|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)|
|jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)|
|[mangohud](https://github.com/flightlessmango/MangoHud)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)|
|mesa|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)|
|powerbuttond|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/powerbuttond/status_image/last_build.png?)|
|[python3-hid](https://github.com/apmorton/pyhidapi)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)|
|rmlint|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/rmlint/status_image/last_build.png?)|
|[ryzenadj](https://github.com/FlyGoat/RyzenAdj)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)|
|[sddm-sugar-steamOS](https://github.com/JiayuanWen/sddm-sugar-steamOS)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sddm-sugar-steamOS/status_image/last_build.png?)|
|[sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)|
|steamdeck-kde-presets|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)|
|steamdeck-kde-presets-desktop|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)|
|steam_notif_daemon|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)|
|udisks2|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)|
|vpower|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)|

Additionally, the following packages are used from other Copr repos:

|Package|Status|
|---|---|
|[distrobox](https://github.com/89luca89/distrobox)-git|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/distrobox-git/package/distrobox-git/status_image/last_build.png?)|
|[gcadapter_oc-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/gcadapter_oc-kmod/status_image/last_build.png?)|
|[gnome-vrr](https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/package/mutter/status_image/last_build.png?)|
|[gradience](https://copr.fedorainfracloud.org/coprs/lyessaadi/gradience/)|![Build Status](https://copr.fedorainfracloud.org/coprs/lyessaadi/gradience/package/gradience/status_image/last_build.png?)|
|[hl2linux-selinux](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/package/hl2linux-selinux/status_image/last_build.png?)|
|[latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)|
|[noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)|
|[obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)|
|[openrgb-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/openrgb-kmod/status_image/last_build.png?)|
|[rom-properties](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/package/rom-properties/status_image/last_build.png?)|
|[steamdeck-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/jupiter-kmod/status_image/last_build.png?)|
|[system76-scheduler](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/package/system76-scheduler/status_image/last_build.png?)|
|[wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?)|

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## [![Repography logo](https://images.repography.com/logo.svg)](https://repography.com) / Recent Activity [![Time period](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_badge.svg)](https://repography.com)
[![Timeline graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_timeline.svg)](https://github.com/ublue-os/bazzite/commits)
[![Issue status graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_issues.svg)](https://github.com/ublue-os/bazzite/issues)
[![Pull request status graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_prs.svg)](https://github.com/ublue-os/bazzite/pulls)
[![Top contributors](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_users.svg)](https://github.com/ublue-os/bazzite/graphs/contributors)

## [![Repography logo](https://images.repography.com/logo.svg)](https://repography.com) / Top Contributors
[![Top contributors](https://images.repography.com/35181738/ublue-os/bazzite/top-contributors/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_table.svg)](https://github.com/ublue-os/bazzite/graphs/contributors)

## Special Thanks

Bazzite is a community effort and wouldn't exist without everyone's support. Below are some of the people who've helped us along the way:

- [evlaV](https://gitlab.com/evlaV) - For making Valve's code available and for being [this person](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - For gamescope-session and for valuable support along the way.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - For supporting us with technical issues and for creating a similar project. Seriously, go check it out. It's our Nix-based cousin.
- [Steam Deck Homebrew](https://deckbrew.xyz) - For choosing to support distributions other than SteamOS despite the extra work, and a special thanks to [PartyWumpus](https://github.com/PartyWumpus) for getting Decky Loader working with SELinux for us.
- [cyrv6737](https://github.com/cyrv6737) - For the initial inspiration and the base that became bazzite-arch.

## Build Your Own

Bazzite is built entirely in GitHub and creating your own custom version of it is as easy as forking this repository, adding a private signing key, and enabling GitHub actions.

[Familiarize yourself](https://docs.github.com/en/actions/security-guides/encrypted-secrets) on keeping secrets in github. You'll need to [generate a new keypair](https://docs.sigstore.dev/cosign/overview/) with cosign. The public key can be in your public repo <sub><sup>(Your users need it to check the signatures)</sup></sub>, and you can paste the private key in `Settings -> Secrets -> Actions` with the name `SIGNING_SECRET`.

We also ship a config for the popular [pull app](https://github.com/apps/pull) if you'd like to keep your fork in sync with upstream. Enable this app on your repo to keep track of Bazzite changes while also making your own modifications.

## Join The Community

You can find us on the [Universal Blue Discord](https://discord.gg/f8MUghG5PB).
