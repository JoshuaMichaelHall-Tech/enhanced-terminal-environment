#!/bin/bash
# Enhanced Terminal Environment Functions
# Custom functions to enhance terminal-based development workflow

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
    echo "Usage: newproject <name> [<type>]"
    echo "Types: generic, python, node, ruby (default: generic)"
    return 1
  fi
  
  local project_dir="$HOME/projects/$name"
  
  # Check if directory already exists
  if [[ -d "$project_dir" ]]; then
    echo "Project directory already exists: $project_dir"
    return 1
  fi
  
  # Create directory
  mkdir -p "$project_dir"
  cd "$project_dir" || return
  
  # Initialize git
  git init
  
  # Create README.md
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
  
  # Initialize project based on type
  case "$type" in
    python)
      # Create Python project
      mkdir -p src tests
      touch src/__init__.py
      touch src/main.py
      touch tests/__init__.py
      touch tests/test_main.py
      
      # Create virtual environment setup
      python3 -m venv venv
      
      # Create .gitignore
      curl -s https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore > .gitignore
      
      # Create minimal requirements.txt
      echo "# Requirements
pytest>=7.0.0
black>=23.0.0
pylint>=2.17.0
" > requirements.txt
      
      echo "Python project created at $project_dir"
      echo "To activate the virtual environment, run: source venv/bin/activate"
      ;;
      
    node)
      # Create Node.js project
      mkdir -p src test
      touch src/index.js
      touch test/index.test.js
      
      # Initialize npm
      npm init -y
      
      # Create .gitignore
      curl -s https://raw.githubusercontent.com/github/gitignore/master/Node.gitignore > .gitignore
      
      echo "Node.js project created at $project_dir"
      echo "To install dependencies, run: npm install"
      ;;
      
    ruby)
      # Create Ruby project
      mkdir -p lib spec
      touch lib/main.rb
      touch spec/main_spec.rb
      
      # Create Gemfile
      cat > Gemfile << EOF
source 'https://rubygems.org'

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'pry', '~> 0.14'
end
EOF
      
      # Create .gitignore
      curl -s https://raw.githubusercontent.com/github/gitignore/master/Ruby.gitignore > .gitignore
      
      echo "Ruby project created at $project_dir"
      echo "To install dependencies, run: bundle install"
      ;;
      
    *)
      # Generic project with minimal structure
      mkdir -p src docs
      touch src/.gitkeep docs/.gitkeep
      
      # Create .gitignore
      echo "# Logs
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
" > .gitignore
      
      echo "Generic project created at $project_dir"
      ;;
  esac
  
  # Initial commit
  git add .
  git commit -m "Initial commit" --no-verify
  
  # Return to project directory
  cd "$project_dir" || return
}

#-------------------------------------------------------------
# Git Functions
#-------------------------------------------------------------

# Clone GitHub repository and cd into it
# Usage: gclone <username/repo>
gclone() {
  local repo="$1"
  
  if [[ -z "$repo" ]]; then
    echo "Usage: gclone <username/repo>"
    return 1
  fi
  
  git clone "https://github.com/$repo.git"
  
  # Extract repo name and cd into it
  local repo_name
  repo_name=$(echo "$repo" | sed 's/.*\///')
  cd "$repo_name" || return
}

# Create a branch with the given name, or a feature branch with today's date if no name provided
# Usage: gcreate [<branch-name>]
gcreate() {
  local branch_name="$1"
  
  if [[ -z "$branch_name" ]]; then
    branch_name="feature/$(date +%Y-%m-%d)"
  fi
  
  git checkout -b "$branch_name"
  echo "Created and switched to branch: $branch_name"
}

# Show stats for current git repository
# Usage: gstats
gstats() {
  echo "=== Git Repository Statistics ==="
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commits: $(git rev-list --count HEAD)"
  echo "Contributors: $(git shortlog -s -n --all | wc -l)"
  echo "Last commit: $(git log -1 --pretty=%B)"
  echo "Modified files: $(git status -s | wc -l)"
}

#-------------------------------------------------------------
# Docker Functions
#-------------------------------------------------------------

# Stop all running containers
# Usage: dstop
dstop() {
  if [[ "$(docker ps -q)" ]]; then
    docker stop $(docker ps -q)
    echo "All containers stopped"
  else
    echo "No running containers found"
  fi
}

# Clean up Docker resources (containers, images, networks)
# Usage: dclean
dclean() {
  echo "Cleaning up Docker resources..."
  
  # Remove all stopped containers
  if [[ "$(docker ps -a -q)" ]]; then
    echo "Removing stopped containers..."
    docker rm $(docker ps -a -q)
  else
    echo "No containers to remove"
  fi
  
  # Remove unused images
  if [[ "$(docker images -f "dangling=true" -q)" ]]; then
    echo "Removing dangling images..."
    docker rmi $(docker images -f "dangling=true" -q)
  else
    echo "No dangling images to remove"
  fi
  
  # Remove unused networks
  echo "Removing unused networks..."
  docker network prune -f
  
  # Remove unused volumes
  echo "Removing unused volumes..."
  docker volume prune -f
  
  echo "Docker cleanup complete"
}

# Restart a container
# Usage: drestart <container-name-or-id>
drestart() {
  local container="$1"
  
  if [[ -z "$container" ]]; then
    echo "Usage: drestart <container-name-or-id>"
    return 1
  fi
  
  docker restart "$container"
  echo "Container $container restarted"
}

# Run a command in a container
# Usage: dexec <container-name-or-id> <command>
dexec() {
  local container="$1"
  local cmd="${2:-sh}"
  
  if [[ -z "$container" ]]; then
    echo "Usage: dexec <container-name-or-id> [<command>]"
    echo "Default command: sh"
    return 1
  fi
  
  docker exec -it "$container" $cmd
}

#-------------------------------------------------------------
# Development Workflow Functions
#-------------------------------------------------------------

# Start a development server based on project type
# Usage: serve [<port>]
serve() {
  local port="${1:-8000}"
  
  # Detect project type
  if [[ -f "package.json" ]]; then
    # Node.js project
    if grep -q "\"start\":" package.json; then
      echo "Starting Node.js application on npm start..."
      npm start
    elif [[ -f "index.js" || -f "src/index.js" || -f "app.js" || -f "server.js" ]]; then
      echo "Starting Node.js application..."
      npx nodemon $(find . -name "index.js" -o -name "app.js" -o -name "server.js" | head -1)
    else
      echo "Starting http-server on port $port..."
      npx http-server -p "$port"
    fi
  elif [[ -f "manage.py" ]]; then
    # Django project
    echo "Starting Django development server on port $port..."
    python manage.py runserver "$port"
  elif [[ -f "app.py" || -f "wsgi.py" || -f "application.py" ]]; then
    # Flask/WSGI project
    echo "Starting Flask/WSGI application on port $port..."
    if [[ -f "requirements.txt" ]]; then
      if ! command -v flask &> /dev/null; then
        pip install flask
      fi
      FLASK_APP=$(find . -name "app.py" -o -name "wsgi.py" -o -name "application.py" | head -1) FLASK_ENV=development flask run --port "$port"
    else
      python -m http.server "$port"
    fi
  elif [[ -f "config.ru" ]]; then
    # Ruby/Rack project
    echo "Starting Rack application..."
    bundle exec rackup -p "$port"
  else
    # Generic
    echo "No specific project type detected. Starting simple HTTP server on port $port..."
    python -m http.server "$port"
  fi
}

  # Run tests based on project type
# Usage: test
test() {
  # Detect project type
  if [[ -f "package.json" ]]; then
    # Node.js project
    if grep -q "\"test\":" package.json; then
      echo "Running Node.js tests with npm test..."
      npm test
    elif [[ -d "test" || -d "tests" ]]; then
      echo "Running tests with Jest..."
      npx jest
    else
      echo "No tests found in this Node.js project."
    fi
  elif [[ -f "pytest.ini" || -d "tests" || -d "test" ]]; then
    # Python project
    echo "Running Python tests with pytest..."
    python -m pytest
  elif [[ -f "manage.py" ]]; then
    # Django project
    echo "Running Django tests..."
    python manage.py test
  elif [[ -f "Gemfile" ]]; then
    # Ruby project
    if [[ -d "spec" ]]; then
      echo "Running RSpec tests..."
      bundle exec rspec
    else
      echo "Running Ruby tests..."
      bundle exec rake test
    fi
  else
    echo "No known test setup detected."
  fi
}

# Format code based on project type
# Usage: format
format() {
  # Detect project type
  if [[ -f "package.json" ]]; then
    # Node.js project
    if grep -q "\"format\":" package.json; then
      echo "Formatting code with npm script..."
      npm run format
    elif command -v prettier &> /dev/null; then
      echo "Formatting code with prettier..."
      npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"
    else
      echo "Installing prettier and formatting code..."
      npm install --save-dev prettier
      npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"
    fi
  elif [[ -f "pyproject.toml" || -d "venv" || -f "requirements.txt" ]]; then
    # Python project
    if command -v black &> /dev/null; then
      echo "Formatting code with black..."
      black .
    else
      echo "Installing black and formatting code..."
      pip install black
      black .
    fi
  elif [[ -f "Gemfile" ]]; then
    # Ruby project
    if command -v rubocop &> /dev/null; then
      echo "Formatting code with rubocop --auto-correct..."
      bundle exec rubocop --auto-correct
    else
      echo "Installing rubocop and formatting code..."
      gem install rubocop
      rubocop --auto-correct
    fi
  else
    echo "No known formatter detected for this project type."
  fi
}

#-------------------------------------------------------------
# System Utility Functions
#-------------------------------------------------------------

# Show system information
# Usage: sysinfo
sysinfo() {
  echo "=== System Information ==="
  echo "OS: $(uname -s)"
  echo "Kernel: $(uname -r)"
  echo "CPU: $(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | tr -s ' ' | sed 's/^[ \t]*//' 2>/dev/null || sysctl -n machdep.cpu.brand_string 2>/dev/null)"
  echo "Memory: $(free -h | grep Mem | awk '{print $2}' 2>/dev/null || sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 " GB"}')"
  echo "Disk usage: $(df -h / | grep / | awk '{print $3 " / " $2 " (" $5 ")"}')"
  
  # Display running services
  echo -e "\n=== Running Services ==="
  if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service --state=running | head -n 10 | grep -v "UNIT\|LOAD\|ACTIVE\|SUB\|DESCRIPTION" | awk '{print $1}'
  elif command -v launchctl &> /dev/null; then
    launchctl list | head -n 10 | grep -v "PID\|Status\|Label" | awk '{print $3}'
  fi
  
  # Display network information
  echo -e "\n=== Network Information ==="
  if command -v ip &> /dev/null; then
    ip addr | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1
  else
    ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'
  fi
  
  # Docker information if available
  if command -v docker &> /dev/null; then
    echo -e "\n=== Docker Information ==="
    echo "Docker version: $(docker --version)"
    echo "Running containers: $(docker ps -q | wc -l)"
    echo "Total containers: $(docker ps -a -q | wc -l)"
    echo "Images: $(docker images -q | wc -l)"
  fi
}

# Find large files
# Usage: findlarge [<directory>] [<number-of-files>]
findlarge() {
  local dir="${1:-.}"
  local count="${2:-10}"
  
  echo "Finding $count largest files in $dir..."
  find "$dir" -type f -exec du -h {} \; | sort -rh | head -n "$count"
}

# Find files containing a string
# Usage: findtext <text> [<directory>]
findtext() {
  local text="$1"
  local dir="${2:-.}"
  
  if [[ -z "$text" ]]; then
    echo "Usage: findtext <text> [<directory>]"
    return 1
  fi
  
  echo "Finding files containing '$text' in $dir..."
  if command -v rg &> /dev/null; then
    # Use ripgrep if available (much faster)
    rg -l "$text" "$dir"
  else
    # Fall back to grep
    grep -r --include="*" -l "$text" "$dir"
  fi
}

# Monitor system resources
# Usage: monitor
monitor() {
  echo "Monitoring system resources (press Ctrl+C to exit)..."
  if command -v htop &> /dev/null; then
    htop
  elif command -v glances &> /dev/null; then
    glances
  else
    echo "Installing htop for system monitoring..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install htop
      htop
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y htop
      htop
    else
      echo "Unsupported OS for automatic installation. Please install htop manually."
      top
    fi
  fi
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
    echo "Usage: pgbackup <database-name> [<output-file>]"
    return 1
  fi
  
  echo "Creating PostgreSQL backup of $db_name to $output_file..."
  pg_dump "$db_name" > "$output_file"
  echo "Backup completed: $output_file ($(du -h "$output_file" | cut -f1))"
}

# PostgreSQL database restore
# Usage: pgrestore <database-name> <input-file>
pgrestore() {
  local db_name="$1"
  local input_file="$2"
  
  if [[ -z "$db_name" || -z "$input_file" ]]; then
    echo "Usage: pgrestore <database-name> <input-file>"
    return 1
  fi
  
  if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file not found: $input_file"
    return 1
  fi
  
  echo "Restoring PostgreSQL backup from $input_file to $db_name..."
  psql "$db_name" < "$input_file"
  echo "Restore completed to database: $db_name"
}

# Create a new PostgreSQL database
# Usage: pgcreate <database-name>
pgcreate() {
  local db_name="$1"
  
  if [[ -z "$db_name" ]]; then
    echo "Usage: pgcreate <database-name>"
    return 1
  fi
  
  echo "Creating PostgreSQL database: $db_name..."
  createdb "$db_name"
  echo "Database created: $db_name"
}

#-------------------------------------------------------------
# Terminal Session Management
#-------------------------------------------------------------

# Save current terminal directory to a file
# Usage: savedir [<name>]
savedir() {
  local name="${1:-default}"
  local save_dir="$HOME/.saved_dirs"
  
  mkdir -p "$save_dir"
  echo "$PWD" > "$save_dir/$name"
  echo "Current directory saved as '$name': $PWD"
}

# Change to a saved directory
# Usage: loaddir [<name>]
loaddir() {
  local name="${1:-default}"
  local save_dir="$HOME/.saved_dirs"
  local dir_file="$save_dir/$name"
  
  if [[ ! -f "$dir_file" ]]; then
    echo "No saved directory named '$name'"
    return 1
  fi
  
  local dir=$(cat "$dir_file")
  cd "$dir" || return
  echo "Changed to saved directory '$name': $dir"
}

# List saved directories
# Usage: lsdirs
lsdirs() {
  local save_dir="$HOME/.saved_dirs"
  
  if [[ ! -d "$save_dir" ]]; then
    echo "No saved directories"
    return
  fi
  
  echo "Saved directories:"
  for file in "$save_dir"/*; do
    local name=$(basename "$file")
    local dir=$(cat "$file")
    echo "  $name: $dir"
  done
}

#-------------------------------------------------------------
# Utility Functions
#-------------------------------------------------------------

# Weather forecast
# Usage: weather [<city>]
weather() {
  local city="${1:-}"
  
  if [[ -z "$city" ]]; then
    # Try to get location from IP
    echo "Getting weather for current location..."
    curl -s "wttr.in/?F"
  else
    echo "Getting weather for $city..."
    curl -s "wttr.in/$city?F"
  fi
}

# Get a cheat sheet for a command
# Usage: cheatsheet <command>
cheatsheet() {
  local command="$1"
  
  if [[ -z "$command" ]]; then
    echo "Usage: cheatsheet <command>"
    return 1
  fi
  
  echo "Cheat sheet for $command:"
  curl -s "cheat.sh/$command"
}

# Generate a random password
# Usage: genpassword [<length>]
genpassword() {
  local length="${1:-16}"
  
  if ! [[ "$length" =~ ^[0-9]+$ ]]; then
    echo "Error: Length must be a number"
    return 1
  fi
  
  echo "Generating random password of length $length..."
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "$length"
  echo  # Add newline
}

# IP information
# Usage: ipinfo [<ip-address>]
ipinfo() {
  local ip="${1:-}"
  
  if [[ -z "$ip" ]]; then
    echo "Getting information for your public IP..."
    curl -s "ipinfo.io"
  else
    echo "Getting information for IP: $ip..."
    curl -s "ipinfo.io/$ip"
  fi
}

# Calculate expression
# Usage: calc <expression>
calc() {
  local expression="$*"
  
  if [[ -z "$expression" ]]; then
    echo "Usage: calc <expression>"
    return 1
  fi
  
  echo "Calculating: $expression"
  echo "$expression" | bc -l
}

# Show a horizontal separator line for terminal output
# Usage: hr
hr() {
  local width=$(tput cols)
  printf '%*s\n' "$width" '' | tr ' ' '-'
}

# Touch and open a file
# Usage: touchopen <filename>
touchopen() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Usage: touchopen <filename>"
    return 1
  fi
  
  touch "$file"
  $EDITOR "$file"
}

# Set terminal title
# Usage: title <title>
title() {
  local title="$*"
  
  if [[ -z "$title" ]]; then
    echo "Usage: title <title>"
    return 1
  fi
  
  echo -ne "\033]0;$title\007"
}

# Run any command with a timeout
# Usage: timeout_cmd <seconds> <command>
timeout_cmd() {
  local timeout="$1"
  shift
  local cmd="$@"
  
  if [[ -z "$timeout" || -z "$cmd" ]]; then
    echo "Usage: timeout_cmd <seconds> <command>"
    return 1
  fi
  
  timeout "$timeout" $cmd
  local status=$?
  
  if [[ $status -eq 124 ]]; then
    echo "Command timed out after $timeout seconds"
    return 124
  fi
  
  return $status
}

  