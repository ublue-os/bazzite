#!/bin/env bash

function echod() { echo "[DEBUG]: $*"; }

if ! command -v brew >/dev/null; then
    echod "[DEBUG]:This script needs 'brew' to run"
    exit 1
fi
if ! command -v cargo >/dev/null; then
    echod "Installing rust"
    brew install rustup && rustup-init -y
fi
if ! command -v just >/dev/null; then
    echod "Installing just"
    brew install just
fi

# Install mdbook and other
echod "Installing mdbook"
cargo install --git https://github.com/HollowMan6/mdBook --rev b5ca7bc39ac2e8073dc2fb9d984c0e46c498c167 mdbook --locked
cargo install mdbook-i18n-helpers --locked --version 0.3.5
cargo install i18n-report --locked --version 0.2.0
cargo install mdbook-pdf --locked --version 0.1.10 --features fetch
cargo install mdbook-cmdrun --locked --version 0.6.0

# Check if we are running Linux or MacOS, and install Poedit
os=$(uname -s)
case ${os,,} in
linux*)
    set -x
    flatpak install net.poedit.Poedit --system --noninteractive
    sudo flatpak override --socket=wayland  net.poedit.Poedit
    set +x
    ;;
darwin*)
    brew install --cask poedit
    ;;
*)
    exit 1
    ;;
esac

echod "Dependencies installed succesfully"