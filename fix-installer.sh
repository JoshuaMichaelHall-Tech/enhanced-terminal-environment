#!/usr/bin/env bash
# fix-installer.sh - Comprehensive fix for the Enhanced Terminal Environment installer
# Addresses common issues with setup scripts and prevents installation failures
# Version: 1.0

# Exit on error, undefined variables, and propagate pipe failures
set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Script directory (resolving symlinks)
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Log functions
log_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

log_header() {
    echo -e "\n${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}$(printf '=%.0s' {1..60})${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Ensure directory exists with proper permissions
ensure_directory() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating directory: $dir"
        if mkdir -p "$dir"; then
            chmod 755 "$dir"
            log_success "Directory created: $dir"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    else
        log_info "Directory already exists: $dir"
        # Verify permissions
        if [[ -w "$dir" ]]; then
            log_success "Directory is writable: $dir"
        else
            log_warning "Directory exists but is not writable: $dir"
            if ! chmod 755 "$dir"; then
                log_warning "Failed to make directory writable: $dir"
            fi
        fi
    fi
    
    return 0
}

# Fix Python setup script
fix_python_setup() {
    log_header "Fixing Python Setup Script"
    
    local python_script="$SCRIPT_DIR/scripts/setup/python-setup.sh"
    
    if [[ ! -f "$python_script" ]]; then
        log_error "Python setup script not found at: $python_script"
        return 1
    fi
    
    # Create backup
    local backup_file="${python_script}.bak-$(date +%Y%m%d%H%M%S)"
    log_info "Creating backup of Python setup script at: $backup_file"
    cp "$python_script" "$backup_file" || {
        log_error "Failed to create backup of Python setup script"
        return 1
    }
    
    log_info "Fixing create_templates_dir function..."
    # Fix the create_templates_dir function
    sed -i.tmp '
/^create_templates_dir() {/,/^}/c\
create_templates_dir() {\
    local dir="$HOME/.local/share/python-templates"\
    \
    if [[ ! -d "$dir" ]]; then\
        log_info "Creating Python templates directory: $dir"\
        mkdir -p "$dir" || handle_error "Failed to create templates directory"\
    fi\
    \
    # Return directory path\
    echo "$dir"\
}
' "$python_script"

    # Fix PEP 668 compatibility for macOS
    log_info "Improving PEP 668 compatibility..."
    sed -i.tmp2 '
/# Install pipx using Homebrew/,/log_success "pipx already installed"/c\
        # Install pipx using Homebrew (PEP 668 compatible approach)\
        if ! command_exists pipx; then\
            log_info "Installing pipx via Homebrew..."\
            if ! brew install pipx; then\
                log_warning "Failed to install pipx via Homebrew, trying alternative..."\
                # Create virtual environment for pipx\
                log_info "Creating virtual environment for Python tools..."\
                python3 -m venv "$HOME/.local/pipx-env" || handle_error "Failed to create virtual environment"\
                source "$HOME/.local/pipx-env/bin/activate" || handle_error "Failed to activate virtual environment"\
                python3 -m pip install pipx || handle_error "Failed to install pipx in virtual environment"\
                \
                # Create symlink to pipx\
                mkdir -p "$HOME/.local/bin"\
                ln -sf "$HOME/.local/pipx-env/bin/pipx" "$HOME/.local/bin/pipx"\
                \
                # Add to PATH if not already there\
                if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc"; then\
                    echo '"'"'export PATH="$HOME/.local/bin:$PATH"'"'"' >> "$HOME/.zshrc"\
                fi\
                \
                # Add to current session\
                export PATH="$HOME/.local/bin:$PATH"\
            fi\
            \
            # Ensure pipx binaries are in PATH\
            if command_exists pipx; then\
                log_info "Configuring pipx..."\
                pipx ensurepath || log_warning "Failed to add pipx to PATH"\
            fi\
        else\
            log_success "pipx already installed"\
        fi
' "$python_script"

    # Clean up temp files
    rm -f "${python_script}.tmp" "${python_script}.tmp2"
    
    # Verify file syntax
    if bash -n "$python_script"; then
        log_success "Python setup script fixed successfully"
    else
        log_error "Python setup script has syntax errors after fixing"
        log_info "Restoring backup..."
        cp "$backup_file" "$python_script"
        return 1
    fi
    
    return 0
}

# Fix Node.js setup script
fix_nodejs_setup() {
    log_header "Fixing Node.js Setup Script"
    
    local node_script="$SCRIPT_DIR/scripts/setup/node-setup.sh"
    
    if [[ ! -f "$node_script" ]]; then
        log_error "Node.js setup script not found at: $node_script"
        return 1
    fi
    
    # Create backup
    local backup_file="${node_script}.bak-$(date +%Y%m%d%H%M%S)"
    log_info "Creating backup of Node.js setup script at: $backup_file"
    cp "$node_script" "$backup_file" || {
        log_error "Failed to create backup of Node.js setup script"
        return 1
    }
    
    log_info "Improving NVM installation logic..."
    # Fix the setup_nvm function to properly handle existing Node.js installations
    sed -i.tmp '
/setup_nvm() {/,/return 0/c\
setup_nvm() {\
    # Check if Node.js is already installed\
    if command_exists node && command_exists npm; then\
        log_success "Node.js $(node --version) and npm $(npm --version) already installed"\
        NODE_INSTALLED=true\
        return 0\
    fi\
\
    # If NVM is not installed\
    if [[ ! -d "$HOME/.nvm" ]]; then\
        log_info "Installing NVM (Node Version Manager)..."\
        \
        # Download and run the NVM installer\
        if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then \
            log_warning "Failed to install NVM using curl, trying wget..."\
            if ! wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then\
                log_error "Failed to install NVM"\
                return 1\
            fi\
        fi\
        \
        # Add NVM to shell profile if not already there\
        if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then\
            cat >> "$HOME/.zshrc" << '"'"'EOL'"'"'\

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOL\
        fi\
        \
        # Load NVM for current session\
        export NVM_DIR="$HOME/.nvm"\
        # Use conditional check to ensure the files exist before sourcing them\
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then\
            # shellcheck disable=SC1090\
            . "$NVM_DIR/nvm.sh"\
        else\
            log_warning "NVM script not found. You may need to restart your shell."\
            return 1\
        fi\
        \
        if [[ -s "$NVM_DIR/bash_completion" ]]; then\
            # shellcheck disable=SC1090\
            . "$NVM_DIR/bash_completion"\
        fi\
    else\
        log_success "NVM already installed."\
        \
        # Ensure NVM is loaded for the current session\
        export NVM_DIR="$HOME/.nvm"\
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then\
            # shellcheck disable=SC1090\
            . "$NVM_DIR/nvm.sh"\
        else\
            log_warning "NVM script not found. You may need to restart your shell."\
            return 1\
        fi\
    fi\
    \
    # Verify NVM is properly loaded\
    if ! command_exists nvm; then\
        log_warning "NVM command not found after installation. You may need to restart your shell."\
        log_warning "After restart, run: '"'"'nvm --version'"'"' to verify NVM is installed."\
        return 1\
    fi\
    \
    return 0\
}
' "$node_script"

    # Fix create_templates_dir function
    log_info "Fixing Node.js templates directory creation..."
    sed -i.tmp2 '
/^create_templates_dir() {/,/^}/c\
create_templates_dir() {\
    local dir="$HOME/.local/share/node-templates"\
    \
    if [[ ! -d "$dir" ]]; then\
        log_info "Creating Node.js templates directory: $dir"\
        mkdir -p "$dir" || handle_error "Failed to create templates directory"\
    fi\
    \
    echo "$dir"\
}
' "$node_script"

    # Clean up temp files
    rm -f "${node_script}.tmp" "${node_script}.tmp2"
    
    # Verify file syntax
    if bash -n "$node_script"; then
        log_success "Node.js setup script fixed successfully"
    else
        log_error "Node.js setup script has syntax errors after fixing"
        log_info "Restoring backup..."
        cp "$backup_file" "$node_script"
        return 1
    fi
    
    return 0
}

# Fix Ruby setup script
fix_ruby_setup() {
    log_header "Fixing Ruby Setup Script"
    
    local ruby_script="$SCRIPT_DIR/scripts/setup/ruby-setup.sh"
    
    if [[ ! -f "$ruby_script" ]]; then
        log_error "Ruby setup script not found at: $ruby_script"
        return 1
    fi
    
    # Create backup
    local backup_file="${ruby_script}.bak-$(date +%Y%m%d%H%M%S)"
    log_info "Creating backup of Ruby setup script at: $backup_file"
    cp "$ruby_script" "$backup_file" || {
        log_error "Failed to create backup of Ruby setup script"
        return 1
    }
    
    # For Ruby, we'll replace the entire file with a simpler, more reliable version
    log_info "Replacing Ruby setup script with simplified version..."
    cat > "$ruby_script" << 'EOL'
#!/usr/bin/env bash
# Ruby development environment setup script
# Part of Enhanced Terminal Environment

set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Error handling
handle_error() {
    log_error "$1"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Create project templates directory
create_templates_dir() {
    local dir="$HOME/.local/share/ruby-templates"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating Ruby templates directory: $dir"
        mkdir -p "$dir" || handle_error "Failed to create templates directory"
    fi
    
    echo "$dir"
}

# Add function to .zshrc
add_function_to_zshrc() {
    local function_name="$1"
    local function_path="$2"
    
    if ! grep -q "${function_name}()" "$HOME/.zshrc"; then
        log_info "Adding ${function_name} function to .zshrc"
        cat >> "$HOME/.zshrc" << EOF

# Ruby project creator function
${function_name}() {
    ${function_path} "\$@"
}
EOF
    else
        log_success "${function_name} function already exists in .zshrc"
    fi
}

# Main function
main() {
    log_info "Setting up Ruby development environment..."

    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        readonly OS="macOS"
        log_info "Detected macOS system"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        readonly OS="Linux"
        log_info "Detected Linux system"
    else
        handle_error "Unsupported operating system: $OSTYPE"
    fi

    # Install Ruby
    if command_exists ruby; then
        log_info "Ruby is already installed: $(ruby --version)"
    else
        if [[ "$OS" == "macOS" ]]; then
            log_info "Installing Ruby via Homebrew..."
            if brew install ruby; then
                log_success "Ruby installed successfully via Homebrew"
                # Add Ruby to PATH
                if ! grep -q "/usr/local/opt/ruby/bin" "$HOME/.zshrc" && ! grep -q "/opt/homebrew/opt/ruby/bin" "$HOME/.zshrc"; then
                    if [[ -d "/usr/local/opt/ruby/bin" ]]; then
                        echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> "$HOME/.zshrc"
                    elif [[ -d "/opt/homebrew/opt/ruby/bin" ]]; then
                        echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> "$HOME/.zshrc"
                    fi
                fi
            else
                log_error "Failed to install Ruby via Homebrew"
                exit 1
            fi
        elif [[ "$OS" == "Linux" ]]; then
            log_info "Installing Ruby via apt..."
            sudo apt-get update && sudo apt-get install -y ruby-full || handle_error "Failed to install Ruby"
        fi
    fi

    # Install essential Ruby gems
    if command_exists gem; then
        log_info "Installing essential Ruby gems..."
        for gem_name in bundler pry rubocop solargraph rake rspec; do
            if ! gem list -i "^${gem_name}$" > /dev/null 2>&1; then
                log_info "Installing ${gem_name}..."
                gem install "$gem_name" || log_warning "Failed to install ${gem_name}, continuing anyway..."
            else
                log_success "${gem_name} already installed, skipping..."
            fi
        done
    else
        log_warning "Ruby gem command not available. Skipping gem installation."
    fi

    # Create Ruby project template
    local templates_dir
    templates_dir=$(create_templates_dir)
    local template_script="$templates_dir/basic_ruby_project.sh"

    # Create simplified Ruby project template
    log_info "Creating Ruby project template..."
    cat > "$template_script" << 'EOF'
#!/usr/bin/env bash
# Basic Ruby project template generator

set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: rubyproject <projectname>${NC}"
    exit 1
fi

PROJECT_NAME="$1"
# Convert project name to valid Ruby module name
SANITIZED_NAME=$(echo "$PROJECT_NAME" | tr '-' '_' | tr '[:upper:]' '[:lower:]')
CAPITALIZED_NAME=$(echo "$SANITIZED_NAME" | sed 's/^./\U&/g')

# Check if directory already exists
if [[ -d "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists.${NC}"
    exit 1
fi

echo -e "${BLUE}Creating Ruby project: $PROJECT_NAME${NC}"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

# Create project structure
echo -e "${BLUE}Creating project structure...${NC}"
mkdir -p lib
mkdir -p spec
mkdir -p bin

# Create Gemfile
cat > Gemfile << 'EOFINNER'
source 'https://rubygems.org'

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'solargraph', '~> 0.44'
  gem 'pry', '~> 0.14'
end
EOFINNER

# Create main library file
cat > lib/${SANITIZED_NAME}.rb << EOFINNER
# Main module for ${PROJECT_NAME}
module ${CAPITALIZED_NAME}
  VERSION = '0.1.0'.freeze

  # Your code goes here...
  def self.hello
    puts "Hello from ${PROJECT_NAME}!"
  end
end
EOFINNER

# Create executable
mkdir -p bin
cat > bin/${PROJECT_NAME} << EOFINNER
#!/usr/bin/env ruby

require_relative '../lib/${SANITIZED_NAME}'

# Add command-line handling code here
${CAPITALIZED_NAME}.hello
EOFINNER
chmod +x bin/${PROJECT_NAME}

# Create README
cat > README.md << EOFINNER
# ${CAPITALIZED_NAME}

A Ruby project.

## Installation

\`\`\`bash
# Install dependencies
bundle install
\`\`\`

## Usage

\`\`\`ruby
require '${SANITIZED_NAME}'

# Your code here
${CAPITALIZED_NAME}.hello
\`\`\`

## Development

\`\`\`bash
# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
\`\`\`

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.
EOFINNER

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify

echo -e "${GREEN}Ruby project $PROJECT_NAME created successfully!${NC}"
EOF

    # Make template executable
    chmod +x "$template_script" || handle_error "Failed to make template script executable"

    # Add function to .zshrc
    add_function_to_zshrc "rubyproject" "$template_script"

    log_success "Ruby environment setup complete!"
    log_info "New commands available:"
    log_info "  rubyproject - Create a new Ruby project"
    log_warning "Restart your shell or run 'source ~/.zshrc' to use the new commands"
}

# Run the main function
main "$@"
EOL

    # Verify file syntax
    if bash -n "$ruby_script"; then
        log_success "Ruby setup script replaced successfully"
    else
        log_error "Ruby setup script has syntax errors after replacement"
        log_info "Restoring backup..."
        cp "$backup_file" "$ruby_script"
        return 1
    fi
    
    return 0
}

# Fix main install.sh script
fix_install_script() {
    log_header "Fixing Main Install Script"
    
    local install_script="$SCRIPT_DIR/install.sh"
    
    if [[ ! -f "$install_script" ]]; then
        log_error "Main install script not found at: $install_script"
        return 1
    fi
    
    # Create backup
    local backup_file="${install_script}.bak-$(date +%Y%m%d%H%M%S)"
    log_info "Creating backup of main install script at: $backup_file"
    cp "$install_script" "$backup_file" || {
        log_error "Failed to create backup of main install script"
        return 1
    }
    
    log_info "Enhancing directory creation in main install script..."
    # Fix the directory creation function
    sed -i.tmp '
/create_essential_directories() {/,/^}/c\
create_essential_directories() {\
    log_info "Creating essential directories..."\
    \
    # List of essential directories\
    local dirs=(\
        "$HOME/.config/nvim"\
        "$HOME/.config/tmux"\
        "$HOME/.tmux/plugins"\
        "$HOME/.zsh"\
        "$HOME/.local/bin"\
        "$HOME/projects"\
        "$HOME/.local/share/python-templates"\
        "$HOME/.local/share/node-templates"\
        "$HOME/.local/share/ruby-templates"\
    )\
    \
    for dir in "${dirs[@]}"; do\
        if [[ ! -d "$dir" ]]; then\
            mkdir -p "$dir" && \
            chmod 755 "$dir" && \
            log_success "Created: $dir" || \
            log_warning "Failed to create: $dir"\
        else\
            log_info "Directory already exists: $dir"\
            # Verify permissions\
            if [[ -w "$dir" ]]; then\
                chmod 755 "$dir" 2>/dev/null || true\
            else\
                log_warning "Directory exists but may not be writable: $dir"\
                chmod 755 "$dir" 2>/dev/null || log_warning "Failed to fix permissions for: $dir"\
            fi\
        fi\
    done\
}
' "$install_script"

    # Add verification before running component scripts
    log_info "Adding verification before running component scripts..."
    local run_script_function=$(cat << 'EOF'
# Command execution with error handling and logging
run_script() {
    local script="$1"
    local error_msg="$2"
    local component="$3"
    
    if [[ ! -f "$script" ]]; then
        log_error "Script not found: $script"
        return 1
    fi
    
    # Verify prerequisites for component
    verify_component_prerequisites "$component" || {
        log_error "Failed to verify prerequisites for $component"
        return 1
    }
    
    log_info "Running: $script"
    echo "$(date): Running $script" >> "$LOG_FILE"
    
    # Run the script and capture its exit code
    if bash "$script" >> "$LOG_FILE" 2>&1; then
        log_success "Successfully executed: $script"
        return 0
    else
        local exit_code=$?
        log_error "$error_msg"
        log_warning "Check $LOG_FILE for more details."
        
        # Ask if the user wants to continue
        read -r -p "Continue with installation despite error? [Y/n]: " CONTINUE
        echo "User choice on continuing: $CONTINUE" >> "$LOG_FILE"
        
        if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
            log_info "Installation aborted by user."
            exit 1
        fi
        
        return $exit_code
    fi
}

# Verify prerequisites for a component
verify_component_prerequisites() {
    local component="$1"
    
    case "$component" in
        core)
            # Core prerequisites
            return 0
            ;;
        python)
            # Verify python dirs exist
            mkdir -p "$HOME/.local/share/python-templates" || {
                log_error "Failed to create python templates directory"
                return 1
            }
            ;;
        node)
            # Verify node dirs exist
            mkdir -p "$HOME/.local/share/node-templates" || {
                log_error "Failed to create node templates directory"
                return 1
            }
            ;;
        ruby)
            # Verify ruby dirs exist
            mkdir -p "$HOME/.local/share/ruby-templates" || {
                log_error "Failed to create ruby templates directory"
                return 1
            }
            ;;
        *)
            log_warning "Unknown component: $component"
            return 0
            ;;
    esac
    
    return 0
}
EOF
)

    # Insert the verification function into main script
    if ! grep -q "verify_component_prerequisites" "$install_script"; then
        log_info "Adding component verification function..."
        # Find the run_script function and replace it
        sed -i.tmp2 '/run_script() {/,/^}/c\'"$run_script_function" "$install_script"
    fi

    # Clean up temp files
    rm -f "${install_script}.tmp" "${install_script}.tmp2"
    
    # Verify file syntax
    if bash -n "$install_script"; then
        log_success "Main install script fixed successfully"
    else
        log_error "Main install script has syntax errors after fixing"
        log_info "Restoring backup..."
        cp "$backup_file" "$install_script"
        return 1
    fi
    
    return 0
}

# Create and ensure template directories exist
ensure_template_dirs() {
    log_header "Creating Template Directories"
    
    # Essential template directories
    local template_dirs=(
        "$HOME/.local/share/python-templates"
        "$HOME/.local/share/node-templates"
        "$HOME/.local/share/ruby-templates"
    )
    
    for dir in "${template_dirs[@]}"; do
        ensure_directory "$dir" || {
            log_error "Failed to ensure directory: $dir"
            return 1
        }
    done
    
    log_success "All template directories created successfully"
    return 0
}

# Main function
main() {
    log_header "Enhanced Terminal Environment - Installer Fix Script"
    echo -e "This script will fix common issues with the Enhanced Terminal Environment installer."
    echo
    
    # Create and ensure template directories exist first
    ensure_template_dirs || {
        log_error "Failed to create template directories"
        return 1
    }
    
    # Fix component setup scripts
    fix_python_setup || log_warning "Failed to fix Python setup script, but continuing..."
    fix_nodejs_setup || log_warning "Failed to fix Node.js setup script, but continuing..."
    fix_ruby_setup || log_warning "Failed to fix Ruby setup script, but continuing..."
    
    # Fix main install script
    fix_install_script || log_warning "Failed to fix main install script, but continuing..."
    
    log_header "Fix Script Completed"
    echo -e "${GREEN}The Enhanced Terminal Environment installer has been fixed.${NC}"
    echo -e "${YELLOW}You can now run the installation in recovery mode:${NC}"
    echo -e "  ${BOLD}./install.sh --recover${NC}"
    echo
    echo -e "${BLUE}If you encounter any issues, you can also try:${NC}"
    echo -e "  1. Running each component setup script directly:"
    echo -e "     ${BOLD}./scripts/setup/python-setup.sh${NC}"
    echo -e "     ${BOLD}./scripts/setup/node-setup.sh${NC}"
    echo -e "     ${BOLD}./scripts/setup/ruby-setup.sh${NC}"
    echo -e "  2. Checking the installation log: ${BOLD}install_log.txt${NC}"
    echo
}

# Run the main function
main "$@"