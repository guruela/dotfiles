#!/usr/bin/env bash
set -e

# 1. Install yay
if ! command -v yay &>/dev/null; then
  echo "yay not found, installing..."
  sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
else
  echo "yay already installed, skipping..."
fi

# 2. Install packages
echo "installing packages..."

packages=(
  git
  github-cli
  ghostty
  neovim
  tmux
  zsh
  ripgrep
  fd
  fzf
  eza
  zoxide
  zsh-autocomplete
  zsh-patina-git
  opencode
)

yay -S --needed --noconfirm "${packages[@]}"
