<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=33", "fetched_at": "2024-09-03 16:43:17.727110+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Why is it called Bazzite?
[Fedora Linux's Atomic Desktops](https://fedoraproject.org/atomic-desktops/) originally followed a naming scheme based on [minerals.](https://fedoraproject.org/kinoite/)  Bazzite is a mineral that is known for being strong, lightweight, and is colored [blue](https://universal-blue.org/).

# What Bazzite image do I use?

Bazzite's [website](https://bazzite.gg/#image-picker) offers a streamlined way of selecting the correct image which will be chosen based on hardware, desktop environment, and to include Steam Gaming Mode if the hardware supports it.

Bazzite offers multiple images, but most images will be following *one of these two formats*:
- Bazzite that automatically boots into Steam Gaming Mode with manual updates
- Bazzite that does **not** have Steam Gaming Mode and receives automatic updates daily

**Images are split up between **two** types of Bazzite editions**:

## 1. Desktop Edition

>**Steam Gaming Mode is not on these specific images!**

Intended specifically for desktops and laptops with a focus on gaming which is influenced by SteamOS's Desktop Mode and the maintenance-free nature of ChromeOS.

Steam and other gaming utilities are part of the base operating system. System rollbacks available with a rock-solid stable Fedora Linux base.  **Updates are automatically downloaded in the background and applied on a restart**.  Most modern hardware should be compatible outside of specific drivers that do not work well on desktop Linux.

The choice of KDE Plasma and GNOME for the desktop environment with others planned for the future.  [Flathub](https://flathub.org/) is enabled out of the box, so all of the applications that you would find on SteamOS are available on Bazzite. 
 
## [2. Handheld/HTPC Edition (`-deck` Images)](https://universal-blue.discourse.group/docs?topic=37)

Mimics SteamOS with "**Steam Gaming Mode**" and its features fully functional.  This version of Bazzite boots directly into the Steam Gaming Mode session and are intended for handheld PCs and home theater setups.

Images also includes a Desktop Mode session with the choice of GNOME or KDE Plasma and is based on our Desktop images.  **Updates are manually installed by the user and applied on a restart**.  

>Steam Gaming Mode **requires** a modern AMD graphics card or an Intel Arc graphics card.

### Desktop Environments & Specific Hardware Variants

Both types of images also come with the choice of using [KDE Plasma](https://kde.org/plasma-desktop/) or [GNOME](https://www.gnome.org/) for the desktop environment and certain images are made with specific hardware support.

There is more information about this topic on the [Installation Guide](https://ublue-os.github.io/bazzite/General/Installation_Guide/) to help guide users on which image to choose before the installation. 


## Bazzite Image Chart

|Image | Desktop Environment | Steam Gaming Mode | Hardware | Edition|
|--- | --- | --- | --- | ---|
|`bazzite` | KDE Plasma | No | AMD/Intel GPUs | Desktop|
|`bazzite-nvidia` | KDE Plasma | No | Nvidia GPUs | Desktop|
|`bazzite-gnome` | GNOME | No | AMD/Intel GPUs | Desktop|
|`bazzite-gnome-nvidia` | GNOME | No | Nvidia GPUs | Desktop|
|`bazzite-deck` | KDE Plasma | Yes | AMD/Intel Arc GPUs | Handheld/HTPC|
|`bazzite-deck-gnome` | GNOME | Yes | AMD/Intel Arc GPUs | Handheld/HTPC|
|`bazzite-asus` | KDE Plasma | No | ASUS Laptops (AMD/Intel GPUs | Desktop|
|`bazzite-asus-gnome` | GNOME | No | ASUS Laptops (AMD/Intel GPUs) | Desktop|
|`bazzite-asus-nvidia` | KDE Plasma | No | ASUS Laptops (Nvidia GPUs) | Desktop|
|`bazzite-gnome-asus-nvidia` | GNOME | No | ASUS Laptops (Nvidia GPUs) | Desktop|
|`bazzite-ally` | KDE Plasma | Yes | ASUS Laptops (Steam Gaming Mode Enabled) | Handheld/HTPC|
|`bazzite-ally-gnome` | GNOME | Yes | ASUS Laptops (Steam Gaming Mode Enabled) | Handheld/HTPC|


## Who are the target audiences?
- Desktop users who want an operating system designed for gaming with inspiration from SteamOS that has fairly low maintenance.
- Steam Deck users who feel limited by SteamOS and also want newer system packages.
- Home Theater PC setups for a console-like experience.
- [Handheld PC](https://universal-blue.discourse.group/docs?topic=1038) users who would prefer a SteamOS-like experience.

# SteamOS is based on Arch Linux, so why use Fedora Linux? 

SteamOS receives package and driver updates less frequently despite the rolling release base.

Bazzite will follow Fedora's update release cycle which means early access to new graphics card driver and kernel updates in comparison to SteamOS.

Fedora Linux and Universal Blue currently supports a specific "atomic" implementation to maintain multiple images that can receive all of the same updates at once, which is unlike a derivative Linux distribution.

> The **goal** of Bazzite is to have an operating system ready to game after installing it.

### Any advantages to using Fedora?
Since Bazzite is a custom Fedora Atomic Desktop image, it makes use of read-only root files for stability purposes, and is built with [libostree](https://docs.fedoraproject.org/en-US/fedora-silverblue/technical-information/) which has advantages such as:

- Low risk of an unbootable system
- Rollback system updates if necessary, and the ability to pin your current deployment as a backup save state without losing user data.
- Smooth upgrade process from major Fedora point releases.
- Layer Fedora packages to the host that survive between updates.
- Focus on containerized applications that do not interfere with your host system.

> Check out the [Universal Blue homepage](https://universal-blue.org) for more information on what this project is capable of.

## How is Fedora Atomic Desktop different than Fedora Workstation?

If you're familiar with [Fedora Workstation](https://www.fedoraproject.org/workstation/) and [Fedora's Spins](https://www.fedoraproject.org/spins/), but not the Fedora Atomic Desktops paradigm, the major difference is with stability between system upgrades.  There are read-only root files and an emphasis on installing applications as a Flatpak or inside [containers.](https://distrobox.it/)  Read more about [obtaining software on Bazzite](https://universal-blue.discourse.group/docs?topic=35). 

Users can rollback to a previous deployment if a system update breaks their workflow, or rebase entirely back to a stock Fedora Atomic image, [Aurora](https://getaurora.dev/), [Bluefin](https://projectbluefin.io/), or a [custom image by the community](https://universal-blue.discourse.group/docs?topic=340).  Do **not** rebase between different desktop environments.  Read more about how [updates, rolling back, and rebasing works on Bazzite](https://universal-blue.discourse.group/docs?topic=36).

Here's a helpful [cheat sheet](https://docs.fedoraproject.org/en-US/fedora-silverblue/_attachments/silverblue-cheatsheet.pdf) for using **advanced** commands, but gives a glimpse of what this paradigm is capable of.  There is also a future planned ahead of this technology.  Upcoming additions like [bootc](https://containers.github.io/bootc/) will be a major change when it is ready for production.

## Is this another fringe Linux distribution?
Bazzite is **not** a Linux distribution in the traditional sense.  It's a custom Fedora Atomic Desktop image with a recipe on top of it.  Universal Blue images are a proof of concept of using containerized workflows with transactional and in-place operating system updates, and Bazzite exists by being gaming focused with inspiration from SteamOS.

>Essentially, Bazzite is a Fedora Atomic Desktop installation, but with the aid of Universal Blue's tooling, adds packages, services, drivers, etc. to the base image of it.

### How does Bazzite differ?

Bazzite is using a new "**container-native**" approach that Fedora has been testing, and we are taking full advantage of it.  

We are utilizing the [Open Container Initiative (OCI)](https://opencontainers.org/about/overview/) to build the images, and are simply adding packages, services, kernel modules, and our own spin to existing Fedora operating systems.

Unlike traditional Linux distributions, **most of the maintenance and security updates are done upstream** by Fedora and Universal Blue while Bazzite only has to focus on creating a great experience for PC gaming. 

>The ultimate goal of Bazzite is to be Fedora Linux, but provide a great gaming experience out of the box while also being an alternative operating system for the Steam Deck.

#### Image Matrix

We provide several different images that all get the same additions and fixes through updates at the same time unless specified otherwise.  Many images are hardware specific for compatibility reasons, yet all of the images will usually receive the same features and fixes at the same time. 

There can be a hypothetical scenario where everyone involved with Bazzite could stop maintaining the project at once and it will still continue to receive updates directly from upstream.

# Can this be used as a daily driver?

**Yes**.   

Updates are obtained and downloaded straight from upstream which means there is little maintenance to be done with the image on our end since these images are modified Fedora images.  Users will receive application and system updates from Bazzite, Universal Blue, and Fedora daily.

>A friendly reminder that this project is still in its early stages and moving at a fast pace with updates and changes nearly daily.

## What are some of the utilities that Bazzite ships? 
(*in alphabetical order*)
- [Boxkit](https://github.com/ublue-os/boxkit): Tool used for custom OCI Distrobox/Toolbox containers, and anything from [DaVinci Resolve](https://github.com/zelikos/davincibox) to [OBS Studio Portable](https://github.com/ublue-os/obs-studio-portable) can be accessed with this. (The software is in their own special container, so dependencies do not affect your host.)
- [Discover Overlay](https://github.com/trigg/Discover): Discord chat overlay integration for Steam Gaming Mode which has a [special configuration](https://trigg.github.io/Discover/bazzite) for Bazzite where it launches automatically
- [Handheld Daemon](https://github.com/hhd-dev/hhd): Tool for configuring and managing handheld devices from gyro, LEDs, paddles, and TDP. 
- [Ptyxis](https://devsuite.app/ptyxis/): Terminal with first-class container support.
- [`ujust`](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/ujust/): Execute custom commands based on recipes.
- [yafti (Bazzite Portal)](https://github.com/ublue-os/yafti/): First-boot utility for installing additional software.

## Can I use this desktop environment or that standalone window manager?
Make your own [custom image based off Bazzite](https://universal-blue.discourse.group/docs?topic=43) with the DE and WM change that you want.

## Is Secure Boot supported?

>**WARNING (Steam Deck hardware only):** The Steam Deck does not come with secure boot enabled and does not ship with any keys enrolled by default, so do not enable this on Steam Deck hardware unless you absolutely know what you're doing!

**Yes**, but you will have to enroll our key.  

More information on enrolling the key in our [Secure Boot guide](https://universal-blue.discourse.group/docs?topic=2742).


# Are AMD, Intel, and Nvidia graphics card drivers pre-installed?

Yes and they are updated during a system upgrade when available.

## What if I change hardware?

Most hardware changes should **not** require any manual intervention outside of the expectations from that particular hardware which would be OS-agnostic.  

However, if you swap from or to a Nvidia GPU, then [rebasing](https://universal-blue.discourse.group/docs?topic=2646) will be necessary as a manual intervention to get the appropriate graphics drivers.

# What is the difference between Bluefin, Aurora, and Bazzite?

> **TL;DR**: Bazzite is the gaming-centric version of Bluefin (GNOME) and Aurora (KDE Plasma).

[Bluefin](https://projectbluefin.io/) and [Aurora](https://getaurora.dev) are nearly identical outside of branding and desktop environment, but Bazzite strays away from both.  All three are similar for desktop PCs and function similarly and share contributors between projects.  Bluefin and Aurora target two audiences---individuals who want a maintenance-free Linux desktop experience and developers (using the `-dx` images).  

Bazzite exclusively focuses on having an out of the box Linux gaming experience for desktop, HTPC hardware, and handhelds.  Bazzite can be summed up as Bluefin and Aurora but tuned for PC gaming.  All 3 are community-centric custom Fedora Atomic Desktop that is configured for their specific target audience, and for Bazzite specifically: PC gamers who want to use the Linux desktop as the alternative to Windows.

# How do I change the hostname of my device?

Edit the `/etc/hostname` file with a new hostname, save it,  and reboot. 

```
hostnamectl hostname <hostname>
```

# Questions Regarding Java

If its for Minecraft, then install the [Prism Launcher](https://flathub.org/apps/org.prismlauncher.PrismLauncher) for mods that require anything Java related.  If its for development use [Distrobox](https://ublue-os.github.io/bazzite/Installing_and_Managing_Software/Distrobox/).  You will not be able to change Java on your host.

# Why are builds failing?

![Builds Failing|178x43](https://universal-blue.discourse.group/uploads/short-url/tH4LmnMi2rlt2dq0EXCDTG6rtKU.png)

Do not be alarmed if you see this on our [Github repository](https://github.com/ublue-os/bazzite/). Builds can fail for a number of reasons, but it's only temporary.  You can still install and use Bazzite without any issues.  Latest features and fixes may be delayed until the builds are successfully built again however.

<hr>

**Documentation Contributors**: [Kyle Gospodnetich](https://github.com/KyleGospo), [RJ Trujillo](https://github.com/EyeCantCU), [Nathaniel Warburton](https://github.com/storyaddict), and [Jorge Castro](https://github.com/castrojo)

**See also**: [Upstream Fedora Silverblue FAQ](https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/)

<-- [**View all Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=561)