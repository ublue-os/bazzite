#!/usr/bin/bash
#
# Set up x86/x86_64 emulation on aarch64 via FEX-Emu and Box64/Box86.
# FEX-Emu is the primary emulator (faster, better syscall translation).
# Box64/Box86 are installed as secondary options for compatibility.

set -eoux pipefail

ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]] && [[ "${TARGETARCH:-}" != "arm64" ]]; then
    echo "x86 emulation setup is only needed on aarch64, skipping on $ARCH"
    exit 0
fi

FEDORA_VERSION=$(rpm -E %fedora)

# --- FEX-Emu ---
# FEX-Emu provides fast x86/x86_64 emulation with JIT recompilation.
# It integrates with binfmt_misc for transparent execution of x86 binaries.

if dnf5 -y copr enable fex-emu/fex 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        fex-emu
else
    echo "FEX-Emu COPR not available for aarch64/F${FEDORA_VERSION}, skipping"
fi

# --- Box64 (x86_64 emulation) ---
if dnf5 -y copr enable ptitSeb/box64 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        box64
else
    echo "Box64 COPR not available, skipping"
fi

# --- Box86 (x86 32-bit emulation) ---
if dnf5 -y copr enable ptitSeb/box86 2>/dev/null; then
    dnf5 -y install --skip-broken --skip-unavailable \
        box86
else
    echo "Box86 COPR not available, skipping"
fi

# Ensure binfmt_misc support is available for transparent x86 execution
dnf5 -y install --skip-broken --skip-unavailable \
    qemu-user-static \
    qemu-user-binfmt || true

# Create emulation status check script
mkdir -p /usr/lib/bazzite/scripts
cat > /usr/lib/bazzite/scripts/check-x86-emulation.sh << 'CHECK_EOF'
#!/usr/bin/bash
echo "=== x86/x86_64 Emulation Status ==="

echo ""
echo "--- FEX-Emu ---"
if command -v FEXInterpreter &>/dev/null; then
    echo "FEX-Emu: installed ($(FEXInterpreter --version 2>&1 | head -1))"
else
    echo "FEX-Emu: not installed"
fi

echo ""
echo "--- Box64 ---"
if command -v box64 &>/dev/null; then
    echo "Box64: installed ($(box64 --version 2>&1 | head -1))"
else
    echo "Box64: not installed"
fi

echo ""
echo "--- Box86 ---"
if command -v box86 &>/dev/null; then
    echo "Box86: installed ($(box86 --version 2>&1 | head -1))"
else
    echo "Box86: not installed"
fi

echo ""
echo "--- binfmt_misc ---"
if [[ -d /proc/sys/fs/binfmt_misc ]]; then
    echo "binfmt_misc: mounted"
    for f in /proc/sys/fs/binfmt_misc/*; do
        name=$(basename "$f")
        if [[ "$name" == "status" || "$name" == "register" ]]; then
            continue
        fi
        if echo "$name" | grep -qiE "x86|i[3-6]86|fex"; then
            echo "  $name: $(head -1 "$f")"
        fi
    done
else
    echo "binfmt_misc: not mounted (will be available at runtime)"
fi

echo ""
echo "--- qemu-user-static ---"
if command -v qemu-x86_64-static &>/dev/null; then
    echo "qemu-x86_64-static: installed"
else
    echo "qemu-x86_64-static: not installed"
fi
if command -v qemu-i386-static &>/dev/null; then
    echo "qemu-i386-static: installed"
else
    echo "qemu-i386-static: not installed"
fi
CHECK_EOF
chmod +x /usr/lib/bazzite/scripts/check-x86-emulation.sh

# Create helper script for installing Steam via x86 emulation
cat > /usr/lib/bazzite/scripts/setup-steam-arm.sh << 'STEAM_EOF'
#!/usr/bin/bash
set -euo pipefail

echo "=== Steam Setup for ARM64 ==="
echo ""
echo "Steam on ARM64 requires x86_64 emulation."
echo "This script sets up Steam using Flatpak + emulation layer."
echo ""

if ! command -v flatpak &>/dev/null; then
    echo "Error: flatpak is not installed."
    exit 1
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installing Steam Flatpak..."
echo "Note: Steam on ARM64 is experimental. Game compatibility varies."
flatpak install -y flathub com.valvesoftware.Steam

echo ""
echo "Steam installed. Launch it from your application menu."
echo "x86_64 game binaries will be translated through the emulation layer."
STEAM_EOF
chmod +x /usr/lib/bazzite/scripts/setup-steam-arm.sh

/ctx/cleanup
