#!/usr/bin/bash

set -oue pipefail

if [[ "${AKMODS_FLAVOR}" == "surface" ]]; then
    KERNEL_NAME=kernel-surface
else
    KERNEL_NAME=kernel
fi

KERNEL="$(rpm -q "${KERNEL_NAME}" --queryformat '%{FEDORA_VERSION}-%{RELEASE}.%{ARCH}')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "${KERNEL}" --reproducible -v --add ostree -f /tmp/dracut