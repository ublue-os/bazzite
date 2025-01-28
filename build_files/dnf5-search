#!/usr/bin/bash
# Retrieve a list of repos ids by name or id
set -euo pipefail

dnf5 repo info --all --json "$@" | jq -r '.[].id'
