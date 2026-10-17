#!/usr/bin/env bash
#
# Install Terra's Steam Deck-patched UPower and lock its version.
#
# Replaces the default upower with Terra's patched version and
# versionlocks both terra-upower and terra-upower-libs.
#
set -xeuo pipefail

echo "::group::Install patched UPower"
trap 'echo "::endgroup::"' EXIT

# -- Swap to Steam Deck-patched UPower --
# Replace the default upower with the patched version from Terra extras.
echo "==> Installing Steam Deck-patched UPower..."
dnf5 -y swap --allowerasing \
    --repo terra-extras \
    upower terra-upower

# -- Versionlock UPower packages --
# Lock the patched UPower packages.
echo "==> Versionlocking UPower packages..."
dnf5 versionlock add \
    terra-upower \
    terra-upower-libs
