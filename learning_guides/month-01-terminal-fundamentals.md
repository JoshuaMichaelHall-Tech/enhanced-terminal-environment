# Month 1: Terminal & Shell Fundamentals

## Learning Objectives
- Build a solid foundation in navigating and using the terminal
- Master basic shell commands and understand their purpose
- Establish daily habits for terminal usage
- Configure your initial environment and understand dotfiles
- Begin using Zsh and Oh My Zsh effectively

## Resources
- **Primary Text**: [The Linux Command Line](http://linuxcommand.org/tlcl.php) (Chapters 1-10)
- **Reference**: [Terminal Cheatsheet](docs/terminal-cheatsheet.md)
- **Supplementary**: [Bash Guide](https://mywiki.wooledge.org/BashGuide) for deeper understanding

## Week 1: Terminal Navigation & Basic Commands

### Daily Practice (20-30 minutes)
- Review and practice 5 new commands each day
- Complete at least one navigation challenge daily
- Maintain a command journal - write down new commands with examples

### Assignments
1. **Environment Setup**: Run the installation script and verify core tools are installed
   - Reference: [README Installation Section](README.md#installation)
   - Ensure Zsh, Oh My Zsh, and core aliases are working
   - Verify your terminal configuration with `./verify.sh`

2. **Navigation Mastery**:
   - Read TLCL Chapters 1-3
   - Practice navigating the filesystem without using the GUI
   - Create a filesystem map of your home directory structure
   
3. **Command Basics**:
   - Master these command categories: navigation (`cd`, `ls`, `pwd`), file operations (`cp`, `mv`, `rm`, `touch`), and viewing (`cat`, `less`, `head`, `tail`)
   - Complete [cmdchallenge.com](https://cmdchallenge.com/) beginner section
   
4. **Redirections & Pipes**:
   - Read TLCL Chapters 4-6
   - Practice input/output redirection with `>`, `>>`, `<`
   - Build 5 command pipelines using the pipe operator (`|`)

### Week 1 Project
**File System Explorer**: Create a script that helps you navigate and explore your filesystem, showing directory contents, file sizes, and recent modifications.

## Week 2: Environment Configuration & Customization

### Daily Practice (20-30 minutes)
- Add one new alias each day for operations you frequently perform
- Practice using file manipulation commands in different contexts
- Review key bindings and shortcuts in your terminal

### Assignments
1. **Zsh & Oh My Zsh Exploration**:
   - Explore Oh My Zsh plugins enabled in your configuration
   - Test and understand default aliases from `~/.zsh/aliases.zsh`
   - Read documentation for 2-3 plugins (git, fzf, tmux)

2. **Customizing Your Environment**:
   - Read TLCL Chapters 7-8
   - Review your `.zshrc` and understand each component
   - Create 5 custom aliases for commands you use frequently
   
3. **File Permissions & Users**:
   - Learn about file permissions (`chmod`, `chown`)
   - Understand symbolic vs. numeric permission notation
   - Practice changing permissions on test files
   
4. **Text Processing Basics**:
   - Learn the basics of `grep`, `sed`, and `awk`
   - Find patterns in files using `grep`
   - Complete grep exercises from [cmdchallenge.com](https://cmdchallenge.com/)

### Week 2 Project
**Custom Environment Configuration**: Create a personal set of aliases, functions, and configurations. Document each choice with explanations.

## Week 3: Shell Scripting Foundations

### Daily Practice (20-30 minutes)
- Write a one-line shell command that performs a useful task
- Read one script from the `scripts/` directory and understand how it works
- Practice modifying existing scripts to change their behavior

### Assignments
1. **Shell Script Basics**:
   - Read TLCL Chapters 9-10
   - Learn script structure and shebang (`#!/bin/bash`)
   - Create basic scripts with variables and control structures
   
2. **Conditional Logic**:
   - Practice if/else statements in scripts
   - Learn test operators for files and strings
   - Create a script that makes decisions based on input
   
3. **Loops and Iteration**:
   - Master for and while loops
   - Iterate through files and directories
   - Process text files line by line
   
4. **Debug & Troubleshooting**:
   - Learn debugging techniques (`set -x`)
   - Practice identifying and fixing bugs in scripts
   - Study error handling patterns

### Week 3 Project
**File Organizer Script**: Create a script that organizes files in a directory based on type, modification date, or other criteria.

## Week 4: Advanced Navigation & Tools

### Daily Practice (20-30 minutes)
- Use fuzzy finder (fzf) to locate files and directories
- Practice searching and finding text inside files
- Explore one new tool from the Enhanced Terminal Environment each day

### Assignments
1. **Finding Things**:
   - Master `find` command with different criteria
   - Learn `locate` and set up database
   - Practice using `grep` with regular expressions
   
2. **Fuzzy Finding**:
   - Learn fzf basics and integration
   - Practice the `vf` and `proj` custom functions
   - Create custom fzf-based workflows
   
3. **Fast Navigation Techniques**:
   - Create and use directory bookmarks
   - Practice jumping between directories
   - Master history navigation and search
   
4. **Shell Expansions**:
   - Learn advanced pattern matching
   - Understand brace, parameter and command expansions
   - Practice using expansions to increase efficiency

### Week 4 Project
**Personal Command Dashboard**: Create a menu-based script that shows customized system information and provides quick access to your most-used tools and functions.

## Month 1 Project: Custom Shell Environment

**Objective**: Create a personalized shell environment with custom functions, aliases, and tools integrated.

**Requirements**:
1. At least 10 custom aliases for frequent tasks
2. At least 3 custom shell functions that solve real problems
3. A customized prompt with useful information
4. Documentation explaining each customization
5. A setup script that installs your configuration on a new system

**Deliverables**:
- Shell script files with your custom functions
- Modified .zshrc or additional configuration files
- Documentation of your customizations with examples
- Setup/install script for your environment

## Assessment Criteria
- Command accuracy and understanding
- Quality and usefulness of customizations
- Script functionality and error handling
- Documentation clarity
- Setup script reliability

## Suggested Daily Routine
1. 10 minutes reviewing commands from previous day
2. 15 minutes learning new commands/concepts
3. 15-30 minutes hands-on practice with real tasks
4. 5 minutes documenting what you learned in your command journal
