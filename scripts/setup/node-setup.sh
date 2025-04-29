#!/usr/bin/env bash
# Node.js/JavaScript development environment setup script
# Part of Enhanced Terminal Environment - Improved for reliability and cross-platform compatibility
# Version: 2.0

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

# Setup NVM (Node Version Manager)
setup_nvm() {
    # Install NVM if not already installed
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing NVM (Node Version Manager)..."
        
        # Download and run the NVM installer
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || 
            handle_error "Failed to install NVM"
        
        # Add NVM to shell profile if not already there
        if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
            cat >> "$HOME/.zshrc" << 'EOL'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOL
        fi
        
        # Load NVM for current session
        export NVM_DIR="$HOME/.nvm"
        # Use conditional check to ensure the files exist before sourcing them
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            # shellcheck disable=SC1090
            . "$NVM_DIR/nvm.sh"
        else
            log_warning "NVM script not found. You may need to restart your shell."
            return 1
        fi
        
        if [[ -s "$NVM_DIR/bash_completion" ]]; then
            # shellcheck disable=SC1090
            . "$NVM_DIR/bash_completion"
        fi
    else
        log_success "NVM already installed."
        
        # Ensure NVM is loaded for the current session
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            # shellcheck disable=SC1090
            . "$NVM_DIR/nvm.sh"
        else
            log_warning "NVM script not found. You may need to restart your shell."
            return 1
        fi
    fi
    
    # Verify NVM is properly loaded
    if ! command_exists nvm; then
        log_warning "NVM command not found after installation. You may need to restart your shell."
        log_warning "After restart, run: 'nvm --version' to verify NVM is installed."
        return 1
    fi
    
    return 0
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

# Install Node.js packages globally
install_global_packages() {
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
    
    for package in "${packages[@]}"; do
        log_info "Installing ${package}..."
        npm install -g "$package" || log_warning "Failed to install ${package}, continuing anyway..."
    done
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

    # Install NVM (Node Version Manager)
    if ! setup_nvm; then
        log_warning "NVM setup encountered issues. Continuing with installation..."
    else
        log_success "NVM setup completed successfully."
    fi

    # Install Node.js LTS version
    if command_exists nvm; then
        log_info "Installing Node.js LTS version..."
        
        # Install LTS version
        if ! nvm install --lts; then
            handle_error "Failed to install Node.js LTS version"
        fi
        
        # Use LTS version
        if ! nvm use --lts; then
            handle_error "Failed to use Node.js LTS version"
        fi
        
        # Set as default
        if ! nvm alias default 'lts/*'; then
            log_warning "Failed to set Node.js LTS as default"
        fi
        
        # Verify Node.js installation
        if command_exists node; then
            log_success "Node.js $(node --version) installed successfully"
        else
            handle_error "Node.js installation verification failed"
        fi
        
        # Install essential global npm packages
        log_info "Installing essential Node.js development tools..."
        install_global_packages
    else
        handle_error "NVM not available. Cannot install Node.js."
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
        echo -e "${YELLOW}jq not found. Skipping package.json modification.${NC}"
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
    echo -e "${YELLOW}Falling back to simple package.json modification${NC}"
    # Simple modification without jq
    sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "node src\/index.js",\n    "test": "jest",\n    "lint": "eslint src\/**\/*.js",\n    "format": "prettier --write \\"src\/**\/*.js\\",/g' package.json
    sed -i.bak 's/"author": ""/"author": "Joshua Michael Hall"/g' package.json
    sed -i.bak 's/"license": "ISC"/"license": "MIT"/g' package.json
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
  nodemon

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify

echo -e "${GREEN}Node.js project $PROJECT_NAME created successfully!${NC}"
EOL

    # Make template executable
    chmod +x "$template_script" || handle_error "Failed to make template script executable"

    # Add function to .zshrc
    add_function_to_zshrc "nodeproject" "$template_script"

    log_success "Node.js environment setup complete!"
    log_info "New commands available:"
    log_info "  nodeproject - Create a new Node.js project"
    log_info "  nvm - Manage Node.js versions"
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
EOL