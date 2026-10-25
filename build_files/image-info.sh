#!/usr/bin/env bash
#
# Generate image metadata and update os-release for the Bazzite image.
#
set -xeuo pipefail

echo "::group::Set image metadata"
trap 'echo "::endgroup::"' EXIT

# Set image identifiers, URLs, and branding constants.
IMAGE_PRETTY_NAME="Bazzite"
IMAGE_LIKE="fedora"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_BRANCH_NORMALIZED="${IMAGE_BRANCH}"

if [[ "${IMAGE_BRANCH_NORMALIZED}" == "main" ]]; then
    IMAGE_BRANCH_NORMALIZED="stable"
fi

FEDORA_VERSION=$(rpm -E %fedora)

# Write the image metadata JSON file with all build-time variables.
cat > "${IMAGE_INFO}" <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "${IMAGE_REF}",
  "image-tag": "stable",
  "image-branch": "${IMAGE_BRANCH_NORMALIZED}",
  "base-image-name": "${BASE_IMAGE_NAME}",
  "fedora-version": "${FEDORA_VERSION}",
  "version": "${VERSION_TAG}",
  "version-pretty": "${VERSION_PRETTY}"
}
EOF

# Source the base `os-release` file, so we can fill in some fields that
# can carry over to the new `os-release` file.
# shellcheck disable=SC1091
source /usr/lib/os-release

# Rewrite os-release fields to reflect the Bazzite branding and identity.
tee /usr/lib/os-release <<EOF
NAME="${IMAGE_PRETTY_NAME}"
VERSION="${VERSION_TAG} (${BASE_IMAGE_NAME^})"
RELEASE_TYPE=${RELEASE_TYPE}
ID=${IMAGE_PRETTY_NAME,}
ID_LIKE="${IMAGE_LIKE}"
VERSION_ID=${VERSION_ID}
VERSION_CODENAME="${BASE_IMAGE_NAME^}"
PRETTY_NAME="${IMAGE_PRETTY_NAME}"
ANSI_COLOR="0;38;2;138;43;226"
LOGO=bazzite-logo
CPE_NAME="cpe:/o:universal-blue:${IMAGE_PRETTY_NAME,}:${FEDORA_VERSION}"
DEFAULT_HOSTNAME="${IMAGE_PRETTY_NAME,}"
HOME_URL="https://bazzite.gg"
DOCUMENTATION_URL="https://docs.bazzite.gg"
SUPPORT_URL="https://discord.bazzite.gg"
BUG_REPORT_URL="https://github.com/ublue-os/bazzite/issues/"
SUPPORT_END=${SUPPORT_END}
VARIANT="${VARIANT}"
VARIANT_ID=${IMAGE_NAME}
OSTREE_VERSION='${VERSION_TAG}'
BUILD_ID="${VERSION_PRETTY}"
BOOTLOADER_NAME="${IMAGE_PRETTY_NAME} ${VERSION_PRETTY}"
IMAGE_ID="${IMAGE_NAME}-${VERSION_TAG}"
EOF

# Ensure grub2-mkconfig uses "Bazzite" as the distributor name.
echo "${IMAGE_PRETTY_NAME} release ${FEDORA_VERSION} (${BASE_IMAGE_NAME^})" > /etc/system-release

# Correct the EFIDIR path since ID is no longer fedora.
sed -i \
  "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" \
  /usr/sbin/grub2-switch-to-blscfg
