# KDE Partition Manager Auto-Mount Guide

<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=3780", "fetched_at": "2024-09-03 16:43:09.824214+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![KDE|48x48](https://universal-blue.discourse.group/uploads/short-url/36fqQF6jDStXU1NdJBAEbfxlUP0.png)

**This is pre-installed on KDE images.**

# Instructions

![KDE Partition Manager|690x462, 75%](https://universal-blue.discourse.group/uploads/short-url/o0eqJ0Eg45DagNv4qBb3ev5pohU.png)
![Do not check the boxes!|690x197](https://universal-blue.discourse.group/uploads/short-url/ouTOEbJCNdYgjmANiiWYSP9IuNM.png)

1.  Open KDE Partition Manager
2.  Locate the disk and partition you want to mount
3.  Right click on the partition and click "Edit Mount Point"
4.  Select "Identify by: UUID" (This will guarantee you mount THIS partition instead of a different one if the device nodes change for some reason)
5.  Select a mounting path (You would want to use `/var/mnt/games` or something similar for permanent mounts)
6.  **Untick all the boxes in the graphical application if they are checked**
7.  Click "More..." and add extra options depending on what filesystem is on the partition (read the "Filesystem Arguments" section)
8.  Click OK on both windows to save the mount points.
9. A message will appear that the actions will edit `/etc/fstab` (Click "OK" to continue)
10. Mount the disk manually in KDE Partition Manager and enter your sudo password
11.  Open the terminal to test the mounts by running the **command**: 
```command
sudo systemctl daemon-reload && sudo mount -a
```
12. **If no errors appeared then it should be safe to reboot.**
        
>**Note**: If errors occur, then research the error and undo what you did and try again.  Redo the previous two steps in the terminal (see CLI method down below and research how to use fstab) as KDE Partition Manager might not give a good error to search for if the test mount fails.

Display Name should be added too.  Name it whatever you want it to be identified as.

## Required additional options depending on **filesystem**
Use the below generic options depending on your filesystem (these are just good defaults)
You can copy+paste these into the "More.." dialog and they will be valid

>**Note**:  "Users can mount and unmount" is an **optional** setting.

## Filesystem arguments

>**Warning**: If a drive is formatted, then do not remove it from `/etc/fstab`, so the "nofail" option is a must to avoid issues with booting.

![btrfs example|290x317](https://universal-blue.discourse.group/uploads/short-url/iB9gQvWpbMBjaKGagqJaSgtFbNt.png)
>**Example: btrfs requires these additional options.**


### **BTRFS**: 
```command
defaults,compress-force=zstd:3,noatime,lazytime,commit=120,space_cache=v2,nofail
```

### **Ext4**:  
```command
defaults,noatime,errors=remount-ro,nofail,rw,users,exec
```

### **NTFS**:  
```command
defaults,noatime,nofail,rw,users,exec
```
>**Note**: Do not use the NTFS filesystem for game library storage in Bazzite, and it is not supported and you will get lots of issues with it.  NTFS is **not** intended as a game drive for Bazzite.

## Advanced Options (Not required for most setups)
>Change at your own risk!

### Information about compression: 

**3** is a good balance, older CPUs should use **1**.

### Information about subvolumes: 

use `subvol=name` as an option, KDE and GNOME Disks let you only mount 1 subvolume through the GUI, you can mount the root with `subvol=/` if a default subvolume is configured in the filesystem.

# Installing KDE Partition Manager on non-KDE images

If you would like to install this, then it can be layered to your system by entering in a terminal:

```
rpm-ostree install kde-partitionmanager
```

Reboot your system after it has finished installing the terminal.
