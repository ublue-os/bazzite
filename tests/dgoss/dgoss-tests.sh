#!/usr/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 <tests-dir> <image-ref>"
    exit 1
}

tests_dir="${1:-}"
image_ref="${2:-}"

if [[ -z "${tests_dir}" || -z "${image_ref}" ]]; then
    usage
fi

# Force dgoss to use podman
export CONTAINER_RUNTIME=podman

# Fail fast if dgoss not present
if ! command -v dgoss >/dev/null 2>&1; then
    echo "dgoss not found in PATH" >&2
    exit 2
fi

# Find all test directories containing test.sh
mapfile -t test_scripts < <(find "${tests_dir}" -mindepth 2 -maxdepth 2 -type f -name 'test.sh' | sort)

if [[ ${#test_scripts[@]} -eq 0 ]]; then
    echo "No test.sh files found in ${tests_dir}" >&2
    exit 2
fi

for test_script in "${test_scripts[@]}"; do
    test_dir="$(dirname "${test_script}")"
    test_name="$(basename "${test_dir}")"

    echo "Running test: ${test_name}..."

    (cd "${test_dir}" && ./test.sh "${image_ref}")
done

echo "All tests passed"
