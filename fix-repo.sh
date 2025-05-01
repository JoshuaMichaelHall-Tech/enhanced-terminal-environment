#!/usr/bin/env bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing Python setup script...${NC}"

# Get repo directory (assuming this script is in the repo root)
REPO_DIR="$(pwd)"
PYTHON_SETUP_SCRIPT="${REPO_DIR}/scripts/setup/python-setup.sh"

if [[ ! -f "$PYTHON_SETUP_SCRIPT" ]]; then
    echo -e "${RED}Error: Python setup script not found at ${PYTHON_SETUP_SCRIPT}${NC}"
    echo -e "${YELLOW}Please run this script from the repository root directory${NC}"
    exit 1
fi

# Create backup of the original script
cp "$PYTHON_SETUP_SCRIPT" "${PYTHON_SETUP_SCRIPT}.bak"
echo -e "${GREEN}Created backup at ${PYTHON_SETUP_SCRIPT}.bak${NC}"

# Fix the create_templates_dir function in the script
# This ensures the function runs without errors and creates dirs as needed
sed -i.tmp '
/^create_templates_dir() {/,/^}/c\
create_templates_dir() {\
    local dir="$HOME/.local/share/python-templates"\
    \
    echo "Creating Python templates directory: $dir"\
    mkdir -p "$dir" || { echo -e "${RED}ERROR: Failed to create templates directory${NC}" >&2; return 1; }\
    \
    # Explicitly return the directory path\
    echo "$dir"\
}
' "$PYTHON_SETUP_SCRIPT"

# Ensure proper error handling when saving the template script
sed -i.tmp2 's/chmod +x "\$template_script"/chmod +x "\$template_script" || handle_error "Failed to make template script executable"/' "$PYTHON_SETUP_SCRIPT"

# Clean up temp files
rm -f "${PYTHON_SETUP_SCRIPT}.tmp" "${PYTHON_SETUP_SCRIPT}.tmp2"

echo -e "${GREEN}Fixed Python setup script${NC}"
echo -e "${YELLOW}Now manually create the templates directory:${NC}"
echo -e "  mkdir -p ~/.local/share/python-templates"
echo -e "${YELLOW}Then run the recovery script:${NC}"
echo -e "  ./install.sh --recover"