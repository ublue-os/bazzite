#!/usr/bin/bash
if [[ -z ${project_root} ]]; then
    project_root=$(git rev-parse --show-toplevel)
fi
# shellcheck disable=SC1091
. "${project_root}/just_scripts/sudoif.sh"

set -euox pipefail

#shellcheck disable=SC2154
sudoif rm -f "${project_root}"/just_scripts/output/* #ISOs
