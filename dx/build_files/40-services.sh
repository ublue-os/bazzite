#!/usr/bin/env bash
set -xeuo pipefail

systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable ublue-system-setup.service
systemctl --global enable ublue-user-setup.service
systemctl enable bazzite-dx-groups.service
