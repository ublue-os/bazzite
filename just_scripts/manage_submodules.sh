#!/bin/bash

# Script to manage Git submodules
set -e

# Check for arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {init|update|status}"
    exit 1
fi

COMMAND=$1

case $COMMAND in
    init)
        echo "Initializing submodules..."
        git submodule init
        git submodule update --recursive --init
        ;;
    update)
        echo "Updating all submodules..."
        git submodule update --recursive --remote
        ;;
    status)
        echo "Checking submodule status..."
        git submodule status
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 {init|update|status}"
        exit 1
        ;;
esac
