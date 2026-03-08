#!/usr/bin/env bash

group() {
  WHAT=$1
  shift
  echo "::group:: === $WHAT ==="
}

log() {
  echo "=== $* ==="
}
