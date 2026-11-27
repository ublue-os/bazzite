#!/usr/bin/env bash
set -xeuo pipefail

echo "--- Starting developer build ---"

cp --archive --verbose --force /tmp/system_files/dx/. /

/ctx/bazzite-dx/01-install-packages.sh
/ctx/bazzite-dx/02-configure-desktop.sh
/ctx/bazzite-dx/03-finalize.sh
