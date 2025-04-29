#!/bin/bash
# System setup script for Enhanced Terminal Environment
# Sets up core tools and directories

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Error handling function
handle_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Directory creation with error handling
create_dirs() {
    local dir="$1"
    echo -e "${BLUE}Creating directory: $dir${NC}"
    mkdir -p "$dir" || handle_error "Failed to create directory: $dir"
}

# Add Zsh shell handling
register_zsh_shell() {
    # Get the path to zsh
    local zsh_path=$(which zsh)
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        echo -e "${BLUE}Adding Zsh to standard shells...${NC}"
        echo "$zsh_path" | sudo tee -a /etc/shells || handle_error "Failed to add Zsh to /etc/shells. Try running 'sudo echo \"$zsh_path\" >> /etc/shells' manually."
    fi
}

# Command execution with error handling
run_command() {
    echo -e "${BLUE}Running: $1${NC}"
    eval "$1" || handle_error "Command failed: $1"
}

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
create_dirs ~/.config/nvim
create_dirs ~/.config/tmux
create_dirs ~/.tmux/plugins
create_dirs ~/.zsh
create_dirs ~/.local/bin
create_dirs ~/projects

# Install core dependencies based on OS
if [[ "$OS" == "macOS" ]]; then
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${BLUE}Installing Homebrew...${NC}"
        run_command "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        
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
    
    # Install essential tools with idempotence checks
    for tool in neovim tmux zsh git ripgrep fzf fd jq bat eza htop wget curl; do
        if ! brew list "$tool" &>/dev/null; then
            echo -e "${BLUE}Installing $tool...${NC}"
            brew install "$tool"
        else
            echo -e "${GREEN}$tool already installed, skipping...${NC}"
        fi
    done
    
    # Install GitHub CLI with idempotence check
    if ! brew list gh &>/dev/null; then
        echo -e "${BLUE}Installing GitHub CLI...${NC}"
        brew install gh
    else
        echo -e "${GREEN}GitHub CLI already installed, skipping...${NC}"
    fi
    
    # Install database tools with idempotence checks
    echo -e "${BLUE}Installing database tools...${NC}"
    for dbtool in postgresql@14 mongodb-atlas-cli; do
        if ! brew list "$dbtool" &>/dev/null; then
            echo -e "${BLUE}Installing $dbtool...${NC}"
            brew install "$dbtool"
        else
            echo -e "${GREEN}$dbtool already installed, skipping...${NC}"
        fi
    done
    
    # Install Docker with idempotence check
    if ! brew list --cask docker &>/dev/null; then
        echo -e "${BLUE}Installing Docker...${NC}"
        brew install --cask docker
    else
        echo -e "${GREEN}Docker already installed, skipping...${NC}"
    fi
    
    # Install HTTP tools with idempotence check
    if ! brew list httpie &>/dev/null; then
        echo -e "${BLUE}Installing HTTPie...${NC}"
        brew install httpie
    else
        echo -e "${GREEN}HTTPie already installed, skipping...${NC}"
    fi
    
    # Install cloud tools
    echo -e "${BLUE}Installing cloud tools...${NC}"
    
    # Install AWS CLI and Ansible with idempotence checks
    for cloudtool in awscli ansible; do
        if ! brew list "$cloudtool" &>/dev/null; then
            echo -e "${BLUE}Installing $cloudtool...${NC}"
            brew install "$cloudtool"
        else
            echo -e "${GREEN}$cloudtool already installed, skipping...${NC}"
        fi
    done
    
    # Terraform installation with license change handling
    if ! command -v terraform &> /dev/null && ! command -v tofu &> /dev/null; then
        echo -e "${BLUE}Installing OpenTofu (Terraform alternative)...${NC}"
        brew tap opentofu/opentofu
        brew install opentofu
        
        # Create terraform alias for compatibility
        echo 'alias terraform="tofu"' >> ~/.zsh/aliases.zsh
        
        echo -e "${YELLOW}Note: Using OpenTofu as Terraform alternative due to license changes${NC}"
        echo -e "${YELLOW}A 'terraform' alias has been created for compatibility${NC}"
    else
        echo -e "${GREEN}Terraform or OpenTofu already installed.${NC}"
    fi
    
elif [[ "$OS" == "Linux" ]]; then
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo apt update
    
    # Function to check if a package is installed
    is_installed() {
        dpkg -l "$1" 2>/dev/null | grep -q ^ii
    }
    
    echo -e "${BLUE}Installing essential tools...${NC}"
    
    # Install essential tools with idempotence checks
    for tool in build-essential neovim tmux zsh git curl wget unzip ripgrep fzf jq htop gnupg apt-transport-https ca-certificates software-properties-common; do
        if ! is_installed "$tool"; then
            echo -e "${BLUE}Installing $tool...${NC}"
            sudo apt install -y "$tool"
        else
            echo -e "${GREEN}$tool already installed, skipping...${NC}"
        fi
    done
    
    # Special case for fd-find which has a different package name
    if ! is_installed "fd-find"; then
        echo -e "${BLUE}Installing fd-find...${NC}"
        sudo apt install -y fd-find
        
        # Create symbolic link if not exists
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
            ln -sf $(which fdfind) ~/.local/bin/fd
        fi
    else
        echo -e "${GREEN}fd-find already installed, skipping...${NC}"
    fi
    
    # Special case for bat which has a different package name in Ubuntu
    if ! is_installed "bat"; then
        echo -e "${BLUE}Installing bat...${NC}"
        sudo apt install -y bat
        
        # Create symbolic link if not exists
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            ln -sf $(which batcat) ~/.local/bin/bat
        fi
    else
        echo -e "${GREEN}bat already installed, skipping...${NC}"
    fi
    
    # Install GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${BLUE}Installing GitHub CLI...${NC}"
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    else
        echo -e "${GREEN}GitHub CLI already installed.${NC}"
    fi
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${BLUE}Installing Docker...${NC}"
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo usermod -aG docker $USER
        echo -e "${YELLOW}Log out and back in for Docker permissions to take effect${NC}"
    else
        echo -e "${GREEN}Docker already installed.${NC}"
    fi
    
    # Install PostgreSQL
    if ! is_installed "postgresql"; then
        echo -e "${BLUE}Installing PostgreSQL...${NC}"
        sudo apt install -y postgresql postgresql-contrib
    else
        echo -e "${GREEN}PostgreSQL already installed.${NC}"
    fi
    
    # Install AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${BLUE}Installing AWS CLI...${NC}"
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    else
        echo -e "${GREEN}AWS CLI already installed.${NC}"
    fi
    
# Install OpenTofu
if ! command -v tofu &> /dev/null; then
    echo -e "${BLUE}Installing OpenTofu...${NC}"
    
    # Download the installer script
    curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
    
    # Give it execution permissions
    chmod +x install-opentofu.sh
    
    # Run the installer for deb-based systems
    ./install-opentofu.sh --install-method deb
    
    # Remove the installer
    rm -f install-opentofu.sh
    
    # Verify installation
    if command -v tofu &> /dev/null; then
        echo -e "${GREEN}OpenTofu installed successfully: $(tofu --version)${NC}"
    else
        echo -e "${RED}OpenTofu installation failed.${NC}"
    fi
else
    echo -e "${GREEN}OpenTofu already installed: $(tofu --version)${NC}"
fi
    
    # Install Ansible
    if ! is_installed "ansible"; then
        echo -e "${BLUE}Installing Ansible...${NC}"
        sudo apt install -y ansible
    else
        echo -e "${GREEN}Ansible already installed.${NC}"
    fi
    
    # Install HTTPie
    if ! is_installed "httpie"; then
        echo -e "${BLUE}Installing HTTPie...${NC}"
        sudo apt install -y httpie
    else
        echo -e "${GREEN}HTTPie already installed.${NC}"
    fi
fi

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${BLUE}Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo -e "${GREEN}Tmux Plugin Manager already installed.${NC}"
fi

# Set up Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Prevent Oh My Zsh from changing the .zshrc file (we'll use our own)
    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc 2>/dev/null || true
else
    echo -e "${GREEN}Oh My Zsh already installed.${NC}"
fi

# Install Zsh plugins
echo -e "${BLUE}Installing Zsh plugins...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo -e "${GREEN}zsh-autosuggestions already installed.${NC}"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo -e "${GREEN}zsh-syntax-highlighting already installed.${NC}"
fi

# Install FZF
if [ ! -d "$HOME/.fzf" ]; then
    echo -e "${BLUE}Installing FZF integration...${NC}"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
else
    echo -e "${GREEN}FZF already installed.${NC}"
fi

# Set Zsh as default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}Setting Zsh as default shell...${NC}"
    register_zsh_shell
    chsh -s "$(which zsh)" || handle_error "Failed to change shell to Zsh. Try running 'chsh -s $(which zsh)' manually."
else
    echo -e "${GREEN}Zsh already set as default shell.${NC}"
fi

echo -e "${GREEN}System setup complete!${NC}"
echo -e "${YELLOW}Note: Some changes may require logging out and back in to take effect.${NC}"
