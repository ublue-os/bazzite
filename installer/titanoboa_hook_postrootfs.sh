#!/usr/bin/env bash

set -eo pipefail

### BAZZITE SPECIFIC TWEAKS ###

# Disable services
(
    set +e
    for s in \
        rpm-ostree-countme.service \
        tailscaled.service \
        bootloader-update.service \
        brew-upgrade.timer \
        brew-update.timer \
        brew-setup.service \
        rpm-ostreed-automatic.timer \
        uupd.timer \
        ublue-system-setup.service \
        ublue-guest-user.service \
        check-sb-key.service; do
        systemctl disable $s
    done

    for s in \
        ublue-flatpak-manager.service \
        podman-auto-update.timer \
        ublue-user-setup.service; do
        systemctl --global disable $s
    done
)

# Dont start Steam at login
rm -vf /etc/skel/.config/autostart/steam*.desktop

###############################

# We need to make our own Profiles. This makes anaconda think we are a Kinoite Install
. /etc/os-release
if [[ "$ID_LIKE" =~ rhel ]]; then
    echo 'VARIANT_ID="kinoite"' >>/usr/lib/os-release
else
    sed -i "s/^VARIANT_ID=.*/VARIANT_ID=kinoite/" /usr/lib/os-release
fi
sed -i "s/^ID=.*/ID=fedora/" /usr/lib/os-release

# Install Anaconda, Webui if >= F42
if [[ "$ID_LIKE" =~ rhel ]]; then
    dnf install -y anaconda-liveinst
    HIDE_SPOKE="1"
else
    dnf install -y anaconda-live libblockdev-{btrfs,lvm,dm}
    if [[ "$(rpm -E %fedora)" -ge 42 ]]; then
        # Needed for Anaconda Web UI
        mkdir -p /var/lib/rpm-state
        dnf install -y anaconda-webui
    else
        HIDE_SPOKE="1"
    fi
fi

if [[ "${HIDE_SPOKE:-}" ]]; then
    # Hide Root Spoke
    cat <<EOF >>/etc/anaconda/conf.d/anaconda.conf
[User Interface]
hidden_spokes =
    PasswordSpoke
EOF
fi

# Get Artwork
git clone https://github.com/ublue-os/packages.git /root/packages
case "${PRETTY_NAME,,}" in
"bazzite"*)
    mkdir -p /usr/share/anaconda/pixmaps/silverblue
    cp -r /root/packages/bazzite/fedora-logos/* /usr/share/anaconda/pixmaps/
    ;;
esac
rm -rf /root/packages

# Variables
imageref="$(podman images --format '{{ index .Names 0 }}' 'bazzite*')"
imageref="${imageref##*://}"
imagetag="$(podman images --format '{{ .Tag }}' "$imageref")"
sbkey='https://github.com/ublue-os/akmods/raw/main/certs/public_key.der'

# Secureboot Key Fetch
mkdir -p /run/install/repo
curl -Lo /run/install/repo/sb_pubkey.der "$sbkey"

# Default Kickstart
cat <<EOF >>/usr/share/anaconda/interactive-defaults.ks
ostreecontainer --url=$imageref:$imagetag --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
%include /usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
EOF

# Signed Images
cat <<EOF >>/usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%post --erroronfail
bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry $imageref:$imagetag
%end
EOF

# Enroll Secureboot Key
cat <<EOF >>/usr/share/anaconda/post-scripts/secureboot-enroll-key.ks
%post --erroronfail --nochroot
set -oue pipefail

readonly ENROLLMENT_PASSWORD="universalblue"
readonly SECUREBOOT_KEY="/run/install/repo/sb_pubkey.der"

if [[ ! -d "/sys/firmware/efi" ]]; then
	echo "EFI mode not detected. Skipping key enrollment."
	exit 0
fi

if [[ ! -f "\$SECUREBOOT_KEY" ]]; then
	echo "Secure boot key not provided: \$SECUREBOOT_KEY"
	exit 0
fi

SYS_ID="\$(cat /sys/devices/virtual/dmi/id/product_name)"
if [[ ":Jupiter:Galileo:" =~ ":\$SYS_ID:" ]]; then
	echo "Steam Deck hardware detected. Skipping key enrollment."
	exit 0
fi

mokutil --timeout -1 || :
echo -e "\$ENROLLMENT_PASSWORD\n\$ENROLLMENT_PASSWORD" | mokutil --import "\$SECUREBOOT_KEY" || :
%end
EOF

# Install Flatpaks
cat <<'EOF' >>/usr/share/anaconda/post-scripts/install-flatpaks.ks
%post --erroronfail --nochroot
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP /var/lib/flatpak "$target"
%end
EOF

# Disable Fedora Flatpak Repo
cat <<EOF >>/usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%post --erroronfail
systemctl disable flatpak-add-fedora-repos.service
%end
EOF

# Set Anaconda Payload to use flathub
cat <<EOF >>/etc/anaconda/conf.d/anaconda.conf
[Payload]
flatpak_remote = flathub https://dl.flathub.org/repo/
EOF
