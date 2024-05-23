#!/usr/bin/bash
set -euo pipefail
container_mgr=(
    docker
    podman
    podman-remote
)
for i in "${container_mgr[@]}"; do
    if [[ $(command -v "$i") ]]; then
        echo "Container Manager: ${i}"
        ${i} images --filter "reference=localhost/bazzite*-build" 
    fi
done
