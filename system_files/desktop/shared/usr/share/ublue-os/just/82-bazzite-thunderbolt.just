# vim: set ft=make :

# Show current kernel variant (stable or fairydust)
[group("arm")]
kernel-variant:
    #!/usr/bin/bash
    image_variant=$(cat /usr/share/ublue-os/kernel-variant 2>/dev/null || echo "stable")
    kernel=$(uname -r)
    running_variant="stable"
    if [[ "$kernel" == *fairydust* ]]; then
        running_variant="fairydust"
    fi
    echo "Image variant  : $image_variant"
    echo "Running kernel : $kernel"
    echo "Kernel flavor  : $running_variant"
    echo ""
    if [[ "$image_variant" == "fairydust" || "$running_variant" == "fairydust" ]]; then
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
    set -euo pipefail
    BUILD_DEPS=(
        gcc gcc-c++ make bc bison flex git
        openssl-devel dwarves elfutils-libelf-devel
        perl perl-Carp rpm-build ncurses-devel python3
        rsync cpio binutils openssl diffutils
        hostname kmod dracut grubby
    )
    APPLE_INPUT_DRIVERS=(
        pinctrl-apple-gpio
        spi-apple
        hid-apple
        spi-hid-apple
        spi-hid-apple-of
    )
    USB4_DRIVERS=(
        typec
        typec_displayport
        typec_thunderbolt
        phy-apple-atc
        phy-apple-dptx
        thunderbolt
        thunderbolt_net
    )
    INITRAMFS_DRIVERS=("${APPLE_INPUT_DRIVERS[@]}" "${USB4_DRIVERS[@]}")
    PERSIST_ROOT="/var/lib/fairydust-kernel/modules"
    if [[ "$(uname -m)" != "aarch64" ]]; then
        echo "This command is only relevant on aarch64 (Apple Silicon) systems."
        exit 1
    fi
    WORK_DIR=$(mktemp -d /var/tmp/fairydust-XXXXX)
    cleanup() {
        rm -rf "$WORK_DIR"
    }
    trap cleanup EXIT

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
        if ! sudo rpm-ostree install --apply-live "${BUILD_DEPS[@]}"; then
            echo "rpm-ostree install failed -- falling back to package manager"
            if command -v dnf5 &>/dev/null; then
                sudo dnf5 install -y "${BUILD_DEPS[@]}"
            else
                sudo dnf install -y "${BUILD_DEPS[@]}"
            fi
        fi
    fi

    # Verify make is available before proceeding
    if ! command -v make &>/dev/null; then
        echo "ERROR: 'make' not found. Please run from the fairydust image variant or"
        echo "run: sudo rpm-ostree install make gcc && reboot"
        exit 1
    fi

    echo "--- Cloning fairydust branch to $WORK_DIR ---"
    echo "(Shallow clone, ~500MB)"
    git clone --depth=1 --single-branch --branch=fairydust \
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

    # Enable the actual Fairydust transport and alt-mode symbols on top of
    # the Asahi base config. These are the real Kconfig names in-tree; the
    # module filenames differ for some of them (for example USB4 -> thunderbolt).
    scripts/config --module USB4
    scripts/config --module USB4_NET
    scripts/config --module TYPEC
    scripts/config --module TYPEC_DP_ALTMODE
    scripts/config --module TYPEC_TBT_ALTMODE
    scripts/config --module PHY_APPLE_ATC
    scripts/config --module PHY_APPLE_DPTX
    # olddefconfig sets new symbols to defaults without stdin (no SIGPIPE)
    make ARCH=arm64 olddefconfig

    echo "--- Building kernel (this takes 30-60 minutes) ---"
    NCPU=$(nproc)
    make ARCH=arm64 -j"${NCPU}" Image modules

    # Capture the kernel release string once to use consistently
    KRELEASE=$(make -s kernelrelease)
    echo "Kernel release: $KRELEASE"

    echo "--- Installing kernel modules ---"
    # Keep two copies:
    #   1. a live usroverlay copy so dracut can build the new initramfs now
    #   2. a persistent /var copy that is bind-mounted back onto /lib/modules
    #      on future Fairydust boots, so post-boot module loading still works
    #      after the ephemeral usroverlay disappears.
    sudo mkdir -p "${PERSIST_ROOT}"
    sudo rm -rf "${PERSIST_ROOT}/lib/modules/${KRELEASE}"
    sudo rpm-ostree usroverlay
    echo "Installing modules into live usroverlay for initramfs generation..."
    sudo make ARCH=arm64 modules_install
    echo "Installing modules into ${PERSIST_ROOT} for post-reboot use..."
    sudo make ARCH=arm64 INSTALL_MOD_PATH="${PERSIST_ROOT}" modules_install
    sudo depmod -b "${PERSIST_ROOT}" "${KRELEASE}"

    echo "--- Installing persistent module mount helper ---"
    sudo install -d /usr/local/bin /etc/systemd/system
    sudo bash -c 'cat <<'"'"'EOF'"'"' > /usr/local/bin/fairydust-modules
    #!/usr/bin/bash
    set -euo pipefail

    running="$(uname -r)"
    module_root="/var/lib/fairydust-kernel/modules/lib/modules"

    if [[ "$running" != *fairydust* ]]; then
        exit 0
    fi

    if [[ ! -d "${module_root}/${running}" ]]; then
        echo "fairydust-modules: missing module tree for ${running}" >&2
        exit 1
    fi

    if mountpoint -q /lib/modules; then
        exit 0
    fi

    mount --bind "${module_root}" /lib/modules
    EOF'
    sudo chmod 755 /usr/local/bin/fairydust-modules
    sudo bash -c 'cat <<'"'"'EOF'"'"' > /etc/systemd/system/fairydust-modules.service
    [Unit]
    Description=Expose persistent Fairydust kernel modules
    DefaultDependencies=no
    After=local-fs.target
    Before=systemd-modules-load.service sysinit.target
    ConditionPathExists=/var/lib/fairydust-kernel/modules/lib/modules

    [Service]
    Type=oneshot
    ExecStart=/usr/local/bin/fairydust-modules
    RemainAfterExit=yes

    [Install]
    WantedBy=sysinit.target
    EOF'
    sudo systemctl daemon-reload
    sudo systemctl enable fairydust-modules.service
    sudo systemctl start fairydust-modules.service || true

    echo "--- Installing kernel image and initramfs to /boot ---"
    # Clean up any previous failed fairydust attempts to free /boot space
    sudo rm -f \
        /boot/vmlinuz-fairydust-* \
        /boot/initramfs-fairydust-* \
        /boot/config-fairydust-* \
        /boot/System.map-fairydust-* \
        2>/dev/null || true
    echo "Freed space from previous attempts."
    df -h /boot

    sudo install -m 644 arch/arm64/boot/Image \
        "/boot/vmlinuz-fairydust-${KRELEASE}"
    sudo install -m 644 .config \
        "/boot/config-fairydust-${KRELEASE}"
    sudo install -m 644 System.map \
        "/boot/System.map-fairydust-${KRELEASE}"

    # Use --host-only: only includes drivers for THIS machine's hardware.
    # Generic initramfs is ~400MB and overflows the 1.1GB /boot partition.
    # Host-only initramfs is ~50MB since it only needs Asahi/Apple drivers.
    # Force the Apple internal keyboard/trackpad path and the new USB4/Type-C
    # stack into the image so the Fairydust kernel does not depend on the live
    # module tree just to bring up the built-in input devices.
    sudo dracut --force --host-only \
        --add-drivers "${INITRAMFS_DRIVERS[*]}" \
        --force-drivers "${INITRAMFS_DRIVERS[*]}" \
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

# Set the fairydust kernel as the default boot entry
[group("arm")]
set-fairydust-default:
    #!/usr/bin/bash
    FAIRYDUST=$(find /boot -maxdepth 1 -name 'vmlinuz-fairydust-*' -print 2>/dev/null | sort -V | tail -1)
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
    STABLE=$(find /boot -maxdepth 1 -name 'vmlinuz-*asahi*' ! -name '*fairydust*' -print 2>/dev/null | sort -V | tail -1)
    if [[ -z "$STABLE" ]]; then
        echo "No stable Asahi kernel found."
        exit 1
    fi
    echo "Setting stable kernel as default: $STABLE"
    sudo grubby --set-default="$STABLE"
    echo "Done. Reboot to use the stable kernel."

# Set up an external drive for game storage with auto-mount

# Usage: ujust setup-games-drive /dev/sda  (or whatever device)
[group("arm")]
setup-games-drive DEV="":
    #!/usr/bin/bash
    set -euo pipefail
    if [[ -z "{{ DEV }}" ]]; then
        echo "Usage: ujust setup-games-drive /dev/sda"
        echo ""
        echo "Available block devices:"
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v "^loop"
        exit 1
    fi
    DEV="{{ DEV }}"
    if [[ ! -b "$DEV" ]]; then
        echo "ERROR: $DEV is not a block device."
        exit 1
    fi
    echo "Setting up $DEV as games drive mounted at /var/mnt/games..."
    echo "WARNING: This will format $DEV as ext4 and erase all data on it."
    read -rp "Continue? (y/N): " confirm
    [[ "$confirm" == [yY] ]] || exit 0
    sudo mkfs.ext4 -L "BazziteGames" "$DEV"
    UUID=$(blkid -s UUID -o value "$DEV")
    sudo mkdir -p /var/mnt/games
    if ! grep -q "UUID=${UUID}" /etc/fstab 2>/dev/null; then
        echo "UUID=${UUID}  /var/mnt/games  ext4  defaults,nofail,x-systemd.automount  0  2" \
            | sudo tee -a /etc/fstab > /dev/null
        echo "Added to /etc/fstab (auto-mounts on every boot)."
    fi
    sudo systemctl daemon-reload
    sudo mount /var/mnt/games
    echo ""
    echo "Done! $DEV is now mounted at /var/mnt/games"
    echo "It will auto-mount on every boot."
    df -h /var/mnt/games
