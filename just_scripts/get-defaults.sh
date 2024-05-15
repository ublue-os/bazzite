#!/usr/bin/bash
if [[ -z "${image}" ]]; then
    image=${default_image}
fi

if [[ -z "${target}" ]]; then
    target=${default_target}
elif [[ ${target} == "deck" ]]; then
    target="bazzite-deck"
elif [[ ${target} == "nvidia" ]]; then
    target="bazzite-nvidia"
fi

valid_images=(
    silverblue
    kinoite
    gnome
    kde
)
image=${image,,}
if [[ ! ${valid_images[*]} =~ ${image} ]]; then
    echo "Invalid image..."
    exit 1
fi

target=${target,,}
valid_targets=(
    bazzite
    bazzite-deck
    bazzite-nvidia
)
if [[ ! ${valid_targets[*]} =~ ${target} ]]; then
    echo "Invalid target..."
    exit 1
fi

desktop=""
if [[ ${image} == "gnome" || ${image} == "silverblue" ]]; then
    desktop="-gnome"
fi
image="${target}${desktop}"
if [[ ${image} =~ "nvidia" ]]; then
    image="bazzite${desktop}-nvidia"
fi


