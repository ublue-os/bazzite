# vim: set ft=make :
# Update the Apple Silicon bootloader chain (m1n1, U-Boot) safely
# NOTE: Do NOT rely on rpm-ostree upgrade for these -- run this recipe manually.

# See https://github.com/fedora-asahi-remix-atomic-desktops/images/issues/2
[group("arm")]
update-asahi-bootloader:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    echo "=== Asahi Bootloader Update ==="
    echo ""
    echo "This updates m1n1 and U-Boot in the Apple Silicon boot chain."
    echo "WARNING: Only run this when you know a bootloader update is safe."
    echo "See: https://github.com/fedora-asahi-remix-atomic-desktops/images/issues/2"
    echo ""
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi
    if command -v update-m1n1 &>/dev/null; then
        echo "Running update-m1n1..."
        sudo update-m1n1
        echo "Bootloader update complete."
    else
        echo "update-m1n1 not found. Is asahi-scripts installed?"
        exit 1
    fi

# Check x86/x86_64 emulation status on ARM64
[group("arm")]
check-x86-emulation:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (ARM64) systems."
        exit 0
    fi
    /usr/lib/bazzite/scripts/check-x86-emulation.sh

# Update all x86 emulation packages to latest versions
[group("arm")]
update-x86-emulation:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (ARM64) systems."
        exit 0
    fi
    echo "Updating x86 emulation packages..."
    /usr/libexec/bazzite-arm-runtime-dnf update \
        fex-emu \
        fex-emu-rootfs-fedora \
        mesa-fex-emu-overlay-i386 \
        mesa-fex-emu-overlay-x86_64 \
        box64 \
        muvm \
        libkrun \
        libkrunfw \
        steam
    command -v FEXInterpreter >/dev/null 2>&1
    command -v box64 >/dev/null 2>&1
    command -v muvm >/dev/null 2>&1
    rpm -q qemu-user-static qemu-user-binfmt steam >/dev/null 2>&1
    echo ""
    echo "Update complete."
    /usr/lib/bazzite/scripts/check-x86-emulation.sh

# Launch Steam through FEX-Emu emulation layer
[group("arm")]
run-steam:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "On x86_64 systems, launch Steam normally from your application menu."
        exit 0
    fi
    if command -v steam &>/dev/null; then
        steam
    elif rpm -q steam &>/dev/null; then
        /usr/bin/steam
    else
        echo "Steam is not installed."
        echo "Run: ujust install-steam-arm"
        exit 1
    fi

# Install Steam if it was not included in the image
[group("arm")]
install-steam-arm:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "On x86_64, use the standard Steam installation."
        exit 1
    fi

    if rpm -q steam &>/dev/null; then
        echo "Steam is already installed via RPM (Asahi package)."
        exit 0
    fi

    echo "Installing Steam from Asahi COPR..."
    /usr/libexec/bazzite-arm-runtime-dnf install steam
    rpm -q steam >/dev/null 2>&1
    echo ""
    echo "Steam installed. Launch from your application menu or run: ujust run-steam"

# Test x86 emulation by verifying the installed components
[group("arm")]
test-x86-emulation:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (ARM64) systems."
        exit 0
    fi

    PASS=0
    FAIL=0

    echo "=== x86/x86_64 Emulation Test ==="
    echo ""

    # Test FEX-Emu
    if command -v FEXInterpreter &>/dev/null; then
        echo "[PASS] FEX-Emu is installed"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] FEX-Emu is not installed"
        FAIL=$((FAIL + 1))
    fi

    # Test FEX rootfs
    if [[ -d /usr/share/fex-emu/RootFS ]] || [[ -d /usr/share/fex-emu-rootfs ]]; then
        echo "[PASS] FEX-Emu x86_64 RootFS is present"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] FEX-Emu x86_64 RootFS is missing"
        FAIL=$((FAIL + 1))
    fi

    # Test Mesa overlay
    if ls /usr/lib/fex-emu-overlay* &>/dev/null 2>&1; then
        echo "[PASS] Mesa FEX overlay is present (GPU acceleration)"
        PASS=$((PASS + 1))
    else
        echo "[WARN] Mesa FEX overlay not found (GPU acceleration may be limited)"
    fi

    # Test Box64
    if command -v box64 &>/dev/null; then
        echo "[PASS] Box64 is installed"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] Box64 is not installed"
        FAIL=$((FAIL + 1))
    fi

    # Test muvm
    if command -v muvm &>/dev/null; then
        echo "[PASS] muvm (microVM) is installed"
        PASS=$((PASS + 1))
    else
        echo "[WARN] muvm not installed (some GPU workloads may be slower)"
    fi

    # Test binfmt
    if [[ -d /proc/sys/fs/binfmt_misc ]]; then
        echo "[PASS] binfmt_misc is mounted"
        PASS=$((PASS + 1))
    else
        echo "[WARN] binfmt_misc not mounted (transparent execution unavailable)"
    fi

    # Test qemu static interpreters used as the fallback x86 path
    if command -v qemu-i386-static &>/dev/null || [[ -x /usr/sbin/qemu-i386-static ]]; then
        echo "[PASS] qemu-i386-static is installed"
        PASS=$((PASS + 1))
    else
        echo "[WARN] qemu-i386-static not installed (32-bit fallback may be unavailable)"
    fi

    if command -v qemu-x86_64-static &>/dev/null || [[ -x /usr/sbin/qemu-x86_64-static ]]; then
        echo "[PASS] qemu-x86_64-static is installed"
        PASS=$((PASS + 1))
    else
        echo "[WARN] qemu-x86_64-static not installed (x86_64 fallback may be unavailable)"
    fi

    # Test Steam
    if rpm -q steam &>/dev/null; then
        echo "[PASS] Steam is installed"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] Steam is not installed"
        FAIL=$((FAIL + 1))
    fi

    echo ""
    echo "Results: $PASS passed, $FAIL failed"
    if [[ $FAIL -eq 0 ]]; then
        echo "All critical components are installed. Ready for gaming!"
    else
        echo "Some components are missing. Run: ujust update-x86-emulation"
    fi
