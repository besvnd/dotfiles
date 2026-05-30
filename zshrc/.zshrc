[ -f $HOME/opt/etc/shrc ] && . $HOME/opt/etc/shrc

alias kubectl="kubecolor"

#export PATH="$PATH:$HOME/sw/jdtls/bin"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
eval "$(starship init zsh)"

export KUBE_EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
