#!/usr/bin/bash

set -eoux pipefail

dnf5 clean all
rm -rf /tmp/* || true
rm -rf /var/log/dnf5.log || true
rm -rf /boot/* || true
rm -rf /boot/.* || true

ostree container commit
