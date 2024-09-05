<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2637", "fetched_at": "2024-09-03 16:43:13.297624+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![System Updates|200x200, 100%](../../img/System_Updates.png)

# How do updates work?

Bazzite updates all of the changes made specifically in Bazzite itself, updates from Fedora's base packages upstream, and most user installed applications.  Bazzite typically has new builds twice a week and you can see when it builds [here](https://github.com/ublue-os/bazzite/actions/workflows/build.yml?query=branch%3Amain).

## Desktop Images

- System updates happen **automatically daily** on a schedule and when the hardware is not under heavy use, like playing video games.
  - There is a check in-place to only update the image when your CPU, battery, and RAM usage meets certain requirements.
- Updates will be downloaded in the background and will **apply on the next reboot** and should contain the newest build of Bazzite.

## Handheld/HTPC Images

- Updates can be managed in Steam Gaming Mode **manually** by the user.
   - Open: **Steam Menu** > **Settings** > **System** > **Check for Updates** > **Apply**
       - **Reboot** to apply system upgrades.
- Updates upgrade system packages, containers and installed applications.
- The progress indicator and changelogs are not accurate currently.
  - There's more information at the bottom of this [documentation](https://universal-blue.discourse.group/docs?topic=37).

# How do I update manually on Desktop images?

>**Note**: This manual method also works in Desktop Mode on Handheld/HTPC images in Desktop Mode.


**Note**: `rpm-ostree` does not show a progress indicator for system updates and may appear frozen, but it is not.

- You can force an update with the System Update tool at your own convenience.
  - Reboot your device after it has finished.
  - This upgrades system packages, containers, and installed applications.

## Terminal command to update manually:
```command
ujust update
``` 

## Do I have to reboot after every system update?
**No**, but the system upgrade will not apply until the next reboot.  

- Desktop images: While your device is running, newer updates will still download in the background once a day, and will be waiting to be applied until the device is rebooted.
- Handheld/HTPC images: Updates will be checked daily and can be downloaded at your leisure.
  - Users will need to apply system updates manually similarly to SteamOS.

# How do I view the changelog for each update?
Open a host terminal and enter this **command**:

```
ujust changelogs
```

If you want to see what packages were upgraded/downgraded then enter this **command**:

```
rpm-ostree db diff
```

If the package update contains a formal changelog:

```
rpm-ostree db diff --changelogs
```

Alternatively, you can subscribe to the [RSS feed](https://universal-blue.discourse.group/t/tutorial-subscribing-to-bazzite-news-for-major-update-information/3672) for major announcements regarding the project. 

# How often is there a new Bazzite build?

Usually Bazzite is built twice a week which includes the new changes from us, but it can also be built more than this.  Updates may happen multiple times a day regardless due to updates from upstream (Universal Blue and Fedora), applications installed, firmware upgrades, and any containers that exist on your system updating their packages.

# How does updating to a new Fedora major release work?
Bazzite should automatically update when our new builds based on that new major release are ready, and usually aims for the around the same day when the new Fedora Linux release is out.  

# Can I enable update notifications for Desktop images?
**Yes**

1. Open a host terminal and **enter**:
```command
sudo nano /etc/ublue-update/ublue-update.toml
```

2. Change this line inside of the file:
`dbus_notify = false` to `dbus_notify = true`

3. Save the file as `/etc/ublue-update/ublue-update.toml`

Notifications for updates are now active.

# How do I disable automatic updates for Desktop images?

Read the [upstream documentation](https://universal-blue.discourse.group/docs?topic=80#manually-for-bazzite-and-bluefin-3) to disable automatic updates.

<hr>

[**<-- Back to Updates, Rollback, and Rebasing Guide**](https://universal-blue.discourse.group/docs?topic=36)