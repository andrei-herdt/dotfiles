#!/bin/bash

# TODO: Add install_productivity_terminal_tools

exists() {
  command -v $1 >/dev/null 2>&1
}

install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (
    echo
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  ) >>~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

setup_neovim() {
  mkdir -p ~/.config/

  cd ~/.config

  git clone https://github.com/andrei-herdt/neovim-config.git nvim
}

install_brew_packages() {
  echo install some basic command line utilities using brew

  brew_packages="cmake wget clang-format curl git python3 rsync tmux tree neovim xsel zsh the_silver_searcher htop openssh parallel xclip vifm yazi rename fd "

  brew update
  brew install $brew_packages
  unset brew_packages
}

install_essential_macos_packages() {
  echo install some basic command line utilities using brew

  brew_packages="wget curl git python3 rsync tmux tree neovim xsel zsh the_silver_searcher htop openssh xclip vifm yazi rename lazygit fzf fd sshpass git-lfs zellij"

  brew update
  brew install $brew_packages
  unset brew_packages

  brew install --cask ghostty

  echo "rustup"
  curl https://sh.rustup.rs -sSf | sh
}

install_essential_packages() {
  echo install some basic command line utilities using apt

  packages=(
    curl
    git
    python3-dev
    pip
    rsync
    tmux
    tree
    xsel
    zsh
    silversearcher-ag
    htop
    openssh-server
    tmuxinator
    tree
    fuse
    bat
    xclip
    vifm
    yazi
    zathura
    openvpn
    network-manager-openvpn
    network-manager-openvpn-gnome
    git-lfs
    ripgrep
  )

  sudo apt update
  echo ${packages[*]} | xargs sudo apt install --assume-yes
  unset packages

  install_neovim
}

install_packages() {
  echo install some basic command line utilities using apt

  packages=(
    build-essential
    clang-format
    clang-tidy
    cmake
    curl
    exuberant-ctags
    git
    python-dev
    python3-dev
    rsync
    tmux
    tree
    xsel
    zsh
    silversearcher-ag
    redshift
    htop
    openssh-server
    tmuxinator
    tree
    terminator
    meld
    parallel
    xclip
    vifm
    yazi
    rename
    zathura
    gitk
    tig
    openvpn
    network-manager-openvpn
    network-manager-openvpn-gnome
    git-lfs
    nodejs
    npm
    gh
  )

  sudo apt update
  echo ${packages[*]} | xargs sudo apt install --assume-yes
  unset packages

}

install_scripts() {
  echo "install shell scripts"
  sudo cp bin/viag.sh /usr/local/bin/
  sudo cp bin/vifn.sh /usr/local/bin/
  sudo cp bin/vpn.sh /usr/local/bin/

  # per-user, no sudo: needs to write ~/.local/state/theme-mode
  mkdir -p ~/.local/bin
  cp bin/theme ~/.local/bin/
  chmod +x ~/.local/bin/theme
}

configure_ghostty() {
  echo "configure ghostty"
  mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
  cp ghostty/config.ghostty ~/Library/Application\ Support/com.mitchellh.ghostty/config.ghostty
}

configure_zellij() {
  echo "configure zellij"

  cd "$(dirname "${BASH_SOURCE}")"
  mkdir -p ~/.config/zellij
  cp zellij/config.kdl ~/.config/zellij/config.kdl
}

install_oh_my_zsh() {
  if [ -d ~/.oh-my-zsh ]; then
    echo "oh my zsh already installed, skipping"
    return
  fi

  echo "install oh my zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_powerline_symbols() {
  echo "install powerline symbols"
  local POWERLINE_URL="https://github.com/powerline/powerline/raw/develop/font"
  local POWERLINE_SYMBOLS_FILE="PowerlineSymbols.otf"
  local POWERLINE_SYMBOLS_CONF="10-powerline-symbols.conf"

  if [[ ! -e ~/.fonts/$POWERLINE_SYMBOLS_FILE ]]; then
    curl -fsSL $POWERLINE_URL/$POWERLINE_SYMBOLS_FILE -o /tmp/$POWERLINE_SYMBOLS_FILE
    mkdir ~/.fonts 2>/dev/null
    mv /tmp/$POWERLINE_SYMBOLS_FILE ~/.fonts/$POWERLINE_SYMBOLS_FILE
    fc-cache -vf ~/.fonts/
  fi

  if [[ ! -e ~/.config/fontconfig/conf.d/$POWERLINE_SYMBOLS_CONF ]]; then
    curl -fsSL $POWERLINE_URL/$POWERLINE_SYMBOLS_CONF -o /tmp/$POWERLINE_SYMBOLS_CONF
    mkdir -p ~/.config/fontconfig/conf.d 2>/dev/null
    mv /tmp/$POWERLINE_SYMBOLS_CONF ~/.config/fontconfig/conf.d/$POWERLINE_SYMBOLS_CONF
  fi
}

configure_color_scheme() {
  echo "install solarized color scheme"
  local DIR="/tmp/solarized$$"

  if ! exists dconf; then
    echo "Package dconf-cli required for solarized colors!"
    return -1
  fi

  echo Install solarized color scheme
  git clone https://github.com/sigurdga/gnome-terminal-colors-solarized $DIR
  $DIR/install.sh
  rm -rf $DIR
}

install_fzf() {
  echo "install fzf"
  DIR=~/.fzf/

  git clone --depth 1 https://github.com/junegunn/fzf.git $DIR
  cd $DIR
  ./install --all
}

install_googler() {
  DIR=/tmp/googler
  mkdir -p $DIR
  cd $DIR
  git clone https://github.com/jarun/googler.git
  cd googler
  sudo make install
  cd auto-completion/bash/
  sudo cp googler-completion.bash /etc/bash_completion.d/
  rm -rf $DIR
}

install_autojump() {
  DIR=/tmp/autojump
  mkdir -p $DIR
  cd $DIR
  git clone https://github.com/wting/autojump.git
  cd autojump
  ./install.py
  echo "[[ -s /home/andrei/.autojump/etc/profile.d/autojump.sh ]] && source /home/andrei/.autojump/etc/profile.d/autojump.sh" >>~/.bashrc
  rm -rf $DIR
}

install_docker() {
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_neovim() {
  echo "install neovim (latest release, user-local, no sudo)"

  # Ubuntu's apt package lags badly (e.g. 0.9.5 on 24.04, LazyVim needs
  # >=0.11.2), so pull the official prebuilt release straight from GitHub
  # instead of relying on apt or a PPA.
  local NVIM_DIR=~/.local/opt/nvim-linux-x86_64
  local NVIM_TARBALL=/tmp/nvim-linux-x86_64.tar.gz

  curl -fsSL -o "$NVIM_TARBALL" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  mkdir -p ~/.local/opt ~/.local/bin
  rm -rf "$NVIM_DIR"
  tar -xzf "$NVIM_TARBALL" -C ~/.local/opt
  rm -f "$NVIM_TARBALL"

  # ~/.local/bin is ahead of /usr/bin in $PATH, so this symlink shadows
  # an older apt-packaged nvim without touching system packages or sudo.
  ln -sf "$NVIM_DIR/bin/nvim" ~/.local/bin/nvim

  hash -r
  nvim --version | head -1
}

install_lazygit() {
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  FILENAME=lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
  cd ~/Downloads
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/$FILENAME"
  tar -xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
}

install_rust() {
  curl https://sh.rustup.rs -sSf | sh
}

configure_vim() {
  echo configure vim
  DIR=$PWD
  echo $DIR

  cd $DIR
  cp .vimrc ~
  cp .ycm_extra_conf.py ~
  cp -r .vimcache ~

  # never overwrite existing .vimrc.local
  if [ ! -f ~/.vimrc.local ]; then
    cp .vimrc.local ~
  fi

  # install vim plugins
  vim "+PlugInstall" "+qa"

  # compile youcompleteme
  cd ~/.vim/plugged/youcompleteme || exit 1
  ./install.py --clang-completer

  # copy custom snippets
  cd $DIR
  cp -r my_snippets ~/.vim/
}

configure_vifm() {
  echo configure vifm

  rm -rf ~/.config/vifm/colors
  git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors
}

configure_tmux() {
  echo configure tmux

  cd "$(dirname "${BASH_SOURCE}")"
  cp .tmux.conf ~
}

configure_git() {
  echo configure git

  cd "$(dirname "${BASH_SOURCE}")"
  cp .gitconfig_common ~
  cp .gitignore ~
  cp -r .git_template ~

  # never overwrite existing .gitconfig
  if [ ! -f ~/.gitconfig ]; then
    cp .gitconfig ~
  fi
}

configure_zsh() {
  echo configure zsh

  cd "$(dirname "${BASH_SOURCE}")"
  cp .zshrc ~
}

sync_dotfiles() {
  echo "sync dotfiles"

  cd "$(dirname "${BASH_SOURCE}")"

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"

  local stashed=0
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "stashing local changes"
    git stash push -u -m "sync_dotfiles: autostash $(date +%s)"
    stashed=1
  fi

  git fetch origin "$branch"
  if ! git merge --ff-only "origin/$branch"; then
    echo "local and remote history diverged, merging"
    git merge "origin/$branch" --no-edit
  fi

  if [[ $stashed -eq 1 ]]; then
    echo "restoring local changes"
    git stash pop
  fi

  # Reconfigure with whatever changed. These are all plain "cp repo file
  # into \$HOME" steps, so safe to always rerun; heavier/install-like
  # steps (vim, vifm, color scheme) are left out of sync on purpose - run
  # them by number if you actually use them.
  configure_tmux
  configure_git
  configure_zsh
  configure_zellij

  if [[ "$(uname -s)" == "Darwin" ]]; then
    configure_ghostty
  fi

  echo "sync complete"
}

# Only run the interactive/dispatch driver below when this script is
# executed directly (./install.bash), not when it's sourced to reuse a
# function (e.g. `source install.bash && install_neovim`).
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

IFS=', '
if [ -n "$1" ]; then
  # non-interactive: ./install.bash "5,11,13,12"
  array=($1)
else
  read -p "Choose your option(s)
install
    1) apt packages
    2) other packages
    3) scripts
    4) docker
    5) essential apt packages
    6) sync (git pull + reconfigure for this OS)
configure
    10)  vim
    11)  tmux
    12)  git
    13)  zsh
    14)  color scheme
    15)  vifm
    16)  ghostty
    17)  zellij
    19) brew packages
    20) homebrew
    21) essential macos packages
    22) setup neovim
    23) oh_my_zsh
    100)  all
> " -a array
fi

for choice in "${array[@]}"; do
  case "$choice" in
  1)
    install_packages
    ;;
  2)
    install_oh_my_zsh
    install_powerline_symbols
    install_fzf
    install_googler
    install_autojump
    install_docker
    install_neovim
    install_lazygit
    install_rust
    ;;
  3)
    install_scripts
    ;;
  4)
    install_docker
    ;;
  5)
    install_essential_packages
    ;;
  6)
    sync_dotfiles
    ;;
  10)
    configure_vim
    ;;
  11)
    configure_tmux
    ;;
  12)
    configure_git
    ;;
  13)
    configure_zsh
    ;;
  14)
    configure_color_scheme
    ;;
  15)
    configure_vifm
    ;;
  16)
    configure_ghostty
    ;;
  17)
    configure_zellij
    ;;
  19)
    install_brew_packages
    ;;
  20)
    install_homebrew
    ;;
  21)
    install_essential_macos_packages
    ;;
  22)
    setup_neovim
    ;;
  23)
    install_oh_my_zsh
    ;;
  100)
    configure_vim
    configure_vifm
    configure_tmux
    configure_git
    configure_zsh
    configure_color_scheme
    configure_ghostty
    configure_zellij
    ;;
  *)
    echo invalid number
    ;;
  esac
done

fi
