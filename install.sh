#!/bin/bash
set -e

stow -t ~ nvim
stow -t ~ ghostty
stow -t ~ tmux
stow -t ~ starship
stow -t ~ zshrc

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  sh ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi
