#!/usr/bin/env bash
#
# Build an initramfs image for the installed kernel using dracut.
#
# Supports kernel flavors (e.g. "surface") and integrates with ostree/fido2.
#
set -xeuo pipefail

echo "::group::Build initramfs"
trap 'echo "::endgroup::"' EXIT

# Set KERNEL_SUFFIX based on KERNEL_FLAVOR, defaulting to empty.
if [[ "${KERNEL_FLAVOR:-}" == "surface" ]]; then
    KERNEL_SUFFIX="surface"
else
    KERNEL_SUFFIX=""
fi

# Retrieve the installed kernel version with architecture using dnf5.
QUALIFIED_KERNEL="$(
    dnf5 repoquery \
        --installed \
        --queryformat='%{evr}.%{arch}' \
        "kernel${KERNEL_SUFFIX:+-${KERNEL_SUFFIX}}"
)"
INITRAMFS="/usr/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"

# Exclude build-specific metadata from the initramfs.
OS_RELEASE="/usr/lib/os-release"
TMP_OS_RELEASE=$(mktemp --tmpdir 'os-release-XXXXXXXXXX')
cp "${OS_RELEASE}" "${TMP_OS_RELEASE}"
sed -Ei -e '/^((OSTREE_)?(IMAGE_)?VERSION|PRETTY_NAME|BUILD_ID|BOOTLOADER_NAME|IMAGE_ID)=/d' "${OS_RELEASE}"

# Generate a reproducible initramfs with ostree and fido2 support.
DRACUT_NO_XATTR=1 /usr/bin/dracut \
    --no-hostonly \
    --kver "${QUALIFIED_KERNEL}" \
    --reproducible \
    --zstd \
    -v \
    --add ostree \
    --add fido2 \
    -f "${INITRAMFS}"

# Copy back to preserve the original os-release permissions.
cp "${TMP_OS_RELEASE}" "${OS_RELEASE}"
rm "${TMP_OS_RELEASE}"

# Restrict read/write access to root only.
chmod 0600 "${INITRAMFS}"
