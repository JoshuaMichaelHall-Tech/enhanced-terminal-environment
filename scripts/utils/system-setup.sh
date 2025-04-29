#!/bin/bash
# System setup script for Enhanced Terminal Environment
# Sets up core tools and directories

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
mkdir -p ~/.tmux/plugins
mkdir -p ~/.zsh
mkdir -p ~/.local/bin
mkdir -p ~/projects

# Install core dependencies based on OS
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
    brew install \
        neovim \
        tmux \
        zsh \
        git \
        ripgrep \
        fzf \
        fd \
        jq \
        bat \
        eza \
        htop \
        gh \
        wget \
        curl
    
    # Install database tools
    echo -e "${BLUE}Installing database tools...${NC}"
    brew install postgresql@14 mongodb-community
    
    # Install Docker
    echo -e "${BLUE}Installing Docker...${NC}"
    brew install --cask docker
    
    # Install HTTP tools
    echo -e "${BLUE}Installing HTTP tools...${NC}"
    brew install httpie
    
    # Install cloud tools
    echo -e "${BLUE}Installing cloud tools...${NC}"
    brew install awscli terraform ansible
    
elif [[ "$OS" == "Linux" ]]; then
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo apt update
    
    echo -e "${BLUE}Installing essential tools...${NC}"
    sudo apt install -y \
        build-essential \
        neovim \
        tmux \
        zsh \
        git \
        curl \
        wget \
        unzip \
        ripgrep \
        fd-find \
        fzf \
        jq \
        bat \
        htop \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common
        
    # Create symbolic links for packages with different names
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        ln -sf $(which fdfind) ~/.local/bin/fd
    fi
    
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        ln -sf $(which batcat) ~/.local/bin/bat
    fi
    
    # Install GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${BLUE}Installing GitHub CLI...${NC}"
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
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
    fi
    
    # Install PostgreSQL
    echo -e "${BLUE}Installing PostgreSQL...${NC}"
    sudo apt install -y postgresql postgresql-contrib
    
    # Install AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${BLUE}Installing AWS CLI...${NC}"
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${BLUE}Installing Terraform...${NC}"
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update
        sudo apt install -y terraform
    fi
    
    # Install Ansible
    echo -e "${BLUE}Installing Ansible...${NC}"
    sudo apt install -y ansible
    
    # Install HTTPie
    echo -e "${BLUE}Installing HTTPie...${NC}"
    sudo apt install -y httpie
fi

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${BLUE}Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Set up Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Prevent Oh My Zsh from changing the .zshrc file (we'll use our own)
    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc 2>/dev/null || true
fi

# Install Zsh plugins
echo -e "${BLUE}Installing Zsh plugins...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install FZF
if [ ! -d "$HOME/.fzf" ]; then
    echo -e "${BLUE}Installing FZF integration...${NC}"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
fi

# Set Zsh as default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}Setting Zsh as default shell...${NC}"
    chsh -s $(which zsh)
fi

echo -e "${GREEN}System setup complete!${NC}"
echo -e "${YELLOW}Note: Some changes may require logging out and back in to take effect.${NC}"
