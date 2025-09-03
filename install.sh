#!/bin/bash
set -e

stow -t ~ nvim
stow -t ~ ghostty
stow -t ~ tmux

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  sh ~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi
