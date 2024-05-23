#!/usr/bin/bash
set -euox pipefail
container_mgr=(
    docker
    podman
    podman-remote
)
for i in "${container_mgr[@]}"; do
    if [[ $(command -v "$i") ]]; then
        echo "Container Manager: ${i}"
        ID=$(${i} images --filter "reference=localhost/bazzite*-build")
        xargs -I {} "${i}" image rm {} <<< "$ID"
        echo ""
    fi
done
