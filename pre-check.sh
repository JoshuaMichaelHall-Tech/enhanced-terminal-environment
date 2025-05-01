#!/usr/bin/env bash
# Enhanced Terminal Environment - Pre-Installation Check
# Verifies system requirements and potential conflicts before installation

# Exit on undefined variables
set -u

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

log_header() {
    echo -e "\n${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}$(printf '=%.0s' {1..50})${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# OS detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    else
        echo "Unsupported"
    fi
}

# Check shell environment
check_shell() {
    log_header "Shell Environment"
    
    # Check current shell
    local current_shell=$(basename "$SHELL")
    echo -e "Current shell: ${BOLD}$current_shell${NC}"
    
    if [[ "$current_shell" != "zsh" ]]; then
        log_warning "Zsh is not your current shell. This environment is designed for Zsh."
        log_info "After installation, run: chsh -s $(which zsh)"
    else
        log_success "Using Zsh as shell"
    fi
    
    # Check for Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh is installed"
    else
        log_info "Oh My Zsh will be installed during setup"
    fi
}

# Check package managers
check_package_managers() {
    log_header "Package Managers"
    
    local os=$(detect_os)
    
    if [[ "$os" == "macOS" ]]; then
        if command_exists brew; then
            log_success "Homebrew is installed: $(brew --version | head -n1)"
        else
            log_warning "Homebrew is not installed and will be installed during setup"
            log_info "This may require administrator password"
        fi
    elif [[ "$os" == "Linux" ]]; then
        if command_exists apt-get; then
            log_success "apt package manager is available"
        else
            log_warning "apt package manager not found. The installer is designed for Debian-based distributions."
        fi
    fi
}

# Check potential conflicts
check_conflicts() {
    log_header "Potential Conflicts"
    
    # Check for existing config files
    local configs=(
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim/init.lua"
    )
    
    local conflict_found=false
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            log_warning "Existing configuration found: $config"
            conflict_found=true
        fi
    done
    
    if $conflict_found; then
        log_info "The installer will back up existing configurations if you choose to proceed"
    else
        log_success "No configuration conflicts detected"
    fi
    
    # Check Python environment
    if command_exists python3; then
        local python_version=$(python3 --version 2>&1)
        echo -e "Python version: ${BOLD}$python_version${NC}"
        
        # Check if system supports PEP 668
        if python3 -m pip install --break-system-packages --help &>/dev/null; then
            log_warning "Python has PEP 668 restrictions (externally managed environment)"
            log_info "The installer will use pipx and virtual environments to comply with PEP 668"
        else
            log_success "Python environment has no PEP 668 restrictions"
        fi
    fi
    
    # Check if Tmux is running
    if command_exists tmux && tmux list-sessions &>/dev/null; then
        log_warning "Tmux is currently running. Some configuration changes may require restarting Tmux."
    fi
}

# Check for disk space and permissions
check_system_resources() {
    log_header "System Resources"
    
    # Check available disk space in home directory
    local available_space
    if command_exists df; then
        # Get available space in MB
        if [[ "$(detect_os)" == "macOS" ]]; then
            available_space=$(df -m "$HOME" | awk 'NR==2 {print $4}')
        else
            available_space=$(df -m --output=avail "$HOME" | tail -n1 | tr -d ' ')
        fi
        
        if [[ -n "$available_space" ]]; then
            if [[ "$available_space" -lt 1000 ]]; then
                log_warning "Low disk space: ${available_space}MB available. At least 1GB recommended."
            else
                log_success "Sufficient disk space: ${available_space}MB available"
            fi
        fi
    fi
    
    # Check permissions in key directories
    local dirs=(
        "$HOME/.config"
        "$HOME/.local"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ -w "$dir" ]]; then
                log_success "Have write permissions for: $dir"
            else
                log_error "No write permissions for: $dir"
                log_info "Run: sudo chown -R $(whoami) $dir"
            fi
        else
            log_info "Directory doesn't exist yet: $dir (will be created during installation)"
        fi
    done
}

# Check for language environments
check_language_environments() {
    log_header "Language Environments"
    
    # Check Python
    if command_exists python3; then
        log_success "Python is installed: $(python3 --version 2>&1)"
        
        if command_exists pipx; then
            log_success "pipx is installed: $(pipx --version 2>&1)"
        else
            log_info "pipx will be installed during setup"
        fi
        
        if command_exists poetry; then
            log_success "Poetry is installed: $(poetry --version 2>&1)"
        else
            log_info "Poetry will be installed during setup"
        fi
    else
        log_warning "Python is not installed and will be installed during setup"
    fi
    
    # Check Node.js
    if command_exists node; then
        log_success "Node.js is installed: $(node --version)"
        
        if command_exists nvm; then
            log_success "NVM is installed: $(nvm --version 2>&1)"
        else
            log_info "NVM will be installed during setup"
        fi
    else
        if [[ -d "$HOME/.nvm" ]]; then
            log_warning "NVM directory exists but Node.js is not in PATH"
            log_info "You may need to source NVM in your current shell"
        else
            log_info "Node.js will be installed during setup"
        fi
    fi
    
    # Check Ruby
    if command_exists ruby; then
        log_success "Ruby is installed: $(ruby --version)"
    else
        log_info "Ruby will be installed during setup"
    fi
}

# Summary and recommendations
summarize_checks() {
    log_header "Summary"
    
    local os=$(detect_os)
    
    if [[ "$os" == "Unsupported" ]]; then
        log_error "Your operating system is not officially supported"
        log_info "The installer is designed for macOS and Debian-based Linux distributions"
        log_info "Installation may fail or require manual intervention"
    else
        log_success "Operating system is supported: $os"
    fi
    
    log_info "Ready to proceed with installation? Run ./install.sh"
    log_info "If issues occur during installation, you can run ./install.sh --recover"
}

# Main function
main() {
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}  Enhanced Terminal Environment - Pre-Check Script  ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Checking system compatibility and requirements...${NC}"
    echo

    # Run all checks
    check_shell
    check_package_managers
    check_conflicts
    check_system_resources
    check_language_environments
    summarize_checks
}

# Run the main function
main "$@"