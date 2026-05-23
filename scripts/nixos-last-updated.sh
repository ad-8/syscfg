#!/usr/bin/env sh

cd ~/syscfg/nixos-config || exit 1
date=$(git log -1 --pretty=%ci -- flake.lock)
[ -z "$date" ] && exit 1

echo "$date" | gawk '
{
  split($1, d, "-")
  dstr = d[3]"."d[2]". "substr($2,1,5)
  cmd = "date -d \""$0"\" +%s"
  cmd | getline ts
  close(cmd)
  now = systime()
  age = now - ts
  printf "%s — \033[32m%dd %dh ago\033[0m\n", dstr, age/86400, age%86400/3600
}'

