#!/usr/bin/env bash
#
# Clean up temporary, log, and boot files to free disk space.
#
set -xeuo pipefail

# -- Remove temporary files --
# Clear all contents of /tmp to reclaim space used by temporary data.
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# -- Remove DNF5 log file --
# Delete the DNF5 package manager log if it exists.
rm -rf /var/log/dnf5.log || true

# -- Remove boot files --
# Clear old kernel images and boot artifacts from /boot.
# Intentionally clear /boot in the image being built.
# shellcheck disable=SC2115
rm -rf /boot/* || true
rm -rf /boot/.* || true
rm -rf /usr/lib/sysimage/libdnf5/* || true

# This needs to run after every single rpm transaction in the build has been done
# Relink rpm-ostree-base-db to rpmdb to ensure it correctly reflects the system
# image's rpmdb and doesn't carry over package info from the base image.
# See: https://github.com/coreos/rpm-ostree/issues/4554
# https://forge.fedoraproject.org/atomic/tracker/issues/82
for file in rpmdb.sqlite rpmdb.sqlite-shm rpmdb.sqlite-wal; do
    target="/usr/share/rpm/${file}"
    link_path="/usr/lib/sysimage/rpm-ostree-base-db/${file}"
    if [[ -f "${target}" && -f "${link_path}" ]]; then
        # Note, this needs to be a hardlink, not a symbolic link.
        ln -f "${target}" "${link_path}"
    fi
done
