#!/usr/bin/env sh

# split date output into weekday, date and time
set -- $(LC_ALL=C date '+%a %d.%m. %H:%M')

wd_en=$1
d=$2
t=$3

case "$wd_en" in
    Mon) wd_de="Mo" ;;
    Tue) wd_de="Di" ;;
    Wed) wd_de="Mi" ;;
    Thu) wd_de="Do" ;;
    Fri) wd_de="Fr" ;;
    Sat) wd_de="Sa" ;;
    Sun) wd_de="So" ;;
    *)   wd_de="$wd_en" ;;
esac

echo " $wd_de $d  $t"

