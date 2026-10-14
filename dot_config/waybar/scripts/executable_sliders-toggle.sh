#!/usr/bin/env bash

DIR="$HOME/.config/waybar"
CSS="$DIR/styles/state/sliders.css"
MAIN="$DIR/style.css"

read -r -d '' COLLAPSE_RULES <<'CSS'
/* collapsed */
window#waybar #pulseaudio,
window#waybar #pulseaudio-slider,
window#waybar #backlight,
window#waybar #backlight-slider {
  opacity: 0;
  font-size: 0;
  min-width: 0;
  min-height: 0;
  margin: 0;
  padding: 0;
  background: transparent;
  border: none;
}

window#waybar #pulseaudio-slider slider,
window#waybar #pulseaudio-slider trough,
window#waybar #pulseaudio-slider highlight,
window#waybar #backlight-slider slider,
window#waybar #backlight-slider trough,
window#waybar #backlight-slider highlight {
  min-width: 0;
  min-height: 0;
  margin: 0;
  padding: 0;
  border: none;
}
CSS

is_collapsed() {
  grep -q "collapsed" "$CSS" 2>/dev/null
}

case "${1:-state}" in
toggle)
  if is_collapsed; then
    : >"$CSS.tmp" && mv "$CSS.tmp" "$CSS"
  else
    printf '%s\n' "$COLLAPSE_RULES" >"$CSS.tmp" && mv "$CSS.tmp" "$CSS"
  fi
  touch "$MAIN" # mtime bump -> waybar reloads the stylesheet
  pkill -RTMIN+8 waybar 2>/dev/null || true
  ;;
*)
  if is_collapsed; then
    printf '{"text": "", "class": "collapsed", "tooltip": "Show sliders"}\n'
  else
    printf '{"text": "", "class": "expanded", "tooltip": "Hide sliders"}\n'
  fi
  ;;
esac
