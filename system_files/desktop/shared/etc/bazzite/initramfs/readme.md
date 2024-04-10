Creating the file `rebuild` in this folder will cause
bazzite-hardware-setup to rebuild initramfs on the next boot.

This will include any dracut.conf files from: `/etc/dracut.conf.d/`

If you used any custom arguments through the `args.d` folder,
they have been deprecated in favor of `dracut` config files.
This was because `rpm-ostree` was very picky with it's initramfs args.
