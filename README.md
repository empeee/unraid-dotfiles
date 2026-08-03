# unraid-dotfiles

Boot-time dotfiles for `unpude` (Unraid, `root@unpude.home.arpa`).

Unraid boots its root filesystem entirely into RAM from the USB flash drive, so nothing under
`/root` survives a reboot. An Unraid **User Scripts** plugin entry called `SetupDotFiles` runs
on every array start, clones this repo to `~/dotfiles`, and runs `makesymlinks.sh` to symlink
its files into `$HOME`. It also clones
[`nvim-config`](https://github.com/empeee/nvim-config) into `~/src/nvim-config` and symlinks
`~/.config/nvim` to it, so this box gets the same Neovim config used on every other machine.

This repo is public (and this box has no other credentials for git at boot time) so the clone
can run with no auth. Gitea — which hosts `nvim-config`/`starship-config` for every other
machine — runs *on this same box*, so it isn't up yet when the boot script fires; that's why
`nvim-config` needs a GitHub mirror and why `starship.toml` here is a vendored copy rather than
a symlink to the shared `starship-config` repo (it can drift — check
`~/src/starship-config/starship.toml` on another machine if the prompt looks off).

This is the server/appliance equivalent of `home/mark.nix` in the
[`nixos-dotfiles`](https://github.com/empeee/nixos-dotfiles) flake used on the other machines —
same spirit (shell aliases, git config, shared Neovim config, colored prompt), but plain shell
instead of Nix/home-manager, since Unraid's root filesystem isn't a normal persistent Linux
install.

## One-time host setup (not re-run at every boot)

Package installs and the starship binary aren't re-fetched by the boot script — `un-get`
persists its installs via `/boot/extra` automatically, and the starship binary is cached
straight on the persistent `/boot` flash.

```bash
# Neovim + modern CLI tools, via Unraid's un-get (NerdPack) package manager.
# The neovim package doesn't declare its own shared-library deps (Slackware packages
# generally don't do dependency resolution) — luv/lua-lpeg/tree-sitter/utf8proc/unibilium/luajit
# were all needed too, found by iterating `ldd $(command -v nvim) | grep "not found"` until clean.
un-get update
un-get install neovim eza bat fd ripgrep fzf git-delta luv lua-lpeg tree-sitter utf8proc unibilium luajit

# starship prompt (not in un-get's repos) — musl build, fully static
mkdir -p /boot/config/unraid-dotfiles/bin
curl -L https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz \
  | tar xz -C /boot/config/unraid-dotfiles/bin starship
```

If the starship binary ever causes trouble, delete
`/boot/config/unraid-dotfiles/bin/starship` — the boot script skips it gracefully and `bashrc`
falls back to a plain colored prompt. No other changes needed to back out.

## Boot script

The Unraid User Scripts entry (`Settings → User Scripts → SetupDotFiles`, "Run on array
start") should be:

```bash
export HOME=/root

# unraid-dotfiles (bashrc, tmux.conf, gitconfig, aliases, starship.toml)
if [ -d ~/dotfiles ]; then (cd ~/dotfiles && git pull); else git clone https://github.com/empeee/unraid-dotfiles ~/dotfiles; fi
~/dotfiles/makesymlinks.sh

# neovim config (shared across all machines)
mkdir -p ~/src
if [ -d ~/src/nvim-config ]; then (cd ~/src/nvim-config && git pull); else git clone https://github.com/empeee/nvim-config ~/src/nvim-config; fi
mkdir -p ~/.config
ln -sfn ~/src/nvim-config ~/.config/nvim

# starship (static binary cached on persistent /boot flash; skip gracefully if absent).
# /boot is FAT32, which can't carry an executable bit at all, so this checks -f (exists)
# rather than -x, and always chmods after copying onto the RAM root.
if [ -f /boot/config/unraid-dotfiles/bin/starship ]; then
  cp /boot/config/unraid-dotfiles/bin/starship /usr/local/bin/starship
  chmod +x /usr/local/bin/starship
fi
```
