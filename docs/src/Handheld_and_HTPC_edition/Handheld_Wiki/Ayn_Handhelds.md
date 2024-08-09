# Ayn Loki Max [x]

![Loki Max|375x500, 100%](../../img/Loki_Max.jpg)

**Status**: Platinum

## Post-Installation Setup

- Complete the Bazzite Portal
- Login to Steam
- Reboot device
- Configure the HHD Overlay by opening it with QAM button
- **Optional**: Adjust RGB with Steam Gaming Mode under `Settings > Controller >  Calibration & Advanced > LED Settings`
- Virtual keyboard is Steam's keyboard, but needs to be setup in Steam's settings in Desktop Mode (See "Desktop Controls" section below)

## Workarounds / Known Issues

- Games can sometimes default to 800p resolution.
  - - Manually change the resolution per game in the `Steam Settings > Properties > Game Resolution` to either "Native" or other higher resolutions.
- Back buttons are hard mapped to L3 and R3.
  - This is also an issue on Windows.

# Ayn Loki Mini Pro

![loki_mini_pro|666x500, 100%](../../img/loki_mini_pro.jpg)

**Status**: Silver

## Post-Installation Setup

- Complete the Bazzite Portal
- Login to Steam
- Reboot device
- Configure the HHD Overlay by opening it with QAM button
- **Optional**: Adjust RGB with Steam Gaming Mode under `Settings > Controller >  Calibration & Advanced > LED Settings`
- Virtual keyboard is Steam's keyboard, but needs to be setup in Steam's settings in Desktop Mode (See "Desktop Controls" section below)

## Workarounds / Known Issues

- Games can sometimes default to 800p resolution.
  - - Manually change the resolution per game in the `Steam Settings > Properties > Game Resolution` to either `Native` or other higher resolutions.
- Audio driver does not currently work.
  - No internal audio in either Gaming Mode or Desktop Mode.
    - External audio is reported to have low sound quality.
- Rotation is wrong in Desktop Mode for KDE images.
- Mouse input may break in Desktop Mode.

<hr>

# TDP Controls

![TDP|690x431, 75%](../../img/TDP.jpg)

There are a few options for TDP Controls that work with Bazzite:

- The [HHD-overlay](https://github.com/hhd-dev/hhd/blob/master/readme.md) supports TDP controls.
  - Also has a desktop app that is pre-installed, look for the Handheld Daemon app in Desktop Mode.
- [SimpleDeckyTDP](https://github.com/aarron-lee/SimpleDeckyTDP) supports TDP, GPU, Power Governor, and among other settings.
  - Also has a [graphical application](https://github.com/aarron-lee/SimpleDeckyTDP-Desktop), but needs to be manually installed.
- [PowerControl](https://github.com/mengmeet/PowerControl) supports TDP, GPU, and fan controls on select devices.

# How do I open the HHD Overlay?

![Overlay|690x431, 75%](../../img/Overlay.jpg)
![RGB|690x431, 75%](../../img/RGB.jpg)

Press, hold, or double-tap the Quick Access Menu button.

# Controller Information

For most handheld hardware, besides the Steam Deck, emulation of a DualSense controller is used for full functionality. Double tap or hold the side menu button to access settings for controller emulation including switching to an Xbox controller with reduced functionality.

If your device has paddles, you will want to use the DualSense Edge controller (**excluding the Ayn Loki**). It’s disabled by default because some games do not map it correctly.

Some games and emulators may need Steam Input **disabled** to work correctly with your controls.

## Desktop Controls

Desktop Mode Controller Layout: It may not exist by default if Steam doesn't setup your handheld controller properly. This can be fixed in Steam's controller settings.

![desktop_controls_step_1|588x500, 75%](../../img/desktop_controls_step_1.png)

![desktop_controls_step_2|690x431, 75%](../../img/desktop_controls_step_2.png)

![desktop_controls_step_3|690x431, 75%](../../img/desktop_controls_step_3.jpg)

Make sure to **apply** the desktop controls when you select them.

<hr>

# Contributing

This page is a **wiki**, edit it to add any relevant information you may have regarding the handheld and your experience with Bazzite on it. Make sure to follow proper [documentation guidelines](https://universal-blue.discourse.group/docs?topic=890) and [contributing guidelines](https://universal-blue.discourse.group/docs?topic=81) before adding any edits.

**See also**: [Steam Gaming Mode Overview](../Steam_Gaming_Mode/index.md)

**<-- Back to [Handheld Wiki](index.md)**
