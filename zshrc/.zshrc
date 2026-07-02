[ -f $HOME/opt/etc/shrc ] && . $HOME/opt/etc/shrc

alias kubectl="kubecolor"

#export PATH="$PATH:$HOME/sw/jdtls/bin"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
eval "$(starship init zsh)"

export KUBE_EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
 
set -o vi

# yazi: change to cwd when exiting
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
