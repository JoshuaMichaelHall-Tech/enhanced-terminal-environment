# Month 3: Tmux & Session Management

## Learning Objectives
- Master Tmux for terminal multiplexing and session management
- Create efficient terminal workflows with multiple panes and windows
- Develop persistent sessions for different projects and contexts
- Integrate Tmux with Neovim for a seamless development environment
- Build automation for common project setups

## Resources
- **Primary Text**: [Tmux 2: Productive Mouse-Free Development](https://pragprog.com/titles/bhtmux2/tmux-2/) by Brian P. Hogan (Chapters 1-4)
- **Reference**: [Tmux Cheatsheet](https://tmuxcheatsheet.com/) 
- **Configuration**: Your `.tmux.conf` at `~/.tmux.conf`
- **Supplementary**: [The Tao of Tmux](https://leanpub.com/the-tao-of-tmux/read) (free online)

## Week 1: Tmux Fundamentals

### Daily Practice (20-30 minutes)
- Start all terminal work in a Tmux session
- Practice creating and navigating between sessions, windows, and panes
- Learn 3-5 new Tmux commands each day
- Keep a Tmux command journal - document new commands with examples

### Assignments
1. **Tmux Basics**:
   - Read Tmux 2 Chapter 1
   - Learn session management: create, list, attach, detach
   - Practice prefix key and basic commands
   
2. **Window Management**:
   - Create, rename, and navigate between windows
   - Practice window organization strategies
   - Learn window search and navigation shortcuts
   
3. **Pane Operations**:
   - Split panes horizontally and vertically
   - Navigate between panes using keyboard shortcuts
   - Resize and rearrange panes
   
4. **Tmux Configuration Review**:
   - Study your `.tmux.conf` configuration
   - Understand key bindings and settings
   - Experiment with session options

### Week 1 Project
**Tmux Layout Explorer**: Create multiple Tmux layouts for different workflows and document the commands to create each layout.

## Week 2: Advanced Tmux Features

### Daily Practice (20-30 minutes)
- Use Tmux copy mode for text navigation and selection
- Practice customizing your Tmux status line
- Experiment with different pane layouts for various tasks

### Assignments
1. **Copy Mode Mastery**:
   - Read Tmux 2 Chapter 2
   - Learn to navigate in copy mode using vi keys
   - Practice selecting and copying text across panes
   
2. **Status Line Customization**:
   - Understand status line formatting
   - Add useful information to your status line
   - Create custom status indicators
   
3. **Layout Management**:
   - Master built-in layouts (even-horizontal, even-vertical, etc.)
   - Save and restore custom layouts
   - Practice layout adjustment commands
   
4. **Scripting Tmux**:
   - Learn to send commands to Tmux from shell scripts
   - Automate window and pane creation
   - Practice running commands in specific panes

### Week 2 Project
**Custom Status Line**: Design and implement a custom Tmux status line that displays relevant system and session information.

## Week 3: Tmux Plugins & Integration

### Daily Practice (20-30 minutes)
- Use Tmux plugins to enhance your workflow
- Practice integrating Tmux with Neovim
- Experiment with session persistence strategies

### Assignments
1. **Plugin Manager**:
   - Read Tmux 2 Chapter 3
   - Explore Tmux Plugin Manager (TPM)
   - Install and configure basic plugins
   
2. **Session Management Plugins**:
   - Configure tmux-resurrect for session persistence
   - Practice saving and restoring sessions
   - Explore continuous saving with tmux-continuum
   
3. **Tmux + Neovim Integration**:
   - Configure Tmux and Neovim to work seamlessly
   - Practice navigation between Neovim splits and Tmux panes
   - Learn shared clipboard configurations
   
4. **Custom Key Bindings**:
   - Create custom key bindings for frequent operations
   - Set up project-specific key bindings
   - Practice using binding tables

### Week 3 Project
**Tmux Plugin Configuration**: Set up and configure a set of Tmux plugins that enhance your specific workflow needs.

## Week 4: Project Workflows & Automation

### Daily Practice (20-30 minutes)
- Start every project using appropriate Tmux sessions
- Use the custom session creators: `mkpy`, `mkjs`, `mkrb`
- Create task-specific layouts for different project phases

### Assignments
1. **Project Session Templates**:
   - Read Tmux 2 Chapter 4
   - Study the session templates in `configs/tmux/tmux-sessions/`
   - Understand the session creation functions in `.zshrc`
   
2. **Language-Specific Workflows**:
   - Practice using `mkpy`, `mkjs`, and `mkrb` session creators
   - Customize the templates for your specific needs
   - Create workflow patterns for development, testing, and deployment
   
3. **Session Automation**:
   - Create scripts to set up project-specific environments
   - Learn to automate repetitive session setup tasks
   - Develop strategies for different project types
   
4. **Pair Programming Setup**:
   - Configure Tmux for pair programming scenarios
   - Learn to share sessions securely
   - Practice collaborative workflows

### Week 4 Project
**Project Environment Automator**: Create a script that sets up complete development environments for different project types, with appropriate windows, panes, and initial commands.

## Month 3 Project: Integrated Terminal Workflow

**Objective**: Create a seamless, integrated workflow combining Tmux, Neovim, and shell tools for maximum productivity.

**Requirements**:
1. Custom Tmux configuration optimized for your development workflow
2. Project-specific session templates for at least 3 different project types
3. Integration between Tmux and Neovim for smooth navigation
4. Automation scripts for environment setup and maintenance
5. Documentation of your complete workflow with examples

**Deliverables**:
- Your customized `.tmux.conf` with clear comments
- Shell scripts for session and project management
- Recorded demonstration of your integrated workflow
- Written guide explaining your environment setup and usage
- Benchmark comparing your productivity before and after implementation

## Assessment Criteria
- Workflow efficiency and automation
- Integration between tools (Tmux, Neovim, shell)
- Configuration quality and organization
- Session management approach
- Documentation clarity and completeness

## Suggested Daily Routine
1. 10 minutes practicing Tmux commands and navigation
2. 10 minutes setting up or refining session templates
3. 20-30 minutes using the integrated environment for real work
4. 5 minutes documenting improvements or issues in your workflow
