#!/usr/bin/bash
valid_manager=(
    docker
    podman
    podman-remote
)
if [[ -n ${CONTAINER_MGR} ]]; then
    if [[ "${valid_manager[*]}" =~ ${CONTAINER_MGR} ]]; then
        echo "${CONTAINER_MGR}"
    else
        exit 1
    fi
elif [[ $(command -v docker) ]]; then
    echo docker
elif [[ $(command -v podman) ]]; then
    echo podman
elif [[ $(command -v podman-remote) ]];then
    echo podman-remote
else
    exit 1
fi