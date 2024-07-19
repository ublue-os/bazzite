---
title: System Rollbacks

---

# How do I rollback a system update?

A rollback to the previous system deployment can be done by **entering this command in a host terminal**: 
```
rpm-ostree rollback
``` 
Rollback can also be done in the GRUB menu (the menu you see before booting into Bazzite on Desktop images) by choosing the previous boot entry before booting to the desktop.  It shows your current (`:0`) and your previous (`:1`) deployments, but due to a bug upstream there may be duplicates below them.  Your personal files will **not** be affected by this, and you can still update to the newest builds after rolling back.

## Unhide The GRUB Menu on Handheld/HTPC Images

Handheld/HTPC images do **not** show the GRUB menu at boot by default, and controls may vary with different handheld or HTPC hardware to unhide the menu.

Unhide GRUB on Handheld/HTPC images with this **command**:

```
ujust configure-grub
```
Select the "**unhide**" opiton to have GRUB appear on boot.

# How do I save my **current** deployment?

You can pin your **current** deployment with this **command**:
```
sudo ostree admin pin 0
``` 
In a host terminal for a backup save state of your **current** deployment to rollback to if a new system update causes issues. 

# How do I save my **previous** deployment?

You can pin your **previous** deployment with this **command**:
```
sudo ostree admin pin 1
``` 
In a host terminal for a backup save state of your **previous** deployment to rollback if the current deployment has issues.

# How do I unpin a deployment if I saved it?


Unpin saved **current** deployment:
```
sudo ostree admin pin --unpin 0
```

Unpin saved **previous** deployment:

```
sudo ostree admin pin --unpin 1
```

View all deployment index numbers:

```
rpm-ostree status -v
```

Unpin **saved** deployment:
```
sudo ostree admin pin --unpin <index number>
```

<hr>

[**<-- View online Bazzite documentation**](https://universal-blue.discourse.group/docs?topic=2644)
