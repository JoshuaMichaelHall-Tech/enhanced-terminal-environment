#!/bin/bash
# Node.js/JavaScript development environment setup script
# Part of Enhanced Terminal Environment

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}Setting up Node.js development environment...${NC}"

# Install NVM (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${BLUE}Installing NVM (Node Version Manager)...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Add NVM to shell profile if not already there
    if [[ -z $(grep -r "NVM_DIR" ~/.zshrc) ]]; then
        cat >> ~/.zshrc << 'EOL'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOL
    fi
    
    # Load NVM for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
else
    echo -e "${GREEN}NVM already installed.${NC}"
fi

# Install Node.js LTS version
echo -e "${BLUE}Installing Node.js LTS version...${NC}"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# Install essential global npm packages
echo -e "${BLUE}Installing essential Node.js development tools...${NC}"
npm install -g \
    npm@latest \
    yarn \
    typescript \
    ts-node \
    eslint \
    prettier \
    nodemon \
    serve \
    http-server \
    npm-check-updates

# Create standard Node.js project template directory
TEMPLATE_DIR="$HOME/.local/share/node-templates"
mkdir -p "$TEMPLATE_DIR"

# Create a basic Node.js project template
cat > "$TEMPLATE_DIR/basic_node_project.sh" << 'EOL'
#!/bin/bash
# Basic Node.js project template generator

if [ "$#" -ne 1 ]; then
    echo "Usage: nodeproject projectname"
    exit 1
fi

PROJECT_NAME="$1"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize npm project
npm init -y

# Update package.json with better defaults
tmp=$(mktemp)
jq '.scripts.start = "node src/index.js" | 
    .scripts.test = "jest" | 
    .scripts.lint = "eslint src/**/*.js" |
    .scripts.format = "prettier --write \"src/**/*.js\"" | 
    .author = "Joshua Michael Hall" |
    .license = "MIT"' package.json > "$tmp" && mv "$tmp" package.json

# Create project structure
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
mkdir -p test
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
npm install --save-dev \
  eslint \
  prettier \
  jest \
  nodemon

# Initialize Git repository
git init

echo "Node.js project $PROJECT_NAME created successfully!"
EOL

# Make template executable
chmod +x "$TEMPLATE_DIR/basic_node_project.sh"

# Create nodeproject function
if [[ -z $(grep -r "nodeproject()" ~/.zshrc) ]]; then
    cat >> ~/.zshrc << 'EOL'

# Node.js project creator function
nodeproject() {
    $HOME/.local/share/node-templates/basic_node_project.sh "$@"
}
EOL
fi

echo -e "${GREEN}Node.js environment setup complete!${NC}"
echo -e "${YELLOW}Restart your shell or run 'source ~/.zshrc' to use the new commands${NC}"
