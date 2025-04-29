#!/bin/bash
# Fix script for OpenTofu/Terraform installation

set -euo pipefail

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Attempting to install OpenTofu using current method...${NC}"

# Try the current method of installing OpenTofu
if ! command -v tofu &> /dev/null; then
    # Try direct download method
    if curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh; then
        chmod +x install-opentofu.sh
        ./install-opentofu.sh || echo -e "${YELLOW}OpenTofu installation script failed${NC}"
        rm -f install-opentofu.sh
    else
        echo -e "${YELLOW}Could not download OpenTofu installer${NC}"
    fi
    
    # If OpenTofu installation failed, try Terraform
    if ! command -v tofu &> /dev/null; then
        echo -e "${YELLOW}OpenTofu installation failed, trying Terraform instead...${NC}"
        if brew install terraform; then
            echo -e "${GREEN}Terraform installed successfully${NC}"
            # Create alias for compatibility
            echo 'alias tofu="terraform"' >> ~/.zsh/aliases.zsh
            echo -e "${BLUE}Created 'tofu' alias for terraform${NC}"
        else
            echo -e "${YELLOW}Terraform installation failed. Continuing without Terraform/OpenTofu...${NC}"
        fi
    else
        echo -e "${GREEN}OpenTofu installed successfully${NC}"
    fi
else
    echo -e "${GREEN}OpenTofu already installed${NC}"
fi

echo -e "${GREEN}Installation fix complete. Continue with other configuration steps.${NC}"