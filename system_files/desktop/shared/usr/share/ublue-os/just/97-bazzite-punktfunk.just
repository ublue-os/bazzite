
# Install Punktfunk streaming host
[group("applications")]
install-punktfunk ACTION="":
    #!/usr/bin/bash
    set -euo pipefail

    if [[ "{{ ACTION }}" == "status" ]]; then
        if [[ -f /var/lib/extensions/punktfunk.raw ]]; then
            echo "installed"
        else
            echo "not-installed"
        fi
        exit 0
    fi

    curl -fsSL https://punktfunk.unom.io/install.sh | sh

# Uninstall Punktfunk streaming host
[group("applications")]
uninstall-punktfunk:
    #!/usr/bin/bash
    set -euo pipefail
    curl -fsSL https://punktfunk.unom.io/install.sh | sh -s -- --uninstall
