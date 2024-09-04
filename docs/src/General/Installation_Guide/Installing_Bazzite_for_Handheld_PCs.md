<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=1144", "fetched_at": "2024-09-03 16:43:22.899176+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![ASUS ROG Ally|690x301](https://universal-blue.discourse.group/uploads/short-url/7mVOk5k3GRxSnRMqbXxXBHtiaGL.jpeg)

# Important Notes on Handheld Hardware

>**Note**: Bazzite requires a stable internet connection with no bandwidth cap in place.

>**Attention**: Several handhelds require BitLocker to be unlocked (write down your recovery key too), Windows "Fast Startup" disabled, and **not** putting Windows into Hibernation Mode before installing Bazzite.


>[Bazzite's Handheld Wiki](https://universal-blue.discourse.group/docs?topic=1038) contains information on setting up your handheld after installing Bazzite and workarounds for known issues.

<hr>

# Pre-Installation

>Pre-requisites and steps before installing Bazzite.

### Installer Requirements
* A USB flash drive with 10GB free space
  * **Note**: All data on this drive will be wiped when flashed
* Software to flash the image:
  * [Fedora Media Writer](https://www.fedoraproject.org/en/workstation/download/), [Ventoy](https://www.ventoy.net/en/index.html), or [Rufus](https://rufus.ie/en/)
    * Make sure to properly eject the drive after flashing the ISO to it
* Optional: Physical keyboard (without one, your username will be `bazzite` and the password will be `bazzite`)

### Steam Gaming Mode Requirements
* Compatible graphics card
  * A **modern AMD GPU**
  * An **Intel Arc GPU** (Other Intel GPU series will not boot Steam Gaming Mode)
     * Intel Arc handhelds will currently have missing functionality (TDP limit, controls, etc.)

Handheld users will also benefit from also reading the [Steam Gaming Mode documentation](https://universal-blue.discourse.group/docs?topic=37).

## Desktop Environments

All of the images come with the choice of [KDE Plasma](https://kde.org/plasma-desktop/) or [GNOME](https://www.gnome.org/) for their desktop environment.

More information can be found on our [FAQ](https://faq.bazzite.gg) about the differences between the image variants.

### [KDE Plasma (Default)](https://kde.org/plasma-desktop/)

![KDE Plasma|690x388, 75%](https://universal-blue.discourse.group/uploads/short-url/h7Dqg0SaF3Whee7a9qnlJdtKcss.jpeg)

- KDE Plasma's default interface has a traditional and familiar layout
- Highly customizable with tons of settings
- Qt framework
- Popular Linux distributions like SteamOS use KDE Plasma

### [GNOME (`-gnome` images)](https://www.gnome.org/)

![GNOME|690x359, 75%](https://universal-blue.discourse.group/uploads/short-url/2jxFrUQ5YGMyjpRw65lE37SuxiT.png)

- GNOME's default interface has an elegant and touch-friendly layout
- Simple and concise
- GTK framework
- Popular Linux distributions like Ubuntu use GNOME


### [Steam Gaming Mode (`-deck` images)](https://universal-blue.discourse.group/docs?topic=37)

![Gaming Mode|690x388, 75%](https://universal-blue.discourse.group/uploads/short-url/7V8e6RsZT46dO4ztlWAlmROhc21.jpeg)

>**Note**: Your device will automatically boot into the Steam Gaming Mode session at startup, and Desktop Mode can be accessed from the "**power menu**" in Steam Gaming Mode.

- **Requires a [Steam](https://store.steampowered.com/) account**
- Included in the [Handheld/HTPC images](https://universal-blue.discourse.group/docs?topic=37)
- Interface is designed for handheld and couch gaming
- Controller friendly
- Choice of KDE Plasma or GNOME in Desktop Mode
- Extra functionality with [Decky](https://github.com/SteamDeckHomebrew/decky-loader) [plugins](https://plugins.deckbrew.xyz/)


## Dual Boot Preliminary Setup + Post-Setup Guide

Read the [Dual Boot Guide](https://universal-blue.discourse.group/docs?topic=2743) **after** reading this guide first before proceeding.

<hr>

# Installation Guide

>The part of the guide that requires the most effort.

## 1. Download and Flash Bazzite

- Download [Bazzite](https://download.bazzite.gg) after choosing the correct handheld hardware with our Image Picker tool.
- Flash Bazzite to your bootable medium.
- Eject drive.

## 2. Boot Installation Medium

You may need to research your handheld on how to boot from removable storage.  It may be similar to the Steam Deck with holding down one of the "volume buttons" and pressing another button, but like for other general hardware, it highly dependent on your hardware.

## 3. Installer Setup

> **NOTE**: If you do not have a usb physical keyboard connected, do **NOT** press “*User Creation*”, since it will remove the default username and password, and you will be unable to type a username or password without a physical keyboard.

> **default user**: `bazzite`
> **default password**: `bazzite`

![Installer|690x348](https://universal-blue.discourse.group/uploads/short-url/uHKqd8F4nxZryfP8ebBz1DIbNVv.png)

<!--![Installer](https://universal-blue.discourse.group/uploads/short-url/zfpz6EXcBqQ6jxho1O9jLLSRUE9.png)--!

<!--
![Automatic Partitioning|690x359](https://canada1.discourse-cdn.com/free1/uploads/univeral_blue/original/1X/83958112b4d1d96874868fa33f889bfd0162da9a.png)-->

![User setup example|690x359, 100%](https://universal-blue.discourse.group/uploads/short-url/ifNfb60naVmevFSrJGt3X3IySsV.png)

- Select your language, region, keyboard layout, and time zone.
- Select the drive that Bazzite is going to be installed on.
  - Delete any partitions that you have remaining on the drive **unless [dual booting on the same drive](https://universal-blue.discourse.group/t/dual-boot-preliminary-setup-and-post-setup-guide/2743#p-6361-b-same-drive-method-3)**.
  - If **[dual booting on the same drive](https://universal-blue.discourse.group/t/dual-boot-preliminary-setup-and-post-setup-guide/2743#p-6361-b-same-drive-method-3)**, it is **strongly recommended** to do manual partitioning and create a separate EFI partition.
    - The separate EFI partition will help prevent Windows Updates from affecting your Bazzite installation later down the line.
  -  Only use the automatic storage configuration when installing to separate drives
- Optionally encrypt the drive with a password if desired.
  - **If you lose this password, then it cannot be decrypted**.
- Setup a user account and begin the installation. (If you do not have a physical, skip this step and begin the installation)
  - Give administrative privileges and set a user password. (**required**)
- Begin the installation.
- Reboot device after it has finished installing.

### Important information for users with Secure Boot **enabled**:

Read the [Secure Boot Guide](https://universal-blue.discourse.group/docs?topic=2742).

<hr>

# Post-Installation

>The fine tuning before gaming.

## GRUB Menu
![Rollbacks|690x402, 50%](https://universal-blue.discourse.group/uploads/short-url/8mTB5vEYyXVH1dIK51dhxvXait5.png)

The first boot will show a screen showing your current and last deployment. It will automatically boot if nothing.  It is important to note that the GRUB menu can be used to rollback Bazzite deployments if you encounter issues.  

Read more about this in the [Updates, Rollback, and Rebasing documentation](https://universal-blue.discourse.group/docs?topic=36).

## Configuring System Settings for KDE Plasma and GNOME

![Display Settings (KDE Plasma)|690x370, 75%](https://universal-blue.discourse.group/uploads/short-url/xZrErYyRSyJOeQgWQ8Nv93Wh0ab.png)
***KDE Plasma's System Settings application***

![Display Settings (GNOME)|690x344, 75%](https://universal-blue.discourse.group/uploads/short-url/9ZS8XHFENXAZmnmyrLemrhWNDpH.png)
***GNOME's Settings application***

After you have booted into the Desktop for the first-time configuration, then you can should adjust the settings to your liking.  The most important setting that may need to be changed is the scaling setting in "Display(s) [and Monitor]" since it can be incorrect for the screen of your hardware on a fresh installation.  Monitor orientation should also be corrected if it is rotated improperly.

## First Boot Setup Utility: Bazzite Portal

![Welcome to Bazzite|618x500, 75%](https://universal-blue.discourse.group/uploads/short-url/yiZQ7tMxzKrsPBKTP2AafdVfWsD.jpeg)

>**Attention**: This section requires a stable internet connection.  Make sure you are connected to a network.

An application will pop up welcoming you to Bazzite when you boot into the desktop for the first time.  This is a utility that allows you to tailor Bazzite to your liking by installing additional software.

![Bazzite Portal|584x500, 75%](https://universal-blue.discourse.group/uploads/short-url/r4pnS5b2Dwur3c99ojIaims7t09.png)

- Click "Next" to begin configuring Bazzite.  
- Press the toggle switch button next to the item to have the option enabled or disabled for your installation, some are already toggled on by default.  
- If you would like to customize any of the options, then press the arrow next to the toggle switch button if available.  
- Installing items from the portal **may take a long time**. 

>**Note**: If you only check a few items in a category, then it will only install those selected items.  The switch is only toggled to install **everything** in that category.

>**Attention**: There is a rare chance you will be asked to setup KDE Wallet or GNOME Keyring and set a password to continue installing items from the Bazzite Portal.


## Installing additional software

The [Installing and Managing Applications documentation](https://universal-blue.discourse.group/docs?topic=35) is useful to learn how to install additional software on Bazzite outside of the Bazzite Portal.

## Login to Steam &  Reboot Device

Login to Steam then **reboot** your device when you finish setting up your device during the first-boot process.

![Steam Gaming Mode Setup|690x442, 50%](https://universal-blue.discourse.group/uploads/short-url/pLvHB1NAMlb3ghsR72q7l9Auj8B.jpeg)

After completing all of the above, then your next boot will be in Steam Gaming Mode which requires additional setup for Steam. 

### Post-Setup and Known Issues for Handhelds and Steam Gaming Mode

Read the [Handheld Wiki](https://universal-blue.discourse.group/docs?topic=1038) and [Steam Gaming Mode Overview documentation](https://universal-blue.discourse.group/docs?topic=37) for information regarding Bazzite on handheld PCs.

<hr>

# **Video Tutorial**

> **Note**: We strongly recommend **manual partitioning + creating a separate EFI partition** for dual-booting, **not** automatic partitioning.
>
> See instructions for manual partitioning [here.](https://universal-blue.discourse.group/t/dual-boot-preliminary-setup-and-post-setup-guide/2743#p-6361-manual-partitioning-to-the-same-drive-for-dual-boot-setups-6)

https://www.youtube.com/watch?v=H4226yq0ZwY

<hr>

# Issues Installing Bazzite?

View the [Installation Troubleshoot Guide](https://ublue-os.github.io/bazzite/General/Installation_Guide/troubleshoot_guide/).

<hr>

**Documentation Contributors**: [Kyle Gospodnetich](https://github.com/KyleGospo), [Nathaniel Warburton](https://github.com/storyaddict), [Jorge Castro](https://github.com/castrojo), [Noel Miller](https://github.com/noelmiller), [ChaiQi](https://github.com/atimeofday), [Damian Korcz](https://github.com/damiankorcz), and [Justin Garrison](https://github.com/rothgar)

**See also:** [Upstream Manual Partitioning Guide](https://docs.fedoraproject.org/en-US/fedora-silverblue/installation/#manual-partition) & https://universal-blue.discourse.group/docs?topic=37

<-- [**View all Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=561)