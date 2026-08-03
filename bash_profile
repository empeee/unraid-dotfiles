# .bash_profile
# SSH sessions start as login shells, which bash only sources this file for
# (not .bashrc) — so .bashrc (aliases, prompt, PATH tweaks) is pulled in explicitly below.
export PATH="$HOME/.local/bin:$PATH"

[ -n "$PS1" ] && [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
