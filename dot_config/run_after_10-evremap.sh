#!/bin/bash
set -e

EVREMAP_DIR="$HOME/.local/share/chezmoi/dot_config/evremap"

# 1. Install evremap-git
if !command -v evremap &>/dev/null; then
  echo "evremap not found, installing..."
  yay -S --needed --noconfirm evremap-git
fi

# 2. Install remap configuration
sudo install -Dm644 \
  "$EVREMAP_DIR/remap.toml" \
  /etc/remap.toml

# 3. Install systemd service
sudo install -Dm644 \
  "$EVREMAP_DIR/evremap.service" \
  /etc/systemd/system/evremap.service

# Reload systemd after installing the service
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable evremap.service
