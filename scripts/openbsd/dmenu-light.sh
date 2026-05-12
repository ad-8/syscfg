#!/usr/bin/env sh
set -eu

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

bri=$(printf '10\n20\n30\n40\n50\n60\n70\n80\n90\n100' | dmenu -p 'brightness:') || die 'user cancelled brightness selection'
[ -z "$bri" ] && die 'empty brightness value'
case "$bri" in
    *[!0-9]*) die "invalid brightness value: $bri" ;;
esac

tmp=$(printf '2000\n3000\n4000\n5000\n6000\n6500' | dmenu -p 'color temp:') || die 'user cancelled color temp selection'
[ -z "$tmp" ] && die 'empty color temp value'
case "$tmp" in
    *[!0-9]*) die "invalid color temp value: $tmp" ;;
esac

xbacklight -set "$bri"
sct "$tmp"

printf 'brightness: %s\n' "$bri"
printf 'color temp: %sK\n' "$tmp"
notify-send "brightness: ${bri}" "color temp: ${tmp}K" || true

