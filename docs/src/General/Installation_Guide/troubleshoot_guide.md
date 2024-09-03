<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2495", "fetched_at": "2024-09-03 16:43:22.238775+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# ISO Workarounds

A generic error may appear during installation.

**Workaround Video Tutorial**:
https://www.youtube.com/watch?v=GRdz08hJByo


# Alternative Installation Methods

>**Attention**: Both workaround methods may have scaling issues with the installer depending on the hardware especially if it is a handheld PC.

>**Note**: The workarounds below are also useful for **downloading a smaller ISO size**.

### **Option 1**: Rebasing from a Fedora Atomic Desktop Image (Recommended)

If you experience issues with installing our ISO or the bootable drive you have is too small for Bazzite, then download the [Fedora Kinoite (**KDE Plasma**)](https://fedoraproject.org/atomic-desktops/kinoite/) or [Fedora Silverblue (**GNOME**)](https://fedoraproject.org/atomic-desktops/silverblue/)  depending on which desktop environment preferred.

1. The installation setup is similar to Bazzite and includes the same installer with the same instructions, but do **not** set a root account if its an option in the installer.

2. Once installed, you will not be on Bazzite until you enter the command found on our website that appears under ["**Existing Fedora Atomic Desktop Users**" section](https://download.bazzite.gg) when the download is ready.  

3. Open the terminal and enter this command, and keep in mind this process has **no progress indicator** and will take a long time.  

4. Reboot when the rebase has finished, and Bazzite should be installed after rebooting and your username as well as the user password will carry over from the upstream Fedora Atomic Desktop to Bazzite.

5. You will also be **missing the default applications** until you open a host terminal and **enter**:

```command
ujust _install-system-flatpaks
```
>Choose the "Flathub" remote.
>
>**This command installs:**
>- [Flatpak applications for **KDE Plasma** images](https://github.com/ublue-os/bazzite/blob/9f6f5e143b7545d06803e70e7723997400bd8b88/system_files/desktop/kinoite/usr/share/ublue-os/bazzite/flatpak/install)
>- [Flatpak applications for **GNOME** images](https://github.com/ublue-os/bazzite/blob/9f6f5e143b7545d06803e70e7723997400bd8b88/system_files/desktop/silverblue/usr/share/ublue-os/bazzite/flatpak/install)

6. Once everything is setup properly, then you need to rebase from the **unsigned image** to the **signed image**,  so **enter** in a host terminal:

```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/<IMAGE>
```
Replace `<IMAGE>` with the image you're using which can be found from the "**Existing Fedora Atomic Desktop Users**" section as well.

#### Video Tutorial

https://www.youtube.com/watch?v=Vs4cneBW5ck


### **Option 2**: Older & Buggy Net-Installer (Not Recommended)

>**Note**: This is intended as a last resort!  

This is not something we recommend at all, but an alternative solution is using our [Github release](https://github.com/ublue-os/bazzite/releases/tag/v2.1.0) of the last **online** ISO.  This is **extremely buggy** and suffers from other issues that are now fixed in the offline ISO. 

There is an older [video](https://www.youtube.com/watch?v=doQW1FyAISQ) showcasing how to install the Bazzite with this old online ISO.

>**IMPORTANT**: The video guide does **not** mention this part of the process since this wasn’t a requirement previously:

After installing it and making it to the desktop, then you will have to **rebase** to a signed image:


```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/<IMAGE>
```
Replace `<IMAGE>` with the image you're using.

Reboot when the rebasing process has finished, and you will know because it will tell you to reboot your device.

You will also be missing the default applications, so open a host terminal and **enter**:

```command
ujust _install-system-flatpaks
```

>Choose the "Flathub" remote.

**This command installs:**
- [Flatpak applications for **KDE Plasma** images](https://github.com/ublue-os/bazzite/blob/9f6f5e143b7545d06803e70e7723997400bd8b88/system_files/desktop/kinoite/usr/share/ublue-os/bazzite/flatpak/install)
- [Flatpak applications for **GNOME** images](https://github.com/ublue-os/bazzite/blob/9f6f5e143b7545d06803e70e7723997400bd8b88/system_files/desktop/silverblue/usr/share/ublue-os/bazzite/flatpak/install)