%post --erroronfail --nochroot --log=/tmp/anacoda_custom_logs/install-flatpaks.log
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"

# Trailing slash is mandatory
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/flatpak/"
mkdir -p "$target"

# Trailing slash is mandatory
rsync -aAXUHKP /var/lib/flatpak_original/ "$target"
sync "$target"
%end
