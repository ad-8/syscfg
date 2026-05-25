#!/usr/bin/env sh

wg0_status="$(ifconfig wg0 2>/dev/null | awk '/description:/ {print $NF}')"
wg1_status="$(ifconfig wg1 2>/dev/null | awk '/description:/ {print $NF}')"

if [ -n "$wg0_status" ] && [ -n "$wg1_status" ]; then
    echo " $wg0_status + $wg1_status"
elif [ -n "$wg0_status" ]; then
    echo " $wg0_status"
elif [ -n "$wg1_status" ]; then
    echo " $wg1_status"
else
    echo "NO VPN"
fi
