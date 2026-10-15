#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
readonly MAIN_CSS="$WAYBAR_DIR/style.css"
readonly ACTIVE_IMPORT='@import url("styles/state/sliders.css");'
readonly INACTIVE_IMPORT='/* sliders expanded */'

is_collapsed() {
  grep -Fqx "$ACTIVE_IMPORT" "$MAIN_CSS"
}

replace_import() {
  local current="$1"
  local replacement="$2"

  awk -v current="$current" -v replacement="$replacement" \
    '{ print ($0 == current) ? replacement : $0 }' "$MAIN_CSS" >"$MAIN_CSS.tmp"
  mv "$MAIN_CSS.tmp" "$MAIN_CSS"
}

set_collapsed() {
  replace_import "$INACTIVE_IMPORT" "$ACTIVE_IMPORT"
}

set_expanded() {
  replace_import "$ACTIVE_IMPORT" "$INACTIVE_IMPORT"
}

refresh_waybar() {
  touch "$MAIN_CSS"
  pkill -RTMIN+8 waybar 2>/dev/null || true
}

print_state() {
  if is_collapsed; then
    printf '{"text":"","class":"collapsed","tooltip":"Show sliders"}\n'
  else
    printf '{"text":"","class":"expanded","tooltip":"Hide sliders"}\n'
  fi
}

case "${1:-state}" in
  state)
    print_state
    ;;
  toggle)
    if is_collapsed; then
      set_expanded
    else
      set_collapsed
    fi
    refresh_waybar
    ;;
  *)
    printf 'Usage: %s [state|toggle]\n' "${0##*/}" >&2
    exit 2
    ;;
esac
