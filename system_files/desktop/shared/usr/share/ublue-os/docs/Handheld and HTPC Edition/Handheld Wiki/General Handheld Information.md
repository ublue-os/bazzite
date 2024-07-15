---
title: General Handheld Information

---

# Handheld Compatibility

> This list is incomplete and does not indicate that unlisted handhelds do not work with Bazzite currently, but because we lack specific information regarding their post-installation setup, workarounds, and proper support they are unlisted here.

- Steam Deck
- Lenovo Legion Go
- ASUS ROG Ally
- Ayn Handhelds
- GPD Handhelds
- Ayaneo Handhelds


## Support Rating

Bazzite takes a similar approach to [ProtonDB’s medal system](https://www.protondb.com/) by giving a generic label rating for each handheld. 

* **Platinum**: No major issues and/or simple workarounds are needed for small fixes.
* **Gold**: Minor issues and/or simple workarounds required, but ultimately works.
* **Silver**: Major issues and/or exhaustive workarounds required, but boots and can game.
* **Bronze**: Major issues and/or exhaustive workarounds, but boots and displays a desktop.
* **Borked**: Bazzite does not boot on this hardware.
* **Unknown** (*unlisted*): The handheld is not listed here and a general guide is under “Other Handhelds.”


# HHD Setup

>HHD is intended and functional for handhelds that are **not** the Steam Deck.

**Read the [HHD README](https://github.com/hhd-dev/hhd/blob/master/readme.md) for more information.**

1. Double press side menu button to access Handheld Daemon overlay in Steam Gaming Mode
2. Select the controller emulation and RGB color you want
2a. Gyro functionality **requires** DualSense emulation


# Decky Plugins

>**Note**: Decky may break or uninstall after updates especially if the Steam client or Gamescope is updated.

Install optional [Decky plugins](https://plugins.deckbrew.xyz/) for your handheld.

# eGPU Support

>eGPU is **not** a fully supported feature and has many caveats.

- Modern AMD GPUs *should* work.
  - Nvidia GPUs are most completely unsupported.
- Proprietary connectors, like the one for the ASUS ROG Ally, will not work.

**Recommended Script**:
https://github.com/ewagner12/all-ways-egpu

<hr>

**Documentation Contributors**: [Antheas Kapenekakis](https://github.com/antheas), [Aarron Lee](https://github.com/aarron-lee), and [Zetarancio](https://universal-blue.discourse.group/u/zetarancio)

[View online documentation](https://universal-blue.discourse.group/docs?topic=1038)