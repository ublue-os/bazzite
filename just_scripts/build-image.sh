#!/usr/bin/bash
set -eo pipefail
if [[ -z ${project_root} ]]; then
    project_root=$(git rev-parse --show-toplevel)
fi
if [[ -z ${git_branch} ]]; then
    git_branch=$(git branch --show-current)
fi

# Get Inputs
target=$1
image=$2

# Set image/target/version based on inputs
# shellcheck disable=SC2154,SC1091
. "${project_root}/just_scripts/get-defaults.sh"

# Get info
container_mgr=$(just _container_mgr)
tag=$(just _tag "${image}")

if [[ ${image} =~ "gnome" ]]; then
    base_image="silverblue"
else
    base_image="kinoite"
fi

if [[ ${target} =~ "nvidia" ]]; then
    flavor="nvidia"
else
    flavor="main"
fi

# Build Image
$container_mgr build -f Containerfile \
    --build-arg="IMAGE_NAME=${tag}" \
    --build-arg="BASE_IMAGE_NAME=${base_image}" \
    --build-arg="BASE_IMAGE_FLAVOR=${flavor}" \
    --build-arg="IMAGE_FLAVOR=${flavor}" \
    --build-arg="KERNEL_FLAVOR=bazzite" \
    --build-arg="SOURCE_IMAGE=${base_image}-${flavor}" \
    --build-arg="FEDORA_VERSION=${latest}" \
    --target="${target}" \
    --tag localhost/"${tag}:${latest}-${git_branch}" \
    "${project_root}"
