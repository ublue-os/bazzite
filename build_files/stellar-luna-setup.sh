#!/usr/bin/env bash
set -euxo pipefail

echo "=== Stellar OS: Luna setup ==="

# Make session and app scripts executable
chmod +755 /usr/bin/luna-session
chmod +755 /usr/bin/luna-app

# Make the main Python entry point executable
chmod +755 /usr/share/luna/main.py

echo "=== Luna setup complete ==="
