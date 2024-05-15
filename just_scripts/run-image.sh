#!/usr/bin/bash
if [[ -z ${project_root} ]]; then
    project_root=$(git rev-parse --show-toplevel)
fi
if [[ -z ${git_branch} ]]; then
    git_branch=$(git branch --show-current)
fi
set -eo pipefail

# Get Inputs
target=$1
image=$2
orig_image=$2

# Get image/target/version based on inputs
# shellcheck disable=SC2154,SC1091
. "${project_root}/just_scripts/get-defaults.sh"

# Get variables
container_mgr=$(just _container_mgr)
tag=$(just _tag "${image}")

# Check if requested image exist, if it doesn't build it
ID=$(${container_mgr} images --filter reference=localhost/"${tag}":"${latest}-${git_branch}" --format "{{.ID}}")
if [[ -z ${ID} ]]; then
    just build "${target}" "${orig_image}"
fi

# Run image
"${container_mgr}" run -it --rm localhost/"${tag}:${latest}-${git_branch}" /usr/bin/bash
