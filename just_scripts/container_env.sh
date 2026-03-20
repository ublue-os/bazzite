#!/usr/bin/bash

if [[ ${container_mgr:-} == "docker" ]]; then
    export DOCKER_API_VERSION="${DOCKER_API_VERSION:-1.41}"
fi