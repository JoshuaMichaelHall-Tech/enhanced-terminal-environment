#!/usr/bin/env bash
# Enhanced Terminal Environment Installer
# Main installation script with improved error handling and user experience
# Version: 4.0

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

# Script directory (resolving symlinks)
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Installation log file
readonly LOG_FILE="$SCRIPT_DIR/install_log.txt"

# Language selection defaults (y/n)
INSTALL_PYTHON="n"
INSTALL_NODE="n"
INSTALL_RUBY="n"

# Installation status tracking
CORE_INSTALLED=false
PYTHON_INSTALLED=false
NODE_INSTALLED=false
RUBY_INSTALLED=false
CONFIGS_COPIED=false

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

# Command execution with error handling and logging
run_script() {
    local script="$1"
    local error_msg="$2"
    local component="$3"
    
    if [[ ! -f "$script" ]]; then
        log_error "Script not found: $script"
        return 1
    fi
    
    log_info "Running: $script"
    echo "$(date): Running $script" >> "$LOG_FILE"
    
    # Run the script and capture its exit code
    if bash "$script" >> "$LOG_FILE" 2>&1; then
        log_success "Successfully executed: $script"
        return 0
    else
        local exit_code=$?
        log_error "$error_msg"
        log_warning "Check $LOG_FILE for more details."
        
        # Ask if the user wants to continue
        read -r -p "Continue with installation despite error? [Y/n]: " CONTINUE
        echo "User choice on continuing: $CONTINUE" >> "$LOG_FILE"
        
        if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
            log_info "Installation aborted by user."
            exit 1
        fi
        
        return $exit_code
    fi
}

# Copy configuration directory with error handling
copy_config_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local dir_name="$3"
    
    if [[ ! -d "$src_dir" ]]; then
        log_error "Source directory not found: $src_dir"
        return 1
    fi
    
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir" || {
            log_error "Failed to create directory: $dest_dir"
            return 1
        }
    fi
    
    log_info "Copying $dir_name configuration files..."
    if cp -r "$src_dir/"* "$dest_dir/" 2>/dev/null; then
        log_success "Copied $dir_name configuration files to $dest_dir"
        return 0
    else
        log_error "Failed to copy $dir_name configuration files"
        return 1
    fi
}

# Copy configuration file with error handling
copy_config_file() {
    local src_file="$1"
    local dest_file="$2"
    local file_name="$3"
    
    if [[ ! -f "$src_file" ]]; then
        log_error "Source file not found: $src_file"
        return 1
    fi
    
    local dest_dir
    dest_dir=$(dirname "$dest_file")
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir" || {
            log_error "Failed to create directory: $dest_dir"
            return 1
        }
    fi
    
    log_info "Copying $file_name configuration file..."
    if cp "$src_file" "$dest_file" 2>/dev/null; then
        log_success "Copied $file_name configuration file to $dest_file"
        return 0
    else
        log_error "Failed to copy $file_name configuration file"
        return 1
    fi
}

# Create all essential directories needed for installation
create_essential_directories() {
    log_info "Creating essential directories..."
    
    # List of essential directories
    local dirs=(
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
        "$HOME/.tmux/plugins"
        "$HOME/.zsh"
        "$HOME/.local/bin"
        "$HOME/projects"
        "$HOME/.local/share/python-templates"
        "$HOME/.local/share/node-templates"
        "$HOME/.local/share/ruby-templates"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" && 
            chmod 755 "$dir" && 
            log_success "Created: $dir" || 
            log_warning "Failed to create: $dir"
        else
            log_info "Directory already exists: $dir"
            # Verify permissions
            if [[ -w "$dir" ]]; then
                chmod 755 "$dir" 2>/dev/null || true
            else
                log_warning "Directory exists but may not be writable: $dir"
                chmod 755 "$dir" 2>/dev/null || log_warning "Failed to fix permissions for: $dir"
            fi
        fi
    done
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
    read -r -p "Continue with installation? [Y/n]: " CONTINUE
    echo
    echo "Continue with installation: $CONTINUE" >> "$LOG_FILE"
    
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
    mkdir -p "$HOME/.local/bin" || {
        log_error "Failed to create ~/.local/bin directory"
        return 1
    }
    
    # Copy functions file
    local src_file="$SCRIPT_DIR/scripts/shortcuts/functions.sh"
    local dest_file="$HOME/.local/bin/functions.sh"
    
    if copy_config_file "$src_file" "$dest_file" "custom functions"; then
        # Ensure functions are sourced in .zshrc
        if ! grep -q "source.*functions.sh" "$HOME/.zshrc" 2>/dev/null; then
            log_info "Adding functions sourcing to .zshrc"
            echo '[ -f ~/.local/bin/functions.sh ] && source ~/.local/bin/functions.sh' >> "$HOME/.zshrc"
        else
            log_success "Functions sourcing already in .zshrc"
        fi
        return 0
    else
        return 1
    fi
}

# Copy all configuration files
copy_config_files() {
    log_header "Copying configuration files"
    
    # Neovim setup
    copy_config_dir "$SCRIPT_DIR/configs/neovim" "$HOME/.config/nvim" "Neovim" || 
        log_warning "Failed to copy Neovim configuration, but continuing installation"
    
    # Add enhanced Neovim setup
    log_info "Running enhanced Neovim setup..."
    if bash "$SCRIPT_DIR/scripts/utils/neovim-enhanced-setup.sh"; then
        log_success "Neovim enhanced setup completed successfully"
    else
        log_warning "Neovim enhanced setup had issues, but continuing installation"
    fi

    # Tmux setup
    copy_config_file "$SCRIPT_DIR/configs/tmux/.tmux.conf" "$HOME/.tmux.conf" "Tmux" || 
        log_warning "Failed to copy Tmux configuration, but continuing installation"
    
    mkdir -p "$HOME/.tmux/sessions" || log_warning "Failed to create Tmux sessions directory"
    # Copy sessions without failing if they don't exist
    cp -rf "$SCRIPT_DIR/configs/tmux/tmux-sessions/"* "$HOME/.tmux/sessions/" 2>/dev/null || 
        log_warning "Failed to copy Tmux session templates, but continuing installation"
    
    # Zsh setup
    copy_config_file "$SCRIPT_DIR/configs/zsh/.zshrc" "$HOME/.zshrc" "Zsh" || 
        log_warning "Failed to copy Zsh configuration, but continuing installation"
    
    mkdir -p "$HOME/.zsh" || log_warning "Failed to create Zsh directory"
    copy_config_file "$SCRIPT_DIR/configs/zsh/aliases.zsh" "$HOME/.zsh/aliases.zsh" "Zsh aliases" || 
        log_warning "Failed to copy Zsh aliases, but continuing installation"
    
    # Git setup
    copy_config_file "$SCRIPT_DIR/configs/git/.gitconfig" "$HOME/.gitconfig" "Git" || 
        log_warning "Failed to copy Git configuration, but continuing installation"
    
    # Setup custom functions
    setup_custom_functions || log_warning "Failed to set up custom functions, but continuing installation"
    
    CONFIGS_COPIED=true
    return 0
}

# Check for a previous installation
check_previous_installation() {
    if [[ -f "$HOME/.config/nvim/init.lua" && -f "$HOME/.tmux.conf" && -f "$HOME/.zshrc" ]]; then
    log_warning "Previous installation detected."
        read -r -p "Do you want to back up your existing configuration files before proceeding? [Y/n]: " BACKUP_CONFIG
        echo "Backup configuration: $BACKUP_CONFIG" >> "$LOG_FILE"
        
        if [[ ! "$BACKUP_CONFIG" =~ ^[Nn]$ ]]; then
            # Create backup directory with timestamp
            local backup_dir="$HOME/.config/terminal-env-backup-$(date +%Y%m%d-%H%M%S)"
            log_info "Creating backup in: $backup_dir"
            
            mkdir -p "$backup_dir" || {
                log_error "Failed to create backup directory: $backup_dir"
                return 1
            }
            
            # Backup key configuration files
            cp -r "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || log_warning "Failed to backup Neovim config"
            cp "$HOME/.tmux.conf" "$backup_dir/" 2>/dev/null || log_warning "Failed to backup Tmux config"
            cp "$HOME/.zshrc" "$backup_dir/" 2>/dev/null || log_warning "Failed to backup Zsh config"
            cp -r "$HOME/.zsh" "$backup_dir/" 2>/dev/null || log_warning "Failed to backup Zsh directory"
            cp "$HOME/.gitconfig" "$backup_dir/" 2>/dev/null || log_warning "Failed to backup Git config"
            
            log_success "Configuration backup created at: $backup_dir"
        fi
    fi
    return 0
}

# Check for recovery mode
recovery_mode() {
    # Check if we're running in recovery mode
    if [[ "${1:-}" == "--recover" ]]; then
        log_header "Running in recovery mode"
        log_info "Attempting to resume a previous installation..."
        
        # Check which components were successfully installed
        if [[ -f "$LOG_FILE" ]]; then
            log_info "Found previous installation log at: $LOG_FILE"
            
            # Check if core was installed
            if grep -q "System setup complete" "$LOG_FILE"; then
                log_success "Core environment was successfully installed previously"
                CORE_INSTALLED=true
            fi
            
            # Check if Python was installed
            if grep -q "Python environment setup complete" "$LOG_FILE"; then
                log_success "Python environment was successfully installed previously"
                PYTHON_INSTALLED=true
            elif grep -q "Python: y" "$LOG_FILE"; then
                INSTALL_PYTHON="y"
            fi
            
            # Check if Node.js was installed
            if grep -q "Node.js environment setup complete" "$LOG_FILE"; then
                log_success "Node.js environment was successfully installed previously"
                NODE_INSTALLED=true
            elif grep -q "JavaScript/Node.js: y" "$LOG_FILE"; then
                INSTALL_NODE="y"
            fi
            
            # Check if Ruby was installed
            if grep -q "Ruby environment setup complete" "$LOG_FILE"; then
                log_success "Ruby environment was successfully installed previously"
                RUBY_INSTALLED=true
            elif grep -q "Ruby: y" "$LOG_FILE"; then
                INSTALL_RUBY="y"
            fi
            
            # Check if configs were copied
            if grep -q "configuration files to" "$LOG_FILE"; then
                log_info "Configuration files were likely copied previously"
                read -r -p "Do you want to copy configuration files again? [y/N]: " COPY_CONFIGS
                if [[ "$COPY_CONFIGS" =~ ^[Yy]$ ]]; then
                    CONFIGS_COPIED=false
                else
                    CONFIGS_COPIED=true
                fi
            fi
            
            return 0
        else
            log_warning "No previous installation log found at: $LOG_FILE"
            log_info "Starting fresh installation..."
            return 1
        fi
    fi
    return 1
}

# Main function
main() {
    # Show welcome banner
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}    Enhanced Terminal Environment Installer          ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${BLUE}Setting up your full-stack development environment   ${NC}"
    echo

    # Check if we're running in recovery mode
    if ! recovery_mode "$@"; then
        # Initialize log file for a fresh installation
        init_log_file
        
        # Check for previous installation
        check_previous_installation
        
        # Prompt user for language setup preferences
        prompt_language_setup
        
        # Show installation summary and confirmation
        show_summary
    fi
    
        # Create all essential directories first
        create_essential_directories

    # Core system setup
    if [[ "$CORE_INSTALLED" == "false" ]]; then
        log_header "Setting up core environment"
        if run_script "$SCRIPT_DIR/scripts/utils/system-setup.sh" "Core environment setup failed" "core"; then
            CORE_INSTALLED=true
        fi
    fi

  # Language-specific setup based on user choices
    if [[ "$INSTALL_PYTHON" =~ ^[Yy]$ && "$PYTHON_INSTALLED" == "false" ]]; then
        log_header "Setting up Python environment"
        # Ensure Python templates directory exists
        mkdir -p "$HOME/.local/share/python-templates"
        if run_script "$SCRIPT_DIR/scripts/setup/python-setup.sh" "Python environment setup failed" "python"; then
            PYTHON_INSTALLED=true
        fi
    fi
    
    if [[ "$INSTALL_NODE" =~ ^[Yy]$ && "$NODE_INSTALLED" == "false" ]]; then
        log_header "Setting up Node.js/JavaScript environment"
        # Ensure Node templates directory exists
        mkdir -p "$HOME/.local/share/node-templates"
        if run_script "$SCRIPT_DIR/scripts/setup/node-setup.sh" "Node.js environment setup failed" "node"; then
            NODE_INSTALLED=true
        fi
    fi
    
    if [[ "$INSTALL_RUBY" =~ ^[Yy]$ && "$RUBY_INSTALLED" == "false" ]]; then
        log_header "Setting up Ruby environment"
        # Ensure Ruby templates directory exists
        mkdir -p "$HOME/.local/share/ruby-templates"
        if run_script "$SCRIPT_DIR/scripts/setup/ruby-setup.sh" "Ruby environment setup failed" "ruby"; then
            RUBY_INSTALLED=true
        fi
    fi 
    
    # Copy configuration files
    if [[ "$CONFIGS_COPIED" == "false" ]]; then
        copy_config_files
    fi
    
    # Installation complete
    log_header "Installation Complete!"
    echo -e "${GREEN}Enhanced Terminal Environment has been successfully installed!${NC}"
    echo
    
    # Print installation status
    echo -e "Installation status:"
    echo -e "  Core environment: $(if [[ "$CORE_INSTALLED" == "true" ]]; then echo "${GREEN}Installed${NC}"; else echo "${RED}Failed${NC}"; fi)"
    
    if [[ "$INSTALL_PYTHON" =~ ^[Yy]$ ]]; then
        echo -e "  Python environment: $(if [[ "$PYTHON_INSTALLED" == "true" ]]; then echo "${GREEN}Installed${NC}"; else echo "${RED}Failed${NC}"; fi)"
    fi
    
    if [[ "$INSTALL_NODE" =~ ^[Yy]$ ]]; then
        echo -e "  Node.js environment: $(if [[ "$NODE_INSTALLED" == "true" ]]; then echo "${GREEN}Installed${NC}"; else echo "${RED}Failed${NC}"; fi)"
    fi
    
    if [[ "$INSTALL_RUBY" =~ ^[Yy]$ ]]; then
        echo -e "  Ruby environment: $(if [[ "$RUBY_INSTALLED" == "true" ]]; then echo "${GREEN}Installed${NC}"; else echo "${RED}Failed${NC}"; fi)"
    fi
    
    echo -e "  Configuration files: $(if [[ "$CONFIGS_COPIED" == "true" ]]; then echo "${GREEN}Copied${NC}"; else echo "${RED}Failed${NC}"; fi)"
    echo
    
    echo -e "To finalize the setup:"
    echo -e "1. Start a new terminal session or run: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "2. Start Tmux with the command: ${YELLOW}tmux${NC}"
    echo -e "3. Inside Tmux, press ${YELLOW}Ctrl-a + I${NC} to install Tmux plugins"
    echo
    echo -e "Language-specific development sessions:"
    [[ "$INSTALL_PYTHON" =~ ^[Yy]$ && "$PYTHON_INSTALLED" == "true" ]] && echo -e "- ${YELLOW}mkpy${NC}: Create Python development environment"
    [[ "$INSTALL_NODE" =~ ^[Yy]$ && "$NODE_INSTALLED" == "true" ]] && echo -e "- ${YELLOW}mkjs${NC}: Create JavaScript/Node.js development environment"
    [[ "$INSTALL_RUBY" =~ ^[Yy]$ && "$RUBY_INSTALLED" == "true" ]] && echo -e "- ${YELLOW}mkrb${NC}: Create Ruby development environment"
    echo
    
    # If any component failed, suggest recovery mode
    if [[ "$CORE_INSTALLED" == "false" || 
          ("$INSTALL_PYTHON" =~ ^[Yy]$ && "$PYTHON_INSTALLED" == "false") || 
          ("$INSTALL_NODE" =~ ^[Yy]$ && "$NODE_INSTALLED" == "false") || 
          ("$INSTALL_RUBY" =~ ^[Yy]$ && "$RUBY_INSTALLED" == "false") || 
          "$CONFIGS_COPIED" == "false" ]]; then
        echo -e "${YELLOW}Some components failed to install. You can run:${NC}"
        echo -e "  ${YELLOW}./install.sh --recover${NC} to attempt recovery of failed components."
    fi
    
    echo -e "For complete installation details, see: ${YELLOW}$LOG_FILE${NC}"
    echo -e "${GREEN}Enjoy your enhanced terminal environment!${NC}"
}

# Run the main function with all arguments
main "$@"