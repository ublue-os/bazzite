#!/usr/bin/env bash
set -euo pipefail

if [[ -S /var/run/docker.sock ]]; then
    socket_gid="$(stat -c '%g' /var/run/docker.sock)"
    socket_group="$(getent group "${socket_gid}" | cut -d: -f1 || true)"

    if [[ -z "${socket_group}" ]]; then
        socket_group="docker-host"
        if ! getent group "${socket_group}" >/dev/null; then
            groupadd --gid "${socket_gid}" "${socket_group}"
        elif [[ "$(getent group "${socket_group}" | cut -d: -f3)" != "${socket_gid}" ]]; then
            groupmod --gid "${socket_gid}" "${socket_group}"
        fi
    fi

    usermod -aG "${socket_group}" vscode
fi

workspace_root="$(git -C /workspaces rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -n "${workspace_root}" ]]; then
    git config --global --add safe.directory "${workspace_root}"
fi