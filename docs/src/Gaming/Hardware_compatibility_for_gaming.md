<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2659", "fetched_at": "2024-09-03 16:43:08.896738+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Compatible Handhelds
Read the [Handheld Wiki](../Handheld_and_HTPC_edition/Handheld_Wiki/index.md) to see what handhelds Bazzite currently supports.

# Desktop/HTPC Hardware: Vulkan Compatible GPU

Linux gaming is heavily dependent on having compatible hardware with Vulkan.

If you're using a device with an older or weaker GPU that does not support **Vulkan 1.3 or later**, then you need to use older Proton and Wine builds like **Proton/WINE 6** or earlier. 

Check which Vulkan version your GPU uses, enter this in the terminal:
```command
vulkaninfo | grep 'Instance Version'
```

- If it outputs less than `1.3` in the `Vulkan Instance Version:`  or does not work at all, then you will run into issues including unplayable games and worse performance.
- Really old devices may need to resort to OpenGL translation which performs worse, has graphical issues, etc.

Using insufficient hardware requires utilizing older Proton versions and use this **launch option for most games**:

```command
PROTON_USE_WINED3D=1 %command%
```

# Unsupported Filesystems for Secondary Drives

>**Warning**:  You will lose all of your data reformatting secondary internal/external drives.

See also: [**Auto-Mounting Secondary Drives**](../Advanced/Auto-Mounting_Secondary_Drives.md)

## NTFS

If you are coming from Windows and plan to game on a secondary drive with games already installed on it, then we regret to inform you that the NTFS filesystem is **unsupported** for gaming.  

Any secondary drives that you plan to play video games on should be **backed up and reformatted to either Ext4 or BTRFS**.  You will lose all of the data on this device.

You can use KDE Partition Manager (KDE images) or GNOME Disks (GNOME images) to format the drives appropriately **at your own risk**. 

There is a [guide](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows) for using Proton with NTFS drive, but issues may occur with this setup.

## exFAT and FAT32

exFAT and FAT32 are **unsupported** entirely.  Both filesystems **do not support symbolic links** which is what Proton prefixes use.  

>However, scenarios where a microSD card is formatted to exFAT *may work* in some cases, but it is entirely unsupported by Universal Blue if something goes horribly wrong using it.

# Sharing Games w/ Windows Installation

Install the unofficial [WinBtrfs](https://github.com/maharmstone/btrfs) driver on your Windows installation at your own risk.  Please note that Gamepass games and games installed and launched through the Epic Games Launcher do **not** work with BTRFS under Windows.

<hr>

[**<-- Back to Gaming Guide**](./index.md)
