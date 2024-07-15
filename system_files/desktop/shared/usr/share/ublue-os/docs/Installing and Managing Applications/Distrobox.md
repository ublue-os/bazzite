---
title: Distrobox

---

# What is Distrobox?

Run other minimal variants of popular Linux distributions in Bazzite inside of a container, and access each distribution's packages without any of their dependencies and libraries affecting the host machine.

**Important Notes**:
- Containers are **not** virtual machines.
- Containers are intended to be **disposable** and may run into issues where they need to be recreated.
- Using this method to obtain software **requires knowledge of how traditional Linux operating systems install packages**.
  - Create a test container to familiarize yourself with basic Linux commands before diving in further.

Distrobox containers run sub-systems of other popular [Linux distributions](https://distrobox.it/compatibility/#containers-distros) with access to their package managers (`apt`, `dnf`, `pacman`, etc.) and their package formats (`.deb`/`.rpm`) and any additional repositories like the [AUR](https://aur.archlinux.org/).

**Linux Distribution Examples**:

| OS | Package Manager | Search for Packages
| -------- | -------- | --------
| [Fedora](https://fedoraproject.org/) | [`dnf`](https://docs.fedoraproject.org/en-US/quick-docs/dnf/)   | [Fedora Packages](https://packages.fedoraproject.org/index-static.html) / [COPR Packages](https://copr.fedorainfracloud.org/)
| [Arch Linux](https://archlinux.org/)| [`pacman`](https://wiki.archlinux.org/title/Pacman) | [Arch Linux Packages](https://archlinux.org/packages/) / [AUR Packages](https://aur.archlinux.org/)
| [Debian](https://www.debian.org/) / [Ubuntu](https://ubuntu.com/) | [`apt`](https://ubuntu.com/server/docs/package-management)   | [Debian Packages](https://packages.debian.org/stable/) / [Ubuntu Packages](https://packages.ubuntu.com/) ([PPA](https://launchpad.net/ubuntu/+ppas))
| [openSUSE](https://get.opensuse.org/)|  [`zypper`](https://documentation.suse.com/smart/systems-management/html/concept-zypper/index.html)  | [openSUSE Packages](https://search.opensuse.org/packages/)
| [Void Linux](https://voidlinux.org/) | [`xbps`](https://docs.voidlinux.org/xbps/index.html)   | [Void Linux Packages](https://voidlinux.org/packages/)
| [Alpine Linux](https://www.alpinelinux.org/) | [`apk`](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)   | [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages)

# Use Cases

Distrobox containers can be used for both **development environments** and **installing applications that are not available in any of the other installation methods** which can be exclusive to specific package managers.

# Distrobox Graphical Interface

Distrobox containers can be created and managed graphically with [BoxBuddy](https://github.com/Dvlv/BoxBuddyRS) which is pre-installed.

# Desktop Integration

Applications with a graphical user interface can integrate with your system with an application shortcut **entering this command inside of the container**:

```bash
distrobox-export --app <package>
```

>Read our [Ptyxis documentation](https://universal-blue.discourse.group/docs?topic=300) on how containers integrate with your system.

# Manually Create Pre-Configured Distrobox Containers

```
ujust distrobox-assemble
```
Select the container that you want to use.

>**Advanced users**: Declare your own custom Distrobox containers following the [`distrobox-assemble` documentation](https://distrobox.it/usage/distrobox-assemble/).

## Entering The Container

Swap between different containers in your host with the terminal or alternatively **enter**:
```
distrobox enter <container>
```

## Removing Distrobox Containers

Delete containers graphically with BoxBuddy.

Alternatively, use the **command line**:

```command
distrobox stop <container_name>
```
```commmand
distrobox rm -f <container_name>
```

# Project Website

https://distrobox.it/

<hr>

[**<-- View online Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=2640)