<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=161", "fetched_at": "2024-09-03 16:43:11.636024+00:00"}-->
<!-- ANCHOR_END: METADATA -->

>Follow this guide **at your own discretion** because you can break your system attempting any of this.

![Edit the command for the latest boot entry|690x351](https://universal-blue.discourse.group/uploads/short-url/3DKuxnu44jDcrwx30k2mxFXjLXD.png)

Reboot your device and edit the last deployment by presssing <kbd>E</kbd> on your keyboard.

![Boot with init=/bin/bash|689x359](https://universal-blue.discourse.group/uploads/short-url/6cMudm3PEkBwYakT3FQOlpMtkxF.jpeg)

Boot with `init=/bin/bash` on the kernel command line (e.g. edit GRUB prompt.)

![Reboot|689x359](https://universal-blue.discourse.group/uploads/short-url/1gpqkxAiCQqofTEYWIL7XPONGKr.jpeg)

Continue boot process with <kbd>Ctrl</kbd>+<kbd>X</kbd>

Once you are in the GRUB command line:
1. Temporarily mount SELinux
```
mount -t selinuxfs selinuxfs /sys/fs/selinux
```
2.  Load SELinux policy
```
/sbin/load_policy
```
3. Enter your new password (i.e. passwd nick)
```
passwd [INSERT USERNAME HERE] 
```
4. Sync
```command
sync
```
5. Reboot
```
/sbin/reboot -ff
```

![Commands|690x334](https://universal-blue.discourse.group/uploads/short-url/v3mTMw4ZmaiMU2FuIIIt2gKnKuw.png)

Your user password should now be reset.

Thanks to [Colin Walters](https://github.com/cgwalters) for the [solution](https://github.com/ublue-os/main/issues/469#issuecomment-1885264886).

<hr>

**Documentation Contributors**: [Noel Miller](https://github.com/noelmiller)

[**<-- View all Bazzite documentation**](https://docs.bazzite.gg)
