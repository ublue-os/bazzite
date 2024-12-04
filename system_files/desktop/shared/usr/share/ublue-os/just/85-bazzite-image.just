# vim: set ft=make :

# Enable BTRFS deduplication
enable-deduplication:
    systemctl enable btrfs-dedup@var-home.timer
