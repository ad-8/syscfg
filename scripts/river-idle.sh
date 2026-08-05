#!/usr/bin/env sh

exec swayidle -w \
  timeout 1190 'notify-send locking-screen in-10-seconds' \
  timeout 1200 'swaylock -f -c 000000 -F' \
  timeout 1230 'wlopm --off DP-1; wlopm --off HDMI-A-1' \
  resume       'wlopm --on DP-1; wlopm --on HDMI-A-1' \
  before-sleep 'swaylock -f -c 000000 -F'
