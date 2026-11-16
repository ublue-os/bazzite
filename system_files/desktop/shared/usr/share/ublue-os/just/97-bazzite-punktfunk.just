
# Install Punktfunk streaming host
[group("applications")]
install-punktfunk:
    #!/usr/bin/bash
    set -euo pipefail
    curl -fsSL https://punktfunk.unom.io/install.sh | sh
