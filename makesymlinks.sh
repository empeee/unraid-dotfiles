#!/bin/bash
# Symlinks this repo's dotfiles into $HOME. Run from the boot-time SetupDotFiles User Script
# on unpude (Unraid) — see README.md for why this exists.
set -e

dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

for f in bashrc bash_profile bash_aliases gitconfig tmux.conf; do
  ln -sfn "$dir/$f" "$HOME/.$f"
done

mkdir -p "$HOME/.config"
ln -sfn "$dir/starship.toml" "$HOME/.config/starship.toml"

# Retire the old Vundle-based vimrc: nvim (aliased from vim/vi in bashrc) is now the editor.
# A leftover symlink here would make plain /usr/bin/vim fail on a missing Vundle path.
rm -f "$HOME/.vimrc"
