#!/usr/bin/bash

set -oue pipefail

if [[ "${AKMODS_FLAVOR}" == "surface" ]]; then
    KERNEL_SUFFIX="surface"
else
    KERNEL_SUFFIX=""
fi

/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')" --reproducible -v --add ostree -f /tmp/dracut