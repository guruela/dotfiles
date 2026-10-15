#!/bin/bash
set -e

EVREMAP_DIR="$HOME/.local/share/chezmoi/dot_config/evremap"

# 1. Install evremap-git
yay -S --needed --noconfirm evremap-git

# 2. Install remap configuration
if [[ $(cat /etc/hostname) == "mightytower" ]]; then
  echo "host is mightytower..."
  sudo install -Dm644 \
    "$EVREMAP_DIR/mightytower.toml" \
    /etc/evremap.toml
else
  echo "host is a laptop..."
  sudo install -Dm644 \
    "$EVREMAP_DIR/laptop.toml" \
    /etc/evremap.toml
fi

# 3. Install systemd service
sudo install -Dm644 \
  "$EVREMAP_DIR/evremap.service" \
  /etc/systemd/system/evremap.service

# 4. Load the service if not already
if ! systemctl is-enabled --quiet evremap.service 2>/dev/null; then
  echo "service not enabled, enabling..."
  sudo systemctl daemon-reload
  sudo systemctl enable --now evremap.service
else
  echo "service already enabled, skipping..."
fi
