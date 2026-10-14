#!/usr/bin/env bash
set -euo pipefail

image=$(realpath -- "$1")

if ! command -v wallust >/dev/null; then
  echo "wallust is not installed. Please install it first."
  exit 1
else
  wallust run --skip-sequences --no-hooks --no-templated-hooks --quiet "$image"
fi

if [ -d ~/.config/waybar/styles/generated ]; then
  cp ~/.cache/wallust/waybar-colors.css ~/.config/waybar/styles/generated/colors.css
else
  mkdir -p ~/.config/waybar/styles/generated/
  cp ~/.cache/wallust/waybar-colors.css ~/.config/waybar/styles/generated/colors.css
fi

printf 'wallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n' "$image" >~/.config/hypr/wallpapers/wallpaper.conf

hyprctl hyprpaper wallpaper ", $image, cover" >/dev/null

killall -SIGUSR2 waybar >/dev/null 2>&1

printf 'Wallpaper and Waybar palette updated: %s\n' "$image"
