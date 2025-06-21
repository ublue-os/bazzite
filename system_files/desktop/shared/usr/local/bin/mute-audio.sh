#!/usr/bin/env bash

echo "$(date) - Waiting for default sink..." >> /tmp/mute.log
for i in {1..20}; do
  DEFAULT=$(pactl get-default-sink 2>/dev/null)
  echo "$(date) - pactl get-default-sink output: $DEFAULT" >> /tmp/mute.log
  if [[ -n "$DEFAULT" && "$DEFAULT" != @DEFAULT_SINK@ ]]; then
    echo "$(date) - Sink: $DEFAULT found. Muting..." >> /tmp/mute.log
    pactl set-sink-volume "$DEFAULT" 0%
    pactl set-sink-mute "$DEFAULT" 1
    echo "$(date) - Done." >> /tmp/mute.log
    exit 0
  fi
  sleep 0.5
done
echo "$(date) - No usable sink found after 10s. Skipping mute." >> /tmp/mute.log
