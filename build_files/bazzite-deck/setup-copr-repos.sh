#!/usr/bin/env bash
#
# Enable and configure COPR repositories for Bazzite Deck.
#
# Enables upstream COPR repos (ublue-os, audinux), activates the akmods
# repo, disables skip-if-unavailable in dnf5, and runs cleanup.
#
set -xeuo pipefail

echo "::group::Setup Copr repos (Deck)"
trap 'echo "::endgroup::"' EXIT

# -- Enable akmods COPR repo --
# The akmods repo is disabled by default.
echo "==> Enabling akmods COPR repo..."
dnf5 config-manager enable copr:copr.fedorainfracloud.org:ublue-os:akmods

# -- Enable Ublue and Bazzite COPR repos --
# Install the core set of COPR repositories required for Bazzite.
echo "==> Enabling Ublue and Bazzite COPR repos..."
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/bazzite
dnf5 -y copr enable ublue-os/bazzite-multilib
dnf5 -y copr enable ycollet/audinux

# -- Configure dnf5 availability handling --
# Allow dnf5 to proceed even if a repo is temporarily unavailable.
echo "==> Configuring dnf5 availability handling..."
dnf5 config-manager unsetopt skip_if_unavailable
