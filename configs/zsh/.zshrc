# Enhanced Terminal Environment Zsh Configuration
# A comprehensive configuration for terminal-based development

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  docker
  docker-compose
  npm
  python
  pip
  ruby
  bundler
  fzf
  tmux
  gh
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Environment variables
export EDITOR=nvim
export VISUAL=$EDITOR
export TERM="xterm-256color"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY       # Save timestamps in history
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # Don't record duplicated entries
setopt HIST_IGNORE_SPACE      # Ignore commands that start with a space
setopt HIST_VERIFY            # Show command with history expansion before running it
setopt SHARE_HISTORY          # Share history between sessions
setopt APPENDHISTORY          # Append to history file rather than overwriting it

# Paths
export PATH="$HOME/.local/bin:$PATH"

# Language managers
# Python - Poetry
export PATH="$HOME/.poetry/bin:$PATH"

# Node.js - NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Ruby - RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.rvm/bin"

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

# Load custom aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# Load custom functions
[ -f ~/.local/bin/functions.sh ] && source ~/.local/bin/functions.sh

# Source local configuration if it exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Enhanced Tmux session functions
mks() {
  local session_name=${1:-dev}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "edit"
  tmux new-window -t "$session_name:2" -n "shell"
  tmux new-window -t "$session_name:3" -n "test"
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# Python-specific Tmux session
mkpy() {
  local session_name=${1:-python}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "edit"
  tmux send-keys -t "$session_name:1" "cd ~/projects && nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "cd ~/projects && python" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux send-keys -t "$session_name:3" "cd ~/projects" C-m
  tmux new-window -t "$session_name:4" -n "test"
  tmux send-keys -t "$session_name:4" "cd ~/projects" C-m
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# JavaScript/Node-specific Tmux session
mkjs() {
  local session_name=${1:-node}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "edit"
  tmux send-keys -t "$session_name:1" "cd ~/projects && nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "cd ~/projects && node" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux send-keys -t "$session_name:3" "cd ~/projects" C-m
  tmux new-window -t "$session_name:4" -n "test"
  tmux send-keys -t "$session_name:4" "cd ~/projects" C-m
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# Ruby-specific Tmux session
mkrb() {
  local session_name=${1:-ruby}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "edit"
  tmux send-keys -t "$session_name:1" "cd ~/projects && nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "cd ~/projects && irb" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux send-keys -t "$session_name:3" "cd ~/projects" C-m
  tmux new-window -t "$session_name:4" -n "test"
  tmux send-keys -t "$session_name:4" "cd ~/projects" C-m
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# FZF-enhanced functions
# Find and edit file
vf() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --height 80% --layout reverse)
  [[ -n "$file" ]] && $EDITOR "$file"
}

# Quick project navigation
proj() {
  local dir
  dir=$(find ~/projects -mindepth 1 -maxdepth 2 -type d | fzf --height 40% --layout reverse)
  [[ -n "$dir" ]] && cd "$dir"
}

# Docker container shell
dsh() {
  local container
  container=$(docker ps --format "{{.Names}}" | fzf --height 40% --layout reverse)
  [[ -n "$container" ]] && docker exec -it "$container" sh
}

# Database connection helper
dbsh() {
  local db_choice
  db_choice=$(echo -e "PostgreSQL\nMySQL\nMongoDB" | fzf --height 40% --layout reverse)
  
  case $db_choice in
    "PostgreSQL")
      psql -U postgres
      ;;
    "MySQL")
      mysql -u root
      ;;
    "MongoDB")
      mongo
      ;;
    *)
      echo "No database selected"
      ;;
  esac
}

# Welcome message
echo "Welcome to your Enhanced Terminal Environment!"
echo "Type 'mks', 'mkpy', 'mkjs', or 'mkrb' to start a new tmux session."
echo "Use 'vf' to find and edit files, 'proj' to navigate to projects."

# Master the basics. Then practice them every day without fail.
