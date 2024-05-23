#!/usr/bin/bash
#shellcheck disable=SC2154

if [[ -z ${project_root} ]]; then
    project_root=$(git rev-parse --show-toplevel)
fi
if [[ -z ${git_branch} ]]; then
    git_branch=$(git branch --show-current)
fi

# shellcheck disable=SC1091
. "${project_root}/just_scripts/sudoif.sh"

# Check if inside rootless container
if [[ -f /run/.containerenv ]]; then
    #shellcheck disable=SC1091
    source /run/.containerenv
    #shellcheck disable=SC2154
    if [[ "${rootless}" -eq "1" ]]; then
        echo "Cannot build ISO inside rootless podman container... Exiting..."
        exit 1
    fi
fi
container_mgr=$(just _container_mgr)
# If using rootless container manager, exit. Might not be best check
if "${container_mgr}" info | grep Root | grep -q /home; then
    echo "Cannot build ISO with rootless container..."
    exit 1
fi

# Get Inputs
target=$1
image=$2
orig_image=$2

# Set image/target/version based on inputs
# shellcheck disable=SC2154,SC1091
. "${project_root}/just_scripts/get-defaults.sh"

# Set Container tag name
tag=$(just _tag "${image}")

# Remove old ISO if present
sudoif rm -f "${project_root}/just_scripts/output/${tag}-${git_branch}.iso"
sudoif rm -f "${project_root}/just_scripts/output/${tag}-${git_branch}.iso-CHECKSUM"

# Set Base Image
if [[ ${image} =~ "gnome" ]]; then
    base_image="silverblue"
else
    base_image="kinoite"
fi

# Set variant and flatpak dir
if [[ "${base_image}" =~ "silverblue" ]]; then
    flatpak_dir_shortname="installer/gnome_flatpaks"
elif [[ "${base_image}" =~ "kinoite" ]]; then
    flatpak_dir_shortname="installer/kde_flatpaks"
else
    exit 1
fi
variant="Kinoite"
if [[ ${target} =~ "deck" ]]; then
    extra_boot_params="inst.resolution=1280x800"
fi

# Make sure image actually exists, build if it doesn't
ID=$(${container_mgr} images --filter reference=localhost/"${tag}:${latest}-${git_branch}" --format "{{.ID}}")
if [[ -z ${ID} ]]; then
    just build "${target}" "${orig_image}"
fi

# Make temp space
TEMP_FLATPAK_INSTALL_DIR=$(mktemp -d -p "${project_root}" flatpak.XXX)
# Get list of refs from directory
FLATPAK_REFS_DIR=${project_root}/${flatpak_dir_shortname}
FLATPAK_REFS_DIR_LIST=$(tr '\n' ' ' < "${FLATPAK_REFS_DIR}/flatpaks")

# Generate install script
cat << EOF > "${TEMP_FLATPAK_INSTALL_DIR}/script.sh"
cat /temp_flatpak_install_dir/script.sh
mkdir -p /flatpak/flatpak /flatpak/triggers
mkdir /var/tmp || true
chmod -R 1777 /var/tmp
flatpak config --system --set languages "*"
flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system -y ${FLATPAK_REFS_DIR_LIST}
ostree refs --repo=\${FLATPAK_SYSTEM_DIR}/repo | grep '^deploy/' | grep -v 'org\.freedesktop\.Platform\.openh264' | sed 's/^deploy\///g' > /output/flatpaks_with_deps
EOF

workspace=${project_root}
if [[ -f /.dockerenv || -f /run/.containerenv ]]; then
    FLATPAK_REFS_DIR=${LOCAL_WORKSPACE_FOLDER}/${flatpak_dir_shortname}
    TEMP_FLATPAK_INSTALL_DIR="${LOCAL_WORKSPACE_FOLDER}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)"
    workspace=${LOCAL_WORKSPACE_FOLDER}
fi

# Generate Flatpak Dependency List
if [[ ! -f ${project_root}/${flatpak_dir_shortname}/flatpaks_with_deps ]]; then
    "${container_mgr}" run --rm --privileged \
        --entrypoint bash \
        -e FLATPAK_SYSTEM_DIR=/flatpak/flatpak \
        -e FLATPAK_TRIGGERSDIR=/flatpak/triggers \
        --volume "${FLATPAK_REFS_DIR}":/output \
        --volume "${TEMP_FLATPAK_INSTALL_DIR}":/temp_flatpak_install_dir \
        "ghcr.io/ublue-os/${base_image}-main:${version}" /temp_flatpak_install_dir/script.sh
fi

# Remove Temp Directory
if [[ -f /.dockerenv ]]; then
    TEMP_FLATPAK_INSTALL_DIR=${project_root}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)
fi
rm -rf "${TEMP_FLATPAK_INSTALL_DIR}"

if [[ ${container_mgr} =~ "podman" ]]; then
    api_socket=/run/podman/podman.sock
elif [[ ${container_mgr} =~ "docker" ]]; then
    api_socket=/var/run/docker.sock
fi

# Make ISO
${container_mgr} run --rm --privileged  \
    --volume "${api_socket}":/var/run/docker.sock \
    --volume "${workspace}"/just_scripts/build-iso-makefile-patch:/build-container-installer/container/Makefile \
    --volume "${workspace}/${flatpak_dir_shortname}":"/build-container-installer/${flatpak_dir_shortname}" \
    --volume "${workspace}"/just_scripts/output:/build-container-installer/build  \
    --volume "${workspace}"/installer/lorax_templates:/additional_lorax_templates \
    ghcr.io/jasonn3/build-container-installer:main \
    ADDITIONAL_TEMPLATES="/additional_lorax_templates/remove_root_password_prompt.tmpl" \
    ARCH="x86_64" \
    ENABLE_CACHE_DNF="false" \
    ENABLE_CACHE_SKOPEO="false" \
    ENABLE_FLATPAK_DEPENDENCIES="false" \
    ENROLLMENT_PASSWORD="ublue-os" \
    EXTRA_BOOT_PARAMS="${extra_boot_params}" \
    FLATPAK_REMOTE_REFS_DIR="${flatpak_dir_shortname}" \
    IMAGE_NAME="${tag}" \
    IMAGE_REPO="localhost" \
    IMAGE_TAG="${latest}-${git_branch}" \
    ISO_NAME="build/${tag}-${git_branch}.iso" \
    SECURE_BOOT_KEY_URL='https://github.com/ublue-os/akmods/raw/main/certs/public_key.der' \
    VARIANT="${variant}" \
    VERSION="${latest}"
