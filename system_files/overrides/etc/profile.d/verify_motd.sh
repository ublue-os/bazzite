#!/bin/bash

# 1. Get the current image reference
CURRENT_REF=$(rpm-ostree status --json | jq -r '.deployments[0]["container-image-reference"] // empty')

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
fi