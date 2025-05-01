#!/usr/bin/env bash
# Enhanced Terminal Environment - Verification Script
# Checks that all components are correctly installed and configured

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

# Check if function exists in shell
function_exists() {
    type "$1" &>/dev/null
}

# Check core tools
verify_core_tools() {
    log_header "Core Tools"
    
    local core_tools=(
        "zsh:Zsh shell"
        "tmux:Tmux terminal multiplexer" 
        "nvim:Neovim editor"
        "git:Git version control"
        "fzf:Fuzzy finder"
        "ripgrep:Fast search tool (rg)"
        "fd:File finder"
        "jq:JSON processor"
        "bat:Cat with syntax highlighting"
    )
    
    local success_count=0
    local total_tools=${#core_tools[@]}
    
    for tool_info in "${core_tools[@]}"; do
        IFS=':' read -r tool description <<< "$tool_info"
        
        if command_exists "$tool"; then
            local version=""
            # Get version info where applicable
            case "$tool" in
                zsh)
                    version=$(zsh --version 2>&1 | head -n1)
                    ;;
                tmux)
                    version=$(tmux -V 2>&1)
                    ;;
                nvim)
                    version=$(nvim --version 2>&1 | head -n1)
                    ;;
                git)
                    version=$(git --version 2>&1)
                    ;;
                *)
                    version="installed"
                    ;;
            esac
            
            log_success "$description: $version"
            ((success_count++))
        else
            log_error "$description: Not installed"
        fi
    done
    
    echo "Core tools status: $success_count/$total_tools installed"
    
    # Check tmux plugin manager
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_success "Tmux Plugin Manager is installed"
    else
        log_error "Tmux Plugin Manager is not installed"
    fi
}

# Verify configuration files
verify_config_files() {
    log_header "Configuration Files"
    
    local config_files=(
        "$HOME/.zshrc:Zsh configuration"
        "$HOME/.zsh/aliases.zsh:Zsh aliases"
        "$HOME/.tmux.conf:Tmux configuration"
        "$HOME/.config/nvim/init.lua:Neovim configuration"
        "$HOME/.gitconfig:Git configuration"
        "$HOME/.local/bin/functions.sh:Shell functions"
    )
    
    local success_count=0
    local total_files=${#config_files[@]}
    
    for file_info in "${config_files[@]}"; do
        IFS=':' read -r file description <<< "$file_info"
        
        if [[ -f "$file" ]]; then
            # Check if file is non-empty
            if [[ -s "$file" ]]; then
                log_success "$description: Present and configured"
                ((success_count++))
            else
                log_warning "$description: File exists but is empty"
            fi
        else
            log_error "$description: Missing"
        fi
    done
    
    echo "Configuration files status: $success_count/$total_files properly configured"
}

# Verify Python environment
verify_python_env() {
    log_header "Python Environment"
    
    # Check Python version
    if command_exists python3; then
        log_success "Python: $(python3 --version 2>&1)"
        
        # Check essential Python tools
        local python_tools=(
            "pipx:Package installer"
            "poetry:Dependency manager"
            "pyproject:Project creator function"
            "black:Code formatter"
            "flake8:Linter"
            "pytest:Testing framework"
        )
        
        local success_count=0
        local total_tools=${#python_tools[@]}
        
        for tool_info in "${python_tools[@]}"; do
            IFS=':' read -r tool description <<< "$tool_info"
            
            if command_exists "$tool" || function_exists "$tool"; then
                log_success "$description: Installed"
                ((success_count++))
            else
                log_error "$description: Not installed"
            fi
        done
        
        echo "Python tools status: $success_count/$total_tools installed"
        
        # Check template directory
        if [[ -d "$HOME/.local/share/python-templates" ]]; then
            log_success "Python templates directory exists"
            
            if [[ -f "$HOME/.local/share/python-templates/basic_project.sh" && -x "$HOME/.local/share/python-templates/basic_project.sh" ]]; then
                log_success "Python project template is in place and executable"
            else
                log_error "Python project template is missing or not executable"
            fi
        else
            log_error "Python templates directory is missing"
        fi
    else
        log_error "Python is not installed"
    fi
}

# Verify Node.js environment
verify_nodejs_env() {
    log_header "Node.js Environment"
    
    # Check Node.js and npm
    if command_exists node; then
        log_success "Node.js: $(node --version 2>&1)"
        
        if command_exists npm; then
            log_success "npm: $(npm --version 2>&1)"
        else
            log_error "npm is not installed"
        fi
        
        # Check for NVM
        if [[ -d "$HOME/.nvm" ]]; then
            if command_exists nvm; then
                log_success "NVM is properly installed"
            else
                log_warning "NVM directory exists but command is not available in current shell"
                log_info "You may need to source NVM in your current shell"
            fi
        else
            log_error "NVM is not installed"
        fi
        
        # Check essential Node.js tools
        local node_tools=(
            "yarn:Package manager"
            "typescript:TypeScript compiler"
            "ts-node:TypeScript execution"
            "eslint:Code linter"
            "prettier:Code formatter"
            "nodemon:Development server"
            "nodeproject:Project creator function"
        )
        
        local success_count=0
        local total_tools=${#node_tools[@]}
        
        for tool_info in "${node_tools[@]}"; do
            IFS=':' read -r tool description <<< "$tool_info"
            
            if command_exists "$tool" || function_exists "$tool"; then
                log_success "$description: Installed"
                ((success_count++))
            else
                log_error "$description: Not installed"
            fi
        done
        
        echo "Node.js tools status: $success_count/$total_tools installed"
        
        # Check template directory
        if [[ -d "$HOME/.local/share/node-templates" ]]; then
            log_success "Node.js templates directory exists"
            
            if [[ -f "$HOME/.local/share/node-templates/basic_node_project.sh" && -x "$HOME/.local/share/node-templates/basic_node_project.sh" ]]; then
                log_success "Node.js project template is in place and executable"
            else
                log_error "Node.js project template is missing or not executable"
            fi
        else
            log_error "Node.js templates directory is missing"
        fi
    else
        log_error "Node.js is not installed"
    fi
}

# Verify Ruby environment
verify_ruby_env() {
    log_header "Ruby Environment"
    
    # Check Ruby
    if command_exists ruby; then
        log_success "Ruby: $(ruby --version 2>&1)"
        
        if command_exists gem; then
            log_success "RubyGems: $(gem --version 2>&1)"
            
            # Check essential Ruby gems
            local ruby_gems=(
                "bundler:Dependency manager"
                "rspec:Testing framework"
                "rubocop:Linter"
                "solargraph:Language server"
                "pry:REPL"
                "rubyproject:Project creator function"
            )
            
            local success_count=0
            local total_gems=${#ruby_gems[@]}
            
            for gem_info in "${ruby_gems[@]}"; do
                IFS=':' read -r gem description <<< "$gem_info"
                
                if command_exists "$gem" || function_exists "$gem" || gem list -i "^${gem}$" &>/dev/null; then
                    log_success "$description: Installed"
                    ((success_count++))
                else
                    log_error "$description: Not installed"
                fi
            done
            
            echo "Ruby gems status: $success_count/$total_gems installed"
        else
            log_error "RubyGems is not installed"
        fi
        
        # Check template directory
        if [[ -d "$HOME/.local/share/ruby-templates" ]]; then
            log_success "Ruby templates directory exists"
            
            if [[ -f "$HOME/.local/share/ruby-templates/basic_ruby_project.sh" && -x "$HOME/.local/share/ruby-templates/basic_ruby_project.sh" ]]; then
                log_success "Ruby project template is in place and executable"
            else
                log_error "Ruby project template is missing or not executable"
            fi
        else
            log_error "Ruby templates directory is missing"
        fi
    else
        log_error "Ruby is not installed"
    fi
}

# Verify custom functions
verify_functions() {
    log_header "Custom Functions"
    
    local functions=(
        "mkpy:Python Tmux session"
        "mkjs:JavaScript Tmux session"
        "mkrb:Ruby Tmux session"
        "vf:Find and edit with fzf"
        "proj:Project navigation"
        "extract:Archive extraction" 
        "pyproject:Python project creator"
        "nodeproject:Node.js project creator"
        "rubyproject:Ruby project creator"
    )
    
    local success_count=0
    local total_functions=${#functions[@]}
    
    # Source .zshrc to load functions if not in Zsh
    if [[ "$(basename "$SHELL")" != "zsh" ]]; then
        log_warning "Not running in Zsh. Attempting to source .zshrc for function verification..."
        # shellcheck disable=SC1090
        if [[ -f "$HOME/.zshrc" ]]; then
            source "$HOME/.zshrc" &>/dev/null || true
        fi
    fi
    
    for func_info in "${functions[@]}"; do
        IFS=':' read -r func description <<< "$func_info"
        
        if function_exists "$func" || grep -q "${func}()" "$HOME/.zshrc" "$HOME/.local/bin/functions.sh" 2>/dev/null; then
            log_success "$description: Function defined"
            ((success_count++))
        else
            log_error "$description: Function not defined"
        fi
    done
    
    echo "Custom functions status: $success_count/$total_functions defined"
}

# Overall summary
summarize_verification() {
    log_header "Verification Summary"
    
    echo "The Enhanced Terminal Environment verification is complete."
    echo
    echo "If any components are missing or misconfigured, you can:"
    echo "1. Run the installer with the recovery flag: ./install.sh --recover"
    echo "2. Install missing components manually"
    echo "3. Check for errors in the installation log: install_log.txt"
    echo
    echo "For a full terminal experience, restart your terminal or run:"
    echo "  source ~/.zshrc"
    echo
    echo "To create project-specific environments, use the following commands:"
    echo "  mkpy <session-name>    # Create Python development session"
    echo "  mkjs <session-name>    # Create JavaScript development session"
    echo "  mkrb <session-name>    # Create Ruby development session"
}

# Main function
main() {
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}  Enhanced Terminal Environment - Verification      ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Checking that all components are correctly installed...${NC}"
    echo

    # Run all verification checks
    verify_core_tools
    verify_config_files
    verify_python_env
    verify_nodejs_env
    verify_ruby_env
    verify_functions
    summarize_verification
}

# Run the main function
main "$@"