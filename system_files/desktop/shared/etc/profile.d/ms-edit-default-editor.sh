# shellcheck disable=SC2148 sourced, not executed
# msedit is more usable on deck due to control scheme
# Previously we used vim to match SteamOS, but that's very unfriendly on desktop. This is a happy medium.

if [ -z "$EDITOR" ]; then
  export EDITOR=/usr/bin/msedit
fi
