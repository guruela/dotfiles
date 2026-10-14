#!/usr/bin/env bash
set -euo pipefail

if (($# != 1)); then
  printf 'Usage: %s IMAGE\n' "${0##*/}" >&2
  exit 2
fi

for command in wallust hyprctl realpath flock; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Missing dependency: %s\n' "$command" >&2
    exit 1
  }
done

case "$1" in
*$'\n'* | *$'\r'*)
  printf 'Wallpaper path cannot contain newlines.\n' >&2
  exit 2
  ;;
*,*)
  printf 'Wallpaper path cannot contain commas.\n' >&2
  exit 2
  ;;
esac

[[ -f "$1" ]] || {
  printf 'Wallpaper is not a file: %s\n' "$1" >&2
  exit 2
}
image=$(realpath -- "$1")

waybar_dir=${XDG_CONFIG_HOME:-$HOME/.config}/waybar
hypr_dir=${XDG_CONFIG_HOME:-$HOME/.config}/hypr
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/wallust
palette_source=$cache_dir/waybar-colors.css
palette_target=$waybar_dir/styles/generated/colors.css
wallpaper_target=$hypr_dir/hyprpaper.d/current.conf
lock_file=${XDG_RUNTIME_DIR:-$waybar_dir}/waybar-wallpaper.lock
required=(
  bar_bg tooltip_bg surface_subtle text_primary text_secondary
  text_disabled text_inactive accent accent_fg warning success danger
  danger_fg bar_border tooltip_border slider_track bar_shadow
  accent_glow_soft accent_glow_strong
)

mkdir -p "$cache_dir" "${wallpaper_target%/*}"
exec 9>"$lock_file"
flock 9

wallust run --skip-sequences --no-hooks --no-templated-hooks --quiet "$image"
[[ -s "$palette_source" ]] || {
  printf 'Wallust did not generate a Waybar palette.\n' >&2
  exit 1
}

for role in "${required[@]}"; do
  grep -Eq "^@define-color[[:space:]]+$role[[:space:]]+[^;]+;$" "$palette_source" || {
    printf 'Generated palette is missing a valid %s role.\n' "$role" >&2
    exit 1
  }
done

palette_tmp=$(mktemp "${palette_target%/*}/.colors.css.XXXXXX")
wallpaper_tmp=$(mktemp "${wallpaper_target%/*}/.current.conf.XXXXXX")
trap 'rm -f "$palette_tmp" "$wallpaper_tmp"' EXIT

cp -- "$palette_source" "$palette_tmp"
printf 'wallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n' "$image" >"$wallpaper_tmp"

hyprctl hyprpaper wallpaper ", $image, cover" >/dev/null
mv -f -- "$palette_tmp" "$palette_target"
mv -f -- "$wallpaper_tmp" "$wallpaper_target"
touch "$waybar_dir/style.css"
trap - EXIT

killall -SIGUSR2 waybar

printf 'Wallpaper and Waybar palette updated: %s\n' "$image"
