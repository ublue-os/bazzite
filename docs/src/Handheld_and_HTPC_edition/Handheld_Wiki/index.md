---
title: Handheld Wiki
---
<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=1038", "fetched_at": "2024-09-03 16:43:15.186486+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Handheld Compatibility

> **Attention**: This list is incomplete and does not indicate that unlisted handhelds do not work with Bazzite currently, but because we lack specific information regarding their post-installation setup, workarounds, and proper hardware support for Linux, so they are unlisted here.

> **Note**: All handhelds except for the Steam Deck make use of [Handheld Daemon](https://github.com/hhd-dev/hhd/blob/master/readme.md) for controls, TDP, etc.

*Click the name of each hardware to view post-installation setup and known issues/workarounds.*

- [**Steam Deck**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/Steam_Deck/)
- [**Lenovo Legion Go**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/Lenovo_Legion_Go/) ([*Edit Wiki*](https://github.com/ublue-os/bazzite/blob/main/docs/src/Handheld_and_HTPC_edition/Handheld_Wiki/Lenovo_Legion_Go.md))
- [**ASUS ROG Ally**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/ASUS_ROG_Ally/) ([*Edit Wiki*](https://github.com/ublue-os/bazzite/blob/main/docs/src/Handheld_and_HTPC_edition/Handheld_Wiki/ASUS_ROG_Ally.md))
- [**Ayn Handhelds**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/Ayn_Handhelds/) ([*Edit Wiki*](https://github.com/ublue-os/bazzite/blob/main/docs/src/Handheld_and_HTPC_edition/Handheld_Wiki/Ayn_Handhelds.md))
- [**GPD Handhelds**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/GPD_Handhelds/) ([*Edit Wiki*](https://github.com/ublue-os/bazzite/blob/main/docs/src/Handheld_and_HTPC_edition/Handheld_Wiki/GPD_Handhelds.md))
- [**Ayaneo Handhelds**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/Ayaneo_Handhelds/) ([*Edit Wiki*](https://github.com/ublue-os/bazzite/blob/main/docs/src/Handheld_and_HTPC_edition/Handheld_Wiki/Ayaneo_Handhelds.md))
- [**Other Handhelds**](https://ublue-os.github.io/bazzite/Handheld_and_HTPC_edition/Handheld_Wiki/Other_Handhelds/)

## Support Rating

Bazzite takes a similar approach to [ProtonDB’s medal system](https://www.protondb.com/) by giving a generic label rating for each handheld. 

**Platinum**: 
No major issues and/or simple workarounds are needed for small fixes.

**Gold**: 
Minor issues and/or simple workarounds required, but ultimately works.

**Silver**: 
Major issues and/or exhaustive workarounds required, but boots and can game.

**Bronze**: 
Major issues and/or exhaustive workarounds, but boots and displays a desktop.

**Borked**: 
Bazzite does not boot on this hardware.

**Unknown** (*unlisted*): 
The handheld is not listed here and a general guide is under “Other Handhelds.”

# HHD Setup

>HHD is intended and functional for handhelds that are **not** the Steam Deck.

**Read the [HHD README](https://github.com/hhd-dev/hhd/blob/master/readme.md) for more information.**

1. Double press the 'side menu button' to access Handheld Daemon overlay in Steam Gaming Mode

2. Select the controller emulation and RGB color you want

>**Note**: Gyro functionality **requires** DualSense emulation


# Decky Plugins

>**Note**: Decky may break or uninstall after updates especially if the Steam client or Gamescope is updated.

Install optional [Decky plugins](https://plugins.deckbrew.xyz/) for your handheld.  If you experience any major issues then it is recommended to uninstall Decky before reporting Bazzite bugs.

# Bazzite's Steam Gaming Mode Documentation

Check out the [Steam Gaming Mode documentation](https://universal-blue.discourse.group/docs?topic=37) for an in-depth guide on Steam Gaming Mode plus general fixes for common issues.

# eGPU Support

>eGPU is **not** a fully supported feature and has many caveats. 

**Notes**:
- Modern AMD GPUs are **supported**.
- Intel ARC GPUs are **supported**.
- Nvidia GPUs are **unsupported**.     
- Proprietary connectors, like the one for the ASUS ROG Ally, will not work.

## **Recommended External Guide & Script**:
Read this [guide](https://github.com/ewagner12/all-ways-egpu) for eGPU usage on Linux, and use the script at your own risk.

<hr>

**Documentation Contributors**: [Antheas Kapenekakis](https://github.com/antheas), [Aarron Lee](https://github.com/aarron-lee), and [Zetarancio](https://universal-blue.discourse.group/u/zetarancio)

← [**View all Bazzite documentation**](https://docs.bazzite.gg)
