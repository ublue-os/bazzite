#!/usr/bin/env bash
set -xeuo pipefail

echo "::group::Finalize bazzite-dx image"
trap 'echo "::endgroup::"' EXIT

systemctl enable docker.socket podman.socket
systemctl enable ublue-system-setup.service bazzite-dx-groups.service
systemctl --global enable ublue-user-setup.service

echo 'import "/usr/share/ublue-os/just/95-bazzite-dx.just"' >> /usr/share/ublue-os/justfile
sed -i \
    '/^yaml-blocklist-paths:/a\  - /usr/share/ublue-os/bazaar/blocklist-dx.yaml' \
    /usr/share/ublue-os/bazaar/main.yaml

mkdir -p /usr/lib/opt
for directory in /var/opt/*/; do
    [[ -d "${directory}" ]] || continue
    name=$(basename "${directory}")
    mv "${directory}" "/usr/lib/opt/${name}"
    echo "L+ /var/opt/${name} - - - - /usr/lib/opt/${name}" >> /usr/lib/tmpfiles.d/opt-fix.conf
done
