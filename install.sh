#!/bin/bash

# Enhanced Terminal Environment Installer
# Main installation script that calls modular components
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

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Core installation - Creates necessary directories and installs core tools
echo -e "${BLUE}Setting up core environment...${NC}"
bash "$SCRIPT_DIR/scripts/utils/system-setup.sh"

# Language setup - Prompt user for which languages to install
echo -e "\n${YELLOW}Language Setup${NC}"
echo -e "Which languages would you like to set up? (y/n for each)"

read -p "Python? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Setting up Python environment...${NC}"
    bash "$SCRIPT_DIR/scripts/setup/python-setup.sh"
fi

read -p "JavaScript/Node.js? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Setting up JavaScript/Node.js environment...${NC}"
    bash "$SCRIPT_DIR/scripts/setup/node-setup.sh"
fi

read -p "Ruby? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Setting up Ruby environment...${NC}"
    bash "$SCRIPT_DIR/scripts/setup/ruby-setup.sh"
fi

# Copy configuration files
echo -e "${BLUE}Copying configuration files...${NC}"
# Neovim setup
mkdir -p ~/.config/nvim
cp -r "$SCRIPT_DIR/configs/neovim/"* ~/.config/nvim/

# Tmux setup
cp "$SCRIPT_DIR/configs/tmux/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.tmux/sessions
cp "$SCRIPT_DIR/configs/tmux/tmux-sessions/"* ~/.tmux/sessions/

# Zsh setup
cp "$SCRIPT_DIR/configs/zsh/.zshrc" ~/.zshrc
mkdir -p ~/.zsh
cp "$SCRIPT_DIR/configs/zsh/aliases.zsh" ~/.zsh/

# Git setup
cp "$SCRIPT_DIR/configs/git/.gitconfig" ~/.gitconfig

# Setup custom functions
echo -e "${BLUE}Setting up custom functions...${NC}"
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/scripts/shortcuts/functions.sh" ~/.local/bin/
echo "[ -f ~/.local/bin/functions.sh ] && source ~/.local/bin/functions.sh" >> ~/.zshrc

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
