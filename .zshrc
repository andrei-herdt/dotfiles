# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bira"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(vi-mode docker git web-search z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export EDITOR='nvim'

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
eval `dircolors ~/.dir_colors/dircolors`

alias t='tmux attach || tmux new'
alias tt='tmux attach -t 1 || tmux new -t 0'
alias cclip='xclip -selection clipboard'
alias git='git --no-pager'
alias zshconfig="vi ~/.zshrc"
alias vimconfig="vi ~/.vimrc"
alias fn='find . -name'
alias viag='/usr/local/bin/viag.sh'

export PATH="/usr/lib/ccache:$PATH"

export KEYTIMEOUT=1

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.fzf.zsh

# {{{1 vi mode cursor indicator
function zle-keymap-select zle-line-init
{
    # change cursor shape
    if [[ -n "$TMUX" ]]; then  # tmux
      case $KEYMAP in
          vicmd)      print -n '\033[0 q';; # block cursor
          viins|main) print -n '\033[6 q';; # line cursor
      esac
    else # iTerm2
      case $KEYMAP in 
          vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;  # block cursor
          viins|main) print -n -- "\E]50;CursorShape=1\C-G";;  # line cursor
      esac
    fi

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    if [[ -n "$TMUX" ]]; then # tmux
      print -n -- '\033[0 q'  # block cursor
    else # iTerm2
      print -n -- "\E]50;CursorShape=0\C-G"  # block cursor
    fi
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# taskwarrior
alias in='task add +in'
alias today='task add +today'
export PS1='$(task +in +PENDING count) '$PS1
tickle () {
    deadline=$1
    shift
    in +tickle wait:$deadline $@
}
alias tick=tickle
alias think='tickle +1d'
alias rnd='task add +rnd'
alias p='task proj:$1'

webpage_title (){
    wget -qO- "$*" | hxselect -s '\n' -c  'title' 2>/dev/null
}

read_and_review (){
    link="$1"
    title=$link
    echo $title
    descr="\"Read and review: $title\""
    id=$(task add +next +rnr "$descr" | sed -n 's/Created task \(.*\)./\1/p')
    task "$id" annotate "$link"
}

alias rnr=read_and_review

# autojump
[[ -s /home/andrei/.autojump/etc/profile.d/autojump.sh ]] && source /home/andrei/.autojump/etc/profile.d/autojump.sh

autoload -U compinit && compinit -u

dockerexec (){
    docker exec -it $1 /bin/zsh
}
alias dex=dockerexec
