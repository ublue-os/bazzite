#!/usr/bin/bash

set -eo pipefail

if [[ -z ${project_root} ]]; then
    project_root=$(git rev-parse --show-toplevel)
fi
if [[ -z ${git_branch} ]]; then
    git_branch=$(git branch --show-current)
fi

# Resolve image
target=$1
image=$2
resolved=$(just _resolve_image "$target" "$image")
image_name=$(echo "$resolved" | cut -d' ' -f1)

container_mgr=${container_mgr}
tag="${image_name}-build"

# Check if ISO exists, create if it doesn't
#shellcheck disable=SC2154
if [[ ! -f "${project_root}/just_scripts/output/${tag}-${git_branch}.iso" ]]; then
    just build-iso "$target" "$image"
fi

workspace=${project_root}
if [[ -f /.dockerenv ]]; then
    workspace=${LOCAL_WORKSPACE_FOLDER}
fi

${container_mgr} run --rm --cap-add NET_ADMIN \
    --publish 127.0.0.1:8006:8006 \
    --env "CPU_CORES=2" \
    --env "RAM_SIZE=4G" \
    --env "DISK_SIZE=64G" \
    --env "BOOT_MODE=uefi" \
    --device=/dev/kvm \
    --volume "${workspace}/just_scripts/output/${tag}-${git_branch}.iso":/boot.iso \
    docker.io/qemux/qemu-docker
