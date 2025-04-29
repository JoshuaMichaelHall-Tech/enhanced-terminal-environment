#!/bin/bash
# Fixed Python development environment setup script
# Part of Enhanced Terminal Environment - Updated for macOS PEP 668 compliance

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Python development environment (PEP 668 compliant)...${NC}"

# Install Python and related tools
if ! brew list python@3.11 &>/dev/null; then
    echo -e "${BLUE}Installing Python 3.11 via Homebrew...${NC}"
    brew install python@3.11
else
    echo -e "${GREEN}Python 3.11 already installed.${NC}"
fi

# Install pipx for managing Python tools
if ! command -v pipx &> /dev/null; then
    echo -e "${BLUE}Installing pipx...${NC}"
    brew install pipx
    pipx ensurepath
    
    # Add pipx to PATH if not already
    if [[ -z $(grep -r "pipx" ~/.zshrc) ]]; then
        echo 'eval "$(register-python-argcomplete pipx)"' >> ~/.zshrc
    fi
else
    echo -e "${GREEN}pipx already installed.${NC}"
fi

# Install Poetry using the official installer (better than pipx for Poetry)
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

# Install essential Python development tools using pipx
echo -e "${BLUE}Installing essential Python development tools...${NC}"

# List of tools to install
PYTHON_TOOLS=(
    "ipython"
    "black"
    "flake8"
    "pylint"
    "mypy"
    "pytest"
    "httpie"
    "virtualenv"
)

# Install each tool if not already installed
for tool in "${PYTHON_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${BLUE}Installing $tool...${NC}"
        pipx install "$tool"
    else
        echo -e "${GREEN}$tool already installed, skipping...${NC}"
    fi
done

# Install pytest-cov as a pytest plugin
if pipx list | grep -q "pytest"; then
    echo -e "${BLUE}Adding pytest-cov plugin to pytest...${NC}"
    pipx inject pytest pytest-cov
fi

# Create standard Python project template directory
TEMPLATE_DIR="$HOME/.local/share/python-templates"
mkdir -p "$TEMPLATE_DIR"

# Create a basic Python project template with updated approach
cat > "$TEMPLATE_DIR/basic_project.sh" << 'EOL'
#!/bin/bash
# Basic Python project template generator - PEP 668 compliant

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

# Create pyproject.toml (modern approach instead of setup.py)
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
EOL
fi

echo -e "${GREEN}Python environment setup complete!${NC}"
echo -e "${YELLOW}New commands available:${NC}"
echo -e "  ${GREEN}pyproject${NC} - Create a new Python project with virtual environment"
echo -e "  ${GREEN}pipx${NC} - Install and run Python applications in isolated environments"
echo -e "${YELLOW}Restart your shell or run 'source ~/.zshrc' to use the new commands${NC}"