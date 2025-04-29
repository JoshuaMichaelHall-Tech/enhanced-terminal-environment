#!/usr/bin/env bash
# Python development environment setup script
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

# Ensure a Python command exists and extract version
check_python_version() {
    local python_cmd="$1"
    
    if command_exists "$python_cmd"; then
        # Get Python version
        local version
        version=$("$python_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        echo "$version"
    else
        echo ""
    fi
}

# Create project templates directory
create_templates_dir() {
    local dir="$HOME/.local/share/python-templates"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating Python templates directory: $dir"
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

# Python project creator function
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
    log_info "Setting up Python development environment..."

    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        readonly OS="macOS"
        log_info "Detected macOS system"
        
        # Install Python via Homebrew on macOS
        local python_version
        python_version=$(check_python_version "python3")
        
        if [[ -z "$python_version" ]]; then
            log_info "Installing Python via Homebrew..."
            brew install python@3.11 || handle_error "Failed to install Python"
            
            # Check if Python was installed successfully
            python_version=$(check_python_version "python3")
            if [[ -z "$python_version" ]]; then
                handle_error "Python installation failed"
            fi
        else
            log_success "Python already installed: $python_version"
        fi
        
        # Install pipx
        if ! command_exists "pipx"; then
            log_info "Installing pipx..."
            
            # Make sure pip is installed and up to date
            python3 -m pip install --upgrade pip || handle_error "Failed to upgrade pip"
            
            # Install pipx to user directory
            python3 -m pip install --user pipx || handle_error "Failed to install pipx"
            
            # Ensure pipx binaries are in PATH
            python3 -m pipx ensurepath || log_warning "Failed to add pipx to PATH"
            
            # Add pipx to shell completion if possible
            if python3 -c "import importlib.util; print(importlib.util.find_spec('pipx') is not None)" 2>/dev/null | grep -q "True"; then
                if ! grep -q "register-python-argcomplete pipx" "$HOME/.zshrc"; then
                    echo 'eval "$(register-python-argcomplete pipx)"' >> "$HOME/.zshrc"
                fi
            fi
            
            # Verify pipx installation
            if ! command_exists "pipx"; then
                log_warning "pipx not found in PATH after installation. You may need to restart your shell."
                log_warning "After restart, if pipx commands aren't recognized, run: python3 -m pipx ensurepath"
            else
                log_success "pipx installed successfully"
            fi
        else
            log_success "pipx already installed"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        readonly OS="Linux"
        log_info "Detected Linux system"
        
        # Update package lists
        log_info "Updating package lists..."
        sudo apt update || handle_error "Failed to update package lists"
        
        # Install Python and related tools on Linux
        local python_version
        python_version=$(check_python_version "python3")
        
        if [[ -z "$python_version" ]]; then
            log_info "Installing Python 3..."
            sudo apt install -y python3 python3-dev python3-venv python3-pip || handle_error "Failed to install Python"
            
            # Check if Python was installed successfully
            python_version=$(check_python_version "python3")
            if [[ -z "$python_version" ]]; then
                handle_error "Python installation failed"
            fi
        else
            log_success "Python already installed: $python_version"
        fi
        
        # Install pipx
        if ! command_exists "pipx"; then
            log_info "Installing pipx..."
            sudo apt install -y python3-pipx || handle_error "Failed to install pipx"
            
            # Ensure pipx is in path
            pipx ensurepath || log_warning "Failed to add pipx to PATH"
            
            # Add pipx to shell completion if possible
            if ! grep -q "register-python-argcomplete pipx" "$HOME/.zshrc"; then
                echo 'eval "$(register-python-argcomplete pipx)"' >> "$HOME/.zshrc"
            fi
            
            # Verify pipx installation
            if ! command_exists "pipx"; then
                log_warning "pipx not found in PATH after installation. You may need to restart your shell."
            else
                log_success "pipx installed successfully"
            fi
        else
            log_success "pipx already installed"
        fi
    else
        handle_error "Unsupported operating system: $OSTYPE"
    fi

    # Install Poetry using the official installer
    if ! command_exists "poetry"; then
        log_info "Installing Poetry (Python package manager)..."
        curl -sSL https://install.python-poetry.org | python3 - || handle_error "Failed to install Poetry"
        
        # Add Poetry to PATH if not already
        if ! grep -q "poetry/bin" "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        fi
        
        # Verify Poetry installation
        if ! command_exists "poetry"; then
            log_warning "Poetry not found in PATH after installation. You may need to restart your shell."
            log_warning "After restart, if poetry commands aren't recognized, add '$HOME/.poetry/bin' to your PATH."
        else
            log_success "Poetry installed successfully"
        fi
    else
        log_success "Poetry already installed, upgrading if necessary..."
        poetry self update || log_warning "Failed to update Poetry"
    fi

    # Install essential Python development tools using pipx
    log_info "Installing essential Python development tools..."

    # List of tools to install
    local PYTHON_TOOLS=(
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
        if ! command_exists "$tool"; then
            log_info "Installing $tool..."
            pipx install "$tool" || log_warning "Failed to install $tool, continuing anyway..."
        else
            log_success "$tool already installed, skipping..."
        fi
    done

    # Install pytest-cov as a pytest plugin
    if command_exists "pytest"; then
        log_info "Adding pytest-cov plugin to pytest..."
        pipx inject pytest pytest-cov || log_warning "Failed to add pytest-cov plugin, continuing anyway..."
    fi

    # Create Python project template
    local templates_dir
    templates_dir=$(create_templates_dir)
    local template_script="$templates_dir/basic_project.sh"

    # Create Python project template script
    log_info "Creating Python project template..."
    cat > "$template_script" << 'EOL'
#!/usr/bin/env bash
# Basic Python project template generator - PEP 668 compliant

set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: pyproject <projectname>${NC}"
    exit 1
fi

PROJECT_NAME="$1"
# Convert project name to valid Python package name
PACKAGE_NAME=$(echo "$PROJECT_NAME" | tr '-' '_' | tr '[:upper:]' '[:lower:]')

# Check if directory already exists
if [[ -d "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists.${NC}"
    exit 1
fi

echo -e "${BLUE}Creating project: $PROJECT_NAME${NC}"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

# Create virtual environment
echo -e "${BLUE}Setting up virtual environment...${NC}"
python3 -m venv venv
echo -e "${GREEN}Created virtual environment at ./venv${NC}"

# Create project structure
echo -e "${BLUE}Creating project structure...${NC}"
mkdir -p "$PACKAGE_NAME/tests"

# Create main module
mkdir -p "$PACKAGE_NAME/$PACKAGE_NAME"
touch "$PACKAGE_NAME/$PACKAGE_NAME/__init__.py"

# Create main.py with proper content
cat > "$PACKAGE_NAME/$PACKAGE_NAME/main.py" << EOF
"""Main entry point of the application."""


def main():
    """Main entry point of the application."""
    print("Hello, World!")


if __name__ == "__main__":
    main()
EOF

# Create test file
cat > "$PACKAGE_NAME/tests/__init__.py" << EOF
"""Test package."""
EOF

cat > "$PACKAGE_NAME/tests/test_main.py" << EOF
"""Test the main module."""
import pytest
from ${PACKAGE_NAME}.main import main


def test_main():
    """Test the main function."""
    # This is a placeholder test
    assert True
EOF

# Create README
cat > "$PACKAGE_NAME/README.md" << EOF
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
from $PACKAGE_NAME import main
main.main()
\`\`\`

## Development

\`\`\`bash
# Run tests
pytest

# Format code
black $PACKAGE_NAME
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

# Create pyproject.toml (modern approach)
cat > "$PACKAGE_NAME/pyproject.toml" << EOF
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
${PACKAGE_NAME} = "${PACKAGE_NAME}.main:main"
EOF

# Create .gitignore
cat > "$PACKAGE_NAME/.gitignore" << 'EOF'
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

# Initialize Git repository
cd "$PACKAGE_NAME" || exit 1
echo -e "${BLUE}Initializing Git repository...${NC}"
git init
git add .
git commit -m "Initial project structure" --no-verify

echo -e "${GREEN}Python project $PROJECT_NAME created successfully with virtual environment!${NC}"
echo -e "${YELLOW}To activate the environment, run:${NC}"
echo -e "  cd ${PROJECT_NAME}"
echo -e "  source venv/bin/activate" 
echo -e "${YELLOW}Then install development dependencies:${NC}"
echo -e "  pip install -e \".[dev]\""
EOL

    # Make template executable
    chmod +x "$template_script" || handle_error "Failed to make template script executable"

    # Add function to .zshrc
    add_function_to_zshrc "pyproject" "$template_script"

    log_success "Python environment setup complete!"
    log_info "New commands available:"
    log_info "  pyproject - Create a new Python project with virtual environment"
    log_info "  poetry - Manage Python packages and dependencies"
    log_info "  pipx - Install and run Python applications in isolated environments"
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