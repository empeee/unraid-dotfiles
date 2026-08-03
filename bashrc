# .bashrc
# Boot-time dotfiles for unpude (Unraid). See README.md — root filesystem is RAM-only, so
# this repo is re-cloned and re-symlinked on every array start by a User Scripts entry.

shopt -s direxpand

# Colors work regardless of the specific TERM string as long as we have a tty;
# the old TERM whitelist (xterm/screen/xterm-256color only) silently dropped colors
# under Ghostty (TERM=xterm-ghostty).
if [ -t 1 ] && tput setaf 1 &>/dev/null; then
  reset=$(tput sgr0)
  bold=$(tput bold)
  red=$(tput setaf 1)
  yellow=$(tput setaf 3)
  user_color=$yellow
  [ "$UID" -eq 0 ] && user_color=$red

  alias ls='ls --color=auto'
fi

if [ -f "$HOME/.bash_aliases" ]; then
  source "$HOME/.bash_aliases"
fi

umask 002
export HISTCONTROL=ignoredups:ignorespace
shopt -s histappend cdspell

export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR=nvim
alias vim=nvim
alias vi=nvim

command -v eza &>/dev/null && alias ls='eza --icons --group-directories-first'
command -v eza &>/dev/null && alias lsa='eza -lahg --git --icons --group-directories-first'
command -v eza &>/dev/null && alias tree='eza --tree --icons --git --group-directories-first'
command -v bat &>/dev/null && alias cat='bat'
alias grep='grep --color=auto'
alias emergency-prompt="PS1='\\u@\\h \\w \\\$ '"

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
else
  export PS1="${reset}${user_color}[\\u@\\h]${reset} \\w \\n${bold}[\\@]${reset} > "
fi
