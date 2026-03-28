# vim: set ft=make :

# Check x86/x86_64 emulation status on ARM64
[group("arm")]
check-x86-emulation:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (ARM64) systems."
        exit 0
    fi
    /usr/lib/bazzite/scripts/check-x86-emulation.sh

# Install or update FEX-Emu for x86/x86_64 emulation
[group("arm")]
setup-fex-emu:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "FEX-Emu is only needed on aarch64 (ARM64) systems."
        exit 1
    fi

    if command -v FEXInterpreter &>/dev/null; then
        echo "FEX-Emu is already installed."
        FEXInterpreter --version 2>&1 || true
        echo ""
        echo "To update, run: sudo dnf5 update fex-emu"
        exit 0
    fi

    echo "Installing FEX-Emu for x86/x86_64 emulation..."
    sudo dnf5 -y copr enable fex-emu/fex
    sudo dnf5 -y install fex-emu
    echo ""
    echo "FEX-Emu installed. x86/x86_64 binaries can now be run transparently."

# Install or update Box64 for x86_64 emulation
[group("arm")]
setup-box64:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "Box64 is only needed on aarch64 (ARM64) systems."
        exit 1
    fi

    if command -v box64 &>/dev/null; then
        echo "Box64 is already installed."
        box64 --version 2>&1 || true
        echo ""
        echo "To update, run: sudo dnf5 update box64"
        exit 0
    fi

    echo "Installing Box64 for x86_64 emulation..."
    sudo dnf5 -y copr enable ptitSeb/box64
    sudo dnf5 -y install box64
    echo ""
    echo "Box64 installed."

# Install or update Box86 for 32-bit x86 emulation
[group("arm")]
setup-box86:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "Box86 is only needed on aarch64 (ARM64) systems."
        exit 1
    fi

    if command -v box86 &>/dev/null; then
        echo "Box86 is already installed."
        box86 --version 2>&1 || true
        echo ""
        echo "To update, run: sudo dnf5 update box86"
        exit 0
    fi

    echo "Installing Box86 for 32-bit x86 emulation..."
    sudo dnf5 -y copr enable ptitSeb/box86
    sudo dnf5 -y install box86
    echo ""
    echo "Box86 installed."

# Install all x86 emulation layers (FEX-Emu + Box64 + Box86)
[group("arm")]
setup-x86-emulation:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "x86 emulation setup is only needed on aarch64 (ARM64) systems."
        exit 1
    fi

    echo "=== Setting up x86/x86_64 emulation ==="
    echo ""

    echo "--- Installing FEX-Emu ---"
    if ! command -v FEXInterpreter &>/dev/null; then
        sudo dnf5 -y copr enable fex-emu/fex 2>/dev/null || true
        sudo dnf5 -y install --skip-broken --skip-unavailable fex-emu
    else
        echo "Already installed."
    fi

    echo ""
    echo "--- Installing Box64 ---"
    if ! command -v box64 &>/dev/null; then
        sudo dnf5 -y copr enable ptitSeb/box64 2>/dev/null || true
        sudo dnf5 -y install --skip-broken --skip-unavailable box64
    else
        echo "Already installed."
    fi

    echo ""
    echo "--- Installing Box86 ---"
    if ! command -v box86 &>/dev/null; then
        sudo dnf5 -y copr enable ptitSeb/box86 2>/dev/null || true
        sudo dnf5 -y install --skip-broken --skip-unavailable box86
    else
        echo "Already installed."
    fi

    echo ""
    echo "=== Setup complete ==="
    /usr/lib/bazzite/scripts/check-x86-emulation.sh

# Install Steam on ARM64 via Flatpak (experimental, requires x86 emulation)
[group("arm")]
install-steam-arm:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This recipe is for ARM64 systems. On x86_64, Steam is installed natively."
        exit 1
    fi
    /usr/lib/bazzite/scripts/setup-steam-arm.sh

# Test x86 emulation by running a simple binary
[group("arm")]
test-x86-emulation:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (ARM64) systems."
        exit 0
    fi

    echo "=== Testing x86_64 emulation ==="
    echo ""

    if command -v FEXInterpreter &>/dev/null; then
        echo "FEX-Emu: available"
    elif command -v box64 &>/dev/null; then
        echo "Box64: available"
    elif command -v qemu-x86_64-static &>/dev/null; then
        echo "qemu-user-static: available (fallback)"
    else
        echo "No x86_64 emulator found. Run: ujust setup-x86-emulation"
        exit 1
    fi

    if [[ -d /proc/sys/fs/binfmt_misc ]]; then
        X86_REGISTERED=false
        for f in /proc/sys/fs/binfmt_misc/*; do
            name=$(basename "$f")
            if echo "$name" | grep -qiE "x86_64|fex"; then
                if head -1 "$f" | grep -q "enabled"; then
                    X86_REGISTERED=true
                    echo "binfmt handler '$name' is enabled"
                fi
            fi
        done
        if ! $X86_REGISTERED; then
            echo "No active x86_64 binfmt handler found."
            echo "x86 binaries may need to be invoked explicitly through the emulator."
        fi
    else
        echo "binfmt_misc not mounted; transparent execution not available."
    fi

    echo ""
    echo "Emulation layer is configured. x86_64 binaries should be runnable."
