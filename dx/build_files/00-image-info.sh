#!/usr/bin/env bash

set -eoux pipefail

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

# image-info File
sed -i 's/"image-name": [^,]*/"image-name": "'"$IMAGE_NAME"'"/' $IMAGE_INFO
sed -i 's|"image-ref": [^,]*|"image-ref": "'"$IMAGE_REF"'"|' $IMAGE_INFO

# OS Release File
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release

# KDE About page
# We don't want to edit an unexisting file on gnome variants
if [[ "$IMAGE_NAME" != *gnome* ]]; then
    sed -i "s|^Website=.*|Website=https://dev.bazzite.gg|" /etc/xdg/kcm-about-distrorc
    if [[ "$IMAGE_NAME" != *nvidia* ]]; then
        sed -i "s/^Variant=.*/Variant=Developer Experience/" /etc/xdg/kcm-about-distrorc
    else
        sed -i "s/^Variant=.*/Variant=Developer Experience (NVIDIA)/" /etc/xdg/kcm-about-distrorc
    fi
fi
