#!/usr/bin/env bash

set -oue pipefail

IMAGE_REF="docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

case $FEDORA_MAJOR_VERSION in
  38)
    IMAGE_TAG="latest"
    ;;
  *)
    IMAGE_TAG="$FEDORA_MAJOR_VERSION"
    ;;
esac

{
  echo "{"
  echo '"image-name": "'"$IMAGE_NAME"'",'
  echo '"image-flavor": "'"$IMAGE_FLAVOR"'",'
  echo '"image-vendor": "'"$IMAGE_VENDOR"'",'
  echo '"image-ref": "'"$IMAGE_REF"'",'
  echo '"image-tag":"'"$IMAGE_TAG"'",'
  echo '"base-image-name": "'"$BASE_IMAGE_NAME"'",'
  echo '"fedora-version": "'"$FEDORA_MAJOR_VERSION"'"'
  echo "}"
} > "/usr/share/ublue-os/image-info.json"
