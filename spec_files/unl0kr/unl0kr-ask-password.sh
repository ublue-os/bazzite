#!/usr/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later

# Try to hide plymouth for unl0kr
# TODO: Find way to do this without sleeping
sleep 5
plymouth hide-splash 2>/dev/null

# Searching for passwords for unl0kr
for file in `ls /run/systemd/ask-password/ask.*`; do
  socket="$(cat "$file" | grep "Socket=" | cut -d= -f2)"
  /usr/bin/unl0kr | /lib/systemd/systemd-reply-password 1 "$socket"
done

# Try to show plymouth again after unl0kr
plymouth show-splash 2>/dev/null
