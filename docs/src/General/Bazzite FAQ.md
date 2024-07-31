---
title: Bazzite FAQ

---

# What Bazzite image am I on?

|Image | Desktop Environment| Steam Gaming Mode | Hardware |Edition|
|---|---|---|---|---|
| `bazzite` | KDE Plasma| No| AMD/Intel GPUs|Desktop|
| `bazzite-nvidia` | KDE Plasma| No| Nvidia GPUs|Desktop|
| `bazzite-gnome` | GNOME | No | AMD/Intel GPUs |Desktop|
|  `bazzite-gnome-nvidia` | GNOME |  No | Nvidia GPUs |Desktop| 
| `bazzite-deck`:|KDE Plasma | Yes | AMD/Intel Arc GPUs|Handheld/HTPC|
| `bazzite-deck-gnome`|GNOME|Yes|AMD/Intel Arc GPUs|Handheld/HTPC|
| `bazzite-asus` | KDE Plasma| No| ASUS Laptops (AMD/Intel GPUs| Desktop| 
| `bazzite-asus-gnome` | GNOME| No| ASUS Laptops (AMD/Intel GPUs)| Desktop| 
| `bazzite-asus-nvidia`|KDE Plasma|No|ASUS Laptops (Nvidia GPUs)| Desktop| 
| `bazzite-gnome-asus-nvidia`|GNOME|No|ASUS Laptops (Nvidia GPUs)|Desktop| 


# How do I change the hostname of my device?

Edit the `/etc/hostname` file with a new hostname, save it,  and reboot. 

```
hostnamectl hostname <hostname>
```

# Why are builds failing?

Do not be alarmed if you see this on our [Github repository](https://github.com/ublue-os/bazzite/). Builds can fail for a number of reasons, but it's only temporary.  You can still install and use Bazzite without any issues.  Latest features and fixes may be delayed until the builds are successfully built again however.

# How do I report a bug?

While we try to help people as much as we can, we prefer that issues are triaged through GitHub so they can be tracked and labelled properly. Here's a quick guide.

If you've been redirected here it means one of us wants to track this in GitHub. Don't worry, you didn't mess up, we just need to put it in the system. This forum and GitHub support markdown formatting, so usually it's just a matter of copying and pasting it into GitHub. 

Read the [GitHub Quickstart](https://docs.github.com/en/issues/tracking-your-work-with-issues/quickstart) for more information.

## Quick Tips to Reporting Issues

- One issue per problem please! 
- Try to fill out the form as best you can
- Remember we're enthusiasts with jobs, sometimes it might take a while, especially if it's a nice-to-have and not a critical issue

## Setting Expectations

We're Linux geeks, but most of us come from a dev-ops background and not deep technical distribution work. More hands on deck are always welcome!

- Kernel issues like freezes and crashes can be tough to diagnose, we'll do our best
- There's not much we can do in certain situations, if you're using an Nvidia closed source driver sometimes you might get an issue that is completely out of our control - the gift that keeps on giving!
- Check Fedora's [How to File a Bug](https://docs.fedoraproject.org/en-US/quick-docs/bugzilla-file-a-bug/) docs - **please be respectful when reporting issues to Fedora** - it doesn't hurt to rule out a Universal Blue issue before reporting something for Fedora. Our intended mission is to **help** Fedora as efficiently as possible.
- Some days the t-rex just gets you - If you're treading off the beaten path it's entirely possible that you are the first person trying it. Thanks for volunteering by filing issues and submitting documentation.

## Finding where to file an issue (Universal Blue Repositories)

Depending on where you find an issue, it might need to go in a certain repository. Don't worry if you mess this up, we can move them, here's a quick guide to save you some time. 

- [ublue-os/bazzite](https://github.com/ublue-os/bazzite/issues/new) - Bazzite issues.

- [ublue-os/config](https://github.com/ublue-os/config/issues/new) - for just commands, udev rules, and service units. Things in this repo end up on every Universal Blue image.

- [ublue-os/akmods](https://github.com/ublue-os/akmods/issues/new) - extra kernel modules. Usually for that awful piece of hardware that doesn't have inkernel driver support. :smile: 

- [ublue-os/main](https://github.com/ublue-os/main/issues/new) - for base images. Issues about codecs, and general issues. This is usually our catch all repo and will have issues relating to things that affect the entire project. These don't integrate akmods so no weird hardware things don't go in here.

- [ublue-os/hwe](https://github.com/ublue-os/hwe/issues/new) - hwe means "hardware enablement". If you have an issue with Nvidia, Asus, or Surface devices, file it in this repo.

- [ublue-os/toolboxes](https://github.com/ublue-os/toolboxes/issues/new) - Anything related to our distroboxes and associated podman quadlets.

For everything else check out the [list of repositories](https://github.com/ublue-os).

## Update before reporting

First, see if the bug is already fixed in an update by manually updating the system, then rebooting to see if the issue still persists between updates.

## Attaching system logs
Open a host terminal and **enter**:
```
ujust device-info
```
Attach the link that it outputs for system logs.

## Experience a crash?
```
ujust logs-last-boot
```

<hr>

**Documentation Contributors**: [Kyle Gospodnetich](https://github.com/KyleGospo), [RJ Trujillo](https://github.com/EyeCantCU), [Nathaniel Warburton](https://github.com/storyaddict), and [Jorge Castro](https://github.com/castrojo)

[**<-- View online documentation**](https://faq.bazzite.gg)