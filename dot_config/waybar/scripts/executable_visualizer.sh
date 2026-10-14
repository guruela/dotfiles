#!/usr/bin/env bash

BAR='▁▂▃▄▅▆▇█'

command -v cava >/dev/null 2>&1 || exit 0

cava -p "$HOME/.config/waybar/integrations/cava.conf" 2>/dev/null |
  while IFS=' ' read -r -a levels; do
    out=''
    for lvl in "${levels[@]}"; do
      [[ "$lvl" =~ ^[0-9]+$ ]] || continue
      ((lvl > 7)) && lvl=7
      out+="${BAR:$lvl:1}"
    done
    [[ -n "$out" ]] && printf '%s\n' "$out"
  done
