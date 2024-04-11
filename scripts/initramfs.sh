#!/usr/bin/bash

set -oue pipefail

/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')" --reproducible -v --add ostree -f /tmp/dracut