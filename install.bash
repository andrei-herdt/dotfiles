#!/bin/bash

exists() {
  command -v $1 >/dev/null 2>&1
}

install_packages() {
echo install some basic command line utilities using apt

packages=(
build-essential
clang-format
clang-tidy
cmake
curl
dconf-cli
exuberant-ctags
git
python-dev
python3-dev
rsync
tmux
tree
vim-gnome
xsel
zsh
taskwarrior
taskd
bugwarrior
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
python-pip
gnome-tweak-tool
vifm
rename
zathura
)

sudo apt update
echo ${packages[*]} | xargs sudo apt install --assume-yes
unset packages;

}

install_scripts() {
    echo "install shell scripts"
    sudo cp bin/viag.sh /usr/local/bin/
    sudo cp bin/vifn.sh /usr/local/bin/
}

install_oh_my_zsh() {
    echo "install oh my zsh"
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

install_powerline_symbols() {
    echo "install powerline symbols"
    local POWERLINE_URL="https://github.com/powerline/powerline/raw/develop/font"
    local POWERLINE_SYMBOLS_FILE="PowerlineSymbols.otf"
    local POWERLINE_SYMBOLS_CONF="10-powerline-symbols.conf"

    if [[ ! -e ~/.fonts/$POWERLINE_SYMBOLS_FILE ]]; then
        curl -fsSL $POWERLINE_URL/$POWERLINE_SYMBOLS_FILE -o /tmp/$POWERLINE_SYMBOLS_FILE
        mkdir ~/.fonts 2> /dev/null
        mv /tmp/$POWERLINE_SYMBOLS_FILE ~/.fonts/$POWERLINE_SYMBOLS_FILE
        fc-cache -vf ~/.fonts/
    fi

    if [[ ! -e ~/.config/fontconfig/conf.d/$POWERLINE_SYMBOLS_CONF ]]; then
        curl -fsSL $POWERLINE_URL/$POWERLINE_SYMBOLS_CONF -o /tmp/$POWERLINE_SYMBOLS_CONF
        mkdir -p ~/.config/fontconfig/conf.d 2> /dev/null
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

install_atom() {
    echo "install atom"
    curl -sL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
    sudo apt update
    sudo apt install atom
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

install_google_chrome() {
    DIR=/tmp/google_chrome
    mkdir -p $DIR
    cd $DIR
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    cd
    rm -rf $DIR
}

install_autojump() {
    DIR=/tmp/autojump
    mkdir -p $DIR
    cd $DIR
    git clone git@github.com:wting/autojump.git
    cd autojump
    ./install.py
    rm -rf $DIR
}

install_gdbgui() {
    pip install gdbgui
}

configure_vim() {
    echo configure vim

    cd "$(dirname "${BASH_SOURCE}")";
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
}

configure_vifm() {
    echo configure vifm

    rm -rf ~/.config/vifm/colors
    git clone https://github.com/vifm/vifm-colors ~/.config/vifm/colors
}

configure_tmux() {
    echo configure tmux

    cd "$(dirname "${BASH_SOURCE}")";
    cp .tmux.conf ~
}

configure_git() {
    echo configure git

    cd "$(dirname "${BASH_SOURCE}")";
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

    cd "$(dirname "${BASH_SOURCE}")";
    cp .zshrc ~
}

configure_taskwarrior() {
    echo configure taskwarrior

    cd "$(dirname "${BASH_SOURCE}")";
    cp .taskrc ~

}

configure_taskd() {
    echo configure taskd
    export TASKDDATA=~/.config/taskd
    mkdir -p $TASKDDATA
    taskd init
    cp -r /usr/share/taskd/pki $TASKDDATA
    cd "$(dirname "${BASH_SOURCE}")";
    cp vars $TASKDDATA/pki/
    cd $TASKDDATA/pki/
    echo "CN=`hostname -f`" >> vars
    ./generate
    cp *.pem $TASKDDATA
    taskd config --force client.cert $TASKDDATA/client.cert.pem
    taskd config --force log $PWD/taskd.log
    taskd config --force pid.file $PWD/taskd.pid
    taskd config --force server localhost:53589
    taskd config
}

IFS=', '
read -p "Choose your option(s)
install
    1) apt packages
    2) other packages
    3) scripts
configure
    10)  vim
    11)  tmux
    12)  git
    13)  zsh
    14)  color scheme
    15)  vifm
    16)  taskwarrior
    17)  taskd
    18)  all
> " -a array

for choice in "${array[@]}"; do
    case "$choice" in
        1)
            install_packages
            ;;
        2)
            install_oh_my_zsh
            install_powerline_symbols
            install_fzf
            install_atom
            install_googler
            install_google_chrome
            install_gdbgui
            install_autojump
            ;;
        3)
            install_scripts
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
            configure_taskwarrior
            ;;
        17)
            configure_taskd
            ;;
        18)
            configure_vim
            configure_vifm
            configure_tmux
            configure_git
            configure_zsh
            configure_color_scheme
            ;;
        *)
            echo invalid number
            ;;
    esac
done
