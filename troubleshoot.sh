#!/bin/bash
# Enhanced Terminal Environment - Installation Troubleshooter for macOS
# This script diagnoses and fixes common installation issues

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==== Enhanced Terminal Environment - macOS Troubleshooter ====${NC}"
echo

# Check for log file
LOG_FILE="$(pwd)/install_log.txt"
if [[ -f "$LOG_FILE" ]]; then
    echo -e "${BLUE}Found installation log file at:${NC} $LOG_FILE"
    echo -e "${YELLOW}Last 20 lines of log file:${NC}"
    tail -n 20 "$LOG_FILE"
    echo
else
    echo -e "${RED}Installation log file not found at: $LOG_FILE${NC}"
    echo -e "${YELLOW}Looking for log file in current directory...${NC}"
    find . -name "install_log.txt" -print
    echo
fi

# Check for Homebrew
echo -e "${BLUE}Checking for Homebrew installation...${NC}"
if command -v brew &> /dev/null; then
    echo -e "${GREEN}Homebrew is installed:${NC} $(brew --version | head -n 1)"
    
    # Test Homebrew functionality
    echo -e "${BLUE}Testing Homebrew functionality...${NC}"
    if brew doctor; then
        echo -e "${GREEN}Homebrew is working properly.${NC}"
    else
        echo -e "${YELLOW}Homebrew reported issues. This might be affecting the installation.${NC}"
    fi
else
    echo -e "${RED}Homebrew is not installed or not in PATH.${NC}"
    echo -e "${YELLOW}This will prevent the installation script from working properly.${NC}"
    
    # Check shell environment
    echo -e "${BLUE}Checking shell environment...${NC}"
    echo -e "Current shell: $SHELL"
    echo -e "Path to zsh: $(which zsh 2>/dev/null || echo 'Not found')"
    
    # Check if Homebrew is installed but not in PATH
    if [[ -d "/opt/homebrew" ]]; then
        echo -e "${YELLOW}Homebrew directory exists but isn't in PATH. Try running:${NC}"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    elif [[ -d "/usr/local/Homebrew" ]]; then
        echo -e "${YELLOW}Homebrew directory exists but isn't in PATH. Try running:${NC}"
        echo 'eval "$(/usr/local/bin/brew shellenv)"'
    else
        echo -e "${YELLOW}Homebrew needs to be installed. Run the following command:${NC}"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
fi

# Check for essential directories
echo -e "${BLUE}Checking for essential directories...${NC}"
for dir in "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.tmux/plugins" "$HOME/.zsh" "$HOME/.local/bin" "$HOME/projects"; do
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}Directory exists:${NC} $dir"
    else
        echo -e "${YELLOW}Directory does not exist:${NC} $dir"
    fi
done

# Check for permissions issues
echo -e "${BLUE}Checking for permission issues...${NC}"
if [[ ! -w "$HOME/.config" ]]; then
    echo -e "${RED}Permission issue detected: Cannot write to $HOME/.config${NC}"
    echo -e "${YELLOW}Run the following command to fix:${NC} sudo chown -R $(whoami) $HOME/.config"
fi

# Check for essential tools
echo -e "${BLUE}Checking for essential tools...${NC}"
for tool in git curl zsh tmux; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}$tool is installed:${NC} $(which $tool)"
    else
        echo -e "${RED}$tool is not installed or not in PATH.${NC}"
    fi
done

# Show system information
echo -e "${BLUE}System information:${NC}"
echo -e "macOS version: $(sw_vers -productVersion)"
echo -e "Architecture: $(uname -m)"
echo -e "PATH: $PATH"
echo

echo -e "${BLUE}==== Troubleshooting complete ====${NC}"
echo -e "${YELLOW}To resolve the installation issue:${NC}"
echo -e "1. Check the log file details above for specific errors"
echo -e "2. Ensure Homebrew is properly installed and functioning"
echo -e "3. Make sure you have the necessary permissions"
echo -e "4. After addressing the issues, try the installation again"
echo -e "5. If problems persist, you may need to run components of the installation script manually"
echo
echo -e "${BLUE}To run the installation with more verbose output:${NC}"
echo -e "bash ./install.sh"
echo