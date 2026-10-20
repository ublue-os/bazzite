#!/usr/bin/env bash
#
# Normalize filesystem timestamps without affecting chunkah's layer plan.
# See: https://github.com/coreos/chunkah/issues/160
#
# Run at the end of every stage, not only in the final one. Touching a file
# from a lower layer makes overlayfs copy the whole file up, so a single pass
# in the final stage would duplicate everything the earlier stages changed
# into one multi-GB layer. Files a stage changed are still in its own upper
# layer, where resetting their mtime is cheap.
#
set -xeuo pipefail

find /usr /etc /opt -newermt '1970-01-01T00:00:00Z' -exec touch -h -a -m -d '1970-01-01T00:00:00Z' {} +
