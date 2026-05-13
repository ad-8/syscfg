#!/usr/bin/env sh
set -eu

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

bri=$(printf '100\n90\n80\n70\n60\n50\n40\n30\n20\n10' | dmenu -p 'brightness:') || die 'user cancelled brightness selection'
[ -z "$bri" ] && die 'empty brightness value'
case "$bri" in
    *[!0-9]*) die "invalid brightness value: $bri" ;;
esac

tmp=$(printf '6500\n6000\n5000\n4000\n3000\n2000' | dmenu -p 'color temp:') || die 'user cancelled color temp selection'
[ -z "$tmp" ] && die 'empty color temp value'
case "$tmp" in
    *[!0-9]*) die "invalid color temp value: $tmp" ;;
esac

xbacklight -set "$bri"
sct "$tmp"

printf 'brightness: %s\n' "$bri"
printf 'color temp: %sK\n' "$tmp"
notify-send "brightness: ${bri}" "color temp: ${tmp}K" || true

