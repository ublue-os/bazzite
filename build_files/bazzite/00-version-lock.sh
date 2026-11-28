#!/usr/bin/env bash
#
# Version Lock
#
# Ensure package updates don't break the image
#
set -xeuo pipefail

echo "::group::Version Lock"
trap 'echo "::endgroup::"' EXIT

# -- Versionlock KDE packages for Kinoite --
# On Kinoite images, lock qt6 and plasma packages to prevent unwanted updates.
echo "==> Checking for Kinoite image..."
if [[ "${BASE_IMAGE_NAME}" == "kinoite" ]]; then
    echo "    Detected Kinoite, versionlocking qt6 and plasma packages..."
    dnf versionlock add "qt6-*"
    dnf versionlock add "plasma-*"
fi

# Global version locks
dnf versionlock add "zstd"
dnf versionlock add "libzstd"
