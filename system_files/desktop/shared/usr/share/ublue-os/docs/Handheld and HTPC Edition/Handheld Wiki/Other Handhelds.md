---
title: Other Handhelds

---

# Other Handhelds

>Certain handhelds have been confirmed to boot Bazzite, but are plagued by missing driver support for Linux including missing audio drivers.

Unsupported handhelds *could work* with Bazzite and the "**Other Handhelds**" section should cover unsupported handhelds, but there may be major issues encountered that are undocumented.  If your handheld hardware is not listed, then you can still give Bazzite a try with our Handheld/HTPC image.  

Your mileage may vary with untested hardware.  Bazzite does **not** have the required setup for unsupported handheld, so setup will be manually done by the end user with unsupported handhelds.

**Commands for functional HHD**:
**Test HHD**:

```
systemctl start hhd@yourusername
```

If the test is successful:

```
systemctl enable hhd@yourusername
```
>**Note**: Replace `yourusername` with your Bazzite username.

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

# Controller Information

For most handheld hardware, besides the Steam Deck, emulation of a DualSense controller is used for full functionality. Double tap or hold the side menu button to access settings for controller emulation including switching to an Xbox controller with reduced functionality.

If your device has paddles, you will want to use the DualSense Edge controller (**except for a few like the Ayn Loki**). It’s disabled by default because some games do not map it correctly.

Some games and emulators may need Steam Input **disabled** to work correctly with your controls.

## Desktop Controls

Desktop Mode Controller Layout:  It may not exist by default if Steam doesn't setup your handheld controller properly.  This can be fixed in Steam's controller settings.

Make sure to **apply** the desktop controls when you select them.

<hr>

[View online documentation](https://universal-blue.discourse.group/docs?topic=2415)