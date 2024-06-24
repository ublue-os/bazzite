[Unit]
Description=Workaround sunshine not having the correct caps
ConditionFileIsExecutable=/usr/bin/sunshine
After=local-fs.target

[Service]
Type=oneshot
# Copy if it doesn't exist
ExecStartPre=/usr/bin/bash -c "[ -x /usr/local/bin/.sunshine ] || /usr/bin/cp /usr/bin/sunshine /usr/local/bin/.sunshine"
# This is faster than using .mount unit. Also allows for the previous line/cleanup
ExecStartPre=/usr/bin/bash -c "/usr/bin/mount --bind /usr/local/bin/.sunshine /usr/bin/sunshine"
# Fix caps
ExecStart=/usr/bin/bash -c "/usr/sbin/setcap 'cap_sys_admin+p' $(/usr/bin/readlink -f $(/usr/bin/which sunshine))"
# Clean-up after ourselves
ExecStop=/usr/bin/umount /usr/bin/sunshine
ExecStop=/usr/bin/rm /usr/local/bin/.sunshine
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
