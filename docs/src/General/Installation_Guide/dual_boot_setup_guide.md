<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "htthttps://universal-blue.discourse.group/docs?topic=2743", "fetched_at": "2024-09-03 16:43:23.309649+00:00"}-->
<!-- ANCHOR_END: METADATA -->

>**Note**:  Make sure to read the [**Installation Guide**](./index.md) for your device first before proceeding.

# Two Methods: Method *A* or Method *B*

* **A)** Installing Bazzite on a separate drive (Recommended)
* **B)** Manual partitioning on the same drive

## **A**) *Separate* Drive Method

>**Note**: This method is ideal for desktops and HTPCs, and would be inconvenient for handhelds unless planned to keep stationary.

Install Bazzite on a separate internal or external drive.

1. Install the other operating system on a drive (like Windows)
2. Install Bazzite on a **second** drive
3. Set Bazzite as the **default** in your boot order (optional)

You can also install Windows to an external drive with Windows-to-Go using [Rufus](https://rufus.ie/en/) to dual boot if you do not have an internal drive available.

## **B**) *Same* Drive Method

> **Note**: This must be done **before installing Bazzite**.

>Recommended for handheld PCs or mobile setups.

If you do not have multiple drives or are using a device that will not be stationary, then you will have to manually partition on the same drive.

### Note about dual booting with **Windows** specifically:

Dual booting Bazzite with Windows on the same drive works better with **Windows already installed before Bazzite**.

### Bazzite Partition

Create space for Bazzite with the Disk Management application in Windows.

<kbd>Win</kbd> + <kbd>R</kbd> to open Windows Run and enter: 
```
diskmgmt.msc
```
Then, right-click your Windows partition and select "Shrink Volume" from the drop-down menu.  Afterwards, select how much storage you want to allocate for Bazzite.

It is **strongly recommended for to setup a separate EFI partition**. The separate EFI partition will help prevent Windows Updates from affecting your Bazzite installation later down the line.

# Manual Partitioning to the Same Drive for Dual Boot Setups

If you need a tutorial video for manual partitioning, watch this [tutorial]( https://www.youtube.com/watch?v=EDip92Zq-RE).

1.  Select Installation Destination
2.  Select `Advanced Custom(Blivet-GUI)` under Storage Configuration.
3.  Create partitions and devices:
   
    ```
    Manual Partitioning Scheme:

    mount point: /boot/efi  
    format:      EFI system partition
    size:        300MB  

    mount point: /boot
    format:      ext4
    size:        1GB

    mount point:
    format: btrfs
    size: [max]

    mount point: /
    format:      btrfs (subvolume)

    mount point: /var
    format:      btrfs (subvolume)

    mount point: /var/home
    format:      btrfs (subvolume)
    ```

>**Note about dual booting other Fedora Atomic Desktop images on the **same** drive**: If you want to dual boot another **Fedora libostree image** (like [Bluefin](https://projectbluefin.io/)) installed alongside Bazzite, then you would have to make an additional EFI partition and switch between them through the BIOS boot menu.

<hr>

# Dual Boot Post-Configuration Setup

>**Note:** [Handheld/HTPC](../../Handheld_and_HTPC_edition/Steam_Gaming_Mode.md) images hide GRUB by default, but the <kbd>Esc</kbd> key on a keyboard will unhide the GRUB menu without unhiding it with a `ujust` command.

## Regenerate GRUB to show Windows Entry

If you  do **not** see your Windows boot in the GRUB menu, then open a host terminal and **enter**:

```
ujust regenerate-grub
```
## Bazzite as Primary Boot

If the `OS Boot Manager` has set `Windows Boot Manager` to be the first boot priority, then this may result in booting directly into Windows after the install instead of Bazzite.  You may have to fix this in your BIOS settings.

<hr>

**Documentation Contributors**: [ChaiQi](https://github.com/atimeofday), [Damian Korcz](https://github.com/damiankorcz), and [Aarron Lee](https://github.com/aarron-lee)