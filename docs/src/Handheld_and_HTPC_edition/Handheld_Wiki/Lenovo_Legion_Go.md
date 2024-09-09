<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2413", "fetched_at": "2024-09-03 16:43:19.836067+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Lenovo Legion Go

![legion_go|690x387, 100%](../../img/legion_go.jpeg)

**Status**: Platinum

## Installing Bazzite

Read the [**Installing Bazzite on Handheld PCs documentation**](https://ublue-os.github.io/bazzite/General/Installation_Guide/Installing_Bazzite_for_Handheld_PCs/).

## Post-Installation Setup

Open a host terminal and enter the following **commands**:

- Complete the Bazzite Portal
- Login to Steam
- Reboot device
- Configure the HHD Overlay by opening it with <kbd>Legion R</kbd>
- **Optional**: Adjust RGB with Steam Gaming Mode under `Settings > Controller >  Calibration & Advanced > LED Settings`

## Optional Tweaks

- Adjust RGB with Steam Gaming Mode in Handheld Daemon
- Adjust the scaling of the UI in the Display Settings
- Set a charge limit in HHD with Handheld Daemon
- Install Decky + the [CSS Loader plugin](https://deckthemes.com/download/deck) and then in Desktop Mode, open the "Terminal" application and enter:
```
ujust install-hhd-controller-glyph-theme
``` 

## Workarounds / Known Issues

- Performance overlay might be reporting inaccurate power consumption. 
- Adaptive/auto display brightness is currently broken.
   - Manual brightness slider in Steam's UI works without issues.
- BIOS and controller firmware is **recommended** to update in Windows.
- Virtual keyboard is Steam's keyboard, but needs to be setup in Steam's settings in Desktop Mode. (See "Desktop Controls" section below)
    - <kbd>**Legion L**</kbd> + <kbd>**X**/**Square**</kbd> (This can be remapped)
- Try not to change the resolution in Desktop Mode!  
  - Connecting to an external monitor may also cause issues.  
    - If your screen doesn't display the correct output or looks grainy/noisy, then you will have to **ssh into it and enter this command**:

```command
mv ~/.config/kwinoutputconfig.json ~/.config/kwinoutputconfig.json.old
```

## BIOS Update Information

A [thread](https://universal-blue.discourse.group/docs?topic=3064) on our forums goes over in detail on how to update the BIOS without having Windows installed.

## External Resource

For more information, check out the [Legion Go Tips and Tricks guide](https://github.com/aarron-lee/legion-go-tricks) which includes useful scripts for this handheld.

<hr>

# Additional Information

This applies to most handhelds running Bazzite.

## TDP Controls

![TDP|690x431, 75%](../../img/TDP.jpeg)

There are a few options for TDP Controls that work with Bazzite:

* The [HHD-overlay](https://github.com/hhd-dev/hhd/blob/master/readme.md) supports TDP controls.
  * Also has a desktop app that is pre-installed, look for the Handheld Daemon app in Desktop Mode.
* [SimpleDeckyTDP](https://github.com/aarron-lee/SimpleDeckyTDP) supports TDP, GPU, Power Governor, and among other settings.
  * Also has a [graphical application](https://github.com/aarron-lee/SimpleDeckyTDP-Desktop), but needs to be manually installed.

## How do I open the HHD Overlay?

![Overlay|690x431, 75%](../../img/HHD_Overlay.jpeg)

![Legion HHD|690x431, 75%](../../img/HHD_Settings_Example.jpeg)


Press, hold, or double-tap the Quick Access Menu button.

>**Example**: <kbd>Legion R</kbd> for the Lenovo Legion Go.

## Controller Information

For most handheld hardware, besides the Steam Deck, emulation of a DualSense controller is used for full functionality. Double tap or hold the side menu button to access settings for controller emulation including switching to an Xbox controller with reduced functionality.

If your device has paddles, you will want to use the DualSense Edge controller. It’s disabled by default because some games do not map it correctly.

Some games and emulators may need Steam Input **disabled** to work correctly with your controls.

### Desktop Controls

Desktop Mode Controller Layout:  It may not exist by default if Steam doesn't setup your handheld controller properly.  This can be fixed in Steam's controller settings.

![desktop_controls_step_1|588x500, 75%](../../img/handheld_desktop_controls_1.png)

![desktop_controls_step_2|690x431, 75%](../../img/handheld_desktop_controls_2.png)

![desktop_controls_step_3|690x431, 75%](../../img/handheld_desktop_controls_3.jpeg)

Make sure to **apply** the desktop controls when you select them.

## Force reboot device to prevent drive corruption if Steam crashes

>**Note**: This is only for the ASUS ROG Ally and Lenovo Legion Go.

Hold down the "**select**" button on your device to force a reboot. This feature can be disabled in the overlay settings.

<hr>

# Contributing

This page is a **wiki**, edit it to add any relevant information you may have regarding the handheld and your experience with Bazzite on it.  Make sure to follow proper [documentation guidelines](https://universal-blue.discourse.group/docs?topic=890) and [contributing guidelines](https://universal-blue.discourse.group/docs?topic=81) before adding any edits.

**See also**: [Steam Gaming Mode Overview](../Steam_Gaming_Mode.md)

**<-- Back to [Handheld Wiki](./index.md)**
