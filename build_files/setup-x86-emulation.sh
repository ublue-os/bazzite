#!/usr/bin/bash
#
# Set up x86/x86_64 emulation and gaming stack on aarch64.
#
# On Fedora Asahi Remix, the full emulation stack is available from
# standard Fedora repos and the Asahi Steam COPR (pre-configured in
# the base image):
#   - fex-emu: Fast x86/x86_64 JIT emulator with rootfs and Mesa overlays
#   - box64: x86_64 userspace emulator
#   - muvm/libkrun: MicroVM for near-native GPU-accelerated x86 workloads
#   - steam: Asahi's Steam package with FEX integration

set -eoux pipefail

# FEX-Emu: primary emulation layer
# Pulls in fex-emu-rootfs-fedora (x86_64 sysroot) and
# mesa-fex-emu-overlay (GPU acceleration through emulation)
dnf5 -y install \
    fex-emu

# Box64: secondary x86_64 emulator for additional compatibility
dnf5 -y install --skip-broken --skip-unavailable \
    box64

# muvm/libkrun: microVM-based emulation for GPU-intensive workloads
# These allow running x86 apps with near-native Apple GPU access
dnf5 -y install --skip-broken --skip-unavailable \
    muvm \
    libkrun \
    libkrunfw

# qemu-user-static: fallback emulation via binary translation
dnf5 -y install --skip-broken --skip-unavailable \
    qemu-user-static \
    qemu-user-binfmt

# Steam: Asahi's package handles FEX integration automatically
# The @asahi steam COPR is already configured in the base image
dnf5 -y install --skip-broken --skip-unavailable \
    steam

# Create emulation status check script
mkdir -p /usr/lib/bazzite/scripts
cat > /usr/lib/bazzite/scripts/check-x86-emulation.sh << 'CHECK_EOF'
#!/usr/bin/bash
echo "=== x86/x86_64 Emulation Status ==="

echo ""
echo "--- FEX-Emu ---"
if command -v FEXInterpreter &>/dev/null; then
    echo "  Installed"
    FEXInterpreter --version 2>&1 | sed 's/^/  /' || true
    if [[ -d /usr/share/fex-emu/RootFS ]]; then
        echo "  x86_64 RootFS: present"
    fi
    if [[ -d /usr/lib/fex-emu-overlay ]]; then
        echo "  Mesa overlay: present (GPU acceleration enabled)"
    fi
else
    echo "  Not installed"
fi

echo ""
echo "--- Box64 ---"
if command -v box64 &>/dev/null; then
    echo "  Installed ($(box64 --version 2>&1 | head -1))"
else
    echo "  Not installed"
fi

echo ""
echo "--- muvm (microVM GPU emulation) ---"
if command -v muvm &>/dev/null; then
    echo "  Installed"
else
    echo "  Not installed"
fi

echo ""
echo "--- Steam ---"
if command -v steam &>/dev/null || rpm -q steam &>/dev/null; then
    echo "  Installed ($(rpm -q steam 2>/dev/null || echo 'via flatpak'))"
else
    echo "  Not installed"
fi

echo ""
echo "--- binfmt_misc ---"
if [[ -d /proc/sys/fs/binfmt_misc ]]; then
    echo "  Mounted"
    for f in /proc/sys/fs/binfmt_misc/*; do
        name=$(basename "$f")
        [[ "$name" == "status" || "$name" == "register" ]] && continue
        if echo "$name" | grep -qiE "x86|i[3-6]86|fex"; then
            echo "    $name: $(head -1 "$f")"
        fi
    done
else
    echo "  Not mounted (will be available at runtime)"
fi

echo ""
echo "--- qemu-user-static ---"
if command -v qemu-x86_64-static &>/dev/null; then
    echo "  qemu-x86_64-static: installed"
else
    echo "  qemu-x86_64-static: not installed"
fi
CHECK_EOF
chmod +x /usr/lib/bazzite/scripts/check-x86-emulation.sh

/ctx/cleanup
