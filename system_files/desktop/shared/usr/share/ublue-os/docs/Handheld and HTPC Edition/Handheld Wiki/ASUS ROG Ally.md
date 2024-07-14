---
title: ASUS ROG Ally

---

# ASUS ROG Ally

**Status**: Gold

## Post-Installation Setup

- Complete the Bazzite Portal
- Login to Steam
- Reboot device
- Configure the HHD Overlay by opening it with the QAM button
- Virtual keyboard is Steam's keyboard, but needs to be setup in Steam's settings in Desktop Mode (See "Desktop Controls" section below)
   - There is **no default keybinding for Steam's on-screen keyboard**(Remap it to <kbd>**X**</kbd> or whatever you prefer)
- Holding the Armoury Crate button (on the side) allows you to switch to Mouse Mode
- **Optional**: Adjust RGB with Steam Gaming Mode under `Settings > Controller >  Calibration & Advanced > LED Settings`

## Workarounds / Known Issues

- Games can sometimes default to 800p resolution.
    - Manually change the resolution per game in the `Steam Settings > Properties > Game Resolution` to either `Native` or other higher resolutions.
- [Status of CPU Boost on Bazzite](https://github.com/aarron-lee/SimpleDeckyTDP/blob/main/README.md#are-there-cpu-boost-controls)
  - Disable CPU boost to avoid excess power usage and other issues.
- Changing A/C power sometimes leads to a stuck TDP.
- LED is on max brightness by default and cannot be changed on any other operating system outside of Windows.
  - This is tied to the firmware.
  - This also affects when the ally is charging.
- The Ally does **not support** button holding.
  - Steam Input's chords do not work by default.
    - Swapping the Start/Select button(s) is a workaround.
- Suspend can break if SMT is disabled
- Current issues with the Ally's BIOS may cause may cause the Ally to be stuck at 10w TDP, and won't be able to change after suspending.
    - This does not occur using SimpleDeckyTDP with [Ryzenadj](https://github.com/FlyGoat/RyzenAdj).
- VRR may limit the FPS to 70.
  - Fix this by enabling "Force Composite" in Steam Gaming Mode under "Developer" settings.
     - Developer Mode must be turned on first.

<hr>

# TDP Controls

There are a few options for TDP Controls that work with Bazzite:

* The [HHD-overlay](https://github.com/hhd-dev/hhd/blob/master/readme.md) supports TDP controls.
  * Also has a desktop app that is pre-installed, look for the Handheld Daemon app in Desktop Mode.
* [SimpleDeckyTDP](https://github.com/aarron-lee/SimpleDeckyTDP) supports TDP, GPU, Power Governor, and among other settings.
  * Also has a [graphical application](https://github.com/aarron-lee/SimpleDeckyTDP-Desktop), but needs to be manually installed.
* [PowerControl](https://github.com/mengmeet/PowerControl) supports TDP, GPU, and fan controls on select devices.

# How do I open the HHD Overlay?

Press, hold, or double-tap the Quick Access Menu button.

>**Note**: ASUS ROG Ally does not support **holding**!

# Controller Information

For most handheld hardware, besides the Steam Deck, emulation of a DualSense controller is used for full functionality. Double tap or hold the side menu button to access settings for controller emulation including switching to an Xbox controller with reduced functionality.

If your device has paddles, you will want to use the DualSense Edge controller. It’s disabled by default because some games do not map it correctly.

Some games and emulators may need Steam Input **disabled** to work correctly with your controls.

## Desktop Controls

Desktop Mode Controller Layout:  It may not exist by default if Steam doesn't setup your handheld controller properly.  This can be fixed in Steam's controller settings.

Make sure to **apply** the desktop controls when you select them.

# Force reboot device to prevent drive corruption if Steam crashes
>**Note**: This is only for the ASUS ROG Ally and Lenovo Legion Go.

Hold down the "**select**" button on your device to force a reboot. This feature can be disabled in the overlay settings.

<hr>

[View online documentation](https://universal-blue.discourse.group/docs?topic=2414)