#!/usr/bin/env sh

set -eu

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

vol=$(printf '0\n10\n20\n30\n40\n50\n60\n70\n80\n90\n100' | dmenu -p 'volume:') || die 'user cancelled volume selection'
[ -z "$vol" ] && die 'empty volume value'
case "$vol" in
    *[!0-9]*) die "invalid volume value: $vol" ;;
esac

lvl=$(awk "BEGIN {printf \"%.2f\", $vol / 100}")

sndioctl output.level="$lvl" || die "sndioctl failed"

printf 'volume: %s%%\n' "$vol"
notify-send "volume: ${vol}%" || true

