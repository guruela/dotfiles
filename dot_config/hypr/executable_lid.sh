#!/usr/bin/env zsh

if [[ "$(hyprctl monitors)" =~ "\sDP-[0-9]+" ]]; then
  if [[ $1 == "open" ]]; then
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = false })'
  else
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
  fi
fi
