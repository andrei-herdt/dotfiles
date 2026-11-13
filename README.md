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

Select the things you want. On a fresh macOS machine, a good starting
selection is: `20,21,13,11,12` (Homebrew, essential macOS packages, zsh,
tmux, git).

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

## Your private configuration

The following files are reserved for your private local configuration:
 - `~/.vimrc.local`
 - `~/.gitconfig`

They won't be overwritten if they exist.

## Feedback

Feel free to leave your [suggestions/improvements](https://github.com/andrei-herdt/dotfiles/issues)!

## Thanks to…

* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
