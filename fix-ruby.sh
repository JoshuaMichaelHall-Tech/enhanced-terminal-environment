#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing Ruby setup script...${NC}"

# Get the repository directory (run this from the repo root)
REPO_DIR="$(pwd)"
RUBY_SETUP_SCRIPT="${REPO_DIR}/scripts/setup/ruby-setup.sh"

# Create backup of the original script
cp "$RUBY_SETUP_SCRIPT" "${RUBY_SETUP_SCRIPT}.bak"
echo -e "${GREEN}Created backup at ${RUBY_SETUP_SCRIPT}.bak${NC}"

# Modify the setup_rvm function to use an alternative method
sed -i.tmp '
/setup_rvm() {/,/return 0/c\
setup_rvm() {\
    # If RVM is not installed, try Homebrew Ruby installation\
    if ! command_exists rvm; then\
        log_info "Installing Ruby via Homebrew..."\
        if command_exists brew; then\
            if brew install ruby; then\
                log_success "Ruby installed successfully via Homebrew"\
                # Add Ruby to PATH if not already there\
                if ! grep -q "/usr/local/opt/ruby/bin" "$HOME/.zshrc" && ! grep -q "/opt/homebrew/opt/ruby/bin" "$HOME/.zshrc"; then\
                    if [[ -d "/usr/local/opt/ruby/bin" ]]; then\
                        echo '\''export PATH="/usr/local/opt/ruby/bin:$PATH"'\'' >> "$HOME/.zshrc"\
                    elif [[ -d "/opt/homebrew/opt/ruby/bin" ]]; then\
                        echo '\''export PATH="/opt/homebrew/opt/ruby/bin:$PATH"'\'' >> "$HOME/.zshrc"\
                    fi\
                fi\
                export PATH="/opt/homebrew/opt/ruby/bin:$PATH"\
                return 0\
            else\
                log_error "Failed to install Ruby via Homebrew"\
                return 1\
            fi\
        else\
            log_warning "Homebrew not available for Ruby installation"\
            return 1\
        fi\
    else\
        log_success "RVM already installed."\
        return 0\
    fi\
}
' "$RUBY_SETUP_SCRIPT"

# Clean up temporary files
rm -f "${RUBY_SETUP_SCRIPT}.tmp"

echo -e "${GREEN}Ruby setup script fixed${NC}"
echo -e "${YELLOW}Now run the recovery script:${NC}"
echo -e "  ./install.sh --recover"