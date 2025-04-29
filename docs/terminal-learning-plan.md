# Essential Terminal Environment - 12 Month Learning Plan

This focused guide provides only the most essential resources and learning paths for mastering a terminal-centric software engineering workflow.

## Core Resources (Primary Focus)

### 1. Shell & Terminal Fundamentals

**Primary Book:**

- **"The Linux Command Line"** by William Shotts
    - Free online version available at [linuxcommand.org](http://linuxcommand.org/tlcl.php)
    - Complete this book within the first 3 months

**Essential Online References:**

- [**GNU Bash Manual**](https://www.gnu.org/software/bash/manual/) - Use as reference only
- [**explainshell.com**](https://explainshell.com/) - For understanding complex commands

**Practical Application:**

- Create and maintain a dotfiles repository on GitHub
- Set up basic aliases and functions for common operations
- Master piping, redirection, and command substitution

### 2. Neovim for Software Development

**Primary Resources:**

- [**Learn Vim (the Smart Way)**](https://github.com/iggredible/Learn-Vim) - Free, comprehensive guide
- **"Practical Vim"** by Drew Neil - Reference only as needed
- Daily `vimtutor` practice for the first month

**Minimal Configuration:**

- Start with [**LazyVim**](https://www.lazyvim.org/) - Pre-configured setup for faster productivity
- Gradually customize as you learn what you need
- Focus on learning the editor before excessive customization

**Essential Plugins Only:**

- LSP configuration for Python
- Telescope for fuzzy finding
- A simple status line
- Git integration

### 3. Tmux for Session Management

**Primary Resource:**

- [**Tmux Cheat Sheet**](https://tmuxcheatsheet.com/) - Print and keep at desk
- **"Tmux 2: Productive Mouse-Free Development"** by Brian P. Hogan - First 4 chapters only

**Essential Configuration:**

- Use [**Oh My Tmux**](https://github.com/gpakosz/.tmux) as a starting point
- Modify only key bindings that conflict with your workflow
- Focus on session persistence and window management

### 4. Docker & Containerization

**Primary Resources:**

- [**Docker Documentation - Get Started**](https://docs.docker.com/get-started/)
- [**Docker for Developers**](https://www.packtpub.com/product/docker-for-developers/9781789536058) - First 5 chapters only

**Essential Skills:**

- Creating and managing containers
- Writing efficient Dockerfiles
- Managing multi-container applications with Docker Compose
- Integrating Docker with your development workflow

### 5. Cloud CLI Tools & Infrastructure as Code

**Primary Resources:**

- [**AWS CLI Documentation**](https://docs.aws.amazon.com/cli/)
- [**Terraform: Up & Running**](https://www.terraformupandrunning.com/) - First 4 chapters
- [**Ansible Documentation**](https://docs.ansible.com/)

**Focus Areas:**

- Managing cloud resources via terminal
- Infrastructure as code fundamentals
- Automating deployment processes

### 6. SQL Fundamentals

**Primary Resources:**

- [**SQLZoo**](https://sqlzoo.net/) - Interactive exercises (complete all sections)
- [**PostgreSQL Documentation**](https://www.postgresql.org/docs/) - Reference as needed
- [**Mode Analytics SQL Tutorial**](https://mode.com/sql-tutorial/) - For practical applications

**Practice Environment:**

- Install PostgreSQL locally
- Use real datasets for practice (e.g., [Kaggle datasets](https://www.kaggle.com/datasets))
- Connect your Python applications to your database

### 7. HTTP Terminal Tools

**Primary Resources:**

- [**curl documentation**](https://curl.se/docs/)
- [**HTTPie documentation**](https://httpie.io/docs)
- [**jq Manual**](https://stedolan.github.io/jq/manual/)

**Practice:**

- API testing workflows
- Combining HTTP tools with jq for JSON processing
- Scripting HTTP operations

## Month-by-Month Focus

### Months 1-3: Foundations

- Complete first half of "The Linux Command Line"
- Daily `vimtutor` practice + Learn Vim (the Smart Way) chapters 1-8
- Basic tmux usage and configuration
- Introduction to Docker basics
- SQLZoo fundamentals sections
- Basic curl/HTTPie usage

### Months 4-6: Integration

- Complete "The Linux Command Line"
- Configure Neovim for Python development
- Create tmux workflow scripts
- Docker Compose for local development environments
- Package managers (npm, pip, poetry)
- SQLZoo advanced sections and Mode Analytics Tutorial
- GitHub CLI for workflow integration

### Months 7-9: Workflow Optimization

- Shell scripting for automation
- Complete Learn Vim (the Smart Way)
- Integrate Neovim and tmux workflow
- Database design practice with PostgreSQL
- Infrastructure as code with Terraform basics
- Terminal-based monitoring tools (htop, glances)
- Make and Makefile automation

### Months 10-12: Advanced Applications

- AWS/GCP CLI tools and cloud management
- Ansible for configuration management
- Advanced Docker patterns and optimization
- Node.js/Python REPLs for rapid testing
- Advanced linting and formatting workflows
- Build practical projects integrating all tools
- Terminal-based productivity system

## Essential Tools Timeline

| Month | New Tools to Master |
|-------|---------------------|
| 1-2   | Zsh fundamentals, basic Neovim, basic Tmux |
| 3-4   | Git advanced workflows, curl/HTTPie basics |
| 5-6   | Docker fundamentals, package managers (npm/pip/poetry) |
| 7-8   | GitHub CLI, Make, MongoDB CLI |
| 9-10  | AWS/GCP CLI basics, htop/glances, jq |
| 11-12 | Terraform/Ansible basics, Node.js/Python REPLs, linting tools |

## Essential Integration Projects

1. **Full-Stack Development Environment**
    
    - Neovim configured for Python/JavaScript development
    - Tmux session management for projects
    - Docker containers for services
    - Git workflow integration with GitHub CLI

2. **Data Pipeline & API Project**
    
    - SQL/MongoDB data extraction and processing
    - API testing with curl/HTTPie
    - Infrastructure defined with Terraform
    - Python data manipulation
    - Shell scripts for automation

3. **Cloud-Native Terminal Workflow**
    
    - AWS/GCP resource management via CLI
    - Container orchestration
    - Infrastructure as code
    - Monitoring and debugging
    - CI/CD integration

4. **Terminal Productivity System**
    
    - Task/note management
    - Project organization
    - Workflow automation
    - Cross-platform synchronization

## Daily Practice Routine (45 minutes)

- 15 minutes: Shell command practice
- 15 minutes: Vim editing exercises
- 15 minutes: Project-based application with new tools

## Weekly Learning (4 hours)

- 1 hour: Read next section of primary resource
- 1 hour: Practice new techniques
- 1 hour: Apply learning to real project
- 1 hour: Experiment with new terminal tools

## Essential Regular Practice Sources

- [**Exercism**](https://exercism.org/) - For Python programming practice
- [**cmdchallenge.com**](https://cmdchallenge.com/) - For shell command mastery
- [**Vim Adventures**](https://vim-adventures.com/) - For Vim movement practice
- [**pgexercises.com**](https://pgexercises.com/) - For SQL practice
- [**Docker Labs**](https://github.com/docker/labs) - For Docker practice
- [**GitHub Learning Lab**](https://lab.github.com/) - For advanced Git workflows
- [**Katacoda**](https://www.katacoda.com/) - For interactive cloud-native tutorials