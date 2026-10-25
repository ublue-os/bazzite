#!/usr/bin/env bash
#
# Install Gamescope Session supporting files for Bazzite.
#
# Downloads the Steam bootstrap archive used by gamescope-session-plus
# and sets component metadata attributes for tracking.
#
set -xeuo pipefail

echo "::group::Install gamescope session"
trap 'echo "::endgroup::"' EXIT

# -- Create gamescope-session-plus directory --
# Ensure the target directory exists before downloading files.
echo "==> Creating gamescope-session-plus directory..."
mkdir -p /usr/share/gamescope-session-plus/

# -- Download Steam bootstrap archive --
# Fetch the Steam bootstrap tarball used by gamescope-session-plus.
STEAM_BOOTSTRAP_URL=https://large-package-sources.nobaraproject.org/bootstrap_steam.tar.gz
STEAM_BOOTSTRAP_SHA256=5bb64e2ed0f488b7c507f1207974c0c77a2f27ab3fa6bfb505d1176144b18ce1
STEAM_BOOTSTRAP=/usr/share/gamescope-session-plus/bootstrap_steam.tar.gz
echo "==> Downloading Steam bootstrap archive..."
curl --fail --location --retry 5 --retry-all-errors --continue-at - \
    --output "${STEAM_BOOTSTRAP}" "${STEAM_BOOTSTRAP_URL}"
echo "${STEAM_BOOTSTRAP_SHA256}  ${STEAM_BOOTSTRAP}" | sha256sum --check

# -- Set component metadata attributes --
# Tag the bootstrap archive with component and update-interval for tracking.
echo "==> Setting component metadata attributes..."
setfattr \
    -n user.component \
    -v "steam-bootstrap" \
    "${STEAM_BOOTSTRAP}"

setfattr \
    -n user.update-interval \
    -v "yearly" \
    "${STEAM_BOOTSTRAP}"
