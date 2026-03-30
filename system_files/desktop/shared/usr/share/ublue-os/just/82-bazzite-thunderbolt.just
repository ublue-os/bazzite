# vim: set ft=make :

# Show current kernel variant (stable or fairydust)
[group("arm")]
kernel-variant:
    #!/usr/bin/bash
    variant=$(cat /usr/share/ublue-os/kernel-variant 2>/dev/null || echo "stable")
    kernel=$(uname -r)
    echo "Kernel variant : $variant"
    echo "Running kernel : $kernel"
    echo ""
    if [[ "$variant" == "fairydust" ]]; then
        echo "Fairydust features: Thunderbolt, USB4, DisplayPort Alt Mode"
        echo "See: https://github.com/AsahiLinux/linux/tree/fairydust"
    else
        echo "Run 'ujust install-fairydust-kernel' to switch to the experimental kernel."
    fi

# Show Thunderbolt/USB4 device status
[group("arm")]
thunderbolt-status:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 0
    fi
    echo "=== Thunderbolt / USB4 Status ==="
    echo ""
    echo "--- bolt daemon ---"
    systemctl is-active bolt.service 2>/dev/null || echo "bolt.service not running"
    echo ""
    echo "--- Thunderbolt devices ---"
    if command -v boltctl &>/dev/null; then
        boltctl list 2>/dev/null || echo "No Thunderbolt devices detected"
    else
        echo "boltctl not available"
    fi
    echo ""
    echo "--- USB4 controllers ---"
    lspci 2>/dev/null | grep -iE "thunderbolt|usb4" || echo "No Thunderbolt/USB4 PCI devices found"
    echo ""
    echo "--- USB devices ---"
    lsusb 2>/dev/null | head -20

# Authorize all connected Thunderbolt devices
[group("arm")]
thunderbolt-authorize-all:
    #!/usr/bin/bash
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 0
    fi
    if ! command -v boltctl &>/dev/null; then
        echo "boltctl not found. Is bolt installed?"
        exit 1
    fi
    echo "Authorizing all pending Thunderbolt devices..."
    boltctl enroll --policy auto 2>/dev/null || true
    boltctl list 2>/dev/null

# Install the fairydust experimental kernel (Thunderbolt, USB4, DisplayPort)
# WARNING: This builds the kernel from source which takes 30-60 minutes.

# The fairydust branch is NOT production-ready. Use at your own risk.
[group("arm")]
install-fairydust-kernel:
    #!/usr/bin/bash
    set -eo pipefail
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi

    echo "=== Fairydust Kernel Installation ==="
    echo ""
    echo "  Branch: https://github.com/AsahiLinux/linux/tree/fairydust"
    echo "  Features: Thunderbolt, USB4, DisplayPort Alt Mode over USB-C"
    echo ""
    echo "  WARNING: This is an EXPERIMENTAL development kernel."
    echo "  WARNING: It may cause instability or data loss."
    echo "  WARNING: Build takes 30-60 minutes."
    echo ""
    read -rp "Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Aborted."
        exit 0
    fi

    echo "--- Checking build dependencies ---"
    # On the fairydust image variant, all build deps are pre-installed.
    # On the stable variant, install them now via rpm-ostree.
    VARIANT=$(cat /usr/share/ublue-os/kernel-variant 2>/dev/null || echo "stable")
    if [[ "$VARIANT" != "fairydust" ]]; then
        echo "Note: installing build deps on stable variant (fairydust has them pre-installed)"
        sudo rpm-ostree install --apply-live \
            gcc gcc-c++ make bc bison flex git \
            openssl-devel dwarves elfutils-libelf-devel \
            perl perl-Carp rpm-build ncurses-devel python3 \
            rsync cpio binutils openssl diffutils \
            hostname kmod dracut grubby 2>&1 || \
        echo "rpm-ostree install failed -- trying dnf5 (may need reboot after)"
    fi

    # Verify make is available before proceeding
    if ! command -v make &>/dev/null; then
        echo "ERROR: 'make' not found. Please run from the fairydust image variant or"
        echo "run: sudo rpm-ostree install make gcc && reboot"
        exit 1
    fi

    WORK_DIR=$(mktemp -d /var/tmp/fairydust-XXXXX)
    echo "--- Cloning fairydust branch to $WORK_DIR ---"
    echo "(Shallow clone, ~500MB)"
    git clone --depth=1 --branch=fairydust \
        https://github.com/AsahiLinux/linux.git \
        "$WORK_DIR/linux"

    cd "$WORK_DIR/linux"

    echo "--- Configuring kernel (using running config as base) ---"
    if cp "/boot/config-$(uname -r)" .config 2>/dev/null; then
        echo "Using running kernel config as base: /boot/config-$(uname -r)"
    else
        echo "Running kernel config not found -- using asahi ARM64 defconfig"
        make ARCH=arm64 defconfig
    fi
    # Enable Thunderbolt/USB4 -- these are the key symbols for dock + display support
    scripts/config --enable CONFIG_USB4
    scripts/config --enable CONFIG_USB4_NET
    scripts/config --enable CONFIG_THUNDERBOLT
    scripts/config --enable CONFIG_THUNDERBOLT_NET
    scripts/config --enable CONFIG_USB_TYPEC_ALTMODE
    scripts/config --enable CONFIG_USB_TYPEC_DP_ALTMODE
    # Use olddefconfig: sets ALL new symbols to their defaults silently.
    # Do NOT use "yes | make oldconfig" -- yes generates infinite output,
    # gets SIGPIPE when make closes stdin, exits 141, and kills the recipe.
    make ARCH=arm64 olddefconfig

    echo "--- Building kernel (this takes 30-60 minutes) ---"
    NCPU=$(nproc)
    make ARCH=arm64 -j"${NCPU}" Image modules

    echo "--- Installing kernel ---"
    sudo make ARCH=arm64 modules_install
    sudo install -m 644 arch/arm64/boot/Image \
        "/boot/vmlinuz-fairydust-$(make -s kernelrelease)"
    sudo dracut --force \
        "/boot/initramfs-fairydust-$(make -s kernelrelease).img" \
        "$(make -s kernelrelease)"

    echo "--- Updating GRUB ---"
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg

    echo ""
    echo "=== Installation complete ==="
    echo "Fairydust kernel installed: $(make -s kernelrelease)"
    echo "Reboot and select it from the GRUB menu to test."
    echo ""
    echo "After verifying it works, run: ujust set-fairydust-default"
    echo ""

    rm -rf "$WORK_DIR"

# Set the fairydust kernel as the default boot entry
[group("arm")]
set-fairydust-default:
    #!/usr/bin/bash
    FAIRYDUST=$(ls /boot/vmlinuz-fairydust-* 2>/dev/null | head -1)
    if [[ -z "$FAIRYDUST" ]]; then
        echo "No fairydust kernel found. Run: ujust install-fairydust-kernel"
        exit 1
    fi
    VERSION=$(echo "$FAIRYDUST" | sed 's|/boot/vmlinuz-fairydust-||')
    echo "Setting fairydust kernel $VERSION as default..."
    sudo grubby --set-default="/boot/vmlinuz-fairydust-$VERSION"
    echo "Done. Reboot to use the fairydust kernel."

# Revert to the stable Asahi kernel as default
[group("arm")]
set-stable-kernel-default:
    #!/usr/bin/bash
    STABLE=$(ls /boot/vmlinuz-*asahi* 2>/dev/null | grep -v fairydust | head -1)
    if [[ -z "$STABLE" ]]; then
        echo "No stable Asahi kernel found."
        exit 1
    fi
    echo "Setting stable kernel as default: $STABLE"
    sudo grubby --set-default="$STABLE"
    echo "Done. Reboot to use the stable kernel."
