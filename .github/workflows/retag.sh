#!/bin/bash
# Usage: ./retag.sh <input_image_ref> <tag> [<tag>...]

set -euxo pipefail

# Error handling with GitHub Actions compatible error output
trap 'echo "::error file=${0},line=${LINENO}::Something went wrong"' ERR

if [[ " $* " == @(-h|--help) ]]; then
    echo "Usage: ./${0##*/} <input_image_ref> <tag> [<tag>...]"
    exit 0
fi

unset -v INPUT_REF
unset -v FINAL_TAGS
INPUT_REF=$1
FINAL_TAGS=("${@:2}")
declare -p INPUT_REF
declare -p FINAL_TAGS

# Initialize an empty array to store the final image references
declare -a final_refs

# Process each tag and build the complete image reference
for tag in "${FINAL_TAGS[@]}"; do
    # Strip any existing tags or digests from the image reference and append the new tag
    _img="${INPUT_REF}"
    _img="${_img%%:*}"
    _img="${_img%%@*}"
    final_refs+=("${_img}:$tag")
done

# Check each final ref is valid
declare -p final_refs
for _ref in "${final_refs[@]}"; do
    if [[ $(grep -o ':' <<<"$_ref" | wc -l) -ne 1 ]]; then
        echo "::error::Invalid image reference: $_ref"
        exit 1
    fi
done

# Login into Github Container Registry in skopeo
echo "${GITHUB_TOKEN}" | sudo skopeo login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin

# Copy the input image to each of the final image references
echo "# Image retaggins" >>"${GITHUB_STEP_SUMMARY}"
for _ref in "${final_refs[@]}"; do
    sudo skopeo copy docker://"$INPUT_REF" docker://"$_ref" &&
        {
            echo '```'
            echo "$INPUT_REF -> $_ref"
            echo '```'
        } >>"${GITHUB_STEP_SUMMARY}"
done
