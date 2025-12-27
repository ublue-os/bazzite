#!/usr/bin/bash
set -euo pipefail

image=$1
dgoss run "${image}"

# Additional volume mounts can be specified to add fixture data.
# Example:
# dgoss run -v /path/to/fixture:/path/in/container "${image}"
