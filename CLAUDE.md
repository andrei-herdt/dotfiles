# CLAUDE.md

Instructions for an agent setting up this environment on a new machine.

## What this repo is

Personal dotfiles for zsh, tmux, zellij, and git. `install.bash` is an
interactive menu script that `cp`s files from this repo into `$HOME` —
**there is no symlinking**. Once copied, the live file and the repo file
are independent; changes made on a machine after install do not
automatically flow back here.

Neovim config is a **separate** repo (`andrei-herdt/neovim-config`), not
part of this one.

## Bootstrap steps (macOS)

1. **SSH key**, if this machine doesn't already have one added to GitHub:
   ```bash
   ssh-keygen -t ed25519 -C "andrei.herdt@gmail.com"
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```
   Add `~/.ssh/id_ed25519.pub` to the user's GitHub account, then confirm:
   ```bash
   ssh -T git@github.com
   ```
   If you can't add a key interactively (no browser/user present), ask the
   user to add it rather than proceeding over HTTPS — HTTPS git auth has
   previously failed in sandboxed/non-interactive shells on this user's
   machines (no TTY for the credential prompt).

2. **Clone this repo**:
   ```bash
   mkdir -p ~/devel && cd ~/devel
   git clone git@github.com:andrei-herdt/dotfiles.git
   cd dotfiles
   ```

3. **Run the installer** and pick, in order: `20` (Homebrew), `21`
   (essential macOS packages — installs zellij, neovim, tmux, fzf,
   lazygit, ghostty, rustup, etc. via brew), `13` (zsh), `11` (tmux), `12`
   (git):
   ```bash
   ./install.bash
   ```
   This is an interactive `read -p`; pass the numbers when prompted
   (comma or space separated), e.g. `20,21,13,11,12`.

   Do **not** select `100` ("all") expecting it to be complete — it skips
   `20`/`21`/`22`/`23` (Homebrew, brew packages, neovim, oh-my-zsh) and
   covers configure-only steps.

   Skip `10` (vim) and `15` (vifm) unless the user says they use them —
   `~/.vimrc` and `~/.p10k.zsh` are not part of this user's current setup.

4. **Neovim config** (not covered by `install.bash`):
   ```bash
   mkdir -p ~/.config && cd ~/.config
   git clone git@github.com:andrei-herdt/neovim-config.git nvim
   ```
   Open `nvim` once afterward so `lazy.nvim` installs plugins.

5. **Zellij config** (tracked here, but not copied by `install.bash`):
   ```bash
   mkdir -p ~/.config/zellij
   cp ~/devel/dotfiles/zellij/config.kdl ~/.config/zellij/config.kdl
   ```

## Things to never do

- **Never overwrite `~/.gitconfig`** if it already exists. It's
  intentionally per-machine (e.g. different email for work vs. personal
  machines) and `install.bash`'s `configure_git` already guards this —
  don't bypass that guard by `cp`-ing it manually.
- Don't assume config files are symlinked. If you edit
  `~/.config/zellij/config.kdl` or `~/.zshrc` etc. after install, copy the
  change back into this repo (`cp <live path> <repo path>`) and commit —
  the repo will not pick it up on its own.
- Prefer the SSH remote (`git@github.com:...`) over HTTPS for this repo
  and `neovim-config` — HTTPS push has failed here before due to no
  working credential helper in non-interactive shells.

## Verifying the result

After setup, a quick sanity check:
```bash
zellij -V && nvim --version | head -1 && tmux -V
zsh -ic 'alias | grep -c .'   # aliases from .zshrc loaded
```
