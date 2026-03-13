#!/usr/bin/env bash
set -xeuo pipefail

# Add bazzite-dx just file
echo "import \"/usr/share/ublue-os/just/95-bazzite-dx.just\"" >> /usr/share/ublue-os/justfile
