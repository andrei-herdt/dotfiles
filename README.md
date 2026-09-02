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

- **Neovim config** lives in a separate repo, not in this one:
  ```bash
  mkdir -p ~/.config && cd ~/.config
  git clone git@github.com:andrei-herdt/neovim-config.git nvim
  ```
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
