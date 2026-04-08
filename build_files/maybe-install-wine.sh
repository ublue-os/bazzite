#!/usr/bin/bash
set -euo pipefail

echo "SKIP_WINE=${SKIP_WINE:-0}"

if [[ "${SKIP_WINE:-0}" == "1" ]]; then
    echo "Skipping native Wine build (--skip-wine flag set)."
    echo "x86 Wine will still be available via FEX-Emu/Box64 emulation."
    exit 0
fi

echo "Building native Wine for aarch64..."
exec bash /ctx/install-native-wine-aarch64.sh
