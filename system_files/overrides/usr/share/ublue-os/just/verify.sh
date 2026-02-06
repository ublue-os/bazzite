# verify-image:
#  Detects if you are on an unverified official image and rebases you to the signed version.
verify-image:
    @echo "Checking image verification status..."
    @REF=$(rpm-ostree status --json | jq -r '.deployments[0]["container-image-reference"] // empty')
    @BAD="ostree-unverified-registry:"
    @GOOD="ostree-image-signed:docker://"
    
    @# Logic: Check for Unverified AND Official
    @if [[ "$REF" == *"$BAD"* ]] && [[ "$REF" == *"ghcr.io/ublue-os/"* ]]; then \
        echo "⚠️  UNVERIFIED OFFICIAL IMAGE DETECTED"; \
        echo "Current: $REF"; \
        CLEAN_REF=${REF#$BAD}; \
        TARGET="$GOOD$CLEAN_REF"; \
        echo ""; \
        echo "Target:  $TARGET"; \
        echo ""; \
        echo "This will rebase your system to the signed image."; \
        echo "This allows you to receive secure updates."; \
        echo ""; \
        read -p "Proceed with rebase? [y/N] " -n 1 -r; \
        echo ""; \
        if [[ $REPLY =~ ^[Yy]$ ]]; then \
            echo "Requesting root permission to rebase..."; \
            pkexec rpm-ostree rebase "$TARGET"; \
        else \
            echo "Cancelled."; \
        fi \
    else \
        echo "✅ System is either already verified or a custom user image. No action needed."; \
    fi