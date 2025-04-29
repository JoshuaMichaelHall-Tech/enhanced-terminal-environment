#!/bin/bash

# Enhanced Terminal Environment Installer
# Supports macOS and Linux with Python, JavaScript, and Ruby focus
# Version 2.0

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}    Enhanced Terminal Environment Installer          ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${BLUE}Setting up your full-stack development environment   ${NC}"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    echo -e "${BLUE}Detected macOS system${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    echo -e "${BLUE}Detected Linux system${NC}"
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${BLUE}Creating configuration directories...${NC}"
mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux
mkdir -p ~/.local/bin

# Install required packages based on OS
if [[ "$OS" == "macOS" ]]; then
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${BLUE}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo -e "${BLUE}Homebrew already installed.${NC}"
    fi
    
    echo -e "${BLUE}Installing essential tools...${NC}"
    brew install neovim tmux zsh git ripgrep fzf fd jq gh
    
    echo -e "${BLUE}Installing development tools...${NC}"
    brew install node python@3.11 ruby 
    
    echo -e "${BLUE}Installing database tools...${NC}"
    brew install postgresql mongodb-community
    
    echo -e "${BLUE}Installing containerization tools...${NC}"
    brew install docker docker-compose
    
    echo -e "${BLUE}Installing cloud tools...${NC}"
    brew install awscli terraform ansible
    
    echo -e "${BLUE}Installing HTTP tools...${NC}"
    brew install curl httpie
    
    echo -e "${BLUE}Installing monitoring tools...${NC}"
    brew install htop glances
    
elif [[ "$OS" == "Linux" ]]; then
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo apt update
    
    echo -e "${BLUE}Installing essential tools...${NC}"
    sudo apt install -y neovim tmux zsh git curl wget build-essential ripgrep fd-find fzf jq
    
    echo -e "${BLUE}Installing development tools...${NC}"
    sudo apt install -y nodejs npm python3 python3-pip python3-venv ruby ruby-dev
    
    echo -e "${BLUE}Installing database tools...${NC}"
    sudo apt install -y postgresql postgresql-contrib
    
    # MongoDB (simplified installation)
    echo -e "${BLUE}Setting up MongoDB repository...${NC}"
    sudo apt install -y gnupg
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt update
    sudo apt install -y mongodb-org
    
    echo -e "${BLUE}Installing Docker...${NC}"
    sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker $USER
    
    echo -e "${BLUE}Installing Cloud Tools...${NC}"
    # AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    
    # Terraform
    sudo apt install -y software-properties-common
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt update
    sudo apt install -y terraform
    
    # Ansible
    sudo apt install -y ansible
    
    echo -e "${BLUE}Installing HTTP tools...${NC}"
    sudo apt install -y curl httpie
    
    echo -e "${BLUE}Installing monitoring tools...${NC}"
    sudo apt install -y htop
    pip3 install glances
    
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
    
    # Create symlink for fd-find if needed
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        ln -sf $(which fdfind) ~/.local/bin/fd
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
fi

# Install language-specific package managers
echo -e "${BLUE}Setting up language-specific package managers...${NC}"

# Python Poetry
echo -e "${BLUE}Installing Poetry for Python...${NC}"
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Node Version Manager (nvm)
echo -e "${BLUE}Installing NVM for Node.js...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Ruby Version Manager (rvm)
echo -e "${BLUE}Installing RVM for Ruby...${NC}"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 3.2.0
rvm use 3.2.0 --default

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${BLUE}Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo -e "${BLUE}Tmux Plugin Manager already installed.${NC}"
fi

# Copy Tmux configuration
echo -e "${BLUE}Setting up tmux configuration...${NC}"
cp .tmux.conf ~/.tmux.conf

# Set up Neovim configuration (assumes init.lua is in the current directory)
echo -e "${BLUE}Setting up Neovim configuration...${NC}"
cp init.lua ~/.config/nvim/

# Set up zsh configuration
echo -e "${BLUE}Setting up Zsh configuration...${NC}"
cat > ~/.zshrc << 'EOL'
# Basic zsh configuration
export EDITOR=nvim

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Basic completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt COMPLETE_ALIASES

# Path settings
export PATH="$HOME/.local/bin:$PATH"

# Language version managers
# NVM (Node.js)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# RVM (Ruby)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.rvm/bin"

# Poetry (Python)
export PATH="$HOME/.poetry/bin:$PATH"

# Useful aliases
alias ls="ls -G"
alias ll="ls -la"
alias ..="cd .."
alias ...="cd ../.."
alias vim="nvim"
alias vi="nvim"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"

# GitHub CLI aliases
alias ghpr="gh pr create"
alias ghprl="gh pr list"
alias ghprc="gh pr checkout"

# Tmux aliases
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tk="tmux kill-session -t"

# Docker aliases
alias dc="docker-compose"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dps="docker ps"
alias di="docker images"

# Cloud CLI aliases
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"

# Enhanced tmux session creator
mks() {
  local session_name=${1:-dev}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "edit"
  tmux new-window -t "$session_name:2" -n "shell"
  tmux new-window -t "$session_name:3" -n "test"
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# Project-specific tmux sessions
mkpy() {
  local session_name=${1:-python}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "editor"
  tmux send-keys -t "$session_name:1" "nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "python" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux new-window -t "$session_name:4" -n "test"
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

mkjs() {
  local session_name=${1:-node}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "editor"
  tmux send-keys -t "$session_name:1" "nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "node" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux new-window -t "$session_name:4" -n "test"
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

mkrb() {
  local session_name=${1:-ruby}
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name:1" "editor"
  tmux send-keys -t "$session_name:1" "nvim" C-m
  tmux new-window -t "$session_name:2" -n "repl"
  tmux send-keys -t "$session_name:2" "irb" C-m
  tmux new-window -t "$session_name:3" -n "shell"
  tmux new-window -t "$session_name:4" -n "test"
  tmux select-window -t "$session_name:1"
  tmux attach-session -t "$session_name"
}

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Advanced file finder with preview
vf() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --height 80% --layout reverse)
  [[ -n "$file" ]] && nvim "$file"
}

# Quick project navigator
proj() {
  local dir
  dir=$(find ~/projects -type d -maxdepth 2 | fzf --height 40% --layout reverse)
  [[ -n "$dir" ]] && cd "$dir"
}

# Docker container selector
dsh() {
  local container
  container=$(docker ps --format "{{.Names}}" | fzf --height 40% --layout reverse)
  [[ -n "$container" ]] && docker exec -it "$container" /bin/bash
}

# Set prompt
PS1='%F{green}%n@%m%f:%F{blue}%~%f$ '
EOL

# Set Zsh as default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}Setting Zsh as default shell...${NC}"
    chsh -s $(which zsh)
fi

# Install FZF
echo -e "${BLUE}Setting up FZF...${NC}"
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
fi

# Install Node.js packages
echo -e "${BLUE}Installing global Node.js packages...${NC}"
npm install -g eslint prettier typescript ts-node nodemon

# Install Python packages
echo -e "${BLUE}Installing Python packages...${NC}"
pip3 install --user pipenv black pylint pytest httpie

# Install Ruby gems
echo -e "${BLUE}Installing Ruby gems...${NC}"
gem install bundler rubocop solargraph

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
echo "To finalize the setup:"
echo "1. Start a new terminal session or run 'source ~/.zshrc'"
echo "2. Start Tmux with the command 'tmux'"
echo "3. Inside Tmux, press Ctrl-a + I to install Tmux plugins"
echo ""
echo "Language-specific development sessions:"
echo "- mkpy: Create Python development environment"
echo "- mkjs: Create JavaScript/Node.js development environment"
echo "- mkrb: Create Ruby development environment"
echo ""
echo -e "${GREEN}Enjoy your enhanced terminal environment!${NC}"
