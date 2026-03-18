#!/usr/bin/env sh

IS_MUTED=$(sndioctl -n output.mute)

if [ "$IS_MUTED" -eq 1 ]; then
    echo "  MUTED"
else
    VOL=$(sndioctl -n output.level | awk '{printf "%.0f%%", $1 * 100}')
    echo "  $VOL"
fi

