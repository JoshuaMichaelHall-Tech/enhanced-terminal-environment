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
    
elif [[ "$OS" == "Linux" ]]; then
    # Install Python and development tools
    echo -e "${BLUE}Installing Python and development tools...${NC}"
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential
fi

# Ensure pip is up to date (in user space to avoid system conflicts)
echo -e "${BLUE}Updating pip in user space...${NC}"
python3 -m pip install --user --upgrade pip

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

# Create a virtual environment for development tools
VENV_DIR="$HOME/.python-dev-env"
echo -e "${BLUE}Creating Python virtual environment for development tools at $VENV_DIR...${NC}"
python3 -m venv "$VENV_DIR"

# Install essential Python packages in the virtual environment
echo -e "${BLUE}Installing essential Python development tools in virtual environment...${NC}"
source "$VENV_DIR/bin/activate"
pip install \
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
deactivate

# Create activation script for development tools
ACTIVATE_SCRIPT="$HOME/.local/bin/pydev"
mkdir -p "$(dirname "$ACTIVATE_SCRIPT")"
cat > "$ACTIVATE_SCRIPT" << 'EOF'
#!/bin/bash
# Activate Python development environment
source "$HOME/.python-dev-env/bin/activate"
echo "Python development environment activated."
echo "Type 'deactivate' to exit."
EOF
chmod +x "$ACTIVATE_SCRIPT"

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

# Create virtual environment
python3 -m venv venv
echo "Created virtual environment at ./venv"

# Create project structure
mkdir -p "${PROJECT_NAME}/tests"

# Create main module
mkdir -p "${PROJECT_NAME}/${PROJECT_NAME}"
touch "${PROJECT_NAME}/${PROJECT_NAME}/__init__.py"
cat > "${PROJECT_NAME}/${PROJECT_NAME}/main.py" << 'EOF'
def main():
    """Main entry point of the application."""
    print("Hello, World!")

if __name__ == "__main__":
    main()
EOF

# Create test file
cat > "${PROJECT_NAME}/tests/test_main.py" << EOF
import pytest
from ${PROJECT_NAME}.main import main

def test_main():
    """Test the main function."""
    # This is a placeholder test
    assert True
EOF

# Create README
cat > "${PROJECT_NAME}/README.md" << EOF
# $PROJECT_NAME

A Python project.

## Installation

\`\`\`bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate

# Install development dependencies
pip install -e ".[dev]"
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
cat > "${PROJECT_NAME}/pyproject.toml" << EOF
[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "A Python project"
readme = "README.md"
authors = [
    {name = "Joshua Michael Hall", email = "your.email@example.com"}
]
requires-python = ">=3.9"
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
]

dependencies = [
    # Add runtime dependencies here
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "pylint>=2.17.0",
    "mypy>=1.4.0",
]

[project.urls]
"Homepage" = "https://github.com/joshuamichaelhall/${PROJECT_NAME}"
"Bug Tracker" = "https://github.com/joshuamichaelhall/${PROJECT_NAME}/issues"

[project.scripts]
${PROJECT_NAME} = "${PROJECT_NAME}.main:main"
EOF

# Create .gitignore
cat > "${PROJECT_NAME}/.gitignore" << 'EOF'
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

# Activate the virtual environment and install dependencies
cd "${PROJECT_NAME}"
source venv/bin/activate
pip install -e ".[dev]"
deactivate

# Initialize Git repository
git init
git add .
git commit -m "Initial project structure"

echo "Python project $PROJECT_NAME created successfully with virtual environment!"
echo "To activate the environment, run: cd ${PROJECT_NAME} && source venv/bin/activate"
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

# Python development environment activation
alias pydev="source $HOME/.local/bin/pydev"
EOL
fi

echo -e "${GREEN}Python environment setup complete!${NC}"
echo -e "${YELLOW}New commands available:${NC}"
echo -e "  ${GREEN}pyproject${NC} - Create a new Python project with virtual environment"
echo -e "  ${GREEN}pydev${NC} - Activate the Python development tools environment"
echo -e "${YELLOW}Restart your shell or run 'source ~/.zshrc' to use the new commands${NC}"