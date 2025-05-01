#!/usr/bin/env bash
# path-management.sh - Configure path management for both architectures
# Part of Enhanced Terminal Environment

# Exit on error
set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Setup path management
setup_path_management() {
    local path_file="$HOME/.zprofile.d/path.zsh"
    mkdir -p "$HOME/.zprofile.d"
    
    cat > "$path_file" << 'EOF'
# Path Configuration for Enhanced Terminal Environment

# Architecture-specific paths
if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon paths
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
else
    # Intel paths
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="/usr/local/Cellar"
    export HOMEBREW_REPOSITORY="/usr/local"
fi

# Add common paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# Ruby - only add if exists
if [[ -d "$HOMEBREW_PREFIX/opt/ruby/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_PREFIX/opt/ruby/lib"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/ruby/include"
fi

# Python - ensure pip packages are in path
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Node.js - NVM support
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Poetry (Python package manager)
[[ -d "$HOME/.poetry/bin" ]] && export PATH="$HOME/.poetry/bin:$PATH"

# rbenv - only initialize if installed
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi
EOF

    echo -e "${GREEN}Created unified path management at $path_file${NC}"
}

# Run the function if script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_path_management
fi