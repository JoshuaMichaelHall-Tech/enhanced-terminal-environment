# Enhanced Terminal Environment Aliases
# Comprehensive shortcuts for terminal-based development

#-------------------------------------------------------------
# Core Shell Aliases
#-------------------------------------------------------------

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# List directories
alias ls="ls -G"
alias l="ls -lah"
alias ll="ls -lh"
alias la="ls -lAh"

# Use exa for listing if available (modern replacement for ls)
if command -v exa &> /dev/null; then
  alias ls="exa"
  alias l="exa -la --git"
  alias ll="exa -l --git"
  alias la="exa -la --git"
  alias lt="exa -T --git --level=2"
fi

# Directory operations
alias md='mkdir -p'
alias rd='rmdir'

# File operations
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"

# Show/hide files in macOS Finder
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

#-------------------------------------------------------------
# Editor Aliases
#-------------------------------------------------------------

# Neovim
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias sv="sudo nvim"

# Convenience edit aliases
alias zshrc="$EDITOR ~/.zshrc"
alias aliases="$EDITOR ~/.zsh/aliases.zsh"
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias vimconf="$EDITOR ~/.config/nvim/init.lua"

#-------------------------------------------------------------
# Git Aliases
#-------------------------------------------------------------

alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -m"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gds="git diff --staged"
alias gf="git fetch"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline"
alias glog="git log --oneline --graph --decorate"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gm="git merge"
alias gr="git remote"
alias grv="git remote -v"
alias grs="git reset"
alias grsh="git reset --hard"
alias gst="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"

# GitHub CLI aliases
alias ghpr="gh pr create"
alias ghprl="gh pr list"
alias ghprc="gh pr checkout"
alias ghi="gh issue create"
alias ghil="gh issue list"
alias ghic="gh issue checkout"
alias ghr="gh repo"
alias ghrc="gh repo create"

#-------------------------------------------------------------
# Docker Aliases
#-------------------------------------------------------------

alias d="docker"
alias dc="docker-compose"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcl="docker-compose logs -f"
alias dcp="docker-compose pull"
alias dcr="docker-compose restart"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias drmi="docker rmi"
alias drm="docker rm"
alias dprune="docker system prune -a"

#-------------------------------------------------------------
# Tmux Aliases
#-------------------------------------------------------------

alias t="tmux"
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tk="tmux kill-session -t"
alias tka="tmux kill-server"

#-------------------------------------------------------------
# Python Aliases
#-------------------------------------------------------------

alias py="python3"
alias pip="pip3"
alias pyenv="python -m venv venv"
alias pyact="source venv/bin/activate"
alias pyreq="pip freeze > requirements.txt"
alias pyinstall="pip install -r requirements.txt"
alias pytest="python -m pytest"
alias pylint="python -m pylint"
alias pyhttp="python -m http.server"

# Poetry aliases
alias po="poetry"
alias posh="poetry shell"
alias poru="poetry run"
alias poin="poetry install"
alias poad="poetry add"
alias poaddr="poetry add --dev"
alias pour="poetry update"
alias porm="poetry remove"

#-------------------------------------------------------------
# Node.js / NPM / Yarn Aliases
#-------------------------------------------------------------

alias n="node"
alias ni="npm install"
alias nid="npm install --save-dev"
alias nig="npm install -g"
alias nr="npm run"
alias nrs="npm run start"
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrt="npm run test"
alias nrc="npm run clean"
alias nout="npm outdated"
alias nup="npm update"

# Yarn aliases
alias y="yarn"
alias ya="yarn add"
alias yad="yarn add --dev"
alias yap="yarn add --peer"
alias yrm="yarn remove"
alias yr="yarn run"
alias ys="yarn start"
alias yd="yarn dev"
alias yb="yarn build"
alias yt="yarn test"
alias yc="yarn clean"

#-------------------------------------------------------------
# Ruby / Rails / Bundle Aliases
#-------------------------------------------------------------

alias be="bundle exec"
alias bi="bundle install"
alias bu="bundle update"
alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias rdb="bundle exec rails db:migrate"
alias rdbr="bundle exec rails db:rollback"
alias rdbs="bundle exec rails db:seed"
alias rt="bundle exec rails test"
alias rr="bundle exec rspec"
alias ru="bundle exec rubocop"
alias gf="gem install"

#-------------------------------------------------------------
# Database Aliases
#-------------------------------------------------------------

# PostgreSQL
alias pgstart="pg_ctl -D /usr/local/var/postgres start"
alias pgstop="pg_ctl -D /usr/local/var/postgres stop"
alias pgstatus="pg_ctl -D /usr/local/var/postgres status"

# MongoDB
alias mgs="mongod --dbpath ~/data/db"
alias mgc="mongo"

#-------------------------------------------------------------
# Network Aliases
#-------------------------------------------------------------

alias myip="curl http://ipecho.net/plain; echo"
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ports="netstat -tulanp"
alias ping="ping -c 5"
alias wget="wget -c"
alias https="http --default-scheme=https"

#-------------------------------------------------------------
# System Aliases
#-------------------------------------------------------------

alias df="df -h"
alias du="du -h"
alias free="free -m"
alias meminfo="free -m -l -t"
alias psmem="ps auxf | sort -nr -k 4"
alias pscpu="ps auxf | sort -nr -k 3"
alias psg="ps aux | grep -v grep | grep -i -e"

#-------------------------------------------------------------
# Utility Aliases
#-------------------------------------------------------------

# Grep with color
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# History with grep
alias h="history"
alias hg="history | grep"

# Reload shell
alias reload="exec $SHELL -l"

# Edit and source aliases for quick updates
alias ea="$EDITOR ~/.zsh/aliases.zsh && source ~/.zsh/aliases.zsh"

# Get week number
alias week="date +%V"

# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

# Create a backup of a file
bak() {
  cp "$1"{,.bak}
}

# Extract common archive formats
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar e "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
