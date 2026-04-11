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

DNF5_STRICT_REPO_ARGS=(
    "--setopt=*.skip_if_unavailable=0"
    "--setopt=*.timeout=30"
    "--setopt=*.minrate=1000"
    "--setopt=*.retries=10"
)

refresh_dnf_metadata() {
    dnf5 clean all >/dev/null 2>&1 || true
    rm -rf /var/cache/libdnf5/* /var/cache/dnf/* 2>/dev/null || true
}

install_required_packages() {
    local description="$1"
    shift

    if dnf5 -y install "${DNF5_STRICT_REPO_ARGS[@]}" "$@"; then
        return 0
    fi

    echo "${description} install failed; cleaning metadata and retrying once." >&2
    refresh_dnf_metadata
    dnf5 -y install "${DNF5_STRICT_REPO_ARGS[@]}" "$@"
}

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required command is missing after emulation setup: ${command_name}" >&2
        exit 1
    fi
}

require_package() {
    local package_name="$1"

    if ! rpm -q "${package_name}" >/dev/null 2>&1; then
        echo "Required package is missing after emulation setup: ${package_name}" >&2
        exit 1
    fi
}

# FEX-Emu: primary emulation layer
# Pulls in fex-emu-rootfs-fedora (x86_64 sysroot) and
# mesa-fex-emu-overlay (GPU acceleration through emulation)
install_required_packages "FEX emulation stack" \
    fex-emu

# Box64: secondary x86_64 emulator for additional compatibility
install_required_packages "Box64 emulation stack" \
    box64

# muvm/libkrun: microVM-based emulation for GPU-intensive workloads
# These allow running x86 apps with near-native Apple GPU access
install_required_packages "microVM emulation stack" \
    muvm \
    libkrun \
    libkrunfw

# qemu-user-static: fallback emulation via binary translation
# Pulls in the architecture-specific static interpreters, including x86.
install_required_packages "qemu user emulation stack" \
    qemu-user-static \
    qemu-user-binfmt

# Steam: Asahi's package handles FEX integration automatically
# The @asahi steam COPR is already configured in the base image
install_required_packages "Steam on ARM" \
    steam

require_command FEXInterpreter
require_command box64
require_command muvm
require_package qemu-user-static
require_package qemu-user-binfmt
require_package steam

# Create emulation status check script
mkdir -p /usr/lib/bazzite/scripts
cat > /usr/lib/bazzite/scripts/check-x86-emulation.sh << 'CHECK_EOF'
#!/usr/bin/bash
echo "=== x86/x86_64 Emulation Status ==="

echo ""
echo "--- FEX-Emu ---"
if command -v FEXInterpreter &>/dev/null; then
    echo "  Installed"
    fex_version="$(rpm -q --qf '%{VERSION}-%{RELEASE}' fex-emu 2>/dev/null || true)"
    if [[ -n "${fex_version}" ]]; then
        echo "  Version: ${fex_version}"
    fi
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
if command -v qemu-i386-static &>/dev/null || [[ -x /usr/sbin/qemu-i386-static ]]; then
    echo "  qemu-i386-static: installed"
else
    echo "  qemu-i386-static: not installed"
fi
if command -v qemu-x86_64-static &>/dev/null || [[ -x /usr/sbin/qemu-x86_64-static ]]; then
    echo "  qemu-x86_64-static: installed"
else
    echo "  qemu-x86_64-static: not installed"
fi
CHECK_EOF
chmod +x /usr/lib/bazzite/scripts/check-x86-emulation.sh

/ctx/cleanup
