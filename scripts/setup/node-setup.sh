#!/usr/bin/env bash
# Node.js/JavaScript development environment setup script - Improved robustness
# Part of Enhanced Terminal Environment - Improved for reliability and cross-platform compatibility
# Version: 4.0

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

# Setup NVM (Node Version Manager) with better error handling
setup_nvm() {
    # If NVM is already available in the current session, we're good
    if command_exists nvm; then
        log_success "NVM command already available in current session."
        return 0
    fi
    
    # Check if NVM directory exists (may be installed but not loaded in current session)
    if [[ -d "$HOME/.nvm" ]]; then
        log_success "NVM directory exists, loading NVM..."
        
        # Load NVM for current session
        export NVM_DIR="$HOME/.nvm"
        
        # Source NVM scripts with safety checks
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            # shellcheck disable=SC1090
            source "$NVM_DIR/nvm.sh" || {
                log_warning "Failed to source nvm.sh, will attempt alternate approaches"
                return 1
            }
            
            # Load bash completion if available
            if [[ -s "$NVM_DIR/bash_completion" ]]; then
                # shellcheck disable=SC1090
                source "$NVM_DIR/bash_completion" || log_warning "Failed to load NVM bash completion"
            fi
            
            # Verify NVM is now available
            if command_exists nvm; then
                log_success "NVM loaded successfully for current session"
                return 0
            else
                log_warning "NVM not available after loading. Will attempt reinstallation."
            fi
        else
            log_warning "NVM script not found at expected location"
            # Try alternate installation method below
        fi
    fi
    
    # If we're here, NVM needs to be installed or repaired
    log_info "Installing NVM (Node Version Manager)..."
    
    # Clean up any previous failed installation
    if [[ -d "$HOME/.nvm" ]]; then
        log_warning "Cleaning up previous NVM installation..."
        mv "$HOME/.nvm" "$HOME/.nvm.backup.$(date +%Y%m%d%H%M%S)" || log_warning "Failed to backup old NVM installation"
    fi
    
    # Check if curl and/or wget are available
    local install_cmd=""
    if command_exists curl; then
        install_cmd="curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    elif command_exists wget; then
        install_cmd="wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    else
        log_error "Neither curl nor wget is available. Cannot install NVM."
        return 1
    fi
    
    # Run the installation command
    log_info "Downloading and running NVM installer..."
    eval "$install_cmd" || {
        log_error "Failed to install NVM"
        return 1
    }
    
    # Reload shell environment for NVM
    export NVM_DIR="$HOME/.nvm"
    
    # Source NVM with error handling
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck disable=SC1090
        source "$NVM_DIR/nvm.sh" || {
            log_warning "Failed to source NVM after installation"
            return 1
        }
        
        # Verify NVM is now available
        if command_exists nvm; then
            log_success "NVM installed and loaded successfully"
            
            # Add to shell profile if not already there
            if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
                log_info "Adding NVM configuration to .zshrc"
                cat >> "$HOME/.zshrc" << 'EOL'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOL
            else
                log_success "NVM configuration already in .zshrc"
            fi
            
            return 0
        else
            log_warning "NVM command not available even after installation"
            return 1
        fi
    else
        log_warning "NVM script not found after installation"
        return 1
    fi
}

# Install Node.js using NVM safely - fixes the "PROVIDED_VERSION" error
install_node_nvm() {
    log_info "Installing Node.js LTS version via NVM..."
    
    # Explicitly set default NVM version as a workaround for the "PROVIDED_VERSION" error
    export NODE_VERSION=""
    
    # Try to install latest LTS version
    if nvm install --lts; then
        log_success "Node.js LTS installed successfully"
        
        # Explicitly use LTS
        if nvm use --lts; then
            log_success "Using Node.js LTS version"
            
            # Set as default - with explicit error handling for the alias command
            if nvm alias default "lts/*"; then
                log_success "Node.js LTS set as default"
                return 0
            else
                log_warning "Failed to set Node.js LTS as default, but Node.js is installed"
                # This is not a fatal error, Node is still installed
                return 0
            fi
        else
            log_warning "Failed to use Node.js LTS version, but installation succeeded"
            # Try to at least use any available Node version
            nvm use node >/dev/null 2>&1 || true
            return 0
        fi
    else
        log_warning "Failed to install Node.js LTS, trying stable version..."
        
        # Try stable version instead
        if nvm install stable; then
            log_success "Node.js stable version installed successfully"
            
            # Explicitly use stable
            if nvm use stable; then
                log_success "Using Node.js stable version"
                
                # Try to set as default
                nvm alias default stable >/dev/null 2>&1 || log_warning "Failed to set Node.js stable as default"
                return 0
            else
                log_warning "Failed to use Node.js stable version, but installation succeeded"
                return 0
            fi
        else
            log_error "Failed to install any Node.js version via NVM"
            return 1
        fi
    fi
}

# Fallback: Install Node.js using Homebrew (macOS)
install_node_homebrew() {
    if ! command_exists brew; then
        log_warning "Homebrew not available for Node.js installation fallback"
        return 1
    fi
    
    log_info "Installing Node.js via Homebrew..."
    if brew install node; then
        log_success "Node.js installed successfully via Homebrew"
        return 0
    else
        log_error "Failed to install Node.js via Homebrew"
        return 1
    fi
}

# Fallback: Install Node.js using apt (Linux)
install_node_apt() {
    log_info "Installing Node.js via apt..."
    
    # Setup with nodesource (more recent versions)
    log_info "Setting up Node.js repository..."
    if command_exists curl; then
        # Try with the official setup script
        if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
            log_warning "Failed to set up Node.js repository with nodesource script"
            # Fall back to direct apt install (may be older version)
            if sudo apt-get update && sudo apt-get install -y nodejs; then
                log_success "Node.js installed via direct apt (may be older version)"
                return 0
            else
                log_error "Failed to install Node.js via apt"
                return 1
            fi
        fi
    elif command_exists wget; then
        # Try with wget
        if ! wget -qO- https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
            log_warning "Failed to set up Node.js repository with nodesource script"
            # Fall back to direct apt install (may be older version)
            if sudo apt-get update && sudo apt-get install -y nodejs; then
                log_success "Node.js installed via direct apt (may be older version)"
                return 0
            else
                log_error "Failed to install Node.js via apt"
                return 1
            fi
        fi
    else
        # If neither curl nor wget is available
        log_warning "Neither curl nor wget is available, trying direct apt install"
        if sudo apt-get update && sudo apt-get install -y nodejs; then
            log_success "Node.js installed via direct apt (may be older version)"
            return 0
        else
            log_error "Failed to install Node.js via apt"
            return 1
        fi
    fi
    
    # If repository setup succeeded, install Node.js
    if sudo apt-get install -y nodejs; then
        log_success "Node.js installed successfully via apt with nodesource repository"
        return 0
    else
        log_error "Failed to install Node.js via apt after repository setup"
        return 1
    fi
}

# Direct installation for MacOS (as last resort)
install_node_direct_macos() {
    log_info "Attempting direct Node.js installation from official installer..."
    
    # Create temporary directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || return 1
    
    # Download the macOS installer
    log_info "Downloading Node.js package for macOS..."
    if command_exists curl; then
        curl -L -o node.pkg "https://nodejs.org/dist/latest-v18.x/node-v18.19.1.pkg" || return 1
    elif command_exists wget; then
        wget -O node.pkg "https://nodejs.org/dist/latest-v18.x/node-v18.19.1.pkg" || return 1
    else
        log_error "Neither curl nor wget available for download"
        return 1
    fi
    
    # Install the package
    log_info "Installing Node.js package..."
    sudo installer -pkg node.pkg -target / || return 1
    
    # Clean up
    cd - || true
    rm -rf "$tmp_dir"
    
    # Verify installation
    if command_exists node; then
        log_success "Node.js installed successfully via direct package"
        return 0
    else
        log_error "Node.js installation failed or not found in PATH"
        return 1
    fi
}

# Create project templates directory
create_templates_dir() {
    local dir="$HOME/.local/share/node-templates"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating Node.js templates directory: $dir"
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

# Node.js project creator function
${function_name}() {
    ${function_path} "\$@"
}
EOF
    else
        log_success "${function_name} function already exists in .zshrc"
    fi
}

# Install Node.js packages globally with error handling
install_global_packages() {
    log_info "Installing essential Node.js development tools..."
    
    # Define packages to install
    local packages=(
        "npm@latest"
        "yarn"
        "typescript"
        "ts-node"
        "eslint"
        "prettier"
        "nodemon"
        "serve"
        "http-server"
        "npm-check-updates"
    )
    
    local installed_count=0
    local total_packages=${#packages[@]}
    
    for package in "${packages[@]}"; do
        log_info "Installing ${package}..."
        
        # Try to install with error handling
        if npm install -g "$package" > /dev/null 2>&1; then
            log_success "Installed ${package} successfully"
            ((installed_count++))
        else
            log_warning "Failed to install ${package}, continuing anyway..."
        fi
    done
    
    log_info "Successfully installed $installed_count out of $total_packages packages"
    
    # Return success even if some packages failed
    return 0
}

# Verify Node.js installation by checking actual commands
verify_node_install() {
    # Check for node command
    if command_exists node; then
        log_success "Node.js is installed: $(node --version)"
        return 0
    else
        log_error "Node.js command not found in PATH"
        return 1
    fi
}

# Main function
main() {
    log_info "Setting up Node.js development environment..."

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

    # Install Node.js using multiple approaches if needed
    NODE_INSTALLED=false
    
    # First try with NVM
    if setup_nvm; then
        log_success "NVM setup completed successfully."
        
        # Try to install Node.js via NVM
        if install_node_nvm; then
            NODE_INSTALLED=true
        else
            log_warning "Node.js installation via NVM failed, trying alternate methods..."
        fi
    else
        log_warning "NVM setup failed, trying alternate installation methods..."
    fi
    
    # If NVM approach failed, try OS-specific methods
    if [[ "$NODE_INSTALLED" == "false" ]]; then
        if [[ "$OS" == "macOS" ]]; then
            if install_node_homebrew; then
                NODE_INSTALLED=true
            elif install_node_direct_macos; then
                NODE_INSTALLED=true
            fi
        elif [[ "$OS" == "Linux" ]]; then
            if install_node_apt; then
                NODE_INSTALLED=true
            fi
        fi
    fi
    
    # Final verification that Node.js is installed and accessible
    if ! NODE_INSTALLED && verify_node_install; then
        NODE_INSTALLED=true
    fi
    
    # Check if any installation method succeeded
    if [[ "$NODE_INSTALLED" == "false" ]]; then
        log_error "Node.js installation failed using all available methods"
        log_error "Please install Node.js manually and retry the setup"
        exit 1
    fi

    # Install essential global npm packages
    if command_exists npm; then
        install_global_packages
    else
        log_error "npm not available after Node.js installation. Something is wrong with the setup."
        exit 1
    fi

    # Create Node.js project template
    local templates_dir
    templates_dir=$(create_templates_dir)
    local template_script="$templates_dir/basic_node_project.sh"

    # Create Node.js project template script
    log_info "Creating Node.js project template..."
    cat > "$template_script" << 'EOL'
#!/usr/bin/env bash
# Basic Node.js project template generator

set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: nodeproject <projectname>${NC}"
    exit 1
fi

PROJECT_NAME="$1"

# Check if directory already exists
if [[ -d "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists.${NC}"
    exit 1
fi

echo -e "${BLUE}Creating Node.js project: $PROJECT_NAME${NC}"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

# Initialize npm project
echo -e "${BLUE}Initializing npm project...${NC}"
npm init -y

# Function to safely update package.json
update_package_json() {
    local tmp_file
    tmp_file=$(mktemp)
    
    # Make sure temporary file is created successfully
    if [[ ! -f "$tmp_file" ]]; then
        echo -e "${RED}Failed to create temporary file${NC}"
        return 1
    fi
    
    # Create cleanup trap
    trap 'rm -f "$tmp_file"' EXIT
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}jq not found. Using alternative package.json modification method.${NC}"
        return 1
    fi
    
    # Update package.json
    jq '.scripts.start = "node src/index.js" | 
        .scripts.test = "jest" | 
        .scripts.lint = "eslint src/**/*.js" |
        .scripts.format = "prettier --write \"src/**/*.js\"" | 
        .author = "Joshua Michael Hall" |
        .license = "MIT"' package.json > "$tmp_file" || return 1
    
    # Check if the temporary file has content
    if [[ ! -s "$tmp_file" ]]; then
        echo -e "${RED}Failed to update package.json (empty result)${NC}"
        return 1
    fi
    
    # Replace original file
    mv "$tmp_file" package.json
    return 0
}

# Update package.json with better defaults
if ! update_package_json; then
    echo -e "${YELLOW}Falling back to direct package.json editing${NC}"
    # Manual search and replace approach as fallback
    sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "node src\/index.js",\n    "test": "jest",\n    "lint": "eslint src\/**\/*.js",\n    "format": "prettier --write \\"src\/**\/*.js\\",/g' package.json || true
    sed -i.bak 's/"author": ""/"author": "Joshua Michael Hall"/g' package.json || true 
    sed -i.bak 's/"license": "ISC"/"license": "MIT"/g' package.json || true
    rm -f package.json.bak
fi

# Create project structure
echo -e "${BLUE}Creating project structure...${NC}"
mkdir -p src
mkdir -p test

# Create main file
cat > src/index.js << 'EOF'
/**
 * Main application entry point
 */

function main() {
  console.log('Hello, World!');
}

main();

module.exports = { main };
EOF

# Create test file
cat > test/index.test.js << 'EOF'
const { main } = require('../src/index');

describe('Main function', () => {
  test('runs without error', () => {
    // This is a placeholder test
    expect(true).toBe(true);
  });
});
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

A Node.js project.

## Installation

\`\`\`bash
# Install dependencies
npm install
\`\`\`

## Usage

\`\`\`bash
# Run the application
npm start

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format
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
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Dependencies
node_modules/
jspm_packages/
bower_components/

# Coverage directory
coverage/
.nyc_output

# Build output
dist/
build/
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
Thumbs.db
EOF

# Add .eslintrc.js
cat > .eslintrc.js << 'EOF'
module.exports = {
  env: {
    node: true,
    commonjs: true,
    es2021: true,
    jest: true,
  },
  extends: 'eslint:recommended',
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    indent: ['error', 2],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'always'],
  },
};
EOF

# Add .prettierrc
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
EOF

# Install development dependencies
echo -e "${BLUE}Installing development dependencies...${NC}"
npm install --save-dev \
  eslint \
  prettier \
  jest \
  nodemon || echo -e "${YELLOW}Failed to install some dev dependencies, you can install them manually later${NC}"

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify || echo -e "${YELLOW}Failed to create initial commit${NC}"

echo -e "${GREEN}Node.js project $PROJECT_NAME created successfully!${NC}"
EOL

    # Make template executable
    chmod +x "$template_script" || handle_error "Failed to make template script executable"

    # Add function to .zshrc
    add_function_to_zshrc "nodeproject" "$template_script"

    log_success "Node.js environment setup complete!"
    log_info "New commands available:"
    log_info "  nodeproject - Create a new Node.js project"
    if command_exists nvm; then
        log_info "  nvm - Manage Node.js versions"
    fi
    log_warning "Restart your shell or run 'source ~/.zshrc' to use the new commands"
}

# Run the main function with all arguments
main "$@"