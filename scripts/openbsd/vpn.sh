#!/usr/bin/env sh

WGIF="$(ifconfig wg0 2>/dev/null | grep -Eo '[A-Z]{2}-[0-9]+|muc')"

if [ -z "$WGIF" ]; then
    echo "NO VPN"
else
    echo " $WGIF"
fi

