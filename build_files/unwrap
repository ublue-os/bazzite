#!/usr/bin/bash

set -eoux pipefail

# there is no 'rpm-ostree cliwrap uninstall-from-root', but this is close enough. See:
# https://github.com/coreos/rpm-ostree/blob/6d2548ddb2bfa8f4e9bafe5c6e717cf9531d8001/rust/src/cliwrap.rs#L25-L32
if [ -d /usr/libexec/rpm-ostree/wrapped ]; then
    # binaries which could be created if they did not exist thus may not be in wrapped dir
    rm -f \
        /usr/bin/yum \
        /usr/bin/dnf \
        /usr/bin/kernel-install
    # binaries which were wrapped
    mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin
    rm -fr /usr/libexec/rpm-ostree
fi
