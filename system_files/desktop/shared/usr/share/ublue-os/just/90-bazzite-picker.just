# vim: set ft=make :

# Interactive picker for ujust recipes
[group("utilities")]
pick:
    #!/usr/bin/env bash
    set -euo pipefail

    REPO="ublue-os/bazzite-ujust-picker"
    DEST="$HOME/.local/bin/ujust-picker"

    # Ensure local bin directory exists
    mkdir -p "$(dirname "$DEST")"

    echo "Checking for latest release from GitHub..."
    API_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" || true)

    if [[ -z "$API_JSON" ]]; then
        if [[ -f "$DEST" ]]; then
            echo "⚠️  GitHub unreachable. Using existing binary at $DEST"
            clear
            exec "$DEST"
        else
            echo "❌ GitHub unreachable and no local binary found. Falling back to list view."
            just --choose
            exit 0
        fi
    fi

    # Parse the latest asset for the current host architecture.
    case "$(uname -m)" in
        aarch64)
            ASSET_NAME="bazzite-ujust-picker_Linux_arm64"
            ;;
        x86_64)
            ASSET_NAME="bazzite-ujust-picker_Linux_x86_64"
            ;;
        *)
            echo "❌ Unsupported architecture for ujust-picker: $(uname -m)"
            exit 1
            ;;
    esac

    ASSET_URL=$(echo "$API_JSON" | jq -r --arg asset_name "$ASSET_NAME" '.assets[] | select(.name == $asset_name) | .browser_download_url')
    TAG_NAME=$(echo "$API_JSON" | jq -r '.tag_name')
    CACHED_TAG_FILE="$DEST.version"

    if [[ -z "$ASSET_URL" || "$ASSET_URL" == "null" ]]; then
        echo "❌ Could not locate $ASSET_NAME in the latest release."
        exit 1
    fi

    # Check if we already have the latest version
    if [[ -f "$DEST" && -f "$CACHED_TAG_FILE" ]]; then
        CURRENT_TAG=$(<"$CACHED_TAG_FILE")
        if [[ "$CURRENT_TAG" == "$TAG_NAME" ]]; then
            echo "✅ Binary already up to date ($TAG_NAME). Running..."
            clear
            exec "$DEST"
        fi
    fi

    echo "⬇️  Downloading updated binary from release $TAG_NAME"
    curl -L "$ASSET_URL" -o "$DEST"
    chmod +x "$DEST"
    echo "$TAG_NAME" > "$CACHED_TAG_FILE"

    echo "🚀 Running picker..."
    clear
    exec "$DEST"
