# Enhanced Terminal Environment

A comprehensive, structured learning path for mastering terminal-based software development, designed for full-stack engineers working with Python, JavaScript, and Ruby.

![Terminal Environment](https://img.shields.io/badge/Terminal-Environment-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-orange)

# Quick Start
For impatient users who want to get up and running immediately:

```bash
# Clone the repository
git clone https://github.com/YourUsername/enhanced-terminal-environment.git
cd enhanced-terminal-environment

# Run the setup script (works on macOS and most Linux distributions)
./setup.sh

# Start a new terminal session to load the environment
source ~/.zshrc
```

This will install:

- Zsh with Oh My Zsh configuration
- Tmux with optimized configuration
- Neovim with programming language support
- Essential CLI tools for development

See INSTALLATION.md for detailed installation instructions and customization options.

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

## Learning Path

This repository now includes a complete, structured 12-month learning path to help you master terminal-based development. Each monthly guide includes:

- Clear learning objectives
- Weekly assignments and projects
- Daily practice routines
- Resource recommendations
- A monthly capstone project

### Learning Path Structure

The guides are organized into four phases:

#### Foundations (Months 1-3)
- **Month 1:** [Terminal & Shell Fundamentals](learning_guides/month-01-terminal-fundamentals.md)
- **Month 2:** [Vim, Neovim & Text Editing](learning_guides/month-02-vim-neovim.md)
- **Month 3:** [Tmux & Session Management](learning_guides/month-03-tmux-session.md)

#### Integration (Months 4-6)
- **Month 4:** [Shell Scripting & Automation](learning_guides/month-04-shell-scripting.md)
- **Month 5:** [Git & Version Control Mastery](learning_guides/month-05-git-version-control.md)
- **Month 6:** [Package Management & Development Environment](learning_guides/month-06-package-management.md)

#### Workflow Optimization (Months 7-9)
- **Month 7:** [Database Management from Terminal](learning_guides/month-07-database-management.md)
- **Month 8:** [HTTP APIs & Network Tools](learning_guides/month-08-http-apis.md)
- **Month 9:** [Monitoring & Performance Optimization](learning_guides/month-09-monitoring-performance.md)

#### Advanced Applications (Months 10-12)
- **Month 10:** [Cloud CLI Tools](learning_guides/month-10-cloud-cli.md)
- **Month 11:** [Configuration Management & Automation](learning_guides/month-11-configuration-management.md)
- **Month 12:** [Terminal Productivity System & Capstone](learning_guides/month-12-productivity-capstone.md)

Each guide is designed to be completed in one month, with approximately 10 hours of study per week.

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

### Starting the Learning Path

1. Begin with the [Month 1 Guide](learning_guides/month-01-terminal-fundamentals.md)
2. Follow the weekly assignments and daily practice routines
3. Complete projects to apply your skills
4. Progress through each month as you build your terminal mastery

## What's Included

- **Cross-platform installation script** for setting up all essential tools
- **Language-specific development environments** for Python, JavaScript, and Ruby
- **Containerization tools** for Docker and microservices
- **Cloud tooling** for AWS, Terraform, and Ansible
- **Terminal-based HTTP clients** for API testing
- **Minimal configurations** for Neovim, Tmux, and Zsh
- **Comprehensive learning guides** with clear objectives and exercises
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

The installation process has been significantly improved to handle common issues automatically. Most users should experience a smooth installation, but if you encounter problems:

### Installation Recovery

If your installation is interrupted or encounters an error:

```bash
# Run the installation in recovery mode
./install.sh --recover
```

This will detect which components were successfully installed and continue from where it left off.

### Directory and Permission Issues

Directory creation and permission handling has been improved, but if you encounter permission errors:

```bash
# Fix permissions for configuration directories
sudo chown -R $(whoami) ~/.config ~/.local
chmod -R 755 ~/.config ~/.local
```

### Python Environment

Python setup now properly handles PEP 668 restrictions ("externally-managed-environment") by using pipx and Poetry, eliminating the need for manual intervention.

### Node.js Environment

Node.js detection and installation has been improved to work with both system-installed Node.js and NVM-installed versions.

### Ruby Environment

Ruby installation now uses a more reliable approach, preferring system Ruby (via Homebrew on macOS or apt on Linux) which avoids RVM installation issues.

### Neovim Setup

The Enhanced Terminal Environment now includes comprehensive Neovim setup that:

- Configures all language providers (Python, Node.js, Ruby, Perl)
- Automatically detects available languages on your system
- Properly configures init.lua with sensible defaults
- Ensures a smooth, warning-free Neovim experience

When running `:checkhealth` in Neovim, you should see all providers properly configured based on your installed languages.

### Configuration Files

Configuration backup is now offered automatically if existing configurations are detected.

### Still Having Problems?

If you're still experiencing issues:

1. Check the installation log: `install_log.txt`
2. Run the pre-check script before installation: `./pre-check.sh`
3. Use the verification script to identify problems: `./verify.sh`
4. Open an issue on the GitHub repository with your specific error messages

### Getting Help

For detailed help with specific components:

- **Tmux**: Press `Ctrl+a ?` for a list of key bindings
- **Neovim**: Type `:help` within Neovim
- **Shell**: Review the aliases with `alias` command
- **Project templates**: Run `pyproject`, `nodeproject`, or `rubyproject` without arguments to see usage

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
- Development of comprehensive learning guides

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
