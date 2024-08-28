#!/bin/env bash

REPO_DIR="$(git rev-parse --show-toplevel)"

function echod() { echo "[DEBUG]: $*"; }

if ! command -v brew >/dev/null; then
    echod "This script needs 'brew' to run"
    exit 1
fi
if ! command -v poetry >/dev/null; then
    echod "Installing Poetry"
    brew install poetry
fi
if ! command -v just >/dev/null; then
    echod "Installing just"
    brew install just
fi

# Install poetry project
echod "Setting up poetry project"
(
    cd "$REPO_DIR"/docs
    mkdir -p .venv
    poetry install
) || {
    echod "Error setting up poetry project"
    exit 1
}
echod "Dependencies installed succesfully"