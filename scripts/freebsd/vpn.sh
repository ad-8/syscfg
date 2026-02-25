#!/usr/bin/env sh

WGIF="$(wg show interfaces)"

if [ -z "$WGIF" ]; then
    echo "NO VPN"
else
    echo "$WGIF"
fi

