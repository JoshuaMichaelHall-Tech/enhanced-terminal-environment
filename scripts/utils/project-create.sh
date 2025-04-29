#!/bin/bash
# Project creation utility for Enhanced Terminal Environment
# Creates project scaffolding for different languages

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_help() {
  echo "Usage: project-create [OPTIONS] <project-name>"
  echo ""
  echo "Options:"
  echo "  -t, --type TYPE    Project type (python, node, ruby, generic)"
  echo "  -d, --dir PATH     Parent directory for project (default: ~/projects)"
  echo "  -g, --git          Initialize Git repository (default: true)"
  echo "  -h, --help         Show this help message"
  echo ""
  echo "Examples:"
  echo "  project-create -t python myapp"
  echo "  project-create --type node --dir ~/code mynodeapp"
  echo ""
}

# Default values
PROJECT_TYPE="generic"
PARENT_DIR="$HOME/projects"
INIT_GIT=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    -d|--dir)
      PARENT_DIR="$2"
      shift 2
      ;;
    -g|--git)
      INIT_GIT="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)
      PROJECT_NAME="$1"
      shift
      ;;
  esac
done

# Validate project name
if [[ -z "$PROJECT_NAME" ]]; then
  echo -e "${RED}Error: Project name is required.${NC}"
  show_help
  exit 1
fi

# Validate project type
case "$PROJECT_TYPE" in
  python|node|ruby|generic)
    ;;
  *)
    echo -e "${RED}Error: Invalid project type. Must be one of: python, node, ruby, generic${NC}"
    exit 1
    ;;
esac

# Ensure parent directory exists
mkdir -p "$PARENT_DIR"

# Set full project path
PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"

# Check if project directory already exists
if [[ -d "$PROJECT_DIR" ]]; then
  echo -e "${RED}Error: Project directory already exists: $PROJECT_DIR${NC}"
  exit 1
fi

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

echo -e "${GREEN}Creating $PROJECT_TYPE project: $PROJECT_NAME${NC}"
echo -e "${BLUE}Project directory: $PROJECT_DIR${NC}"

# Initialize Git repository if requested
if [[ "$INIT_GIT" == true ]]; then
  echo -e "${BLUE}Initializing Git repository...${NC}"
  git init
fi

# Create standard README
cat > README.md << EOF
# $PROJECT_NAME

## Description

A brief description of the project.

## Installation

\`\`\`bash
# Installation instructions
\`\`\`

## Usage

\`\`\`bash
# Usage examples
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

# Create LICENSE file
cat > LICENSE << EOF
MIT License

Copyright (c) $(date +%Y) Joshua Michael Hall

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create project structure based on project type
case "$PROJECT_TYPE" in
  python)
    echo -e "${BLUE}Creating Python project structure...${NC}"
    
    # Create directory structure
    mkdir -p "${PROJECT_NAME}/tests"
    
    # Create Python module structure
    SANITIZED_NAME=$(echo "$PROJECT_NAME" | tr '-' '_')
    mkdir -p "${PROJECT_NAME}/${SANITIZED_NAME}"
    touch "${PROJECT_NAME}/${SANITIZED_NAME}/__init__.py"
    
    # Create main module
    cat > "${PROJECT_NAME}/${SANITIZED_NAME}/main.py" << EOF
"""
Main module for $PROJECT_NAME.
"""

def main():
    """Main entry point of the application."""
    print("Hello from $PROJECT_NAME!")


if __name__ == "__main__":
    main()
EOF
    
    # Create test file
    cat > "${PROJECT_NAME}/tests/__init__.py" << EOF
"""Test package for $PROJECT_NAME."""
EOF

    cat > "${PROJECT_NAME}/tests/test_main.py" << EOF
"""
Tests for the main module.
"""
import pytest
from ${SANITIZED_NAME}.main import main


def test_main():
    """Test the main function."""
    # This is a placeholder test
    assert True
EOF
    
    # Create setup.py
    cat > "${PROJECT_NAME}/setup.py" << EOF
from setuptools import setup, find_packages

setup(
    name="${SANITIZED_NAME}",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        # Add dependencies here
    ],
    entry_points={
        'console_scripts': [
            '${SANITIZED_NAME}=${SANITIZED_NAME}.main:main',
        ],
    },
    author="Joshua Michael Hall",
    author_email="your.email@example.com",
    description="A brief description of ${PROJECT_NAME}",
    keywords="${SANITIZED_NAME}",
    url="https://github.com/joshuamichaelhall/${PROJECT_NAME}",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
    ],
    python_requires=">=3.9",
)
EOF
    
    # Create requirements files
    cat > "${PROJECT_NAME}/requirements.txt" << EOF
# Runtime dependencies
# Add dependencies here
EOF

    cat > "${PROJECT_NAME}/requirements-dev.txt" << EOF
# Development dependencies
pytest>=7.0.0
black>=23.0.0
pylint>=2.17.0
mypy>=1.4.0
EOF
    
    # Create .gitignore
    cat > "${PROJECT_NAME}/.gitignore" << EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Distribution / packaging
dist/
build/
*.egg-info/

# Virtual environments
.venv/
venv/
ENV/

# Testing
.coverage
htmlcov/
.pytest_cache/

# Mypy
.mypy_cache/

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
EOF
    
    echo -e "${GREEN}Python project created successfully!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  cd $PROJECT_DIR"
    echo -e "  python -m venv venv"
    echo -e "  source venv/bin/activate"
    echo -e "  pip install -e ."
    echo -e "  pip install -r requirements-dev.txt"
    echo -e "  pytest"
    ;;
    
  node)
    echo -e "${BLUE}Creating Node.js project structure...${NC}"
    
    # Create directory structure
    mkdir -p src test
    
    # Create main file
    cat > src/index.js << EOF
/**
 * Main entry point for $PROJECT_NAME
 */

function main() {
  console.log("Hello from $PROJECT_NAME!");
}

main();

module.exports = { main };
EOF
    
    # Create test file
    cat > test/index.test.js << EOF
const { main } = require('../src/index');

describe('Main function', () => {
  test('runs without error', () => {
    // This is a placeholder test
    expect(true).toBe(true);
  });
});
EOF
    
    # Create package.json
    cat > package.json << EOF
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "description": "A Node.js project",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint src/",
    "format": "prettier --write \\"src/**/*.js\\""
  },
  "keywords": [],
  "author": "Joshua Michael Hall",
  "license": "MIT",
  "devDependencies": {
    "eslint": "^8.35.0",
    "jest": "^29.5.0",
    "nodemon": "^2.0.21",
    "prettier": "^2.8.4"
  },
  "dependencies": {
  }
}
EOF
    
    # Create .gitignore
    cat > .gitignore << EOF
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
    
    # Create ESLint configuration
    cat > .eslintrc.js << EOF
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
    
    # Create Prettier configuration
    cat > .prettierrc << EOF
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
EOF
    
    echo -e "${GREEN}Node.js project created successfully!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  cd $PROJECT_DIR"
    echo -e "  npm install"
    echo -e "  npm test"
    echo -e "  npm start"
    ;;
    
  ruby)
    echo -e "${BLUE}Creating Ruby project structure...${NC}"
    
    # Create directory structure
    mkdir -p lib spec bin
    
    # Sanitize project name for Ruby
    SANITIZED_NAME=$(echo "$PROJECT_NAME" | tr '-' '_')
    
    # Create main library file
    cat > lib/${SANITIZED_NAME}.rb << EOF
# Main module for ${PROJECT_NAME}
module ${SANITIZED_NAME.capitalize}
  VERSION = '0.1.0'.freeze
  
  # Your code goes here...
  def self.hello
    puts "Hello from ${PROJECT_NAME}!"
  end
end
EOF
    
    # Create executable
    cat > bin/${PROJECT_NAME} << EOF
#!/usr/bin/env ruby

require_relative '../lib/${SANITIZED_NAME}'

# Add command-line handling code here
${SANITIZED_NAME.capitalize}.hello
EOF
    chmod +x bin/${PROJECT_NAME}
    
    # Create spec file
    cat > spec/${SANITIZED_NAME}_spec.rb << EOF
require 'spec_helper'
require '${SANITIZED_NAME}'

RSpec.describe ${SANITIZED_NAME.capitalize} do
  it 'has a version number' do
    expect(${SANITIZED_NAME.capitalize}::VERSION).not_to be nil
  end
  
  it 'does something useful' do
    expect(true).to eq(true)
  end
end
EOF
    
    # Create spec helper
    cat > spec/spec_helper.rb << EOF
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
    
    # Create Gemfile
    cat > Gemfile << EOF
source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'yard', '~> 0.9'
  gem 'pry', '~> 0.14'
end
EOF
    
    # Create gemspec
    cat > ${PROJECT_NAME}.gemspec << EOF
require_relative 'lib/${SANITIZED_NAME}'

Gem::Specification.new do |spec|
  spec.name          = "${PROJECT_NAME}"
  spec.version       = ${SANITIZED_NAME.capitalize}::VERSION
  spec.authors       = ["Joshua Michael Hall"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "A brief description of ${PROJECT_NAME}"
  spec.description   = "A longer description of ${PROJECT_NAME}"
  spec.homepage      = "https://github.com/joshuamichaelhall/${PROJECT_NAME}"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/joshuamichaelhall/${PROJECT_NAME}"
  spec.metadata["changelog_uri"] = "https://github.com/joshuamichaelhall/${PROJECT_NAME}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*', 'bin/*', '[A-Z]*']
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
EOF
    
    # Create Rakefile
    cat > Rakefile << EOF
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
EOF
    
    # Create .gitignore
    cat > .gitignore << EOF
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
    cat > .rubocop.yml << EOF
AllCops:
  NewCops: enable
  TargetRubyVersion: 2.6

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
    
    echo -e "${GREEN}Ruby project created successfully!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  cd $PROJECT_DIR"
    echo -e "  bundle install"
    echo -e "  bundle exec rspec"
    echo -e "  bundle exec bin/${PROJECT_NAME}"
    ;;
    
  generic)
    echo -e "${BLUE}Creating generic project structure...${NC}"
    
    # Create basic structure
    mkdir -p src docs tests
    
    # Create placeholder files
    touch src/.gitkeep
    touch docs/.gitkeep
    touch tests/.gitkeep
    
    # Create .gitignore
    cat > .gitignore << EOF
# Logs
logs
*.log

# Dependency directories
node_modules/
vendor/
.venv/
venv/

# Build output
dist/
build/
out/

# Environment variables
.env
.env.local

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
Thumbs.db
EOF
    
    echo -e "${GREEN}Generic project created successfully!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  cd $PROJECT_DIR"
    echo -e "  # Start coding!"
    ;;
esac

# Initial commit if Git was initialized
if [[ "$INIT_GIT" == true ]]; then
  git add .
  git commit -m "Initial commit" --no-verify
  echo -e "${BLUE}Git repository initialized with initial commit.${NC}"
fi

echo -e "${GREEN}Project setup complete: $PROJECT_NAME${NC}"
echo -e "${BLUE}Project path: $PROJECT_DIR${NC}"
