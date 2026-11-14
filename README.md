# My dotfiles for zsh, tmux, zellij, git and neovim

**Warning:** If you want to give these dotfiles a try, you should first fork
this repository, review the code, and remove things you don't want or need.
Don't blindly use my settings unless you know what that entails. Use at your
own risk!

## Install

Clone the repository.
```bash
git clone git@github.com:andrei-herdt/dotfiles.git
cd dotfiles
```

Run the install script.
```bash
./install.bash
```

Select the things you want. On a Mac that is mainly an ssh client into
workstations, `./install.bash 31` does it all: Homebrew, a slim package set
(git, fzf, fd, bat, eza, rsync, ssh tools, Neovim, Ghostty), zsh + `dl`, the
Neovim config, the Ghostty config, an ssh config template and trimmed macOS
defaults (`.macos-ssh`, no sudo). Heavier local tools (tmux, zellij, lazygit,
yazi, ...) are option `27`. On a Linux dev machine use `30`.

### Copying files to a workstation: `dl`

Put `DL_HOST=user@workstation` in `~/.zshrc.local` (never committed). Then
`dl **<Tab>` opens an fzf picker (Downloads first, newest first, then the rest
of `~`), `dl -l` sends the latest download, `dl <name>` looks in `~/Downloads`,
and `ws` ssh-es to the same host. Hosts for plain ssh go in `~/.ssh/config.local`.

### Fresh Linux machine in one step

On Ubuntu/Debian, `./install.bash 30` sets up the whole dev environment:
git, vim, tmux, zsh with Oh My Zsh, Neovim with its config and dependencies,
and the tmux, zellij, vim and zsh configs. It asks for your `sudo` password,
so run it in a normal terminal. It skips `.gitconfig` (your git identity) and
the YouCompleteMe build; run `./install.bash 12` or `10` for those.
Machine-specific shell settings go in `~/.zshrc.local`, which is never
overwritten.

### Not handled by install.bash

A couple of pieces aren't wired into the installer and need a manual step:

- **Neovim** has its own installer option. On Linux, run `./install.bash 26`
  to install the dependencies the config needs (compiler, node, fd, fzf,
  ripgrep, xclip, lazygit, tree-sitter), the latest nvim release, the config
  from the separate
  [neovim-config](https://github.com/andrei-herdt/neovim-config) repo, and its
  plugins and Treesitter parsers. On macOS the equivalent packages come with
  option 21, and `./install.bash 22` clones the config.
- **Zellij config** is tracked here but only ever copied, never symlinked:
  ```bash
  mkdir -p ~/.config/zellij
  cp zellij/config.kdl ~/.config/zellij/config.kdl
  ```

Everything `install.bash` does works the same way — it `cp`s files into
`$HOME` once at install time. There is no symlinking, so if you edit a
config after install, copy the change back into this repo and commit/push
it manually, on whichever file changed.

## What goes where: workstation vs. MacBook

The setup assumes two roles. The **workstation** (Linux) is where the work
happens: editors, multiplexers, compilers, long-running sessions. The
**MacBook** is a thin frontend: a good terminal, ssh, and a few helpers for
moving files. Keep the Mac lean and put anything heavy on the workstation.

| | Workstation (Linux) | MacBook (frontend) |
|---|---|---|
| Installer | `./install.bash 30` | `./install.bash 31` |
| Terminal | none, it is reached over ssh | Ghostty (`ghostty/config.ghostty`) |
| Shell | zsh + Oh My Zsh, `.zshrc` | zsh, `.zshrc` (works without Oh My Zsh) |
| Multiplexer | tmux and zellij: sessions live here and survive disconnects | not needed |
| Editor | Neovim + `neovim-config`, vim | Neovim + `neovim-config` (files get opened locally too) |
| Dev tooling | compiler, node, ripgrep, fd, lazygit, tree-sitter CLI, ccache | ripgrep and tree-sitter CLI for the Neovim config only |
| CLI helpers | bat, eza, fzf | fzf, fd, bat, eza, tree, htop |
| Transfer / network | openssh-server | `rsync` (macOS ships a very old one), `openssh`, `sshpass`, `dl`, `ws` |
| Config | `.tmux.conf`, `zellij/config.kdl`, `.vimrc`, `.gitconfig` | `ghostty/config.ghostty`, `ssh/config`, `.macos-ssh` |
| Clipboard | tmux/zellij send OSC 52 (`set-clipboard on`, no `copy_command`) | Ghostty receives it, so remote copies land in the Mac clipboard |
| Always-on box | option `18` (wifi watchdog, power save off) | n/a |

How the pieces fit:

- **Clipboard over ssh:** copying inside tmux or zellij on the workstation
  reaches the Mac clipboard through OSC 52, which Ghostty supports. Do not set
  `copy_command` to `xclip`/`pbcopy` in zellij: that would target the
  clipboard of the machine zellij runs on.
- **Terminfo:** Ghostty installs its terminfo on the remote host on first
  connect (`shell-integration-features = ssh-terminfo,ssh-env`). Do not force
  `TERM=xterm`.
- **ssh:** `ssh/config` enables connection reuse, so repeated `ssh`/`scp`/`dl`
  to the same host are instant after the first. Put hosts in
  `~/.ssh/config.local` and `DL_HOST` in `~/.zshrc.local`, both untracked.
- **Machine-specific files** (never committed or overwritten): `~/.zshrc.local`,
  `~/.ssh/config.local`, `~/.gitconfig`.
- **Working locally on a Mac more heavily?** `./install.bash 27` adds tmux,
  zellij, lazygit, yazi and friends. Aliases for tools that are not installed
  (`lg`, `z`, `y`) are skipped automatically.
- **Keeping in sync:** `./install.bash 6` pulls and re-applies the config
  steps on either kind of machine.

## Your private configuration

The following files are reserved for your private local configuration:
 - `~/.vimrc.local`
 - `~/.gitconfig`

They won't be overwritten if they exist.

## Feedback

Feel free to leave your [suggestions/improvements](https://github.com/andrei-herdt/dotfiles/issues)!

## Thanks to…

* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
