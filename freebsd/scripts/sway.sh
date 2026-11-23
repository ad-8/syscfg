#!/bin/sh
# Usage: sway.sh volume-up|volume-down|volume-mute|bar-toggle [config]
# FreeBSD sway binds, used by freebsd/dotfiles/sway/.config/sway/config and freebsd/dotfiles/mango/.config/mango/config.conf.

step=5%
# SIGRTMIN (65) + "signal": 8 of custom/volume in config-freebsd
waybar_volume_signal=73
bar_config="${2:-$HOME/.config/waybar/config-freebsd}"

volume() {
    mixer "$1" && pkill -"$waybar_volume_signal" -x waybar
}

case "$1" in
    volume-up) volume vol=+"$step" ;;
    volume-down) volume vol=-"$step" ;;
    volume-mute) volume vol.mute=toggle ;;
    bar-toggle) pkill -x waybar || exec waybar -c "$bar_config" ;;
    *)
        echo "usage: $0 volume-up|volume-down|volume-mute|bar-toggle [config]" >&2
        exit 1
        ;;
esac
