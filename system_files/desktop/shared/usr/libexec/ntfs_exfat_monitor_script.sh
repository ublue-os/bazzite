#!/usr/bin/env bash

#set initial count variables
ntfs=$(lsblk -o fstype,mountpoint | grep -Ec 'ntfs.*\S+')
exfat=$(lsblk -o fstype,mountpoint | grep -Ec 'exfat.*\S+')

#monitor for device add/remove events
udevadm monitor --kernel --udev --subsystem=block | while read -r line; do

#reduce # of greps
    if [[ "$line" != *" change "* ]]; then
        continue
    fi


    new_ntfs=$(lsblk -o fstype,mountpoint | grep -Ec 'ntfs.*\S+')
    new_exfat=$(lsblk -o fstype,mountpoint | grep -Ec 'exfat.*\S+')
    #compare current count to last count, if number increased,
    if [[ "$new_ntfs" > "$ntfs" ]] || [[ "$new_exfat" > "$exfat" ]];
        then
            echo "ntfs count "$ntfs
            echo "new ntfs count "$new_ntfs
            echo "exfat count "$exfat
            echo "new exfat count "$new_exfat
            # send notification
            choice=$(notify-send  -t 500000 --action="opt1=I understand" --action="opt2=Learn more"  -a "Bazzite" "Unsupported filesystems"  "You have mounted an NTFS/exFAT (Windows) partition. You can use it for storing data, however running games from Windows drives is unsupported.")
            echo "User selected $choice"
                case $choice in
                    "opt1")
                        #do nothing
                        ;;
                    "opt2")
                        #open documentation in browser
                        xdg-open "https://docs.bazzite.gg/Gaming/Hardware_compatibility_for_gaming/#unsupported-filesystems-for-secondary-drives" 2> /dev/null
                        ;;
                esac
    fi
    exfat=$new_exfat
    ntfs=$new_ntfs


done
