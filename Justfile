set unstable := true

export project_root := `git rev-parse --show-toplevel`
export git_branch := ` git branch --show-current`
export latest := "44"
export default_image := "kinoite"
export default_target := "bazzite"
kernel_flavor := "ogc"
export just := just_executable()
export container_mgr := env("CONTAINER_MGR", if which("podman") != "" { "podman" } else if which("docker") != "" { "docker" } else if which("podman-remote") != "" { "podman-remote" } else { error("No container manager found") })

alias build-iso := build-iso-release
alias run := run-container

_default:
    @{{ just }} --list

# Resolve target and image name from shorthand inputs
[private]
_resolve_image target image:
    #!/usr/bin/bash
    set -euo pipefail
    target="{{ target }}"
    image="{{ image }}"

    [[ -z "$image" ]] && image="{{ default_image }}"
    [[ -z "$target" ]] && target="{{ default_target }}"
    [[ "$target" == "deck" ]] && target="bazzite-deck"
    [[ "$target" == "nvidia" ]] && target="bazzite-nvidia"

    image="${image,,}"
    target="${target,,}"

    desktop=""
    if [[ "$image" == "gnome" || "$image" == "silverblue" ]]; then
        desktop="-gnome"
    fi
    resolved="${target}${desktop}"
    if [[ "$resolved" =~ nvidia ]]; then
        resolved="bazzite${desktop}-nvidia"
    fi

    if [[ "$image" =~ "gnome" || "$image" =~ "silverblue" ]]; then
        base_image="silverblue"
    else
        base_image="kinoite"
    fi

    echo "${resolved} ${base_image} ${target}"

# Check Just Syntax
[group('Just')]
just-check:
    #!/usr/bin/bash
    find "${project_root}" -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	{{ just }} --unstable --fmt --check -f $file
    done
    {{ just }} --unstable --fmt --check -f ${project_root}/Justfile

# Fix Just Syntax
[group('Just')]
[private]
just-fix:
    #!/usr/bin/bash
    find "${project_root}" -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	{{ just }} --unstable --fmt -f $file
    done
    {{ just }} --unstable --fmt -f ${project_root}/Justfile

# Build image
[group('Image')]
build target="" image="":
    #!/usr/bin/bash
    set -euo pipefail

    resolved=$({{ just }} _resolve_image "{{ target }}" "{{ image }}")
    image_name=$(echo "$resolved" | cut -d' ' -f1)
    base_image=$(echo "$resolved" | cut -d' ' -f2)
    container_target=$(echo "$resolved" | cut -d' ' -f3)

    container_mgr="${container_mgr}"
    tag="${image_name}-build"

    if [[ "$container_target" =~ "nvidia" ]]; then
        flavor="nvidia"
    else
        flavor="main"
    fi

    # Resolve kernel version dynamically
    kernel_version=$(skopeo inspect --retry-times 3 \
        "docker://ghcr.io/ublue-os/akmods:{{ kernel_flavor }}-{{ latest }}" \
        | jq -r '.Labels["ostree.linux"]')

    $container_mgr build -f Containerfile \
        --build-arg="BASE_IMAGE_NAME=${base_image}" \
        --build-arg="FEDORA_VERSION={{ latest }}" \
        --build-arg="KERNEL_FLAVOR={{ kernel_flavor }}" \
        --build-arg="KERNEL_VERSION=${kernel_version}" \
        --build-arg="IMAGE_NAME=${tag}" \
        --build-arg="SOURCE_IMAGE=${base_image}-${flavor}" \
        --target="${container_target}" \
        --tag "localhost/${tag}:{{ latest }}-{{ git_branch }}" \
        "${project_root}"

# Build ISO
[group('ISO')]
build-iso-release target="" image="":
    @{{ project_root }}/just_scripts/build-iso.sh {{ target }} {{ image }}

# Build ISO using ISO Builder Git Head
[group('ISO')]
build-iso-git target="" image="":
    @{{ project_root }}/just_scripts/build-iso-installer-main.sh {{ target }} {{ image }}

# Run ISO
[group('ISO')]
run-iso target="" image="":
    @{{ project_root }}/just_scripts/run-iso.sh {{ target }} {{ image }}

# Run Container
[group('Image')]
run-container target="" image="":
    #!/usr/bin/bash
    set -euo pipefail

    resolved=$({{ just }} _resolve_image "{{ target }}" "{{ image }}")
    image_name=$(echo "$resolved" | cut -d' ' -f1)

    container_mgr="${container_mgr}"
    tag="${image_name}-build"

    # Build if image doesn't exist
    ID=$($container_mgr images --filter "reference=localhost/${tag}:{{ latest }}-{{ git_branch }}" --format "{{{{.ID}}")
    if [[ -z "$ID" ]]; then
        {{ just }} build "{{ target }}" "{{ image }}"
    fi

    $container_mgr run -it --rm "localhost/${tag}:{{ latest }}-{{ git_branch }}" /usr/bin/bash

# List Images
[group('Utility')]
list-images:
    #!/usr/bin/bash
    set -euo pipefail
    for mgr in docker podman podman-remote; do
        if command -v "$mgr" &>/dev/null; then
            echo "Container Manager: ${mgr}"
            $mgr images --filter "reference=localhost/bazzite*-build"
        fi
    done

# Clean Images
[group('Utility')]
clean-images:
    #!/usr/bin/bash
    set -euox pipefail
    for mgr in docker podman podman-remote; do
        if command -v "$mgr" &>/dev/null; then
            echo "Container Manager: ${mgr}"
            $mgr images --filter "reference=localhost/bazzite*-build" --format "{{{{.ID}}" | xargs -r $mgr image rm
        fi
    done

# Clean ISOs
[group('Utility')]
clean-isos:
    #!/usr/bin/bash
    set -euox pipefail
    rm -f "${project_root}"/just_scripts/output/*
