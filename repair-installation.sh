#!/usr/bin/env bash
# repair-installation.sh - Fix architecture-specific issues for Enhanced Terminal Environment
# For use on both Intel and Apple Silicon Macs

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Enhanced Terminal Environment Repair Script =====${NC}"
echo -e "${BLUE}Detecting and fixing architecture-specific issues...${NC}"

# Detect architecture
if [[ "$(uname -m)" == "arm64" ]]; then
    ARCH="Apple Silicon (arm64)"
    BREW_PATH="/opt/homebrew/bin/brew"
else
    ARCH="Intel (x86_64)"
    BREW_PATH="/usr/local/bin/brew"
fi

echo -e "${GREEN}Detected architecture: $ARCH${NC}"

# 1. Create modular profile structure
echo -e "${BLUE}Setting up modular profile structure...${NC}"
mkdir -p "$HOME/.zprofile.d"

if [[ ! -f "$HOME/.zprofile" || ! -d "$HOME/.zprofile.d" ]]; then
    echo '# Load modular profile configs' > "$HOME/.zprofile"
    echo 'for conf in $HOME/.zprofile.d/*.zsh; do' >> "$HOME/.zprofile"
    echo '  [[ -f $conf ]] && source $conf' >> "$HOME/.zprofile"
    echo 'done' >> "$HOME/.zprofile"
    echo -e "${GREEN}Created modular .zprofile${NC}"
else
    echo -e "${YELLOW}Modular .zprofile already exists${NC}"
fi

# 2. Fix Homebrew path
echo -e "${BLUE}Configuring Homebrew for $ARCH...${NC}"
if [[ -x "$BREW_PATH" ]]; then
    echo "eval \"\$($BREW_PATH shellenv)\"" > "$HOME/.zprofile.d/10-homebrew.zsh"
    echo -e "${GREEN}Configured Homebrew path${NC}"
else
    echo -e "${YELLOW}Homebrew not found at $BREW_PATH${NC}"
fi

# 3. Setup universal path management
echo -e "${BLUE}Setting up universal path management...${NC}"
cat > "$HOME/.zprofile.d/20-paths.zsh" << EOF
# Architecture-specific path configuration

# Base paths always needed
export PATH="\$HOME/.local/bin:\$PATH"

# Architecture-specific Homebrew paths
if [[ "\$(uname -m)" == "arm64" ]]; then
    # Apple Silicon
    [[ -d "/opt/homebrew/bin" ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:\$PATH"
    [[ -d "/opt/homebrew/opt/ruby/bin" ]] && export PATH="/opt/homebrew/opt/ruby/bin:\$PATH"
else
    # Intel
    [[ -d "/usr/local/bin" ]] && export PATH="/usr/local/bin:/usr/local/sbin:\$PATH"
    [[ -d "/usr/local/opt/ruby/bin" ]] && export PATH="/usr/local/opt/ruby/bin:\$PATH"
fi

# Common tool paths
[[ -d "\$HOME/.poetry/bin" ]] && export PATH="\$HOME/.poetry/bin:\$PATH"
[[ -d "\$HOME/.cargo/bin" ]] && export PATH="\$HOME/.cargo/bin:\$PATH"
EOF

echo -e "${GREEN}Created universal path configuration${NC}"

# 4. Create rbenv configuration (only if installed)
if command -v brew &>/dev/null && brew list rbenv &>/dev/null; then
    echo -e "${BLUE}Configuring rbenv...${NC}"
    echo 'command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"' > "$HOME/.zprofile.d/30-rbenv.zsh"
    echo -e "${GREEN}Configured rbenv${NC}"
fi

# 5. Create nvm configuration (only if installed)
if [[ -d "$HOME/.nvm" ]]; then
    echo -e "${BLUE}Configuring nvm...${NC}"
    cat > "$HOME/.zprofile.d/40-nvm.zsh" << 'EOF'
# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
    echo -e "${GREEN}Configured nvm${NC}"
fi

# 6. Fix potential syntax errors in functions.sh
if [[ -f "$HOME/.local/bin/functions.sh" ]]; then
    echo -e "${BLUE}Checking for syntax errors in functions.sh...${NC}"
    if ! zsh -n "$HOME/.local/bin/functions.sh" 2>/dev/null; then
        echo -e "${YELLOW}Syntax errors detected in functions.sh${NC}"
        echo -e "${BLUE}Creating backup...${NC}"
        cp "$HOME/.local/bin/functions.sh" "$HOME/.local/bin/functions.sh.bak.$(date +%Y%m%d%H%M%S)"
        
        # Check for common syntax errors and fix
        echo -e "${BLUE}Attempting to fix common syntax errors...${NC}"
        sed -i.bak -e 's/if\s*\[\[.*\]\]\s*$/& then/' "$HOME/.local/bin/functions.sh"
        sed -i.bak -e 's/}\s*if\s*\[\[/}; if [[/' "$HOME/.local/bin/functions.sh"
        sed -i.bak -e 's/fi\s*if\s*\[\[/fi; if [[/' "$HOME/.local/bin/functions.sh"
        sed -i.bak -e 's/else\s*if\s*\[\[/else; if [[/' "$HOME/.local/bin/functions.sh"
        
        # Check if fixed
        if zsh -n "$HOME/.local/bin/functions.sh" 2>/dev/null; then
            echo -e "${GREEN}Successfully fixed syntax errors in functions.sh${NC}"
            rm -f "$HOME/.local/bin/functions.sh.bak"
        else
            echo -e "${RED}Could not automatically fix functions.sh${NC}"
            echo -e "${YELLOW}Manual inspection required${NC}"
        fi
    else
        echo -e "${GREEN}No syntax errors found in functions.sh${NC}"
    fi
fi

# 7. Ensure proper sourcing in .zshrc
echo -e "${BLUE}Checking .zshrc configuration...${NC}"
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "source.*zprofile" "$HOME/.zshrc"; then
        echo -e "${BLUE}Adding .zprofile sourcing to .zshrc...${NC}"
        echo -e "\n# Source .zprofile for consistent environment\n[[ -f \$HOME/.zprofile ]] && source \$HOME/.zprofile" >> "$HOME/.zshrc"
        echo -e "${GREEN}Added .zprofile sourcing to .zshrc${NC}"
    else
        echo -e "${GREEN}.zprofile already sourced in .zshrc${NC}"
    fi
fi

echo -e "${GREEN}Repair completed!${NC}"
echo -e "${BLUE}Please restart your terminal or run 'source ~/.zprofile' to apply changes.${NC}"