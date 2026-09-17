%post --erroronfail --log=/tmp/anacoda_custom_logs/restore-selinux-labels.log
# Make sure SELinux is disabled so restorecon can work.
setenforce 0 || true

# Fix critical policy-store labels.
restorecon -R /etc/selinux

# Properly restore SELinux labels for Flatpak.
restorecon -R /var/lib/flatpak
%end
