#!/usr/bin/bash

ADDRESS=127.0.0.1
PORT=1290

# Check if we are in an interactive bash session
if [[ $- == *i* ]]; then
    set -m
fi

{ python -m http.server -b $ADDRESS $PORT -d "$(dirname "$0")"/html; } >/dev/null 2>&1 &

xdg-open "http://${ADDRESS}:${PORT}"
if [[ $- == *i* ]]; then
    fg >/dev/null 2>&1 || true
fi