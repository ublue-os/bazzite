It is **always** better to install packages with Distrobox than to layer them with rpm-ostree. `ujust distrobox` makes it easy!
Packages installed in Distrobox can be exported to appear like any other application ([View documentation](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-export.md)).
Update break something? You can roll back and pin the previous release or rebase by build date ([View our guide](https://universal-blue.discourse.group/docs?topic=513)).
Installing a non-Steam Windows game? Lutris is pre-installed for better handling of wine prefixes.
BTRFS is used by default for external drives, and we recommend that or EXT4 over NTFS ([More info here](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows)).