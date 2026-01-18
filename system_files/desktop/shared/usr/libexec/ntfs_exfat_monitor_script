#!/usr/bin/env bash

#set user facing variables
firstbutton="I understand"
firstbutton_ignore="Temporarily ignore"
secondbutton="Learn more"
sender="Bazzite"
header="Unsupported filesystem"
warning="You have mounted an NTFS/exFAT (Windows) partition. You can use it for storing data, however running games from Windows drives will cause problems."
documentation="https://docs.bazzite.gg/Gaming/Hardware_compatibility_for_gaming/#unsupported-filesystems-for-secondary-drives"

#set other variables
counter=0
ntfs=$(lsblk -o fstype,mountpoint | grep -Ec 'ntfs.*\S+')
exfat=$(lsblk -o fstype,mountpoint | grep -Ec 'exfat.*\S+')

#monitor for fuseblk and exfat mount events
findmnt -n --poll -t exfat,ntfs,fuseblk | while read -r _; do

    new_ntfs=$(lsblk -o fstype,mountpoint | grep -Ec 'ntfs.*\S+')
    new_exfat=$(lsblk -o fstype,mountpoint | grep -Ec 'exfat.*\S+')
    #compare current count to last count, if number increased,
    if [[ "$new_ntfs" > "$ntfs" ]] || [[ "$new_exfat" > "$exfat" ]];
        then
            echo "ntfs count: "$ntfs -> new ntfs count: "$new_ntfs"
            echo "exfat count: "$exfat -> new exfat count: "$new_exfat"
            #change button text if first button was clicked 5 times or more
            if [[ "$counter" > 4 ]]; then
                firstbutton=$firstbutton_ignore
            fi
            # send notification
            choice="$(notify-send  -t 500000 --action="opt1=$firstbutton" --action="opt2=$secondbutton"  -a "$sender" "$header" "$warning")"
                case $choice in
                    "opt1")
                        if [[ "$counter" > 4 ]]; then
                            echo "stopping service as per user choice. Goodbye."
                            systemctl --user stop ntfs-nag
                        fi
                        ((counter++))
                        echo "counter: "$counter
                        ;;
                    "opt2")
                        #open documentation in browser
                        xdg-open "$documentation" 2> /dev/null
                        ;;
                esac

    fi
    exfat=$new_exfat
    ntfs=$new_ntfs

done
