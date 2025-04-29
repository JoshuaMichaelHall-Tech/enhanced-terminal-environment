#!/usr/bin/env bash
# Enhanced Terminal Environment Installer
# Main installation script with improved error handling and user experience
# Version: 3.0

# Exit on error, undefined variables, and propagate pipe failures
set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Script directory (resolving symlinks)
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Installation log file
readonly LOG_FILE="$SCRIPT_DIR/install_log.txt"

# Language selection defaults (y/n)
INSTALL_PYTHON="n"
INSTALL_NODE="n"
INSTALL_RUBY="n"

# Log functions
log_info() {
    echo -e "${BLUE}INFO: $1${NC}" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE" >&2
}

log_header() {
    echo -e "\n${CYAN}${BOLD}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$(printf '=%.0s' {1..50})${NC}" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
    log_error "$1"
    log_error "Check $LOG_FILE for more details."
    exit 1
}

# Command execution with error handling and logging
run_script() {
    local script="$1"
    local error_msg="$2"
    
    if [[ ! -f "$script" ]]; then
        handle_error "Script not found: $script"
    fi
    
    log_info "Running: $script"
    echo "$(date): Running $script" >> "$LOG_FILE"
    
    if ! bash "$script" >> "$LOG_FILE" 2>&1; then
        handle_error "$error_msg"
    fi
    
    log_success "Successfully executed: $script"
}

# Copy configuration directory with error handling
copy_config_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local dir_name="$3"
    
    if [[ ! -d "$src_dir" ]]; then
        handle_error "Source directory not found: $src_dir"
    fi
    
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir" || handle_error "Failed to create directory: $dest_dir"
    fi
    
    log_info "Copying $dir_name configuration files..."
    cp -r "$src_dir/"* "$dest_dir/" || handle_error "Failed to copy $dir_name configuration files"
    log_success "Copied $dir_name configuration files to $dest_dir"
}

# Copy configuration file with error handling
copy_config_file() {
    local src_file="$1"
    local dest_file="$2"
    local file_name="$3"
    
    if [[ ! -f "$src_file" ]]; then
        handle_error "Source file not found: $src_file"
    fi
    
    local dest_dir
    dest_dir=$(dirname "$dest_file")
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir" || handle_error "Failed to create directory: $dest_dir"
    fi
    
    log_info "Copying $file_name configuration file..."
    cp "$src_file" "$dest_file" || handle_error "Failed to copy $file_name configuration file"
    log_success "Copied $file_name configuration file to $dest_file"
}

# Ask user for language installation preferences
prompt_language_setup() {
    log_header "Language Setup"
    echo -e "Which languages would you like to set up? (y/n for each)" | tee -a "$LOG_FILE"
    
    # Python
    read -r -p "Python? [y/n]: " -n 1 INSTALL_PYTHON
    echo
    echo "Python: $INSTALL_PYTHON" >> "$LOG_FILE"
    
    # Node.js/JavaScript
    read -r -p "JavaScript/Node.js? [y/n]: " -n 1 INSTALL_NODE
    echo
    echo "JavaScript/Node.js: $INSTALL_NODE" >> "$LOG_FILE"
    
    # Ruby
    read -r -p "Ruby? [y/n]: " -n 1 INSTALL_RUBY
    echo
    echo "Ruby: $INSTALL_RUBY" >> "$LOG_FILE"
}

# Display installation summary
show_summary() {
    log_header "Installation Summary"
    echo -e "The following will be installed:" | tee -a "$LOG_FILE"
    echo -e "  - Core environment (shell, Tmux, Neovim, Git)" | tee -a "$LOG_FILE"
    
    [[ "$INSTALL_PYTHON" =~ ^[Yy]$ ]] && echo -e "  - Python development environment" | tee -a "$LOG_FILE"
    [[ "$INSTALL_NODE" =~ ^[Yy]$ ]] && echo -e "  - Node.js/JavaScript development environment" | tee -a "$LOG_FILE"
    [[ "$INSTALL_RUBY" =~ ^[Yy]$ ]] && echo -e "  - Ruby development environment" | tee -a "$LOG_FILE"
    
    echo | tee -a "$LOG_FILE"
    read -r -p "Continue with installation? [Y/n]: " -n 1 CONTINUE
    echo
    
    if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
        log_info "Installation cancelled by user."
        exit 0
    fi
}

# Initialize log file
init_log_file() {
    # Create fresh log file
    echo "Enhanced Terminal Environment Installation Log" > "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "User: $(whoami)" >> "$LOG_FILE"
    echo "System: $(uname -a)" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
}

# Setup custom functions
setup_custom_functions() {
    log_header "Setting up custom functions"
    
    # Create directory if it doesn't exist
    mkdir -p "$HOME/.local/bin" || handle_error "Failed to create ~/.local/bin directory"
    
    # Copy functions file
    local src_file="$SCRIPT_DIR/scripts/shortcuts/functions.sh"
    local dest_file="$HOME/.local/bin/functions.sh"
    
    copy_config_file "$src_file" "$dest_file" "custom functions"
    
    # Ensure functions are sourced in .zshrc
    if ! grep -q "source.*functions.sh" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Adding functions sourcing to .zshrc"
        echo '[ -f ~/.local/bin/functions.sh ] && source ~/.local/bin/functions.sh' >> "$HOME/.zshrc"
    else
        log_success "Functions sourcing already in .zshrc"
    fi
}

# Main function
main() {
    # Show welcome banner
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}    Enhanced Terminal Environment Installer          ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Setting up your full-stack development environment   ${NC}"
    echo

    # Initialize log file
    init_log_file
    
    # Prompt user for language setup preferences
    prompt_language_setup
    
    # Show installation summary and confirmation
    show_summary
    
    # Core system setup
    log_header "Setting up core environment"
    run_script "$SCRIPT_DIR/scripts/utils/system-setup.sh" "Core environment setup failed"
    
    # Language-specific setup based on user choices
    if [[ "$INSTALL_PYTHON" =~ ^[Yy]$ ]]; then
        log_header "Setting up Python environment"
        run_script "$SCRIPT_DIR/scripts/setup/python-setup.sh" "Python environment setup failed"
    fi
    
    if [[ "$INSTALL_NODE" =~ ^[Yy]$ ]]; then
        log_header "Setting up Node.js/JavaScript environment"
        run_script "$SCRIPT_DIR/scripts/setup/node-setup.sh" "Node.js environment setup failed"
    fi
    
    if [[ "$INSTALL_RUBY" =~ ^[Yy]$ ]]; then
        log_header "Setting up Ruby environment"
        run_script "$SCRIPT_DIR/scripts/setup/ruby-setup.sh" "Ruby environment setup failed"
    fi
    
    # Copy configuration files
    log_header "Copying configuration files"
    
    # Neovim setup
    copy_config_dir "$SCRIPT_DIR/configs/neovim" "$HOME/.config/nvim" "Neovim"
    
    # Tmux setup
    copy_config_file "$SCRIPT_DIR/configs/tmux/.tmux.conf" "$HOME/.tmux.conf" "Tmux"
    mkdir -p "$HOME/.tmux/sessions"
    cp -rf "$SCRIPT_DIR/configs/tmux/tmux-sessions/"* "$HOME/.tmux/sessions/" 2>/dev/null || true
    
    # Zsh setup
    copy_config_file "$SCRIPT_DIR/configs/zsh/.zshrc" "$HOME/.zshrc" "Zsh"
    mkdir -p "$HOME/.zsh"
    copy_config_file "$SCRIPT_DIR/configs/zsh/aliases.zsh" "$HOME/.zsh/aliases.zsh" "Zsh aliases"
    
    # Git setup
    copy_config_file "$SCRIPT_DIR/configs/git/.gitconfig" "$HOME/.gitconfig" "Git"
    
    # Setup custom functions
    setup_custom_functions
    
    # Installation complete
    log_header "Installation Complete!"
    echo -e "${GREEN}Enhanced Terminal Environment has been successfully installed!${NC}"
    echo
    echo -e "To finalize the setup:"
    echo -e "1. Start a new terminal session or run: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "2. Start Tmux with the command: ${YELLOW}tmux${NC}"
    echo -e "3. Inside Tmux, press ${YELLOW}Ctrl-a + I${NC} to install Tmux plugins"
    echo
    echo -e "Language-specific development sessions:"
    [[ "$INSTALL_PYTHON" =~ ^[Yy]$ ]] && echo -e "- ${YELLOW}mkpy${NC}: Create Python development environment"
    [[ "$INSTALL_NODE" =~ ^[Yy]$ ]] && echo -e "- ${YELLOW}mkjs${NC}: Create JavaScript/Node.js development environment"
    [[ "$INSTALL_RUBY" =~ ^[Yy]$ ]] && echo -e "- ${YELLOW}mkrb${NC}: Create Ruby development environment"
    echo
    echo -e "For complete installation details, see: ${YELLOW}$LOG_FILE${NC}"
    echo -e "${GREEN}Enjoy your enhanced terminal environment!${NC}"
}

# Trap for cleanup on script exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Installation failed with exit code $exit_code"
        log_error "Check $LOG_FILE for more details."
    fi
    exit $exit_code
}
trap cleanup EXIT

# Run the main function
main "$@"