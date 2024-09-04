#!/usr/bin/env bash

set -eo pipefail

if ! command -v hyperfine >&2 2>/dev/null; then
    echo >&2 "This script requires 'hyperfine'"
    exit 1
fi

cd "$(dirname "${0}")" || exit

# Store current and previous commit hashes
_commit_1_ref=$(git rev-parse "${1:-HEAD~1}")
_commit_2_ref=$(git rev-parse "${2:-HEAD}")

orig_ref=$(git rev-parse --abbrev-ref HEAD)
readonly orig_ref
commit_1=$(git rev-parse "$_commit_1_ref")
commit_2=$(git rev-parse "$_commit_2_ref")

# shellcheck disable=SC2064
trap "git checkout ${orig_ref}" INT EXIT

# Run benchmark
hyperfine \
    --runs 3 \
    --parameter-list ref "${commit_1}","${commit_2}" \
    --setup 'git checkout --quiet -d {ref}' \
    \
    'just mkdocs build' \
    \
    'just mkdocs build'
