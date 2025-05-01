#!/usr/bin/env bash
# Enhanced Terminal Environment Functions
# Comprehensive helper functions for terminal-based development workflow
# Version: 3.0

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

#-------------------------------------------------------------
# Utility Functions
#-------------------------------------------------------------

# Simple log functions
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

# Create a directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
    fi
    return 0
}

#-------------------------------------------------------------
# Project Management Functions
#-------------------------------------------------------------

# Create a new project directory with git initialization
# Usage: newproject <name> [<type>]
# Types: generic, python, node, ruby (default: generic)
newproject() {
    local name="$1"
    local type="${2:-generic}"
    
    if [[ -z "$name" ]]; then
        log_error "Usage: newproject <name> [<type>]"
        log_info "Types: generic, python, node, ruby (default: generic)"
        return 1
    fi
    
    local projects_dir="$HOME/projects"
    # Ensure projects directory exists
    ensure_dir "$projects_dir" || return 1
    
    local project_dir="$projects_dir/$name"
    
    # Check if directory already exists
    if [[ -d "$project_dir" ]]; then
        log_error "Project directory already exists: $project_dir"
        return 1
    fi
    
    # Create directory
    log_info "Creating project directory: $project_dir"
    mkdir -p "$project_dir" || {
        log_error "Failed to create project directory"
        return 1
    }
    
    # Change to project directory
    cd "$project_dir" || {
        log_error "Failed to change to project directory"
        return 1
    }
    
    # Initialize git
    log_info "Initializing Git repository..."
    git init >/dev/null || log_warning "Failed to initialize Git repository"
    
    # Create README.md
    log_info "Creating README.md..."
    cat > README.md << EOF
# $name

## Description

A brief description of the project.

## Installation

\`\`\`bash
# Installation instructions
\`\`\`

## Usage

\`\`\`bash
# Usage examples
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
    
    # Create LICENSE file
    log_info "Creating LICENSE file..."
    cat > LICENSE << EOF
MIT License

Copyright (c) $(date +%Y) Joshua Michael Hall

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    
    # Initialize project based on type
    case "$type" in
        python)
            # Check if pyproject function is available
            if command_exists pyproject; then
                log_info "Creating Python project using pyproject template..."
                # Exit current directory first to avoid nested directories
                cd "$projects_dir" || return 1
                pyproject "$name"
                return $?
            else
                # Create Python project manually
                log_info "Creating Python project structure..."
                mkdir -p src tests
                touch src/__init__.py
                touch src/main.py
                touch tests/__init__.py
                touch tests/test_main.py
                
                # Create virtual environment setup
                log_info "Creating Python virtual environment..."
                if command_exists python3; then
                    python3 -m venv venv || log_warning "Failed to create virtual environment"
                else
                    log_warning "Python3 not found. Skipping virtual environment creation."
                fi
                
                # Create .gitignore
                log_info "Creating .gitignore..."
                curl -s https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore > .gitignore 2>/dev/null || 
                    log_warning "Failed to download Python .gitignore template"
                
                # Create minimal requirements.txt
                log_info "Creating requirements.txt..."
                cat > requirements.txt << EOF
# Requirements
pytest>=7.0.0
black>=23.0.0
pylint>=2.17.0
EOF
                
                log_success "Python project created at $project_dir"
                log_info "To activate the virtual environment, run: source venv/bin/activate"
            fi
            ;;
            
        node)
            # Check if nodeproject function is available
            if command_exists nodeproject; then
                log_info "Creating Node.js project using nodeproject template..."
                # Exit current directory first to avoid nested directories
                cd "$projects_dir" || return 1
                nodeproject "$name"
                return $?
            else
                # Create Node.js project manually
                log_info "Creating Node.js project structure..."
                mkdir -p src test
                touch src/index.js
                touch test/index.test.js
                
                # Initialize npm
                log_info "Initializing npm project..."
                if command_exists npm; then
                    npm init -y >/dev/null || log_warning "Failed to initialize npm project"
                else
                    log_warning "npm not found. Skipping npm initialization."
                fi
                
                # Create .gitignore
                log_info "Creating .gitignore..."
                curl -s https://raw.githubusercontent.com/github/gitignore/master/Node.gitignore > .gitignore 2>/dev/null || 
                    log_warning "Failed to download Node.js .gitignore template"
                
                log_success "Node.js project created at $project_dir"
                log_info "To install dependencies, run: npm install"
            fi
            ;;
            
        ruby)
            # Check if rubyproject function is available
            if command_exists rubyproject; then
                log_info "Creating Ruby project using rubyproject template..."
                # Exit current directory first to avoid nested directories
                cd "$projects_dir" || return 1
                rubyproject "$name"
                return $?
            else
                # Create Ruby project manually
                log_info "Creating Ruby project structure..."
                mkdir -p lib spec
                touch lib/main.rb
                touch spec/main_spec.rb
                
                # Create Gemfile
                log_info "Creating Gemfile..."
                cat > Gemfile << EOF
source 'https://rubygems.org'

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'pry', '~> 0.14'
end
EOF
                
                # Create .gitignore
                log_info "Creating .gitignore..."
                curl -s https://raw.githubusercontent.com/github/gitignore/master/Ruby.gitignore > .gitignore 2>/dev/null || 
                    log_warning "Failed to download Ruby .gitignore template"
                
                log_success "Ruby project created at $project_dir"
                log_info "To install dependencies, run: bundle install"
            fi
            ;;
            
        *)
            # Generic project with minimal structure
            log_info "Creating generic project structure..."
            mkdir -p src docs
            touch src/.gitkeep docs/.gitkeep
            
            # Create .gitignore
            log_info "Creating .gitignore..."
            cat > .gitignore << EOF
# Logs
logs
*.log

# OS specific files
.DS_Store
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
EOF
            
            log_success "Generic project created at $project_dir"
            ;;
    esac
    
    # Initial commit
    log_info "Creating initial Git commit..."
    git add . >/dev/null
    git commit -m "Initial commit" --no-verify >/dev/null || log_warning "Failed to create initial commit"
    
    # Return to project directory
    cd "$project_dir" || return 1
    
    log_success "Project setup complete!"
    return 0
}

#-------------------------------------------------------------
# Git Functions
#-------------------------------------------------------------

# Clone GitHub repository and cd into it
# Usage: gclone <username/repo>
gclone() {
    local repo="$1"
    
    if [[ -z "$repo" ]]; then
        log_error "Usage: gclone <username/repo>"
        return 1
    fi
    
    # Check if git is available
    if ! command_exists git; then
        log_error "Git is not installed"
        return 1
    fi
    
    log_info "Cloning repository: $repo"
    # Clone the repository
    if ! git clone "https://github.com/$repo.git"; then
        log_error "Failed to clone repository"
        return 1
    fi
    
    # Extract repo name and cd into it
    local repo_name
    repo_name=$(echo "$repo" | sed 's/.*\///')
    
    if [[ -d "$repo_name" ]]; then
        cd "$repo_name" || {
            log_error "Failed to change to repository directory"
            return 1
        }
        log_success "Repository cloned successfully"
    else
        log_error "Repository directory not found after cloning"
        return 1
    fi
    
    return 0
}

# Create a branch with the given name, or a feature branch with today's date if no name provided
# Usage: gcreate [<branch-name>]
gcreate() {
    local branch_name="$1"
    
    # Check if git is available
    if ! command_exists git; then
        log_error "Git is not installed"
        return 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_error "Not inside a Git repository"
        return 1
    fi
    
    # Create branch name if not provided
    if [[ -z "$branch_name" ]]; then
        branch_name="feature/$(date +%Y-%m-%d)"
    fi
    
    # Create and switch to the branch
    log_info "Creating and switching to branch: $branch_name"
    if ! git checkout -b "$branch_name"; then
        log_error "Failed to create branch: $branch_name"
        return 1
    fi
    
    log_success "Created and switched to branch: $branch_name"
    return 0
}

# Show stats for current git repository
# Usage: gstats
gstats() {
    # Check if git is available
    if ! command_exists git; then
        log_error "Git is not installed"
        return 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_error "Not inside a Git repository"
        return 1
    fi
    
    # Get repository info
    local branch commits contributors last_commit modified_files
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
    commits=$(git rev-list --count HEAD 2>/dev/null || echo "N/A")
    contributors=$(git shortlog -s -n --all 2>/dev/null | wc -l | tr -d ' ' || echo "N/A")
    last_commit=$(git log -1 --pretty=%B 2>/dev/null | head -n 1 || echo "N/A")
    modified_files=$(git status -s 2>/dev/null | wc -l | tr -d ' ' || echo "N/A")
    
    # Print stats
    echo -e "${BOLD}=== Git Repository Statistics ===${NC}"
    echo -e "${BOLD}Branch:${NC} $branch"
    echo -e "${BOLD}Commits:${NC} $commits"
    echo -e "${BOLD}Contributors:${NC} $contributors"
    echo -e "${BOLD}Last commit:${NC} $last_commit"
    echo -e "${BOLD}Modified files:${NC} $modified_files"
    
    return 0
}

#-------------------------------------------------------------
# Docker Functions
#-------------------------------------------------------------

# Stop all running containers
# Usage: dstop
dstop() {
    # Check if docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    }
    
    # Get running containers
    local containers
    containers=$(docker ps -q)
    
    if [[ -n "$containers" ]]; then
        log_info "Stopping all running containers..."
        # shellcheck disable=SC2086
        if ! docker stop $containers; then
            log_error "Failed to stop containers"
            return 1
        }
        log_success "All containers stopped"
    else
        log_info "No running containers found"
    fi
    
    return 0
}

# Clean up Docker resources (containers, images, networks)
# Usage: dclean
dclean() {
    # Check if docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    fi
    
    log_info "Cleaning up Docker resources..."
    
    # Remove all stopped containers
    local stopped_containers
    stopped_containers=$(docker ps -a -q)
    
    if [[ -n "$stopped_containers" ]]; then
        log_info "Removing stopped containers..."
        # shellcheck disable=SC2086
        docker rm $stopped_containers >/dev/null 2>&1 || log_warning "Failed to remove some containers"
    else
        log_info "No containers to remove"
    fi
    
    # Remove unused images
    local dangling_images
    dangling_images=$(docker images -f "dangling=true" -q)
    
    if [[ -n "$dangling_images" ]]; then
        log_info "Removing dangling images..."
        # shellcheck disable=SC2086
        docker rmi $dangling_images >/dev/null 2>&1 || log_warning "Failed to remove some images"
    else
        log_info "No dangling images to remove"
    fi
    
    # Remove unused networks
    log_info "Removing unused networks..."
    docker network prune -f >/dev/null || log_warning "Failed to prune networks"
    
    # Remove unused volumes
    log_info "Removing unused volumes..."
    docker volume prune -f >/dev/null || log_warning "Failed to prune volumes"
    
    log_success "Docker cleanup complete"
    return 0
}

# Restart a container
# Usage: drestart <container-name-or-id>
drestart() {
    local container="$1"
    
    if [[ -z "$container" ]]; then
        log_error "Usage: drestart <container-name-or-id>"
        return 1
    fi
    
    # Check if docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    fi
    
    log_info "Restarting container: $container"
    if ! docker restart "$container"; then
        log_error "Failed to restart container"
        return 1
    fi
    
    log_success "Container $container restarted"
    return 0
}

# Run a command in a container
# Usage: dexec <container-name-or-id> <command>
dexec() {
    local container="$1"
    local cmd="${2:-sh}"
    
    if [[ -z "$container" ]]; then
        log_error "Usage: dexec <container-name-or-id> [<command>]"
        log_info "Default command: sh"
        return 1
    fi
    
    # Check if docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    fi
    
    log_info "Executing in container $container: $cmd"
    # shellcheck disable=SC2086
    if ! docker exec -it "$container" $cmd; then
        log_error "Failed to execute command in container"
        return 1
    fi
    
    return 0
}

# Shell into a running container with fzf selection
# Usage: dsh
dsh() {
    # Check if docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    }
    
    # Check if fzf is available
    if ! command_exists fzf; then
        log_error "fzf is not installed"
        return 1
    fi
    
    # Get list of containers
    local containers
    containers=$(docker ps --format "{{.Names}}")
    
    if [[ -z "$containers" ]]; then
        log_error "No running containers found"
        return 1
    fi
    
    # Select container with fzf
    local container
    container=$(echo "$containers" | fzf --height 40% --layout reverse --prompt="Select container: ")
    
    if [[ -z "$container" ]]; then
        log_warning "No container selected"
        return 1
    fi
    
    # Execute shell in container
    log_info "Opening shell in container: $container"
    docker exec -it "$container" sh || docker exec -it "$container" bash
    
    return $?
}

#-------------------------------------------------------------
# Development Workflow Functions
#-------------------------------------------------------------

# Start a development server based on project type
# Usage: serve [<port>]
serve() {
    local port="${1:-8000}"
    
    # Validate port is a number
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_error "Port must be a number"
        return 1
    fi
    
    # Detect project type
    if [[ -f "package.json" ]]; then
        # Node.js project
        if grep -q "\"start\":" package.json; then
            log_info "Starting Node.js application with npm start..."
            npm start
        elif [[ -f "index.js" || -f "src/index.js" || -f "app.js" || -f "server.js" ]]; then
            local main_file
            main_file=$(find . -maxdepth 2 -name "index.js" -o -name "app.js" -o -name "server.js" | head -1)
            
            if [[ -n "$main_file" ]]; then
                if command_exists nodemon; then
                    log_info "Starting Node.js application with nodemon: $main_file"
                    nodemon "$main_file"
                else
                    log_info "Starting Node.js application: $main_file"
                    node "$main_file"
                fi
            else
                log_warning "No main file found. Starting http-server on port $port..."
                if command_exists npx; then
                    npx http-server -p "$port"
                else
                    log_error "npx is not installed. Cannot start http-server."
                    return 1
                fi
            fi
        else
            log_info "Starting http-server on port $port..."
            if command_exists npx; then
                npx http-server -p "$port"
            else
                log_error "npx is not installed. Cannot start http-server."
                return 1
            fi
        fi
    elif [[ -f "manage.py" ]]; then
        # Django project
        log_info "Starting Django development server on port $port..."
        python manage.py runserver "$port"
    elif [[ -f "app.py" || -f "wsgi.py" || -f "application.py" ]]; then
        # Flask/WSGI project
        log_info "Starting Flask/WSGI application on port $port..."
        
        # Find main application file
        local app_file
        app_file=$(find . -maxdepth 2 -name "app.py" -o -name "wsgi.py" -o -name "application.py" | head -1)
        
        if [[ -f "requirements.txt" ]]; then
            if ! command_exists flask; then
                log_warning "Flask not found. Installing Flask..."
                pip install flask
            fi
            
            FLASK_APP="$app_file" FLASK_ENV=development flask run --port "$port"
        else
            log_warning "No requirements.txt found. Starting simple HTTP server on port $port..."
            python -m http.server "$port"
        fi
    elif [[ -f "config.ru" ]]; then
        # Ruby/Rack project
        log_info "Starting Rack application..."
        if command_exists bundle; then
            bundle exec rackup -p "$port"
        else
            log_error "Bundler is not installed. Cannot start Rack application."
            return 1
        fi
    else
        # Generic
        log_info "No specific project type detected. Starting simple HTTP server on port $port..."
        
        if command_exists python3; then
            python3 -m http.server "$port"
        elif command_exists python; then
            python -m http.server "$port"
        else
            log_error "Python is not installed. Cannot start HTTP server."
            return 1
        fi
    fi
    
    return $?
}

# Run tests based on project type
# Usage: test
test() {
    # Detect project type
    if [[ -f "package.json" ]]; then
        # Node.js project
        if grep -q "\"test\":" package.json; then
            log_info "Running Node.js tests with npm test..."
            npm test
        elif [[ -d "test" || -d "tests" ]]; then
            if command_exists npx; then
                log_info "Running tests with Jest..."
                npx jest
            else
                log_error "npx is not installed. Cannot run Jest tests."
                return 1
            fi
        else
            log_warning "No tests found in this Node.js project."
        fi
    elif [[ -f "pytest.ini" || -d "tests" || -d "test" ]]; then
        # Python project
        log_info "Running Python tests with pytest..."
        
        if command_exists pytest; then
            python -m pytest
        elif command_exists python; then
            python -m pytest
        else
            log_error "pytest is not installed. Cannot run Python tests."
            return 1
        fi
    elif [[ -f "manage.py" ]]; then
        # Django project
        log_info "Running Django tests..."
        python manage.py test
    elif [[ -f "Gemfile" ]]; then
        # Ruby project
        if [[ -d "spec" ]]; then
            log_info "Running RSpec tests..."
            
            if command_exists bundle; then
                bundle exec rspec
            else
                log_error "Bundler is not installed. Cannot run RSpec tests."
                return 1
            fi
        else
            log_info "Running Ruby tests..."
            
            if command_exists bundle; then
                bundle exec rake test
            else
                log_error "Bundler is not installed. Cannot run Ruby tests."
                return 1
            fi
        fi
    else
        log_warning "No known test setup detected."
    fi
    
    return $?
}

# Format code based on project type
# Usage: format
format() {
    # Detect project type
    if [[ -f "package.json" ]]; then
        # Node.js project
        if grep -q "\"format\":" package.json; then
            log_info "Formatting code with npm script..."
            npm run format
        elif command_exists npx && command_exists prettier; then
            log_info "Formatting code with prettier..."
            npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"
        elif command_exists npx; then
            log_info "Installing prettier and formatting code..."
            npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"
        else
            log_error "Cannot format Node.js project. prettier is not available."
            return 1
        fi
    elif [[ -f "pyproject.toml" || -d "venv" || -f "requirements.txt" ]]; then
        # Python project
        if command_exists black; then
            log_info "Formatting code with black..."
            black .
        elif command_exists pip; then
            log_info "Installing black and formatting code..."
            pip install black
            black .
        else
            log_error "Cannot format Python project. black is not available."
            return 1
        fi
    elif [[ -f "Gemfile" ]]; then
        # Ruby project
        if command_exists rubocop; then
            log_info "Formatting code with rubocop --auto-correct..."
            rubocop --auto-correct
        elif command_exists bundle; then
            log_info "Running rubocop with bundle..."
            bundle exec rubocop --auto-correct
        else
            log_error "Cannot format Ruby project. rubocop is not available."
            return 1
        fi
    else
        log_warning "No known formatter detected for this project type."
    fi
    
    return $?
}

#-------------------------------------------------------------
# System Utility Functions
#-------------------------------------------------------------

# Show system information
# Usage: sysinfo
sysinfo() {
    echo -e "${BOLD}=== System Information ===${NC}"
    
    # OS Information
    local os_type kernel_ver cpu_info memory disk_usage
    os_type=$(uname -s)
    kernel_ver=$(uname -r)
    
    echo -e "${BOLD}OS:${NC} $os_type"
    echo -e "${BOLD}Kernel:${NC} $kernel_ver"
    
    # CPU Information
    if [[ "$os_type" == "Linux" ]]; then
        cpu_info=$(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | tr -s ' ' | sed 's/^[ \t]*//')
    elif [[ "$os_type" == "Darwin" ]]; then
        cpu_info=$(sysctl -n machdep.cpu.brand_string)
    else
        cpu_info="Unknown"
    fi
    echo -e "${BOLD}CPU:${NC} $cpu_info"
    
    # Memory Information
    if [[ "$os_type" == "Linux" ]]; then
        if command_exists free; then
            memory=$(free -h | grep Mem | awk '{print $2}')
        else
            memory="Unknown"
        fi
    elif [[ "$os_type" == "Darwin" ]]; then
        memory=$(sysctl -n hw.memsize | awk '{printf "%.2f GB", $1/1024/1024/1024}')
    else
        memory="Unknown"
    fi
    echo -e "${BOLD}Memory:${NC} $memory"
    
    # Disk Usage
    if command_exists df; then
        disk_usage=$(df -h / | grep / | awk '{print $3 " / " $2 " (" $5 ")"}')
        echo -e "${BOLD}Disk usage:${NC} $disk_usage"
    fi
    
    # Display running services
    echo -e "\n${BOLD}=== Running Services ===${NC}"
    if command_exists systemctl; then
        systemctl list-units --type=service --state=running | head -n 10 | 
            grep -v "UNIT\|LOAD\|ACTIVE\|SUB\|DESCRIPTION" | awk '{print $1}'
    elif [[ "$os_type" == "Darwin" ]]; then
        if command_exists launchctl; then
            launchctl list | head -n 10 | grep -v "PID\|Status\|Label" | awk '{print $3}'
        fi
    fi
    
    # Display network information
    echo -e "\n${BOLD}=== Network Information ===${NC}"
    if command_exists ip; then
        ip addr | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1
    elif command_exists ifconfig; then
        ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'
    fi
    
    # Docker information if available
    if command_exists docker; then
        echo -e "\n${BOLD}=== Docker Information ===${NC}"
        echo -e "${BOLD}Docker version:${NC} $(docker --version)"
        echo -e "${BOLD}Running containers:${NC} $(docker ps -q | wc -l)"
        echo -e "${BOLD}Total containers:${NC} $(docker ps -a -q | wc -l)"
        echo -e "${BOLD}Images:${NC} $(docker images -q | wc -l)"
    fi
    
    return 0
}

# Find large files
# Usage: findlarge [<directory>] [<number-of-files>]
findlarge() {
    local dir="${1:-.}"
    local count="${2:-10}"
    
    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi
    
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        log_error "Count must be a number"
        return 1
    fi
    
    log_info "Finding $count largest files in $dir..."
    
    if command_exists find && command_exists du && command_exists sort; then
        find "$dir" -type f -exec du -h {} \; | sort -rh | head -n "$count"
    else
        log_error "Required commands (find, du, sort) are not available"
        return 1
    fi
    
    return 0
}

# Find files containing a string
# Usage: findtext <text> [<directory>]
findtext() {
    local text="$1"
    local dir="${2:-.}"
    
    if [[ -z "$text" ]]; then
        log_error "Usage: findtext <text> [<directory>]"
        return 1
    fi
    
    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi
    
    log_info "Finding files containing '$text' in $dir..."
    
    if command_exists rg; then
        # Use ripgrep if available (much faster)
        rg -l "$text" "$dir"
    elif command_exists grep; then
        # Fall back to grep
        grep -r --include="*" -l "$text" "$dir"
    else
        log_error "Neither ripgrep nor grep is available"
        return 1
    fi
    
    return $?
}

# Monitor system resources
# Usage: monitor
monitor() {
    log_info "Monitoring system resources (press Ctrl+C to exit)..."
    
    if command_exists htop; then
        htop
    elif command_exists glances; then
        glances
    elif command_exists top; then
        top
    else
        log_warning "No monitoring tool available. Installing htop..."
        
        if [[ "$(uname)" == "Darwin" ]]; then
            if command_exists brew; then
                brew install htop
                htop
            else
                log_error "Homebrew is not installed. Cannot install htop."
                return 1
            fi
        elif [[ "$(uname)" == "Linux" ]]; then
            if command_exists apt; then
                sudo apt update && sudo apt install -y htop
                htop
            elif command_exists yum; then
                sudo yum install -y htop
                htop
            else
                log_error "No package manager found. Cannot install htop."
                return 1
            fi
        else
            log_error "Unsupported OS for automatic installation. Please install htop manually."
            top
        fi
    fi
    
    return $?
}

#-------------------------------------------------------------
# Database Functions
#-------------------------------------------------------------

# PostgreSQL database backup
# Usage: pgbackup <database-name> [<output-file>]
pgbackup() {
    local db_name="$1"
    local output_file="${2:-$db_name-$(date +%Y%m%d).sql}"
    
    if [[ -z "$db_name" ]]; then
        log_error "Usage: pgbackup <database-name> [<output-file>]"
        return 1
    fi
    
    # Check if pg_dump is available
    if ! command_exists pg_dump; then
        log_error "pg_dump is not installed"
        return 1
    }
    
    log_info "Creating PostgreSQL backup of $db_name to $output_file..."
    
    if ! pg_dump "$db_name" > "$output_file"; then
        log_error "Failed to backup database"
        return 1
    fi
    
    local file_size
    file_size=$(du -h "$output_file" | cut -f1)
    log_success "Backup completed: $output_file ($file_size)"
    
    return 0
}

# PostgreSQL database restore
# Usage: pgrestore <database-name> <input-file>
pgrestore() {
    local db_name="$1"
    local input_file="$2"
    
    if [[ -z "$db_name" || -z "$input_file" ]]; then
        log_error "Usage: pgrestore <database-name> <input-file>"
        return 1
    fi
    
    if [[ ! -f "$input_file" ]]; then
        log_error "Input file not found: $input_file"
        return 1
    fi
    
    # Check if psql is available
    if ! command_exists psql; then
        log_error "psql is not installed"
        return 1
    fi
    
    log_info "Restoring PostgreSQL backup from $input_file to $db_name..."
    
    if ! psql "$db_name" < "$input_file"; then
        log_error "Failed to restore database"
        return 1
    fi
    
    log_success "Restore completed to database: $db_name"
    return 0
}

# Create a new PostgreSQL database
# Usage: pgcreate <database-name>
pgcreate() {
    local db_name="$1"
    
    if [[ -z "$db_name" ]]; then
        log_error "Usage: pgcreate <database-name>"
        return 1
    fi
    
    # Check if createdb is available
    if ! command_exists createdb; then
        log_error "createdb is not installed"
        return 1
    fi
    
    log_info "Creating PostgreSQL database: $db_name..."
    
    if ! createdb "$db_name"; then
        log_error "Failed to create database"
        return 1
    fi
    
    log_success "Database created: $db_name"
    return 0
}

# Database connection helper with fzf
# Usage: dbsh
dbsh() {
    # Check if fzf is available
    if ! command_exists fzf; then
        log_error "fzf is not installed"
        return 1
    fi
    
    # Determine available database tools
    local db_options=()
    
    if command_exists psql; then
        db_options+=("PostgreSQL")
    fi
    
    if command_exists mysql; then
        db_options+=("MySQL")
    fi
    
    if command_exists mongo; then
        db_options+=("MongoDB")
    fi
    
    if [[ ${#db_options[@]} -eq 0 ]]; then
        log_error "No database clients found"
        return 1
    fi
    
    # Convert array to newline-separated string for fzf
    local options_str
    options_str=$(printf "%s\n" "${db_options[@]}")
    
    # Select database type with fzf
    local db_choice
    db_choice=$(echo -e "$options_str" | fzf --height 40% --layout reverse --prompt="Select database: ")
    
    if [[ -z "$db_choice" ]]; then
        log_warning "No database selected"
        return 1
    fi
    
    # Connect to selected database
    case "$db_choice" in
        "PostgreSQL")
            log_info "Connecting to PostgreSQL..."
            psql -U postgres
            ;;
        "MySQL")
            log_info "Connecting to MySQL..."
            mysql -u root
            ;;
        "MongoDB")
            log_info "Connecting to MongoDB..."
            mongo
            ;;
        *)
            log_error "Unknown database type: $db_choice"
            return 1
            ;;
    esac
    
    return $?
}

#-------------------------------------------------------------
# Terminal Session Management
#-------------------------------------------------------------

# Save current terminal directory to a file
# Usage: savedir [<name>]
savedir() {
    local name="${1:-default}"
    local save_dir="$HOME/.saved_dirs"
    
    # Ensure save directory exists
    if ! ensure_dir "$save_dir"; then
        log_error "Failed to create save directory"
        return 1
    fi
    
    echo "$PWD" > "$save_dir/$name" || {
        log_error "Failed to save directory"
        return 1
    }
    
    log_success "Current directory saved as '$name': $PWD"
    return 0
}

# Change to a saved directory
# Usage: loaddir [<name>]
loaddir() {
    local name="${1:-default}"
    local save_dir="$HOME/.saved_dirs"
    local dir_file="$save_dir/$name"
    
    if [[ ! -f "$dir_file" ]]; then
        log_error "No saved directory named '$name'"
        return 1
    fi
    
    local dir
    dir=$(cat "$dir_file")
    
    if [[ ! -d "$dir" ]]; then
        log_error "Saved directory no longer exists: $dir"
        return 1
    fi
    
    cd "$dir" || {
        log_error "Failed to change to directory: $dir"
        return 1
    }
    
    log_success "Changed to saved directory '$name': $dir"
    return 0
}

# List saved directories
# Usage: lsdirs
lsdirs() {
    local save_dir="$HOME/.saved_dirs"
    
    if [[ ! -d "$save_dir" ]]; then
        log_info "No saved directories"
        return 0
    fi
    
    echo -e "${BOLD}Saved directories:${NC}"
    local count=0
    
    for file in "$save_dir"/*; do
        [[ -f "$file" ]] || continue
        
        local name dir
        name=$(basename "$file")
        dir=$(cat "$file")
        
        echo -e "  ${BOLD}$name:${NC} $dir"
        ((count++))
    done
    
    if [[ $count -eq 0 ]]; then
        log_info "No saved directories found"
    fi
    
    return 0
}

# Find and edit file with fzf
# Usage: vf [<directory>]
vf() {
    local dir="${1:-.}"
    
    if [[ ! -d "$dir" ]]; then
        log_error "Directory not found: $dir"
        return 1
    fi
    
    # Check for required commands
    if ! command_exists fzf; then
        log_error "fzf is not installed"
        return 1
    fi
    
    local preview_cmd="cat {}"
    
    # Use bat for preview if available
    if command_exists bat; then
        preview_cmd="bat --style=numbers --color=always --line-range :500 {}"
    fi
    
    # Find files and select with fzf
    local file
    file=$(find "$dir" -type f -not -path "*/\.*" | 
        fzf --preview="$preview_cmd" --height 80% --layout reverse --prompt="Select file to edit: ")
    
    # If a file was selected, edit it
    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file"
    else
        log_warning "No file selected"
        return 1
    fi
    
    return 0
}

# Quick project navigation
# Usage: proj
proj() {
    local projects_dir="$HOME/projects"
    
    if [[ ! -d "$projects_dir" ]]; then
        log_error "Projects directory not found: $projects_dir"
        return 1
    fi
    
    # Check for required commands
    if ! command_exists fzf; then
        log_error "fzf is not installed"
        return 1
    fi
    
    # Find project directories
    local project_dirs
    project_dirs=$(find "$projects_dir" -mindepth 1 -maxdepth 2 -type d)
    
    if [[ -z "$project_dirs" ]]; then
        log_error "No project directories found"
        return 1
    fi
    
    # Select project with fzf
    local dir
    dir=$(echo "$project_dirs" | fzf --height 40% --layout reverse --prompt="Select project: ")
    
    # If a project was selected, navigate to it
    if [[ -n "$dir" ]]; then
        cd "$dir" || {
            log_error "Failed to change to directory: $dir"
            return 1
        }
        log_success "Changed to project directory: $dir"
    else
        log_warning "No project selected"
        return 1
    fi
    
    return 0
}

#-------------------------------------------------------------
# Utility Functions
#-------------------------------------------------------------

# Weather forecast
# Usage: weather [<city>]
weather() {
    local city="${1:-}"
    
    # Check for curl
    if ! command_exists curl; then
        log_error "curl is not installed"
        return 1
    fi
    
    if [[ -z "$city" ]]; then
        # Try to get location from IP
        log_info "Getting weather for current location..."
        curl -s "wttr.in/?F"
    else
        log_info "Getting weather for $city..."
        curl -s "wttr.in/$city?F"
    fi
    
    return $?
}

# Get a cheat sheet for a command
# Usage: cheatsheet <command>
cheatsheet() {
    local command="$1"
    
    if [[ -z "$command" ]]; then
        log_error "Usage: cheatsheet <command>"
        return 1
    fi
    
    # Check for curl
    if ! command_exists curl; then
        log_error "curl is not installed"
        return 1
    fi
    
    log_info "Cheat sheet for $command:"
    curl -s "cheat.sh/$command"
    
    return $?
}

# Generate a random password
# Usage: genpassword [<length>]
genpassword() {
    local length="${1:-16}"
    
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        log_error "Error: Length must be a number"
        return 1
    fi
    
    log_info "Generating random password of length $length..."
    
    # Use different methods based on available commands
    if command_exists openssl; then
        openssl rand -base64 "$((length*3/4))" | tr -dc 'a-zA-Z0-9!@#$%^&*()_+' | head -c "$length"
        echo  # Add newline
    elif command_exists /dev/urandom && command_exists tr; then
        LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "$length"
        echo  # Add newline
    else
        log_error "Required commands (openssl or tr) are not available"
        return 1
    fi
    
    return 0
}

# IP information
# Usage: ipinfo [<ip-address>]
ipinfo() {
    local ip="${1:-}"
    
    # Check for curl
    if ! command_exists curl; then
        log_error "curl is not installed"
        return 1
    fi
    
    if [[ -z "$ip" ]]; then
        log_info "Getting information for your public IP..."
        curl -s "ipinfo.io"
    else
        log_info "Getting information for IP: $ip..."
        curl -s "ipinfo.io/$ip"
    fi
    
    return $?
}

# Calculate expression
# Usage: calc <expression>
calc() {
    local expression="$*"
    
    if [[ -z "$expression" ]]; then
        log_error "Usage: calc <expression>"
        return 1
    fi
    
    log_info "Calculating: $expression"
    
    # Use different methods based on available commands
    if command_exists bc; then
        echo "$expression" | bc -l
    elif command_exists python || command_exists python3; then
        # Try Python
        local python_cmd
        if command_exists python3; then
            python_cmd="python3"
        else
            python_cmd="python"
        fi
        
        $python_cmd -c "print(eval('$expression'))"
    else
        log_error "Required commands (bc or python) are not available"
        return 1
    fi
    
    return $?
}

# Show a horizontal separator line for terminal output
# Usage: hr
hr() {
    local width
    
    # Get terminal width
    if command_exists tput; then
        width=$(tput cols)
    else
        # Default width if tput is not available
        width=80
    fi
    
    printf '%*s\n' "$width" '' | tr ' ' '-'
    
    return 0
}

# Touch and open a file
# Usage: touchopen <filename>
touchopen() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        log_error "Usage: touchopen <filename>"
        return 1
    fi
    
    # Create file or update timestamp
    touch "$file" || {
        log_error "Failed to touch file: $file"
        return 1
    }
    
    # Open in editor
    ${EDITOR:-vim} "$file"
    
    return $?
}

# Set terminal title
# Usage: title <title>
title() {
    local title="$*"
    
    if [[ -z "$title" ]]; then
        log_error "Usage: title <title>"
        return 1
    fi
    
    echo -ne "\033]0;$title\007"
    
    return 0
}

# Run any command with a timeout
# Usage: timeout_cmd <seconds> <command>
timeout_cmd() {
    local timeout="$1"
    shift
    local cmd="$@"
    
    if [[ -z "$timeout" || -z "$cmd" ]]; then
        log_error "Usage: timeout_cmd <seconds> <command>"
        return 1
    fi
    
    # Check if timeout command exists
    if ! command_exists timeout; then
        log_error "timeout command is not available"
        return 1
    fi
    
    timeout "$timeout" $cmd
    local status=$?
    
    if [[ $status -eq 124 ]]; then
        log_warning "Command timed out after $timeout seconds"
        return 124
    fi
    
    return $status
}

# Extract archives
# Usage: extract <file>
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)
                log_error "'$1' cannot be extracted via extract()"
                return 1
                ;;
        esac
        log_success "Extracted: $1"
    else
        log_error "'$1' is not a valid file"
        return 1
    fi
    
    return 0
}

# Welcome message
echo "Enhanced Terminal Environment functions loaded."
echo "Type 'vf' to find and edit files, 'proj' to navigate to projects."