#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing Python setup script...${NC}"

# Get the repository directory (run this from the repo root)
REPO_DIR="$(pwd)"
PYTHON_SETUP_SCRIPT="${REPO_DIR}/scripts/setup/python-setup.sh"

# Create backup of the original script
cp "$PYTHON_SETUP_SCRIPT" "${PYTHON_SETUP_SCRIPT}.bak2"
echo -e "${GREEN}Created backup at ${PYTHON_SETUP_SCRIPT}.bak2${NC}"

# Fix the create_templates_dir function by correcting its syntax
sed -i.tmp '
/^create_templates_dir() {/,/^}/c\
create_templates_dir() {\
    local dir="$HOME/.local/share/python-templates"\
    \
    mkdir -p "$dir" || handle_error "Failed to create templates directory"\
    \
    echo "$dir"\
}
' "$PYTHON_SETUP_SCRIPT"

# Clean up temporary files
rm -f "${PYTHON_SETUP_SCRIPT}.tmp"

echo -e "${GREEN}Python setup script fixed${NC}"
echo -e "${YELLOW}Now run the recovery script:${NC}"
echo -e "  ./install.sh --recover"