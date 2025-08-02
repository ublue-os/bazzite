export project_root := `git rev-parse --show-toplevel`
export git_branch := ` git branch --show-current`
export latest := "41"
export default_image := "kinoite"
export default_target := "bazzite"

alias build-iso := build-iso-release
alias run := run-container

_default:
    @just --list

_container_mgr:
    @{{ project_root }}/just_scripts/container_mgr.sh

_tag image:
    @echo {{ image }}-build

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
    @{{ project_root }}/just_scripts/build-image.sh {{ target }} {{ image }} 

# Build ISO
build-iso-release target="" image="":
    @{{ project_root }}/just_scripts/build-iso.sh {{ target }} {{ image }} 

# Build ISO using ISO Builder Git Head
build-iso-git target="" image="":
    @{{ project_root }}/just_scripts/build-iso-installer-main.sh {{ target }} {{ image }}

# Run ISO
run-iso target="" image="":
    @{{ project_root }}/just_scripts/run-iso.sh {{ target }} {{ image }}

# Run Container
run-container target="" image="":
    @{{ project_root }}/just_scripts/run-image.sh {{ target }} {{ image }}

# List Images
list-images:
    @{{ project_root }}/just_scripts/list-images.sh

# Clean Images
clean-images:
    @{{ project_root }}/just_scripts/cleanup-images.sh

# Clean ISOs
clean-isos:
    @{{ project_root }}/just_scripts/cleanup-dir.sh
