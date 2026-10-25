#!/usr/bin/env bash
#
# Root orchestration script for building Bazzite.
#
set -xeuo pipefail

echo "Build deck   = ${BUILD_DECK}"
echo "Build nvidia = ${BUILD_NVIDIA}"
echo ""

# Desktop/Core builds
/ctx/bazzite/build.sh

# Deck builds
if [[ "${BUILD_DECK}" == "TRUE" ]]; then
    /ctx/bazzite-deck/build.sh
fi

# Nvidia builds
if [[ "${BUILD_NVIDIA}" == "TRUE" ]]; then
    /ctx/bazzite-nvidia/build.sh
fi

# Finalize
/ctx/reset-mtimes.sh
