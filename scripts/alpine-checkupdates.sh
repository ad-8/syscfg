#!/bin/sh
doas apk update > /dev/null 2>&1 && apk list -u 2>/dev/null | awk 'BEGIN {
    print "PACKAGE\tORIGIN\tOLD_VER\tNEW_VER"
} {
    if (match($1, /-[0-9][^-]+-r[0-9]+$/)) {
        pkg = substr($1, 1, RSTART-1)
        newver = substr($1, RSTART+1)
    } else {
        pkg = $1; newver = "?"
    }
    origin = $3; sub(/^\{/, "", origin); sub(/\}$/, "", origin)
    oldver = $NF; sub(/\]$/, "", oldver)
    if (match(oldver, /-[0-9][^-]+-r[0-9]+$/)) oldver = substr(oldver, RSTART+1)
    print pkg "\t" origin "\t" oldver "\t" newver
}' | column -t
