#!/usr/bin/env bash
#
# Install Gamescope Session supporting files for Bazzite.
#
# Installs the Steam bootstrap archive used by gamescope-session-plus
# and sets component metadata attributes for tracking.
#
set -xeuo pipefail

echo "::group::Install gamescope session"
trap 'echo "::endgroup::"' EXIT

# -- Create gamescope-session-plus directory --
# Ensure the target directory exists before writing files.
echo "==> Creating gamescope-session-plus directory..."
mkdir -p /usr/share/gamescope-session-plus/

# -- Install Steam bootstrap archive --
# Use the archive published by the steam_bootstrap workflow, or build one
# from Valve's current manifest when it wasn't downloaded.
STEAM_BOOTSTRAP=/usr/share/gamescope-session-plus/bootstrap_steam.tar.zst
if [[ -f /tmp/steam-bootstrap/bootstrap_steam.tar.zst ]]; then
    echo "==> Installing Steam bootstrap archive..."
    cp /tmp/steam-bootstrap/bootstrap_steam.tar.zst "${STEAM_BOOTSTRAP}"
else
    echo "==> Building Steam bootstrap archive..."
    curl --fail --location --silent --show-error --retry 5 --retry-all-errors \
        --output /tmp/steam_client_steamrt64.manifest \
        https://client-update.steamstatic.com/steam_client_steamdeck_stable_steamrt64
    /ctx/tools/steam-bootstrap /tmp/steam_client_steamrt64.manifest "${STEAM_BOOTSTRAP}"
fi

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
