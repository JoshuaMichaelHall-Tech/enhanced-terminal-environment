# Ruby Terminal Workflow Guide

This guide outlines an efficient terminal-based workflow for Ruby development using the Enhanced Terminal Environment.

## Development Environment Setup

### 1. Project Initialization

Create a new Ruby project using the built-in template:

```bash
# Create and navigate to a new Ruby project
rubyproject myproject

# Alternatively, use the manual approach
mkdir -p myproject/{lib,spec}
cd myproject
touch lib/myproject.rb
touch spec/myproject_spec.rb
bundle init
```

### 2. Ruby Version Management with RVM

```bash
# List available Ruby versions
rvm list known

# Install a specific version
rvm install 3.2.0

# Use a specific version
rvm use 3.2.0

# Set default version
rvm use 3.2.0 --default

# Create and use a gemset
rvm gemset create myproject
rvm gemset use myproject
```

### 3. Start a Ruby-specific Tmux Session

```bash
# Start a Ruby development session
mkrb myproject
```

This creates a session with:
- Window 1: Editor (Neovim)
- Window 2: IRB/Pry REPL
- Window 3: Shell
- Window 4: Tests

## Development Workflow

### 1. Gem Management

```bash
# Install a gem
gem install <gemname>

# Install gems from Gemfile
bundle install

# Update gems
bundle update

# Add a gem to Gemfile
bundle add <gemname>

# Execute a command in the bundle context
bundle exec <command>
```

### 2. Testing Cycle

```bash
# Run all tests with RSpec
bundle exec rspec

# Run specific test file
bundle exec rspec spec/specific_spec.rb

# Run with documentation format
bundle exec rspec --format documentation

# Run tests automatically when files change
bundle exec guard
```

### 3. Code Quality Tools

```bash
# Format code with Rubocop
bundle exec rubocop

# Auto-correct formatting issues
bundle exec rubocop -a

# Auto-correct safe issues only
bundle exec rubocop --safe-auto-correct
```

### 4. REPL-Driven Development

```ruby
# In IRB or Pry REPL
require_relative 'lib/mymodule'
reload!  # in Pry to reload changed files

# Debug with Pry
# Add `binding.pry` to your code where needed
# When execution stops:
# ls - list variables and methods
# whereami - show current location
# next - execute next line
# step - step into method
# continue - resume execution
```

### 5. Database Interactions

```bash
# Using ActiveRecord without Rails
# In Ruby file:
# require 'active_record'
# ActiveRecord::Base.establish_connection(...)

# Using Rails console (if applicable)
bundle exec rails console
```

## Terminal-Based Debugging

### 1. Basic Print Debugging

```ruby
puts "Variable: #{variable.inspect}"
pp variable  # Pretty print
```

### 2. Using Pry for Debugging

```ruby
# Install pry if not already available
gem install pry pry-byebug

# Add to your code
require 'pry'; binding.pry

# Common Pry commands:
# next - execute next line
# step - step into method
# continue - resume execution
# whereami - show current location
# ls - list variables and methods
# show-source object - show source code
```

### 3. Using Byebug

```ruby
# Add to your code
require 'byebug'; byebug

# Common commands:
# n - next
# s - step
# c - continue
# l - list code
# p variable - print variable
```

## File Operations

### 1. Finding and Manipulating Files

```bash
# Find Ruby files
find . -name "*.rb" | grep -v "vendor"

# Search inside Ruby files
grep -r "def my_method" --include="*.rb" .

# With ripgrep (faster)
rg "def my_method" -t ruby

# Find and edit with Neovim
nvim $(find . -name "*.rb" | grep "model")
```

### 2. Quick File Editing

```bash
# Find and edit with fzf integration
vf  # Custom function that uses fzf with preview
```

## Project Management

### 1. Documentation

```bash
# Generate documentation with YARD
yard
yard server --reload  # Start documentation server
```

### 2. Running Applications

```bash
# Run a Ruby script
ruby lib/script.rb

# Run with bundle environment
bundle exec ruby lib/script.rb

# Rails specific (if applicable)
bundle exec rails server
bundle exec rails console
```

### 3. Profiling

```bash
# Basic profiling
ruby -rprofile lib/script.rb

# Memory profiling with memory_profiler
# Add to your code:
# require 'memory_profiler'
# report = MemoryProfiler.report { your_code_here }
# puts report.pretty_print
```

## Docker Integration

```bash
# Run Ruby in Docker
docker run -it --rm -v $(pwd):/app ruby-dev

# Build and run your application
docker-compose up -d
docker-compose logs -f
```

## Terminal-Based HTTP Requests

```bash
# Using HTTPie
http GET http://api.example.com/endpoint
http POST http://api.example.com/endpoint name=value

# Using curl
curl -X GET http://api.example.com/endpoint
curl -X POST -H "Content-Type: application/json" -d '{"name":"value"}' http://api.example.com/endpoint
```

## Git Workflow

```bash
# Quick status check
gs  # Alias for git status

# Create feature branch
git checkout -b feature/new-feature

# Stage and commit
ga lib/  # Add specific files
gc "Add new feature"  # Commit with message

# Push and pull
gp  # Push changes
gpl  # Pull latest changes
```

## Environment Variables

```bash
# Set environment variables for current session
export DEBUG=true
export API_KEY="your-key"

# Or use .env file with dotenv
echo 'DEBUG=true' > .env
echo 'API_KEY=your-key' >> .env

# In Ruby:
# require 'dotenv/load'
```

## Ruby on Rails Integration (if applicable)

```bash
# Generate Rails resources
bundle exec rails generate model User name:string
bundle exec rails generate controller Users

# Database operations
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails db:rollback

# Development server
bundle exec rails server
```

## Rake Tasks

```bash
# List available tasks
bundle exec rake -T

# Run a specific task
bundle exec rake task_name

# Custom Rakefile example:
# task :test do
#   puts "Running tests..."
#   sh "bundle exec rspec"
# end
```

## Useful Keyboard Shortcuts

### Tmux

- `Ctrl+a c`: Create new window
- `Ctrl+a n`: Next window
- `Ctrl+a p`: Previous window
- `Ctrl+a ,`: Rename window
- `Ctrl+a %`: Split vertically
- `Ctrl+a "`: Split horizontally
- `Ctrl+a o`: Switch pane
- `Ctrl+a z`: Toggle pane zoom

### Neovim (Custom Keymaps in this Environment)

- `<leader>w`: Save file
- `<leader>q`: Quit
- `<leader>sv`: Split vertically
- `<leader>sh`: Split horizontally
- `<leader>bn`: Next buffer
- `<leader>bp`: Previous buffer

## Daily Development Routine

1. Start or attach to Ruby tmux session: `mkrb project` or `tmux attach -t project`
2. Pull latest changes: `gpl`
3. Install/update dependencies: `bundle install`
4. Run tests to ensure everything works: `bundle exec rspec`
5. Start coding with Neovim: `nvim lib/file.rb`
6. Test changes in REPL: Switch to REPL window with `Ctrl+a 2`
7. Run the application: `bundle exec ruby lib/myproject.rb`
8. Commit changes regularly: `gs`, `ga`, `gc "Message"`
