# vim: set ft=make :

# Enable BTRFS deduplication
[group("system")]
enable-deduplication:
    systemctl enable btrfs-dedup@var-home.timer
