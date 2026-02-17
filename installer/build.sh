#!/usr/bin/bash
# Ref: https://github.com/ondrejbudai/bootc-isos/blob/3b3a185e4a57947f57baf53d2be5aee469274f98/bazzite/src/build.sh

set -exo pipefail

{ export PS4='+( ${BASH_SOURCE}:${LINENO} ): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'; } 2>/dev/null

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_IMAGE=${BASE_IMAGE:?}
INSTALL_IMAGE_PAYLOAD=${INSTALL_IMAGE_PAYLOAD:?}
FLATPAK_DIR_SHORTNAME=${FLATPAK_DIR_SHORTNAME:?}

# Create the directory that /root is symlinked to
mkdir -p "$(realpath /root)"

# bwrap tries to write /proc/sys/user/max_user_namespaces which is mounted as ro
# so we need to remount it as rw
mount -o remount,rw /proc/sys

# Install flatpaks
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -r flatpak install -y --noninteractive <"/src/$FLATPAK_DIR_SHORTNAME/flatpaks"

# Pull the container image to be installed
if mountpoint -q /usr/lib/containers/storage; then
    # We load our image from the host container storage if possible
    podman save --format oci-archive "$INSTALL_IMAGE_PAYLOAD" | podman load --storage-opt additionalimagestore=''
else
    podman pull "$INSTALL_IMAGE_PAYLOAD"
fi

# Run the preinitramfs hook
"$SCRIPT_DIR/titanoboa_hook_preinitramfs.sh"

# Install dracut-live and regenerate the initramfs
dnf install -y dracut-live
kernel=$(kernel-install list --json pretty | jq -r '.[] | select(.has_kernel == true) | .version')
DRACUT_NO_XATTR=1 dracut -v --force --zstd --reproducible --no-hostonly \
    --add "dmsquash-live dmsquash-live-autooverlay" \
    "/usr/lib/modules/${kernel}/initramfs.img" "${kernel}"

# Install livesys-scripts and configure them
dnf install -y livesys-scripts
if [[ ${BASE_IMAGE} == *-gnome* ]]; then
    sed -i "s/^livesys_session=.*/livesys_session=gnome/" /etc/sysconfig/livesys
else
    sed -i "s/^livesys_session=.*/livesys_session=kde/" /etc/sysconfig/livesys
fi
systemctl enable livesys.service livesys-late.service

# Run the postrootfs hook
"$SCRIPT_DIR/titanoboa_hook_postrootfs.sh"

# image-builder needs gcdx64.efi
dnf install -y grub2-efi-x64-cdboot

# image-builder expects the EFI directory to be in /boot/efi
mkdir -p /boot/efi
cp -av /usr/lib/efi/*/*/EFI /boot/efi/

# Remove fallback efi
cp -v /boot/efi/EFI/fedora/grubx64.efi /boot/efi/EFI/BOOT/fbx64.efi # NOTE: remove this line if breaks bootloader

# Set the timezone to UTC
rm -f /etc/localtime
systemd-firstboot --timezone UTC

# / in a booted live ISO is an overlayfs with upperdir pointed somewhere under /run
# This means that /var/tmp is also technically under /run.
# /run is of course a tmpfs, but set with quite a small size.
# ostree needs quite a lot of space on /var/tmp for temporary files so /run is not enough.
# Mount a larger tmpfs to /var/tmp at boot time to avoid this issue.
rm -rf /var/tmp
mkdir /var/tmp
cat >/etc/systemd/system/var-tmp.mount <<'EOF'
[Unit]
Description=Larger tmpfs for /var/tmp on live system

[Mount]
What=tmpfs
Where=/var/tmp
Type=tmpfs
Options=size=50%%,nr_inodes=1m,x-systemd.graceful-option=usrquota

[Install]
WantedBy=local-fs.target
EOF
systemctl enable var-tmp.mount

# Copy in the iso config for image-builder
mkdir -p /usr/lib/bootc-image-builder
cp /src/iso.yaml /usr/lib/bootc-image-builder/iso.yaml

# Clean up dnf cache to save space
dnf clean all
