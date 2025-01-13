#!/usr/bin/bash

set -eoux pipefail

dnf5 clean all
rm -rf /tmp/* || true

ostree container commit
