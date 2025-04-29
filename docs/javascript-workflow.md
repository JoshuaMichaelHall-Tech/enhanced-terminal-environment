# JavaScript Terminal Workflow Guide

This guide outlines an efficient terminal-based workflow for JavaScript/Node.js development using the Enhanced Terminal Environment.

## Development Environment Setup

### 1. Project Initialization

Create a new JavaScript project using the built-in template:

```bash
# Create and navigate to a new JavaScript project
nodeproject myproject

# Alternatively, use the manual approach
mkdir -p myproject/{src,test}
cd myproject
npm init -y
touch src/index.js
touch test/index.test.js
```

### 2. Node Version Management

```bash
# List available Node.js versions
nvm ls-remote

# Install a specific version
nvm install 18.16.1

# Use a specific version
nvm use 18.16.1

# Set default version
nvm alias default 18.16.1
```

### 3. Start a JavaScript-specific Tmux Session

```bash
# Start a JavaScript development session
mkjs myproject
```

This creates a session with:
- Window 1: Editor (Neovim)
- Window 2: Node.js REPL
- Window 3: Shell
- Window 4: Tests

## Development Workflow

### 1. Package Management

```bash
# With npm
npm install <package>  # Install and add to dependencies
npm install --save-dev <package>  # Add as dev dependency
npm install -g <package>  # Install globally
npm update  # Update dependencies
npm ci  # Clean install from package-lock.json

# With Yarn
yarn add <package>  # Install and add to dependencies
yarn add --dev <package>  # Add as dev dependency
yarn global add <package>  # Install globally
yarn upgrade  # Update dependencies
```

### 2. Testing Cycle

```bash
# Run all tests
npm test
# Or with Jest directly
npx jest

# Run specific test file
npx jest test/specific.test.js

# Run with coverage
npx jest --coverage

# Watch mode
npx jest --watch
```

### 3. Code Quality Tools

```bash
# Format code
npx prettier --write "src/**/*.js"

# Lint code
npx eslint src/

# Type checking (with TypeScript)
npx tsc --noEmit
```

### 4. REPL-Driven Development

```javascript
// In Node.js REPL
const module = require('./src/module');
Object.keys(module);  // Check exported properties
help(module.function);  // Check documentation

// Clear REPL cache to reload modules
delete require.cache[require.resolve('./src/module')]
const module = require('./src/module');  // Reload module
```

### 5. Database Interactions

```bash
# Connect to MongoDB
mongo mydatabase

# Run a script
node -e "require('./src/db').initDb()"
```

## Terminal-Based Debugging

### 1. Basic Console Debugging

```javascript
console.log('Variable:', variable);
console.dir(object, { depth: null, colors: true });
```

### 2. Using Node Debugger

```bash
# Add `debugger;` statement to your code
# Start with inspect flag
node --inspect-brk src/index.js

# Connect Chrome to debug at chrome://inspect
```

### 3. Using `node-inspect`

```bash
node inspect src/index.js

# Common commands:
# c - continue execution
# n - next line
# s - step into function
# o - step out of function
# repl - enter REPL to inspect variables
```

## File Operations

### 1. Finding and Manipulating Files

```bash
# Find JavaScript files
find . -name "*.js" | grep -v "node_modules"

# Search inside JavaScript files
grep -r "function myFunction" --include="*.js" .

# With ripgrep (faster)
rg "function myFunction" -t js

# Find and edit with Neovim
nvim $(find . -name "*.js" | grep "controller")
```

### 2. Quick File Editing

```bash
# Find and edit with fzf integration
vf  # Custom function that uses fzf with preview
```

## Project Management

### 1. Documentation

```bash
# Generate documentation with JSDoc
npx jsdoc src/ -d docs/

# Generate README from template
npx readme-md-generator
```

### 2. Running Applications

```bash
# Run directly
node src/index.js

# With npm scripts
npm start
npm run dev

# With nodemon for auto-reloading
npx nodemon src/index.js
```

### 3. Profiling

```bash
# CPU profiling
node --prof src/index.js
node --prof-process isolate-*.log > profile.txt

# Memory snapshots
# Add in code: heapdump.writeSnapshot('heap.heapsnapshot');
# Then analyze in Chrome DevTools
```

## Docker Integration

```bash
# Run Node.js in Docker
docker run -it --rm -v $(pwd):/app node-dev

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
export DEBUG=true
export API_KEY="your-key"

# Or use .env file with dotenv
echo 'DEBUG=true' > .env
echo 'API_KEY=your-key' >> .env

# In JavaScript
// require('dotenv').config();
```

## Common npm Scripts

Add these to your `package.json`:

```json
"scripts": {
  "start": "node src/index.js",
  "dev": "nodemon src/index.js",
  "test": "jest",
  "test:watch": "jest --watch",
  "lint": "eslint src/",
  "format": "prettier --write \"src/**/*.js\"",
  "build": "webpack --mode production"
}
```

## TypeScript Integration

```bash
# Initialize TypeScript project
npx tsc --init

# Compile TypeScript
npx tsc

# Run with ts-node
npx ts-node src/index.ts

# Type checking only
npx tsc --noEmit
```

## Frontend Development (if applicable)

```bash
# Serve static files
npx http-server -p 8080

# Bundle with webpack
npx webpack --mode development

# Bundle with esbuild (faster)
npx esbuild src/index.js --bundle --outfile=dist/bundle.js
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

1. Start or attach to JavaScript tmux session: `mkjs project` or `tmux attach -t project`
2. Pull latest changes: `gpl`
3. Install/update dependencies: `npm install`
4. Run tests to ensure everything works: `npm test`
5. Start coding with Neovim: `nvim src/file.js`
6. Test changes in REPL: Switch to REPL window with `Ctrl+a 2`
7. Start development server: `npm run dev`
8. Commit changes regularly: `gs`, `ga`, `gc "Message"`
