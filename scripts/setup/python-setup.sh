#!/bin/bash
# Python development environment setup script
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

echo -e "${BLUE}Setting up Python development environment...${NC}"

# Install Python and related tools based on OS
if [[ "$OS" == "macOS" ]]; then
    # Check if Python is installed via Homebrew
    if ! brew list python@3.11 &>/dev/null; then
        echo -e "${BLUE}Installing Python 3.11 via Homebrew...${NC}"
        brew install python@3.11
    else
        echo -e "${GREEN}Python 3.11 already installed.${NC}"
    fi
    
    # Ensure pip is up to date
    python3 -m pip install --upgrade pip
    
elif [[ "$OS" == "Linux" ]]; then
    # Install Python and development tools
    echo -e "${BLUE}Installing Python and development tools...${NC}"
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential
    
    # Ensure pip is up to date
    python3 -m pip install --upgrade pip
fi

# Install Poetry
if ! command -v poetry &>/dev/null; then
    echo -e "${BLUE}Installing Poetry (Python package manager)...${NC}"
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH if not already
    if [[ -z $(grep -r "poetry/bin" ~/.zshrc) ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
else
    echo -e "${GREEN}Poetry already installed.${NC}"
    poetry self update
fi

# Install essential Python packages
echo -e "${BLUE}Installing essential Python development tools...${NC}"
python3 -m pip install --user \
    ipython \
    black \
    pylint \
    flake8 \
    mypy \
    pytest \
    pytest-cov \
    httpie \
    requests \
    virtualenv \
    pipenv

# Create standard Python project template directory
TEMPLATE_DIR="$HOME/.local/share/python-templates"
mkdir -p "$TEMPLATE_DIR"

# Create a basic Python project template
cat > "$TEMPLATE_DIR/basic_project.sh" << 'EOL'
#!/bin/bash
# Basic Python project template generator

if [ "$#" -ne 1 ]; then
    echo "Usage: pyproject projectname"
    exit 1
fi

PROJECT_NAME="$1"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create project structure
mkdir -p "$PROJECT_NAME/tests"

# Create main module
mkdir -p "$PROJECT_NAME/$PROJECT_NAME"
touch "$PROJECT_NAME/$PROJECT_NAME/__init__.py"
cat > "$PROJECT_NAME/$PROJECT_NAME/main.py" << 'EOF'
def main():
    """Main entry point of the application."""
    print("Hello, World!")

if __name__ == "__main__":
    main()
EOF

# Create test file
cat > "$PROJECT_NAME/tests/test_main.py" << 'EOF'
import pytest
from ${PROJECT_NAME}.main import main

def test_main():
    """Test the main function."""
    # This is a placeholder test
    assert True
EOF

# Create README
cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

A Python project.

## Installation

\`\`\`bash
# With Poetry
poetry install

# Or with pip
pip install -e .
\`\`\`

## Usage

\`\`\`python
from $PROJECT_NAME import main
main.main()
\`\`\`

## Development

\`\`\`bash
# Run tests
pytest

# Format code
black $PROJECT_NAME
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

# Create pyproject.toml
cat > "$PROJECT_NAME/pyproject.toml" << EOF
[tool.poetry]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "A Python project"
authors = ["Joshua Michael Hall <your.email@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.9"

[tool.poetry.dev-dependencies]
pytest = "^7.0"
black = "^23.0"
pylint = "^2.17"
mypy = "^1.4"

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

[tool.poetry.scripts]
$PROJECT_NAME = "${PROJECT_NAME}.main:main"
EOF

# Initialize Git repository
git init
cat > "$PROJECT_NAME/.gitignore" << 'EOF'
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

echo "Python project $PROJECT_NAME created successfully!"
EOL

# Make template executable
chmod +x "$TEMPLATE_DIR/basic_project.sh"

# Create pyproject function
if [[ -z $(grep -r "pyproject()" ~/.zshrc) ]]; then
    cat >> ~/.zshrc << 'EOL'

# Python project creator function
pyproject() {
    $HOME/.local/share/python-templates/basic_project.sh "$@"
}
EOL
fi

echo -e "${GREEN}Python environment setup complete!${NC}"
echo -e "${YELLOW}Restart your shell or run 'source ~/.zshrc' to use the new commands${NC}"
