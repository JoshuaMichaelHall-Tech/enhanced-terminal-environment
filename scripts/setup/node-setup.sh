#!/usr/bin/env bash
# Node.js/JavaScript development environment setup script
# Part of Enhanced Terminal Environment
# Version: 5.1 - With improved Homebrew handling

# Do not exit on errors immediately to allow graceful fallbacks
set -o pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

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

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Create project templates directory
create_templates_dir() {
    local dir="$HOME/.local/share/node-templates"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating Node.js templates directory: $dir"
        mkdir -p "$dir" || {
            log_error "Failed to create templates directory"
            return 1
        }
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

# Install Node.js - with multiple approaches
install_nodejs() {
    log_info "Attempting to install Node.js..."
    
    # Try using Homebrew first
    if command_exists brew; then
        log_info "Installing Node.js via Homebrew..."
        if brew install node; then
            log_success "Node.js installed successfully via Homebrew"
            return 0
        else
            log_warning "Failed to install Node.js via Homebrew, trying alternative methods..."
        fi
    else
        log_warning "Homebrew not available, trying alternative methods..."
    fi
    
    # For macOS, using the official installer as fallback
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Downloading Node.js installer for macOS..."
        
        # Create a temporary directory
        local tmp_dir=$(mktemp -d)
        
        # Download the pkg installer (LTS version)
        if curl -sSL https://nodejs.org/dist/v18.18.2/node-v18.18.2.pkg -o "$tmp_dir/node.pkg"; then
            log_info "Running Node.js installer. This may require your password..."
            
            # Run the installer
            if sudo installer -pkg "$tmp_dir/node.pkg" -target /; then
                rm -rf "$tmp_dir"
                log_success "Node.js installed successfully via pkg installer"
                return 0
            else
                rm -rf "$tmp_dir"
                log_error "Failed to install Node.js via pkg installer"
            fi
        else
            rm -rf "$tmp_dir"
            log_error "Failed to download Node.js installer"
        fi
    fi
    
    # For Linux, try apt
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt; then
            log_info "Installing Node.js via apt..."
            if sudo apt update && sudo apt install -y nodejs npm; then
                log_success "Node.js installed successfully via apt"
                return 0
            else
                log_error "Failed to install Node.js via apt"
            fi
        fi
    fi
    
    log_error "Failed to install Node.js through any method"
    return 1
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
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    # Check if Node.js is already installed
    if command_exists node; then
        log_success "Node.js is already installed: $(node --version)"
    else
        log_info "Node.js not found. Attempting to install..."
        if ! install_nodejs; then
            log_error "Failed to install Node.js. Please install it manually then run this script again."
            log_info "On macOS, you can install it with: brew install node"
            log_info "On Linux, you can install it with: sudo apt install nodejs npm"
            exit 1
        fi
    fi

    # Verify npm is available
    if ! command_exists npm; then
        log_error "npm is not available despite Node.js being installed."
        log_info "Please install npm and then run this script again."
        exit 1
    fi

    # Create Node.js project template
    log_info "Creating Node.js project template..."
    local templates_dir
    templates_dir=$(create_templates_dir)
    local template_script="$templates_dir/basic_node_project.sh"

    # Create Node.js project template script
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

# Initialize Git repository
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial commit" --no-verify || echo -e "${YELLOW}Failed to create initial commit${NC}"

echo -e "${GREEN}Node.js project $PROJECT_NAME created successfully!${NC}"
EOL

    # Make template executable
    chmod +x "$template_script" || {
        log_error "Failed to make template script executable"
        exit 1
    }

    # Add function to .zshrc
    add_function_to_zshrc "nodeproject" "$template_script"

    log_success "Node.js environment setup complete!"
    log_info "New commands available:"
    log_info "  nodeproject - Create a new Node.js project"
    log_info "Node.js packages can be installed globally with: npm install -g <package-name>"
    log_warning "Restart your shell or run 'source ~/.zshrc' to use the new commands"
    
    return 0
}

# Run the main function
main "$@"