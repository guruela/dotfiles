#!/usr/bin/env bash

set -euo pipefail

action=$(gum choose \
  --header "Power Menu" \
  "Shutdown" \
  "Restart" \
  "Logout") || exit 0

case "$action" in
Shutdown)
  sudo -n systemctl poweroff
  ;;
Restart)
  sudo -n systemctl reboot
  ;;
Logout)
  # Log out of the current graphical session
  loginctl terminate-user "$USER"
  ;;
esac
