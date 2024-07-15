---
title: Hardware Compatibility

---

# Vulkan Compatible GPU

Linux gaming is heavily dependent on having compatible hardware with Vulkan.

If you're using a device with an older or weaker GPU that does not support **Vulkan 1.3 or later**, then you need to use older Proton and Wine builds like **Proton/WINE 6** or earlier. 

Check which Vulkan version your GPU uses, enter this in the terminal:
```
vulkaninfo | grep 'Instance Version'
```

- If it outputs less than `1.3` in the `Vulkan Instance Version:`  or does not work at all, then you will run into issues including unplayable games and worse performance.
- Really old devices may need to resort to OpenGL translation which performs worse, has graphical issues, etc.

Using insufficient hardware requires utilizing older Proton versions and use this **launch option for most games**:

```
PROTON_USE_WINED3D=1 %command%
```

# **Storage**: NTFS and exFAT Filesystems for Secondary Drives

>**Warning**:  You will lose all of your data reformatting secondary internal/external drives.

Bazzite supports BTRFS or Ext4 for secondary filesystems that are intended to run video games off of.

## NTFS

If you are coming from Windows and plan to game on a secondary drive with games already installed on it, then we regret to inform you that the NTFS filesystem is **unsupported** for gaming.  

Any secondary drives that you plan to play video games on should be **backed up and reformatted to either Ext4 or BTRFS**.  You will lose all of the data on this device.

You can use KDE Partition Manager (KDE images) or GNOME Disks (GNOME images) to format the drives appropriately **at your own risk**. 

There is a [guide](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows) for using Proton with NTFS drive, but issues may occur with this setup.

## exFAT and FAT32

exFAT and FAT32 are **unsupported** entirely.  Both filesystems **do not support symlinks** which is what Proton prefixes use.

<hr>

**Documentation Contributors**: [Kyle Gospodnetich](https://github.com/KyleGospo), [RJ Trujillo](https://github.com/EyeCantCU), [Benjamin Shermin](https://github.com/bsherman), [Nathaniel Warburton](https://github.com/storyaddict), and [Jorge Castro](https://github.com/castrojo)

[**<-- View online documentation**](https://universal-blue.discourse.group/docs?topic=2659)