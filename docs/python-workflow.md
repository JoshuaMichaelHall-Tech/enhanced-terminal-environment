# Python Terminal Workflow Guide

This guide outlines an efficient terminal-based workflow for Python development using the Enhanced Terminal Environment.

## Development Environment Setup

### 1. Project Initialization

Create a new Python project using the built-in template:

```bash
# Create and navigate to a new Python project
pyproject myproject

# Alternatively, use the manual approach
mkdir -p myproject/{src,tests}
cd myproject
python -m venv venv
touch src/__init__.py
touch src/main.py
touch tests/__init__.py
touch tests/test_main.py
```

### 2. Virtual Environment Management

```bash
# Activate virtual environment
source venv/bin/activate  # Or using the alias
pyact

# Deactivate when done
deactivate
```

### 3. Start a Python-specific Tmux Session

```bash
# Start a Python development session
mkpy myproject
```

This creates a session with:
- Window 1: Editor (Neovim)
- Window 2: Python REPL
- Window 3: Shell
- Window 4: Tests

## Development Workflow

### 1. Package Management

```bash
# With pip
pip install <package>  # Install a package
pip install -r requirements.txt  # Install from requirements
pip freeze > requirements.txt  # Save dependencies

# With Poetry (recommended for modern projects)
poetry add <package>  # Install and add to dependencies
poetry add --dev <package>  # Add as development dependency
poetry install  # Install all dependencies
poetry update  # Update dependencies
poetry run <command>  # Run command within virtual env
```

### 2. Testing Cycle

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_specific.py

# Run with coverage
pytest --cov=src

# Continuous test watching (requires pytest-watch)
ptw
```

### 3. Code Quality Tools

```bash
# Format code
black src/

# Lint code
pylint src/
flake8 src/

# Type checking
mypy src/
```

### 4. REPL-Driven Development

```python
# In Python REPL
from src import module
import importlib
importlib.reload(module)  # Reload after changes
help(module.function)  # Check documentation
```

### 5. Database Interactions

```bash
# Connect to PostgreSQL
psql mydatabase

# Run a script
python -c "from src.db import init_db; init_db()"
```

## Terminal-Based Debugging

### 1. Basic Print Debugging

```python
print(f"Variable: {variable!r}")
```

### 2. Using PDB

```python
# Add to your code where needed
import pdb; pdb.set_trace()

# Basic PDB commands
# n (next line)
# s (step into function)
# c (continue execution)
# p variable (print variable)
# l (list source code)
# q (quit debugger)
```

### 3. Using IPython for Better Debugging

```python
# Install IPython if not already available
pip install ipython

# Add to your code
from IPython import embed; embed()
```

## File Operations

### 1. Finding and Manipulating Files

```bash
# Find Python files
find . -name "*.py" | grep -v "__pycache__"

# Search inside Python files
grep -r "class MyClass" --include="*.py" .

# With ripgrep (faster)
rg "class MyClass" -t py

# Find and edit with Neovim
nvim $(find . -name "*.py" | grep "model")
```

### 2. Quick File Editing

```bash
# Find and edit with fzf integration
vf  # Custom function that uses fzf with preview
```

## Project Management

### 1. Documentation

```bash
# Generate documentation with Sphinx
sphinx-quickstart
make html
```

### 2. Running Applications

```bash
# Run module
python -m src.main

# Run script with arguments
python src/cli.py --argument value

# With Poetry
poetry run python src/main.py
```

### 3. Profiling

```bash
# Basic timing
python -m cProfile -o output.prof src/main.py

# With visualization (requires snakeviz)
snakeviz output.prof
```

## Docker Integration

```bash
# Run Python in Docker
docker run -it --rm -v $(pwd):/app python-dev

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
ga src/  # Add specific files
gc "Add new feature"  # Commit with message

# Push and pull
gp  # Push changes
gpl  # Pull latest changes
```

## Environment Variables

```bash
# Set environment variables for current session
export DEBUG=True
export API_KEY="your-key"

# Or use .env file with python-dotenv
echo 'DEBUG=True' > .env
echo 'API_KEY=your-key' >> .env

# In Python:
# from dotenv import load_dotenv
# load_dotenv()
```

## Deployment Preparation

```bash
# Create requirements.txt
pip freeze > requirements.txt

# With Poetry, export to requirements.txt format
poetry export -f requirements.txt > requirements.txt

# Create a production .env file
cp .env .env.prod
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

1. Start or attach to Python tmux session: `mkpy project` or `tmux attach -t project`
2. Pull latest changes: `gpl`
3. Create/activate virtual environment: `pyact`
4. Install/update dependencies: `pip install -r requirements.txt`
5. Run tests to ensure everything works: `pytest`
6. Start coding with Neovim: `nvim src/file.py`
7. Test changes in REPL: Switch to REPL window with `Ctrl+a 2`
8. Commit changes regularly: `gs`, `ga`, `gc "Message"`
