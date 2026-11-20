#!/usr/bin/env bash

source /usr/lib/ublue/setup-services/libsetup.sh

version-script dx-usergroups privileged 1 || exit 0

# Function to append a group entry to /etc/group
append_group() {
	local group_name="$1"
	if ! grep -q "^$group_name:" /etc/group; then
		echo "Appending $group_name to /etc/group"
		grep "^$group_name:" /usr/lib/group | tee -a /etc/group >/dev/null
	fi
}

# Setup Groups
append_group docker

# We dont have incus on the image yet
# append_group incus-admin
# usermod -aG incus-admin $user

mapfile -t wheelarray < <(getent group wheel | cut -d ":" -f 4 | tr ',' '\n')
for user in "${wheelarray[@]}"; do
	usermod -aG docker "$user"
done