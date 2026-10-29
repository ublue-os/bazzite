export project_root := `git rev-parse --show-toplevel`
export default_image := "kinoite"
export default_target := "bazzite"

alias run := run-container

_default:
    @just --list

# Check Just Syntax
just-check:
    #!/usr/bin/bash
    find "${project_root}" -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt --check -f $file
    done
    just --unstable --fmt --check -f ${project_root}/Justfile

# Fix Just Syntax
[private]
just-fix:
    #!/usr/bin/bash
    find "${project_root}" -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt -f $file
    done
    just --unstable --fmt -f ${project_root}/Justfile

# Build image
build target="" image="":
    #!/usr/bin/bash
    set -eo pipefail
    target="{{ target }}"
    image="{{ image }}"
    . "${project_root}/just_scripts/get-defaults.sh"
    "${project_root}/build.py" build --image "${image}"

# Run Container
run-container target="" image="":
    #!/usr/bin/bash
    set -eo pipefail
    target="{{ target }}"
    image="{{ image }}"
    . "${project_root}/just_scripts/get-defaults.sh"
    "${project_root}/build.py" shell --image "${image}"

# List Images
list-images:
    @{{ project_root }}/just_scripts/list-images.sh

# Clean Images
clean-images:
    @{{ project_root }}/just_scripts/cleanup-images.sh
