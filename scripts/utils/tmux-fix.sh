#!/usr/bin/env bash
# tmux-fix.sh - Fix tmux compatibility issues on different architectures
# Part of Enhanced Terminal Environment

# Exit on error
set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fix tmux-related issues
setup_tmux_compatibility() {
    # Ensure tmux is in path
    if command -v brew &>/dev/null && brew list tmux &>/dev/null; then
        local tmux_path=$(brew --prefix)/bin/tmux
        
        # Create a compatibility check for the zsh tmux plugin
        local tmux_plugin_fix="$HOME/.zprofile.d/tmux-fix.zsh"
        mkdir -p "$HOME/.zprofile.d"
        
        cat > "$tmux_plugin_fix" << EOF
# Fix for tmux zsh plugin
if [[ -x "$tmux_path" && ! -x "\$(command -v tmux)" ]]; then
    export PATH="\$(dirname "$tmux_path"):\$PATH"
fi
EOF
        echo -e "${GREEN}Created tmux compatibility fix at $tmux_plugin_fix${NC}"
        
        # Ensure tmux plugin knows where to find tmux
        if [[ -d "$HOME/.oh-my-zsh/custom/plugins/tmux" ]]; then
            echo -e "${BLUE}Configuring tmux plugin...${NC}"
            if ! grep -q "ZSH_TMUX_AUTOSTART=true" "$HOME/.zshrc"; then
                cat >> "$HOME/.zshrc" << EOF

# Tmux plugin configuration
export ZSH_TMUX_AUTOSTART=false  # Don't autostart tmux
export ZSH_TMUX_AUTOQUIT=false   # Don't auto quit shell when tmux exits
export ZSH_TMUX_FIXTERM=true     # Fix term for proper color support
EOF
                echo -e "${GREEN}Added tmux plugin configuration to .zshrc${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}Tmux not installed via Homebrew, skipping compatibility setup${NC}"
    fi
}

# Run the function if script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_tmux_compatibility
fi