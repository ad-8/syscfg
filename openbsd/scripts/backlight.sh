#!/usr/bin/env sh

bl=$(xbacklight -get)

printf " %.0f\n" "$bl"

