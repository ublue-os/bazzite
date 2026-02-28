%post --erroronfail --log=/tmp/anacoda_custom_logs/flatpak-restore-selinux-labels.log
chcon -R -t var_lib_t /var/lib/flatpak
%end
