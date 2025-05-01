#!/usr/bin/env bash
# Python development environment setup script - PEP 668 compatible
# Part of Enhanced Terminal Environment
# Version: 3.1 - With improved error handling and dependency checks

# Allow for graceful fallbacks
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
    local dir="$HOME/.local/share/python-templates"
    
    if [[ ! -d "$dir" ]]; then
        log_info "Creating Python templates directory: $dir"
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

# Python project creator function
${function_name}() {
    ${function_path} "\$@"
}
EOF
    else
        log_success "${function_name} function already exists in .zshrc"
    fi
}

# Install Python if not already installed
install_python() {
    log_info "Attempting to install Python..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # For macOS, use Homebrew if available
        if command_exists brew; then
            log_info "Installing Python via Homebrew..."
            if brew install python; then
                log_success "Python installed successfully via Homebrew"
                return 0
            else
                log_warning "Failed to install Python via Homebrew"
            fi
        else
            log_warning "Homebrew not available for Python installation"
        fi
        
        # macOS typically comes with Python pre-installed
        log_info "Checking for system Python..."
        if command_exists python3; then
            log_success "System Python already available: $(python3 --version)"
            return 0
        fi
        
        log_error "No Python installation method available for macOS"
        return 1
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # For Linux, try apt
        if command_exists apt; then
            log_info "Installing Python via apt..."
            if sudo apt update && sudo apt install -y python3 python3-pip python3-venv; then
                log_success "Python installed successfully via apt"
                return 0
            else
                log_error "Failed to install Python via apt"
            fi
        fi
        
        log_error "No Python installation method available for Linux"
        return 1
    fi
    
    return 1
}

# Install pipx using the best available method
install_pipx() {
    log_info "Attempting to install pipx..."
    
    # Try Homebrew first if available
    if command_exists brew; then
        log_info "Installing pipx via Homebrew..."
        if brew install pipx; then
            log_success "pipx installed successfully via Homebrew"
            
            # Ensure pipx binaries are in PATH
            if command_exists pipx; then
                log_info "Configuring pipx..."
                pipx ensurepath || log_warning "Failed to add pipx to PATH"
            fi
            return 0
        else
            log_warning "Failed to install pipx via Homebrew, trying pip installation..."
        fi
    fi
    
    # Try pip as fallback
    if command_exists pip3 || command_exists pip; then
        local pip_cmd="pip3"
        if ! command_exists pip3; then
            pip_cmd="pip"
        fi
        
        log_info "Installing pipx via pip..."
        
        # Try with user installation first
        if $pip_cmd install --user pipx; then
            log_success "pipx installed successfully via pip (user install)"
            
            # Add to PATH if needed
            local python_user_bin="$HOME/.local/bin"
            if [[ -d "$python_user_bin" ]]; then
                if ! echo "$PATH" | grep -q "$python_user_bin"; then
                    log_info "Adding Python user bin to PATH in .zshrc..."
                    echo "export PATH=\"$python_user_bin:\$PATH\"" >> "$HOME/.zshrc"
                    # Also add to current session
                    export PATH="$python_user_bin:$PATH"
                fi
            fi
            
            # Configure pipx if available
            if command_exists pipx || [[ -x "$python_user_bin/pipx" ]]; then
                log_info "Configuring pipx..."
                "$python_user_bin/pipx" ensurepath 2>/dev/null || log_warning "Failed to add pipx to PATH"
            fi
            
            return 0
        else
            log_warning "Failed to install pipx via pip user installation, trying system installation..."
            
            # Try system installation with sudo
            if sudo $pip_cmd install pipx; then
                log_success "pipx installed successfully via pip (system install)"
                return 0
            else
                log_error "Failed to install pipx via pip"
            fi
        fi
    fi
    
    log_error "No pipx installation method available"
    return 1
}

# Install Poetry using the official method
install_poetry() {
    log_info "Installing Poetry (Python package manager)..."
    
    # Create temporary directory for the installer
    TEMPDIR=$(mktemp -d)
    INSTALLER="$TEMPDIR/install-poetry.py"
    
    # Download the installer
    if curl -sSL https://install.python-poetry.org -o "$INSTALLER"; then
        # Run the installer with --user flag to avoid system Python modifications
        python3 "$INSTALLER" --yes || {
            rm -rf "$TEMPDIR"
            log_error "Failed to install Poetry"
            return 1
        }
        rm -rf "$TEMPDIR"
        
        # Add Poetry to PATH if not already
        POETRY_BIN_PATH="$HOME/.poetry/bin"
        if [[ ! -d "$HOME/.local/bin" ]]; then
            mkdir -p "$HOME/.local/bin"
        fi
        
        # Add to zshrc if not already there
        if ! grep -q "poetry/bin" "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/.local/bin:$HOME/.poetry/bin:$PATH"' >> "$HOME/.zshrc"
            log_info "Added Poetry to PATH in .zshrc"
        fi
        
        # For immediate availability in this script
        export PATH="$HOME/.local/bin:$POETRY_BIN_PATH:$PATH"
        
        log_success "Poetry installed successfully"
        return 0
    else
        rm -rf "$TEMPDIR" 2>/dev/null
        log_error "Failed to download Poetry installer"
        return 1
    fi
}

# Install Python development tools
install_python_tools() {
    if command_exists pipx; then
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
        )

        # Install each tool if not already installed
        for tool in "${PYTHON_TOOLS[@]}"; do
            if ! command_exists "$tool"; then
                log_info "Installing $tool with pipx..."
                if ! pipx install "$tool" 2>/dev/null; then
                    log_warning "Failed to install $tool, continuing anyway..."
                fi
            else
                log_success "$tool already installed, skipping..."
            fi
        done

        # Install pytest-cov as a pytest plugin if pytest was successfully installed
        if command_exists pytest; then
            log_info "Adding pytest-cov plugin to pytest..."
            pipx inject pytest pytest-cov 2>/dev/null || log_warning "Failed to add pytest-cov plugin, continuing anyway..."
        fi
        
        return 0
    else
        log_warning "pipx is not available, skipping installation of Python development tools"
        return 1
    fi
}

# Main function
main() {
    log_info "Setting up Python development environment..."

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

    # Check Python installation
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        log_success "Python already installed: $PYTHON_VERSION"
    else
        log_info "Python not found. Attempting to install..."
        if ! install_python; then
            log_error "Failed to install Python. Please install Python 3 manually and run this script again."
            exit 1
        fi
    fi
    
    # Install pipx
    if command_exists pipx; then
        log_success "pipx already installed"
    else
        if ! install_pipx; then
            log_warning "pipx installation failed, some features will be limited"
        fi
    fi
    
    # Install Poetry
    if command_exists poetry; then
        log_success "Poetry already installed"
        # Try to update Poetry
        poetry self update 2>/dev/null || log_warning "Failed to update Poetry, continuing anyway..."
    else
        if ! install_poetry; then
            log_warning "Poetry installation failed, continuing with setup"
        fi
    fi

    # Install Python development tools
    install_python_tools

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
echo
echo -e "${YELLOW}To activate the environment, run:${NC}"
echo -e "  cd ${PROJECT_NAME}"
echo -e "  source venv/bin/activate" 
echo -e "${YELLOW}Then install development dependencies:${NC}"
echo -e "  pip install -e \".[dev]\""
EOL

    # Make template executable
    chmod +x "$template_script" || {
        log_error "Failed to make template script executable" 
        log_error "Failed to make template script executable"
    }

    # Add function to .zshrc
    add_function_to_zshrc "pyproject" "$template_script"

    log_success "Python environment setup complete!"
    log_info "New commands available:"
    log_info "  pyproject - Create a new Python project with virtual environment"
    if command_exists poetry; then
        log_info "  poetry - Manage Python packages and dependencies"
    fi
    if command_exists pipx; then
        log_info "  pipx - Install and run Python applications in isolated environments"
    fi
    log_warning "Restart your shell or run 'source ~/.zshrc' to use the new commands"
}

# Run the main function
main "$@"