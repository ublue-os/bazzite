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

    echo "--- Configuring kernel (Asahi config as base -- 16K pages required) ---"
    # Critical: Apple Silicon REQUIRES CONFIG_ARM64_16K_PAGES=y.
    # arm64 defconfig uses 4K pages -- that kernel black-screens and reboots.
    # We MUST find the running Asahi kernel config. Try multiple paths.
    ASAHI_CONFIG=""
    KERNEL_VER=$(uname -r)
    for cfg_path in \
        "/boot/config-${KERNEL_VER}" \
        "/usr/lib/modules/${KERNEL_VER}/config"; do
        if [[ -f "$cfg_path" ]]; then
            ASAHI_CONFIG="$cfg_path"
            break
        fi
    done

    if [[ -z "$ASAHI_CONFIG" ]]; then
        echo "Config not in /boot or /usr/lib/modules -- extracting from kernel-16k RPM..."
        ASAHI_CONFIG=$(mktemp /tmp/asahi-config-XXXXX)
        rpm -q kernel-16k 2>/dev/null | while read -r pkg; do
            rpm -ql "$pkg" 2>/dev/null | grep "^/boot/config" | head -1
        done | head -1 | xargs -I{} cp {} "$ASAHI_CONFIG" 2>/dev/null || true
        [[ -s "$ASAHI_CONFIG" ]] || ASAHI_CONFIG=""
    fi

    if [[ -z "$ASAHI_CONFIG" ]]; then
        echo "ERROR: Could not find Asahi kernel config anywhere."
        echo "Cannot build a bootable kernel for Apple Silicon without it."
        exit 1
    fi

    cp "$ASAHI_CONFIG" .config
    echo "Using config: $ASAHI_CONFIG"

    # Verify 16K pages -- abort rather than produce an unbootable kernel
    if ! grep -q "^CONFIG_ARM64_16K_PAGES=y" .config; then
        echo "ERROR: CONFIG_ARM64_16K_PAGES is not set in $ASAHI_CONFIG"
        echo "Apple Silicon REQUIRES 16K pages. This config would produce"
        echo "a kernel that black-screens and reboots on Apple Silicon."
        grep -E "ARM64_4K_PAGES|ARM64_16K_PAGES|ARM64_64K_PAGES" .config || true
        exit 1
    fi
    echo "Verified: CONFIG_ARM64_16K_PAGES=y (Apple Silicon safe)"

    # Enable Thunderbolt/USB4 on top of the Asahi base config
    scripts/config --enable CONFIG_USB4
    scripts/config --enable CONFIG_USB4_NET
    scripts/config --enable CONFIG_THUNDERBOLT
    scripts/config --enable CONFIG_THUNDERBOLT_NET
    scripts/config --enable CONFIG_USB_TYPEC_ALTMODE
    scripts/config --enable CONFIG_USB_TYPEC_DP_ALTMODE
    # olddefconfig sets new symbols to defaults without stdin (no SIGPIPE)
    make ARCH=arm64 olddefconfig

    echo "--- Building kernel (this takes 30-60 minutes) ---"
    NCPU=$(nproc)
    make ARCH=arm64 -j"${NCPU}" Image modules

    # Capture the kernel release string once to use consistently
    KRELEASE=$(make -s kernelrelease)
    echo "Kernel release: $KRELEASE"

    echo "--- Installing kernel modules ---"
    # On atomic Fedora/Bazzite, /usr/lib/modules is part of the immutable
    # ostree deployment and is READ-ONLY. rpm-ostree usroverlay mounts a
    # temporary writable overlay on /usr for this boot session only.
    # The overlay is lost on next reboot but the files written to it are
    # copied into the next deployment when you run rpm-ostree commands.
    sudo rpm-ostree usroverlay
    echo "usroverlay active -- /usr/lib/modules is now writable"
    sudo make ARCH=arm64 modules_install

    echo "--- Installing kernel image and initramfs to /boot ---"
    # Clean up any previous failed fairydust attempts to free /boot space
    sudo rm -f /boot/vmlinuz-fairydust-* /boot/initramfs-fairydust-* 2>/dev/null || true
    echo "Freed space from previous attempts."
    df -h /boot

    sudo install -m 644 arch/arm64/boot/Image \
        "/boot/vmlinuz-fairydust-${KRELEASE}"

    # Use --host-only: only includes drivers for THIS machine's hardware.
    # Generic initramfs is ~400MB and overflows the 1.1GB /boot partition.
    # Host-only initramfs is ~50MB since it only needs Asahi/Apple drivers.
    sudo dracut --force --host-only \
        "/boot/initramfs-fairydust-${KRELEASE}.img" \
        "${KRELEASE}"

    echo "Installed kernel and initramfs:"
    ls -lh /boot/*fairydust* 2>/dev/null
    df -h /boot

    echo "--- Updating GRUB ---"
    # grub2-mkconfig fails on atomic Fedora/Bazzite because the root is a
    # composefs overlay and grub2-probe cannot resolve it.
    # grubby is composefs-aware and correctly handles ostree boot entries.
    sudo grubby \
        --add-kernel="/boot/vmlinuz-fairydust-${KRELEASE}" \
        --title="Bazzite ARM fairydust ${KRELEASE}" \
        --initrd="/boot/initramfs-fairydust-${KRELEASE}.img" \
        --copy-default
    echo "GRUB entry added for fairydust kernel."

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
