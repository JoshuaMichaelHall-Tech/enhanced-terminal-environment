#!/usr/bin/env bash
# Fix script for PEP 668 issues with pip on macOS
# Enhanced Terminal Environment

# Exit on undefined variables
set -u

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

echo -e "${BLUE}Enhanced Terminal Environment - PEP 668 Fix Script${NC}"
echo -e "${YELLOW}This script helps resolve issues with Python PEP 668 restrictions.${NC}"
echo

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Please install Python 3 first.${NC}"
    exit 1
fi

echo -e "${BLUE}Python version:${NC} $(python3 --version)"

# Install pipx if not already installed
if ! command -v pipx &> /dev/null; then
    echo -e "${YELLOW}pipx not found, attempting to install via Homebrew...${NC}"
    
    if command -v brew &> /dev/null; then
        echo -e "${BLUE}Installing pipx via Homebrew...${NC}"
        if brew install pipx; then
            echo -e "${GREEN}pipx installed successfully via Homebrew.${NC}"
            echo -e "${BLUE}Configuring pipx...${NC}"
            pipx ensurepath
            echo -e "${GREEN}pipx configured.${NC}"
        else
            echo -e "${RED}Failed to install pipx via Homebrew.${NC}"
            echo -e "${YELLOW}Attempting alternative installation methods...${NC}"
            
            # Try creating a virtual environment for pip
            echo -e "${BLUE}Creating a virtual environment for Python tools...${NC}"
            if python3 -m venv "${HOME}/.local/pipx-env"; then
                echo -e "${GREEN}Virtual environment created.${NC}"
                source "${HOME}/.local/pipx-env/bin/activate"
                
                echo -e "${BLUE}Installing pipx in virtual environment...${NC}"
                if python3 -m pip install pipx; then
                    echo -e "${GREEN}pipx installed in virtual environment.${NC}"
                    
                    # Create symlink to pipx
                    mkdir -p "${HOME}/.local/bin"
                    ln -sf "${HOME}/.local/pipx-env/bin/pipx" "${HOME}/.local/bin/pipx"
                    
                    echo -e "${BLUE}Adding to PATH...${NC}"
                    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "${HOME}/.zshrc"; then
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
                    fi
                    
                    export PATH="${HOME}/.local/bin:${PATH}"
                    echo -e "${GREEN}pipx installed and configured.${NC}"
                else
                    echo -e "${RED}Failed to install pipx in virtual environment.${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Failed to create virtual environment.${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${RED}Homebrew is not installed. Cannot install pipx.${NC}"
        echo -e "${YELLOW}Please install Homebrew first:${NC}"
        echo -e "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
else
    echo -e "${GREEN}pipx is already installed.${NC}"
fi

# Install Poetry if not already installed
if ! command -v poetry &> /dev/null; then
    echo -e "${YELLOW}Poetry not found, attempting to install...${NC}"
    
    # Create temporary directory for the installer
    TEMPDIR=$(mktemp -d)
    INSTALLER="${TEMPDIR}/install-poetry.py"
    
    # Download the installer
    echo -e "${BLUE}Downloading Poetry installer...${NC}"
    if curl -sSL https://install.python-poetry.org -o "${INSTALLER}"; then
        echo -e "${GREEN}Poetry installer downloaded.${NC}"
        
        # Run the installer
        echo -e "${BLUE}Running Poetry installer...${NC}"
        if python3 "${INSTALLER}" --yes; then
            echo -e "${GREEN}Poetry installed successfully.${NC}"
            
            # Add Poetry to PATH if not already
            if ! grep -q "poetry/bin" "${HOME}/.zshrc"; then
                echo -e "${BLUE}Adding Poetry to PATH...${NC}"
                echo 'export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH"' >> "${HOME}/.zshrc"
                echo -e "${GREEN}Added Poetry to PATH in .zshrc${NC}"
            fi
            
            # For immediate availability
            export PATH="${HOME}/.local/bin:${HOME}/.poetry/bin:${PATH}"
        else
            echo -e "${RED}Failed to install Poetry.${NC}"
        fi
        
        # Clean up
        rm -rf "${TEMPDIR}"
    else
        echo -e "${RED}Failed to download Poetry installer.${NC}"
        rm -rf "${TEMPDIR}"
    fi
else
    echo -e "${GREEN}Poetry is already installed.${NC}"
fi

# Resume Python setup
echo -e "${BLUE}Now you can run the Python setup script again.${NC}"
echo -e "${YELLOW}Run the following command to continue installation:${NC}"
echo -e "  cd $(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
echo -e "  ./install.sh --recover"
echo
echo -e "${GREEN}Fix script completed.${NC}"