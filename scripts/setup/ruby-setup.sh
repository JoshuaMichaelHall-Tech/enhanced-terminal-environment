#!/usr/bin/env bash
# Ruby development environment setup script
# Part of Enhanced Terminal Environment - Improved for reliability and cross-platform compatibility
# Version: 3.0

# Exit on error, undefined variables, and propagate pipe failures
set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Script directory (resolving symlinks)
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Log functions for consistent output
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

# Error handling function
handle_error() {
    log_error "$1"
    exit 1
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install Ruby using Homebrew (macOS fallback)
install_ruby_homebrew() {
    if command_exists brew; then
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
            return 0
        else
            log_error "Failed to install Ruby via Homebrew"
            return 1
        fi
    else
        log_warning "Homebrew not available for Ruby installation fallback"
        return 1
    fi
}

# Install Ruby using apt (Linux fallback)
install_ruby_apt() {
    log_info "Installing Ruby via apt..."
    if sudo apt-get update && sudo apt-get install -y ruby-full build-essential; then
        log_success "Ruby installed successfully via apt"
        return 0
    else
        log_error "Failed to install Ruby via apt"
        return 1
    fi
}

# Setup RVM (Ruby Version Manager)
setup_rvm() {
    # If RVM is not installed
    if ! command_exists rvm; then
        log_info "Installing RVM (Ruby Version Manager)..."
        
        # Try multiple GPG key servers in case one fails
        gpg_key_servers=(
            "hkp://keys.gnupg.net"
            "hkp://keyserver.ubuntu.com"
            "hkp://pgp.mit.edu"
        )
        
        # Try each key server until successful or try direct download
        key_imported=false
        
        # Try direct download first
        log_info "Trying direct GPG key download..."
        if curl -sSL https://rvm.io/mpapis.asc | gpg --import - 2>/dev/null &&
           curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - 2>/dev/null; then
            key_imported=true
        else
            # Try key servers
            for server in "${gpg_key_servers[@]}"; do
                log_info "Trying to import GPG keys from $server..."
                if gpg --keyserver "$server" --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 2>/dev/null; then
                    key_imported=true
                    break
                fi
            done
        fi
        
        # Install RVM
        log_info "Downloading and installing RVM..."
        if ! curl -sSL https://get.rvm.io | bash -s stable; then
            log_warning "Failed to install RVM using primary method, trying alternative approach..."
            if ! \curl -sSL https://get.rvm.io | bash; then
                log_warning "RVM installation failed. Trying system Ruby fallback..."
                return 1
            fi
        fi
        
        # Add RVM to shell profile if not already there
        if ! grep -q "rvm/scripts/rvm" "$HOME/.zshrc"; then
            cat >> "$HOME/.zshrc" << 'EOL'

# RVM (Ruby Version Manager)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.rvm/bin"
EOL
        fi
        
        # Load RVM for current session
        if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
            # shellcheck disable=SC1090
            source "$HOME/.rvm/scripts/rvm"
        else
            log_warning "RVM script not found. You may need to restart your shell."
            return 1
        fi
    else
        log_success "RVM already installed."
        
        # Update RVM to latest stable version
        log_info "Updating RVM to latest stable version..."
        rvm get stable || log_warning "Failed to update RVM, continuing anyway..."
        
        # Ensure RVM is loaded
        if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
            # shellcheck disable=SC1090
            source "$HOME/.rvm/scripts/rvm"
        fi
    fi
    
    # Verify RVM is available
    if ! command_exists rvm; then
        log_warning "RVM command not available after installation. You may need to restart your shell."
        log_warning "After restart, run: 'rvm --version' to verify RVM is installed."
        return 1
    fi
    
    return 0
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

# Add function to .zshrc if it doesn't exist
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

# Capitalize a string
capitalize() {
    local str="$1"
    # Use Python if available for more reliable capitalization
    if command_exists python3; then
        python3 -c "import sys; print(sys.argv[1].capitalize())" "$str"
    else
        # Fallback to bash implementation
        echo "${str^}"
    fi
}

# Install Ruby gems
install_essential_gems() {
    local gems=(
        "bundler"
        "pry"
        "rubocop"
        "solargraph"
        "rspec"
        "rake"
    )
    
    local installed_count=0
    local total_gems=${#gems[@]}
    
    for gem in "${gems[@]}"; do
        log_info "Installing ${gem}..."
        if gem install "$gem" 2>/dev/null; then
            ((installed_count++))
        else
            log_warning "Failed to install ${gem}, continuing anyway..."
        fi
    done
    
    log_info "Successfully installed $installed_count out of $total_gems gems"
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

    # Install RVM (Ruby Version Manager)
    RUBY_INSTALLED=false
    if ! setup_rvm; then
        log_warning "RVM setup encountered issues. Trying alternative installation methods..."
        # Try alternative installation methods based on OS
        if [[ "$OS" == "macOS" ]]; then
            if install_ruby_homebrew; then
                RUBY_INSTALLED=true
            fi
        elif [[ "$OS" == "Linux" ]]; then
            if install_ruby_apt; then
                RUBY_INSTALLED=true
            fi
        fi
    else
        log_success "RVM setup completed successfully."
        
        # Install latest stable Ruby version
        if command_exists rvm; then
            log_info "Installing latest stable Ruby version..."
            
            # Try to install latest stable version
            if rvm install ruby --latest; then
                # Use latest stable version as default
                if rvm use ruby --latest --default; then
                    RUBY_INSTALLED=true
                else
                    log_warning "Failed to set latest Ruby as default"
                    # Try to use any installed Ruby version
                    if rvm use ruby; then
                        RUBY_INSTALLED=true
                    fi
                fi
            else
                log_warning "Failed to install latest Ruby version, trying system Ruby..."
                if command_exists ruby; then
                    log_success "System Ruby is available: $(ruby --version)"
                    RUBY_INSTALLED=true
                fi
            fi
        fi
    fi
    
    # Verify Ruby installation
    if command_exists ruby; then
        log_success "Ruby $(ruby --version) installed successfully"
        RUBY_INSTALLED=true
    elif [ "$RUBY_INSTALLED" = false ]; then
        log_error "Ruby installation failed using all available methods"
        log_error "Please install Ruby manually and retry the setup"
        exit 1
    fi

    # Install essential Ruby gems
    if command_exists gem; then
        log_info "Installing essential Ruby development tools..."
        install_essential_gems
    else
        log_error "gem not available. Cannot install Ruby tools."
        exit 1
    fi

    # Create Ruby project template
    local templates_dir
    templates_dir=$(create_templates_dir)
    local template_script="$templates_dir/basic_ruby_project.sh"

    # Create Ruby project template script
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

# Helper functions
capitalize() {
    if command -v python3 &> /dev/null; then
        python3 -c "import sys; print(sys.argv[1].capitalize())" "$1"
    else
        # Fallback to bash implementation
        local first="${1:0:1}"
        local rest="${1:1}"
        echo "${first^^}${rest}"
    fi
}

# Check required commands
for cmd in git; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: '$cmd' is not installed. Please install Git.${NC}"
        exit 1
    fi
done

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: rubyproject <projectname>${NC}"
    exit 1
fi

PROJECT_NAME="$1"
# Convert project name to valid Ruby module name
SANITIZED_NAME=$(echo "$PROJECT_NAME" | tr '-' '_' | tr '[:upper:]' '[:lower:]')
CAPITALIZED_NAME=$(capitalize "$SANITIZED_NAME")

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

# Create spec file
cat > spec/${SANITIZED_NAME}_spec.rb << EOF
require '${SANITIZED_NAME}'

RSpec.describe ${CAPITALIZED_NAME} do
  it 'has a version number' do
    expect(${CAPITALIZED_NAME}::VERSION).not_to be nil
  end
  
  it 'does something useful' do
    expect(true).to eq(true)
  end
end
EOF

# Create spec helper
cat > spec/spec_helper.rb << 'EOF'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
EOF

# Create Rakefile
cat > Rakefile << 'EOF'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
EOF

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

# Create essential configuration files
cat > .gitignore << 'EOF'
# Ruby specific
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/

# Environment normalization
/.bundle/
/vendor/bundle
/lib/bundler/man/

# RVM
.rvmrc

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
Thumbs.db
EOF

# Create .rubocop.yml
cat > .rubocop.yml << 'EOF'
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.0

Style/StringLiterals:
  Enabled: true
  EnforcedStyle: single_quotes

Style/Documentation:
  Enabled: false

Layout/LineLength:
  Max: 100

Metrics/MethodLength:
  Max: 15

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
EOF

# Initialize bundle if bundler is available
if command -v bundle &> /dev/null; then
    echo -e "${BLUE}Installing bundle dependencies...${NC}"
    bundle install
else
    echo -e "${YELLOW}Bundler not found. Please install gems manually with: gem install bundler && bundle install${NC}"
fi

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify

echo -e "${GREEN}Ruby project ${CAPITALIZED_NAME} created successfully!${NC}"
EOL

    # Make template executable
    chmod +x "$template_script" || handle_error "Failed to make template script executable"

    # Add function to .zshrc
    add_function_to_zshrc "rubyproject" "$template_script"

    log_success "Ruby environment setup complete!"
    log_info "New commands available:"
    log_info "  rubyproject - Create a new Ruby project"
    if command_exists rvm; then
        log_info "  rvm - Manage Ruby versions"
    fi
    log_warning "Restart your shell or run 'source ~/.zshrc' to use the new commands"
}

# Trap for cleanup on script exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

# Run the main function
main "$@"