#!/usr/bin/env sh

# glyphs as octal utf-8 so this file stays pure ascii in transit
ico_licht=$(printf '\357\203\253')     # U+F0EB
ico_load=$(printf '\357\213\233')      # U+F2DB
ico_vol=$(printf '\357\200\250')       # U+F028
ico_vol_mute=$(printf '\356\273\250')  # U+EEE8
ico_disk=$(printf '\363\260\213\212')  # U+F02CA
ico_ram=$(printf '\363\260\215\233')   # U+F035B
sep=$(printf ' \342\200\242 ')         # U+2022

scripts=/home/ax/syscfg/scripts
status_fifo="${1:-${XDG_RUNTIME_DIR:-/tmp}/kwm-status}"
weather_cache="${XDG_RUNTIME_DIR:-/tmp}/kwm-weather"

if [ ! -e "$status_fifo" ]; then
	echo "kwm-status: $status_fifo does not exist, is river's init running?" >&2
	exit 1
fi

# weather.clj hits the network, so it never runs inline -- a slow request would
# stall the whole bar, clock included. refresh detached, publish only on
# success: weather.clj prints its errors to stdout, and a failed fetch should
# leave the last good reading standing.
weather_refresh() {
	tmp="$weather_cache.new"
	if timeout 30 "$scripts/bb/weather.clj" dwm > "$tmp" 2>/dev/null &&
		[ -s "$tmp" ]; then
		mv "$tmp" "$weather_cache"
	else
		rm -f "$tmp"
	fi
}

weather() {
	val=$(cat "$weather_cache" 2>/dev/null)
	printf '%s' "${val:-"--"}"
}

volume() {
	# [MUTED] is a glob, so keep pathname expansion off while splitting
	set -f
	set -- $(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
	set +f

	if [ -z "$2" ]; then
		printf '%s  --' "$ico_vol"
	elif [ "$3" = '[MUTED]' ]; then
		printf '%s  MUTED' "$ico_vol_mute"
	else
		awk -v v="$2" -v ico="$ico_vol" 'BEGIN { printf "%s  %.0f%%", ico, v * 100 }'
	fi
}

licht() {
	val=$(cat /tmp/licht-curr-val 2>/dev/null)
	printf '%s %s' "$ico_licht" "${val:-"--"}"
}

load() {
	read -r one rest < /proc/loadavg
	printf '%s %s' "$ico_load" "$one"
}

disk() {
	df -h / --output=avail | awk -v ico="$ico_disk" 'NR == 2 { printf "%s %s", ico, $1 }'
}

ram() {
	free -m | awk -v ico="$ico_ram" '/^Mem:/ { printf "%s %d%%", ico, $3 / $2 * 100 }'
}

tick=0
prev=
while :; do
	# 600s matches waybar's custom/weather; retry each 60s until the first
	# fetch lands, so a login that beats the network isn't blank for 10min
	if [ $((tick % 300)) -eq 0 ] ||
		{ [ ! -s "$weather_cache" ] && [ $((tick % 30)) -eq 0 ]; }; then
		weather_refresh &
	fi

	if [ $((tick % 3)) -eq 0 ]; then
		load_s=$(load)
	fi

	if [ $((tick % 5)) -eq 0 ]; then
		weather_s=$(weather)
		vpn_s=$("$scripts/freebsd/vpn.sh")
	fi

	if [ $((tick % 15)) -eq 0 ]; then
		disk_s=$(disk)
		ram_s=$(ram)
	fi

	line="$weather_s$sep$(volume)$sep$(licht)$sep$load_s"
	line="$line$sep$disk_s$sep$ram_s$sep$vpn_s$sep$("$scripts/freebsd/datetime.sh")"
	if [ "$line" != "$prev" ]; then
		printf '%s\n' "$line" > "$status_fifo"
		prev=$line
	fi

	tick=$((tick + 1))
	sleep 2
done
