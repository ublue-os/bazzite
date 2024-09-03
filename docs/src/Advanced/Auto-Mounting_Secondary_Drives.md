<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=970", "fetched_at": "2024-09-03 16:43:14.005694+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# WARNING!

>**Attention**: You may lose data on the drive(s) or result in an unbootable system if configured improperly.

>**Note:** MicroSD cards automatically mount without any manual intervention required on Bazzite.

>**Important**: Do **not** use the NTFS, exFAT, or FAT32 filesystems for game library storage.

Follow this guide **at your own discretion** and make sure to read the entire document relevant to your method, so you do not miss anything!

<hr>

# Formatting a disk

>**Warning**: This will wipe all existing data on it

## Note when formatting in **KDE Partition Manager**
Make sure you set permissions to **everyone**.

Use a disk graphical user interface like KDE Plasma or GNOME Disks to format your drive.  We recommend formatting secondary drives to **BTRFS** or **Ext4**.  BTRFS is our recommended filesystem, but Ext4 may be better for older spinning mechanical HDDs as secondary drives.

## Creating a secondary drive directory and where to mount drives?
>**Note**: Drive directories should be **lowercase** with **no spaces** for best practice.

>**Attention**: `/var/mnt` should NOT be the path, but create a new **directory** in either `/var/mnt` or `/var/run/media/`.


- `/var/mnt/...` for **permanent** drives
- `/var/run/media/...` for **removable** drives


You can make a directory in `/var/mnt/` by opening a host terminal and **entering this command in a host terminal**:

```command
cd /var/mnt
```
```command
sudo mkdir /var/mnt/games
```

The drive will now be mounted in a directory known as `games`.

>**Note**: `games` can be named anything you desire that fits best practices.

### Permissions for the drive
```command
sudo chown $USER:$USER /var/mnt/games
```

>**Note**: If you plan to reformat the partition, remember to edit the mount point and "Remove" the mount path before you reformat! If not you will have to manually edit `/etc/fstab`.

# Graphical User Interface (GUI) Methods for Auto-Mounting

>**Warning**: Do not set up auto-mount, unmount then format a drive!  It can confuse the software you are configuring drives with.  Instead, **remove the auto-mount first before formatting the drive**.


* [**KDE Partition Manager**](https://universal-blue.discourse.group/docs?topic=3780)
* [**GNOME Disks**](https://universal-blue.discourse.group/docs?topic=3781)

# Alternative Methods (CLI)

There are also two command-line interface (CLI) methods.

1.  Using `systemd.mount`

2.  Editing the `/etc/fstab` file


Command Line Interface methods are intended for advanced users, and it is recommended to research one of the two methods outside of this documentation.

<hr>

# Emergency Mode After Mounting?

This video tutorial shows how to recover from your mounting mistakes.

https://www.youtube.com/watch?v=-2wca_0CpXY

<hr>

**Documentation Contributors**: [HikariKnight](https://github.com/HikariKnight) and [asen23](https://github.com/asen23)

<-- [**View all Bazzite documentation**](https://docs.bazzite.gg)