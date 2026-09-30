#!/bin/bash
set -e

EVREMAP_DIR="$HOME/.local/share/chezmoi/dot_config/evremap"

# 1. Install evremap-git
yay -S --needed --noconfirm evremap-git

# 2. Install remap configuration
sudo install -Dm644 \
  "$EVREMAP_DIR/evremap.toml" \
  /etc/evremap.toml

# 3. Install systemd service
sudo install -Dm644 \
  "$EVREMAP_DIR/evremap.service" \
  /etc/systemd/system/evremap.service

# Reload systemd after installing the service
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable evremap.service
