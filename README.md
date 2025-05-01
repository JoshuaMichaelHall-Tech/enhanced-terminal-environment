# Enhanced Terminal Environment

A comprehensive, structured learning path for mastering terminal-based software development, designed for full-stack engineers working with Python, JavaScript, and Ruby.

![Terminal Environment](https://img.shields.io/badge/Terminal-Environment-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-orange)

## Overview

This project provides a progressive approach to learning essential terminal tools for a modern software development workflow:

- **Shell** (Bash/Zsh) for command-line navigation and automation
- **Neovim** for efficient text editing and programming
- **Tmux** for terminal multiplexing and session management
- **Git/GitHub CLI** for version control and collaboration
- **Docker** for containerization and deployment
- **SQL/NoSQL Databases** for data storage and retrieval
- **Cloud CLI Tools** for infrastructure management
- **HTTP Client Tools** for API testing and integration
- **Package Managers** for dependency management
- **Monitoring Tools** for system and application performance

The course focuses on core fundamentals first, gradually introducing more advanced concepts as your skills develop.

## Philosophy

This learning path is built on these core principles:

- **Mastery Through Deliberate Practice**: Regular, focused practice of specific skills
- **Progressive Skill Acquisition**: Learn fundamentals before moving to advanced concepts
- **Minimal Yet Powerful**: Focus on essential tools that provide the most value
- **Cross-Platform**: Works consistently on both macOS and Linux
- **Project-Based Learning**: Apply skills to real-world projects
- **Language Polyglot**: Support for Python, JavaScript, and Ruby workflows

## Getting Started

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/joshuamichaelhall/enhanced-terminal-env.git
   cd enhanced-terminal-env
   ```

2. Run the pre-installation check (optional but recommended):
   ```bash
   ./pre-check.sh
   ```

3. Run the installation script:
   ```bash
   # For macOS or Linux
   ./install.sh
   ```

4. Verify your installation:
   ```bash
   ./verify.sh
   ```

The script will install and configure the necessary tools with sensible defaults for modern software development.

### What's Included

- **Cross-platform installation script** for setting up all essential tools
- **Language-specific development environments** for Python, JavaScript, and Ruby
- **Containerization tools** for Docker and microservices
- **Cloud tooling** for AWS, Terraform, and Ansible
- **Terminal-based HTTP clients** for API testing
- **Minimal configurations** for Neovim, Tmux, and Zsh
- **Month-by-month learning guides** with clear objectives and exercises
- **Quick reference cheatsheet** for all tools
- **Project suggestions** to reinforce learning

## Tool Categories

### 1. Core Terminal Tools
- Zsh with key plugins and configurations
- Tmux for session management
- Neovim for efficient editing

### 2. Development Tools
- Git and GitHub CLI for version control
- Language-specific tools for Python, JavaScript, and Ruby
- Package managers (pip, npm, gem, etc.)
- Linting and formatting tools

### 3. Data & Infrastructure
- PostgreSQL and MongoDB Atlas CLI
- Docker and Docker Compose
- AWS CLI, Terraform, and Ansible
- Monitoring tools (htop, glances)

### 4. Productivity Enhancers
- Fuzzy finders (fzf)
- Ripgrep and fd for fast searching
- Custom shortcut functions
- HTTP clients (curl, HTTPie)

## Learning Path Structure

The 12-month learning path is structured as follows:

1. **Month 1-3: Foundations**
   - Shell fundamentals and navigation
   - Basic Vim editing and movement
   - Tmux session management
   - Git essentials
   - Docker basics
   - HTTP client fundamentals

2. **Month 4-6: Integration**
   - Shell scripting
   - Advanced Vim techniques
   - Tmux workflow optimization
   - Docker Compose for local development
   - Package managers for Python, JavaScript, and Ruby
   - GitHub CLI for enhanced Git workflows

3. **Month 7-9: Workflow Optimization**
   - Custom scripts and aliases
   - Vim plugins and customization
   - Infrastructure as code with Terraform
   - Advanced Git workflows
   - Database administration from terminal
   - Terminal-based monitoring tools

4. **Month 10-12: Advanced Applications**
   - Full-stack terminal workflow
   - Cloud resource management via CLI
   - Performance optimization
   - Advanced infrastructure automation
   - Terminal-based productivity systems

## Language-Specific Terminal Workflows

### Python
- Virtual environment management with Poetry
- REPL-driven development
- Testing with pytest from terminal
- Package management best practices
- Custom tmux sessions for Python development

### JavaScript/Node.js
- npm/yarn workflow optimization
- Node.js REPL for rapid testing
- Terminal-based debugging
- ESLint and Prettier integration
- Custom tmux sessions for JS development

### Ruby
- Gem management
- Bundler for dependencies
- IRB/Pry for interactive development
- Rubocop for linting
- Custom tmux sessions for Ruby development

## Commands

After installation, you'll have access to the following commands:

### Session Management
- `mkpy <name>` - Create a Python development tmux session
- `mkjs <name>` - Create a JavaScript development tmux session
- `mkrb <name>` - Create a Ruby development tmux session
- `mks <name>` - Create a generic development tmux session

### Project Creation
- `pyproject <name>` - Create a new Python project with virtual environment
- `nodeproject <name>` - Create a new Node.js project
- `rubyproject <name>` - Create a new Ruby project

### Utility Functions
- `vf` - Find and edit files with fuzzy search
- `proj` - Navigate to projects with fuzzy search
- `extract <file>` - Extract archives of various formats
- `dsh` - Enter Docker container shell with fuzzy selection

## Troubleshooting Guide

### Common Installation Issues

#### Python Environment (PEP 668) Issues

**Symptoms:**
- Errors about "externally-managed-environment"
- pip installation failures
- Permission issues with Python packages

**Solutions:**
1. Use the `fix-pip.sh` script included in the repository:
   ```bash
   ./fix-pip.sh
   ```
2. Manual fix - Install pipx using system package manager:
   ```bash
   # On macOS
   brew install pipx
   pipx ensurepath
   # On Ubuntu/Debian
   sudo apt install python3-pipx
   pipx ensurepath
   ```
3. Restart the installation with recovery mode:
   ```bash
   ./install.sh --recover
   ```

#### Ruby Installation Problems

**Symptoms:**
- RVM installation fails with GPG key issues
- Ruby gem installation errors

**Solutions:**
1. Use system Ruby instead of RVM:
   ```bash
   # On macOS
   brew install ruby
   echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install ruby-full
   ```
2. Restart the installation with recovery mode:
   ```bash
   ./install.sh --recover
   ```

#### Node.js/NVM Issues

**Symptoms:**
- NVM installs but Node.js commands aren't recognized
- npm package installations fail

**Solutions:**
1. Manually load NVM in current shell:
   ```bash
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
   ```
2. Install Node.js directly:
   ```bash
   nvm install --lts
   nvm use --lts
   ```

#### Configuration File Conflicts

**Symptoms:**
- Warning messages about existing configuration files
- Configuration not taking effect after installation

**Solutions:**
1. Back up your existing configurations:
   ```bash
   mkdir -p ~/.config-backup
   cp ~/.zshrc ~/.tmux.conf ~/.config/nvim/init.lua ~/.config-backup/
   ```
2. Manually merge your custom settings with the new configurations after installation

#### Tmux Plugin Manager Issues

**Symptoms:**
- Tmux plugins not loading
- Errors when starting Tmux

**Solutions:**
1. Install TPM manually:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
2. Inside Tmux, press `Ctrl-a` followed by `I` to install plugins

### System-Specific Issues

#### macOS

- **Homebrew Permission Issues**: Run the Homebrew installer with proper permissions:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- **macOS Python Issues**: Use the latest Python from Homebrew:
  ```bash
  brew install python
  ```

#### Linux (Debian/Ubuntu)

- **Missing Dependencies**: Ensure build tools are installed:
  ```bash
  sudo apt update
  sudo apt install build-essential
  ```

- **Permission Issues**: Make sure your user has access to necessary directories:
  ```bash
  sudo chown -R $(whoami) ~/.config ~/.local
  ```

### Verification and Recovery

If you encounter issues after installation:

1. Run the verification script to identify problems:
   ```bash
   ./verify.sh
   ```

2. Run the installation in recovery mode to fix issues:
   ```bash
   ./install.sh --recover
   ```

3. For serious issues, you can reset the environment (warning: this will remove your configurations):
   ```bash
   rm -rf ~/.config/nvim ~/.tmux.conf ~/.zshrc.d
   ```
   Then run the installation again.

### Getting Help

If you continue experiencing issues:

1. Check the installation log: `install_log.txt`
2. Run the pre-check script before installation: `./pre-check.sh`
3. Open an issue on the GitHub repository with your specific error messages

## Contributing

Contributions are welcome! If you'd like to improve the guides, fix issues, or suggest enhancements:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell