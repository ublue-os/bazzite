#!/bin/bash

# This script checks if the live system is:
# - currently deployed through unverified container registry;
# - over 1 month old and user chose a specific tag (like stable-43.20260404).

# 1. Get the current image reference, image tag and image date
CURRENT_REF=$(rpm-ostree status --json | jq -r '.deployments[0]["container-image-reference"] // empty')

IMAGE_TAG=${CURRENT_REF##*:}

if [[ "$IMAGE_TAG" == *"stable"* || "$IMAGE_TAG" == *"testing"* ]]; then
    # Remove everything after "-" (testing-43.20260404 becomes testing)
    PROPER_IMAGE_TAG=${IMAGE_TAG%-*}
else
    # If image tag doesn't mention stable or testing, assume the user runs stable version
    PROPER_IMAGE_TAG="stable"
fi

IMAGE_DATE=$(rpm-ostree status | sed -n 's/.*Timestamp: \(.*\)/\1/p')
IMAGE_DATE_SECONDS=$(date -d "$IMAGE_DATE" +%s)
CURRENT_SECONDS=$(date +%s)
DIFFERENCE=$((CURRENT_SECONDS - IMAGE_DATE_SECONDS))
MONTH=$((30 * 24 * 60 * 60))

# 2. Define Identifiers
UNVERIFIED_TAG="ostree-unverified-registry"
OFFICIAL_TAG="ghcr.io/ublue-os/"

# 3. The "Smart" Check
if [[ "$CURRENT_REF" == *"$UNVERIFIED_TAG"* ]] && [[ "$CURRENT_REF" == *"$OFFICIAL_TAG"* ]]; then
    # 4. The Warning (Red Text)
    echo -e "\n\033[0;31m\033[1m[!] SECURITY WARNING: Unverified System Image Detected\033[0m"
    echo -e "\033[0;31m    Your system is running on an unsigned official image."
    echo -e "    This prevents automatic updates and verification.\033[0m"
    # UPDATED COMMAND HERE:
    echo -e "\n    To fix this, run: \033[1mujust verify-image\033[0m\n"
elif [[ "$CURRENT_REF" == *"$OFFICIAL_TAG"* ]] && [[ "$DIFFERENCE" -ge "$MONTH" ]] && [[ "$IMAGE_TAG" != "$PROPER_IMAGE_TAG" ]]; then
    # 4. The Warning (Red Text)
    echo -e "\n\033[0;31m\033[1m[!] SECURITY WARNING: Old System Image Detected\033[0m"
    echo -e "\033[0;31m    Your current image is over 1 month old and is pinned to a certain date."
    echo -e "    This prevents automatic updates.\033[0m"
    # UPDATED COMMAND HERE:
    echo -e "\n    To fix this, run: \033[1mbrh rebase $PROPER_IMAGE_TAG\033[0m\n"
fi
