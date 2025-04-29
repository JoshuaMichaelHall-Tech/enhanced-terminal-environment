#!/usr/bin/env bash
# System setup script for Enhanced Terminal Environment
# Sets up core tools and directories with improved error handling and cross-platform compatibility
# Version: 2.0

# Exit on error, undefined variables, and propagate pipe failures
set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Script directory (resolving symlinks)
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

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

# Error handling function
handle_error() {
    log_error "$1"
    exit 1
}

# Trap for cleanup on script exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code $exit_code"
    fi
    # Add any cleanup tasks here
    exit $exit_code
}
trap cleanup EXIT

# Directory creation with error handling
create_dirs() {
    local dir="$1"
    log_info "Creating directory: $dir"
    mkdir -p "$dir" || handle_error "Failed to create directory: $dir"
}

# Command execution with error handling
run_command() {
    local cmd="$1"
    local error_msg="${2:-Command failed: $cmd}"
    
    log_info "Running: $cmd"
    if ! eval "$cmd"; then
        handle_error "$error_msg"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a package is installed (Debian/Ubuntu)
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Install a package if not installed (macOS)
install_brew_package() {
    local package="$1"
    local package_type="${2:-formula}" # formula or cask
    
    if [[ "$package_type" == "cask" ]]; then
        if ! brew list --cask "$package" &>/dev/null; then
            log_info "Installing $package..."
            brew install --cask "$package" || handle_error "Failed to install $package"
        else
            log_success "$package already installed, skipping..."
        fi
    else
        if ! brew list "$package" &>/dev/null; then
            log_info "Installing $package..."
            brew install "$package" || handle_error "Failed to install $package"
        else
            log_success "$package already installed, skipping..."
        fi
    fi
}

# Install a package if not installed (Debian/Ubuntu)
install_apt_package() {
    local package="$1"
    
    if ! package_installed "$package"; then
        log_info "Installing $package..."
        sudo apt install -y "$package" || handle_error "Failed to install $package"
    else
        log_success "$package already installed, skipping..."
    fi
}

# Add Zsh shell to /etc/shells
register_zsh_shell() {
    # Get the path to zsh
    local zsh_path
    zsh_path="$(command -v zsh)" || handle_error "Zsh not found in PATH"
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "Adding Zsh to standard shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null || 
            handle_error "Failed to add Zsh to /etc/shells. Try running 'sudo echo \"$zsh_path\" >> /etc/shells' manually."
    fi
}

# Setup symbolic links
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ ! -e "$target" ]]; then
        log_info "Creating symbolic link: $source -> $target"
        ln -sf "$source" "$target" || handle_error "Failed to create symbolic link"
    else
        log_success "Symbolic link already exists: $target"
    fi
}

# Setup OpenTofu (Terraform alternative)
setup_opentofu() {
    if ! command_exists "tofu"; then
        log_info "Installing OpenTofu (Terraform alternative)..."
        
        if [[ "$OS" == "macOS" ]]; then
            # Try direct homebrew installation
            if brew install opentofu; then
                log_success "OpenTofu installed successfully via Homebrew"
            else
                log_warning "Homebrew installation failed, trying alternative method..."
                
                # Alternative method using the official installer
                local installer_script="install-opentofu.sh"
                log_info "Downloading OpenTofu installer..."
                
                if curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o "$installer_script"; then
                    chmod +x "$installer_script"
                    
                    log_info "Running OpenTofu installer with brew method..."
                    if ./"$installer_script" --install-method brew; then
                        log_success "OpenTofu installed successfully with official installer"
                    else
                        log_warning "OpenTofu installation failed, falling back to Terraform..."
                        
                        # Install Terraform as fallback
                        if brew install terraform; then
                            log_success "Terraform installed successfully"
                            # Create alias for compatibility
                            mkdir -p "$HOME/.zsh"
                            echo 'alias tofu="terraform"' >> "$HOME/.zsh/aliases.zsh"
                            log_info "Created 'tofu' alias for terraform"
                        else
                            log_warning "Both OpenTofu and Terraform installation failed."
                            log_warning "Continuing without IaC tools. You may need to install them manually."
                        fi
                    fi
                    
                    # Clean up installer script
                    rm -f "$installer_script"
                else
                    log_warning "Failed to download OpenTofu installer, trying Terraform instead..."
                    
                    # Install Terraform as fallback
                    if brew install terraform; then
                        log_success "Terraform installed successfully"
                        # Create alias for compatibility
                        mkdir -p "$HOME/.zsh"
                        echo 'alias tofu="terraform"' >> "$HOME/.zsh/aliases.zsh"
                        log_info "Created 'tofu' alias for terraform"
                    else
                        log_warning "Both OpenTofu and Terraform installation failed."
                        log_warning "Continuing without IaC tools. You may need to install them manually."
                    fi
                }
            fi
        elif [[ "$OS" == "Linux" ]]; then
            # Download and run the installer script
            local installer_script="install-opentofu.sh"
            if curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o "$installer_script"; then
                chmod +x "$installer_script"
                
                # Run the installer for deb-based systems
                if ./"$installer_script" --install-method deb; then
                    log_success "OpenTofu installed successfully with official installer"
                else
                    log_warning "OpenTofu installation failed, falling back to Terraform..."
                    
                    # Try to install Terraform as fallback
                    if apt-get update && apt-get install -y terraform; then
                        log_success "Terraform installed successfully"
                        # Create alias for compatibility
                        echo 'alias tofu="terraform"' >> "$HOME/.zsh/aliases.zsh"
                        log_info "Created 'tofu' alias for terraform"
                    else
                        log_warning "Both OpenTofu and Terraform installation failed."
                        log_warning "Continuing without IaC tools. You may need to install them manually."
                    fi
                fi
                
                # Remove the installer
                rm -f "$installer_script"
            else
                log_warning "Failed to download OpenTofu installer, trying Terraform instead..."
                
                # Try to install Terraform as fallback
                if apt-get update && apt-get install -y terraform; then
                    log_success "Terraform installed successfully"
                    # Create alias for compatibility
                    echo 'alias tofu="terraform"' >> "$HOME/.zsh/aliases.zsh"
                    log_info "Created 'tofu' alias for terraform"
                else
                    log_warning "Both OpenTofu and Terraform installation failed."
                    log_warning "Continuing without IaC tools. You may need to install them manually."
                fi
            fi
        fi
        
        # Verify installation
        if command_exists "tofu"; then
            log_success "OpenTofu available as command: $(tofu version | head -n1)"
        elif command_exists "terraform"; then
            log_success "Terraform installed with 'tofu' alias: $(terraform version | head -n1)"
        else
            log_warning "No IaC tool detected. You may need to install OpenTofu or Terraform manually."
        fi
    else
        log_success "OpenTofu already installed: $(tofu version | head -n1)"
    fi
    
    return 0
}
        
        # Create terraform alias for compatibility if not already exists
        if ! grep -q "alias terraform" "$HOME/.zsh/aliases.zsh" 2>/dev/null; then
            mkdir -p "$HOME/.zsh"
            echo 'alias terraform="tofu"' >> "$HOME/.zsh/aliases.zsh"
        fi
        
        # Verify installation
        if command_exists "tofu"; then
            log_success "OpenTofu installed successfully: $(tofu version | head -n1)"
        else
            log_error "OpenTofu installation failed. Please install manually."
            log_warning "Visit https://opentofu.org/docs/intro/install/ for installation guides."
        fi
    else
        log_success "OpenTofu already installed: $(tofu version | head -n1)"
    fi
}

# Main function
main() {
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        readonly OS="macOS"
        log_info "Detected macOS system"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        readonly OS="Linux"
        log_info "Detected Linux system"
    else
        handle_error "Unsupported operating system: $OSTYPE"
    fi

    # Create necessary directories
    log_info "Creating configuration directories..."
    create_dirs "$HOME/.config/nvim"
    create_dirs "$HOME/.config/tmux"
    create_dirs "$HOME/.tmux/plugins"
    create_dirs "$HOME/.zsh"
    create_dirs "$HOME/.local/bin"
    create_dirs "$HOME/projects"

    # Install core dependencies based on OS
    if [[ "$OS" == "macOS" ]]; then
        # Check for Homebrew
        if ! command_exists "brew"; then
            log_info "Installing Homebrew..."
            run_command '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
                "Failed to install Homebrew"
            
            # Add Homebrew to PATH based on architecture
            if [[ "$(uname -m)" == "arm64" ]]; then
                if ! grep -q "opt/homebrew/bin/brew" "$HOME/.zshrc"; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
                fi
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                if ! grep -q "usr/local/bin/brew" "$HOME/.zshrc"; then
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zshrc"
                fi
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            log_success "Homebrew already installed"
        fi
        
        log_info "Installing essential tools..."
        
        # Essential tools
        local tools=(
            "neovim"
            "tmux"
            "zsh"
            "git"
            "ripgrep"
            "fzf"
            "fd"
            "jq"
            "bat"
            "eza"
            "htop"
            "wget"
            "curl"
        )
        
        for tool in "${tools[@]}"; do
            install_brew_package "$tool"
        done
        
        # Install GitHub CLI
        install_brew_package "gh"
        
        # Database tools
        log_info "Installing database tools..."
        install_brew_package "postgresql@14"
        install_brew_package "mongodb-atlas-cli"
        
        # Install Docker
        log_info "Installing Docker..."
        install_brew_package "docker" "cask"
        
        # Install HTTP tools
        log_info "Installing HTTP tools..."
        install_brew_package "httpie"
        
        # Install cloud tools
        log_info "Installing cloud tools..."
        install_brew_package "awscli"
        install_brew_package "ansible"
        
        # Install OpenTofu
        setup_opentofu
        
    elif [[ "$OS" == "Linux" ]]; then
        log_info "Updating package lists..."
        run_command "sudo apt update" "Failed to update package lists"
        
        log_info "Installing essential tools..."
        
        # Essential tools for Linux
        local tools=(
            "build-essential"
            "neovim"
            "tmux"
            "zsh"
            "git"
            "curl"
            "wget"
            "unzip"
            "ripgrep"
            "fd-find"
            "fzf"
            "jq"
            "bat"
            "htop"
            "gnupg"
            "apt-transport-https"
            "ca-certificates"
            "software-properties-common"
        )
        
        for tool in "${tools[@]}"; do
            install_apt_package "$tool"
        done
        
        # Create symbolic links for packages with different names
        if command_exists "fdfind" && ! command_exists "fd"; then
            create_symlink "$(which fdfind)" "$HOME/.local/bin/fd"
        fi
        
        if command_exists "batcat" && ! command_exists "bat"; then
            create_symlink "$(which batcat)" "$HOME/.local/bin/bat"
        fi
        
        # Install GitHub CLI
        if ! command_exists "gh"; then
            log_info "Installing GitHub CLI..."
            run_command "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg" \
                "Failed to download GitHub CLI GPG key"
            run_command "sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg" \
                "Failed to set permissions on GitHub CLI GPG key"
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | 
                sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            run_command "sudo apt update" "Failed to update package lists after adding GitHub CLI repository"
            run_command "sudo apt install -y gh" "Failed to install GitHub CLI"
        else
            log_success "GitHub CLI already installed"
        fi
        
        # Install Docker
        if ! command_exists "docker"; then
            log_info "Installing Docker..."
            run_command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" \
                "Failed to download Docker GPG key"
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | 
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            run_command "sudo apt update" "Failed to update package lists after adding Docker repository"
            run_command "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin" \
                "Failed to install Docker"
            run_command "sudo usermod -aG docker $USER" "Failed to add user to Docker group"
            log_warning "Log out and back in for Docker permissions to take effect"
        else
            log_success "Docker already installed"
        fi
        
        # Install PostgreSQL
        if ! package_installed "postgresql"; then
            log_info "Installing PostgreSQL..."
            run_command "sudo apt install -y postgresql postgresql-contrib" "Failed to install PostgreSQL"
        else
            log_success "PostgreSQL already installed"
        fi
        
        # Install AWS CLI
        if ! command_exists "aws"; then
            log_info "Installing AWS CLI..."
            run_command "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'" \
                "Failed to download AWS CLI"
            run_command "unzip -q awscliv2.zip" "Failed to extract AWS CLI"
            run_command "sudo ./aws/install" "Failed to install AWS CLI"
            run_command "rm -rf aws awscliv2.zip" "Failed to clean up AWS CLI installation files"
        else
            log_success "AWS CLI already installed"
        fi
        
        # Install OpenTofu
        setup_opentofu
        
        # Install Ansible
        if ! package_installed "ansible"; then
            log_info "Installing Ansible..."
            run_command "sudo apt install -y ansible" "Failed to install Ansible"
        else
            log_success "Ansible already installed"
        fi
        
        # Install HTTPie
        if ! package_installed "httpie"; then
            log_info "Installing HTTPie..."
            run_command "sudo apt install -y httpie" "Failed to install HTTPie"
        else
            log_success "HTTPie already installed"
        fi
    fi

    # Install Tmux Plugin Manager
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing Tmux Plugin Manager..."
        run_command "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" \
            "Failed to clone Tmux Plugin Manager repository"
    else
        log_success "Tmux Plugin Manager already installed"
    fi

    # Set up Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        run_command 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' \
            "Failed to install Oh My Zsh"
        
        # Prevent Oh My Zsh from changing the .zshrc file (we'll use our own)
        if [[ -f "$HOME/.zshrc.pre-oh-my-zsh" ]]; then
            mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc" 
        fi
    else
        log_success "Oh My Zsh already installed"
    fi

    # Install Zsh plugins
    log_info "Installing Zsh plugins..."
    readonly ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Install zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        run_command "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions" \
            "Failed to clone zsh-autosuggestions repository"
    else
        log_success "zsh-autosuggestions already installed"
    fi

    # Install zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        run_command "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" \
            "Failed to clone zsh-syntax-highlighting repository"
    else
        log_success "zsh-syntax-highlighting already installed"
    fi

    # Install FZF
    if [[ ! -d "$HOME/.fzf" ]]; then
        log_info "Installing FZF integration..."
        run_command "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf" \
            "Failed to clone FZF repository"
        run_command "~/.fzf/install --all --no-bash --no-fish" \
            "Failed to install FZF"
    else
        log_success "FZF already installed"
    fi

    # Set Zsh as default shell if it isn't already
    local current_shell
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [[ "$current_shell" != "$(which zsh)" ]]; then
        log_info "Setting Zsh as default shell..."
        register_zsh_shell
        run_command "chsh -s $(which zsh)" \
            "Failed to change shell to Zsh. Try running 'chsh -s $(which zsh)' manually."
    else
        log_success "Zsh already set as default shell"
    fi

    log_success "System setup complete!"
    log_warning "Some changes may require logging out and back in to take effect."
}

# Execute main function
main "$@"