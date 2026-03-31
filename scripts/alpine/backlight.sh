#!/usr/bin/env sh

bl=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
printf " %s\n" "$bl"

