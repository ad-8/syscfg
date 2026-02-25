#!/usr/bin/env sh

back=$(backlight | awk '{print $2}')

printf "Bl: %s\n" "$back"
