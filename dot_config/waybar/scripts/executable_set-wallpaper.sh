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

colors_css=~/.config/waybar/styles/generated/colors.css
active_border=$(sed -nE 's/^@define-color accent (#[[:xdigit:]]{6});$/\1/p' "$colors_css")
inactive_border=$(sed -nE 's/^@define-color text_inactive (#[[:xdigit:]]{6});$/\1/p' "$colors_css")

if [[ ! $active_border =~ ^#[[:xdigit:]]{6}$ || ! $inactive_border =~ ^#[[:xdigit:]]{6}$ ]]; then
  printf 'Could not extract Hyprland border colors from %s\n' "$colors_css" >&2
  exit 1
fi

printf 'wallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n' "$image" >~/.config/hypr/wallpapers/wallpaper.conf

mkdir -p ~/.config/hypr/generated
printf 'return {\n\tactive_border = "rgba(%sff)",\n\tinactive_border = "rgba(%saa)",\n}\n' \
  "${active_border#\#}" "${inactive_border#\#}" >~/.config/hypr/generated/border_colors.lua

hyprctl hyprpaper wallpaper ", $image, cover" >/dev/null
hyprctl eval "hl.config({ general = { col = { active_border = \"rgba(${active_border#\#}ff)\", inactive_border = \"rgba(${inactive_border#\#}aa)\" } } })" >/dev/null

killall -SIGUSR2 waybar >/dev/null 2>&1

printf 'Wallpaper, Waybar palette, and Hyprland borders updated: %s\n' "$image"
