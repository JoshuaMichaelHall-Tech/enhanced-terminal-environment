#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing Ruby setup script...${NC}"

# Get the repository directory
REPO_DIR="$(pwd)"
RUBY_SETUP_SCRIPT="${REPO_DIR}/scripts/setup/ruby-setup.sh"

# Create backup if needed
if [[ ! -f "${RUBY_SETUP_SCRIPT}.bak.orig" ]]; then
  cp "$RUBY_SETUP_SCRIPT" "${RUBY_SETUP_SCRIPT}.bak.orig"
  echo -e "${GREEN}Created backup at ${RUBY_SETUP_SCRIPT}.bak.orig${NC}"
fi

# Write a new, simplified Ruby setup script
cat > "$RUBY_SETUP_SCRIPT" << 'ENDOFFILE'
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
    cat > "$template_script" << 'EOL'
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
cat > Gemfile << 'EOF'
source 'https://rubygems.org'

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'solargraph', '~> 0.44'
  gem 'pry', '~> 0.14'
end
EOF

# Create main library file
cat > lib/${SANITIZED_NAME}.rb << EOF
# Main module for ${PROJECT_NAME}
module ${CAPITALIZED_NAME}
  VERSION = '0.1.0'.freeze

  # Your code goes here...
  def self.hello
    puts "Hello from ${PROJECT_NAME}!"
  end
end
EOF

# Create executable
mkdir -p bin
cat > bin/${PROJECT_NAME} << EOF
#!/usr/bin/env ruby

require_relative '../lib/${SANITIZED_NAME}'

# Add command-line handling code here
${CAPITALIZED_NAME}.hello
EOF
chmod +x bin/${PROJECT_NAME}

# Create README
cat > README.md << EOF
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
EOF

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify

echo -e "${GREEN}Ruby project $PROJECT_NAME created successfully!${NC}"
EOL

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
ENDOFFILE

# Make the script executable
chmod +x "$RUBY_SETUP_SCRIPT"

echo -e "${GREEN}Ruby setup script fixed${NC}"
echo -e "${YELLOW}Now run the recovery script:${NC}"
echo -e "  ./install.sh --recover"