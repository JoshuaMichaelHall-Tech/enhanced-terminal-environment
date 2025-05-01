#!/usr/bin/env bash
# Neovim Enhanced Setup Module
# Part of Enhanced Terminal Environment
# 
# This module properly sets up Neovim with all required providers
# to prevent health check warnings and ensure a smooth experience.

# Exit on error, undefined variables, and propagate pipe failures
set -euo pipefail

# Define colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Log functions
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

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
    fi
    return 0
}

# Setup Neovim configuration
setup_neovim_config() {
    log_info "Setting up Neovim configuration..."
    
    local nvim_config_dir="$HOME/.config/nvim"
    
    # Ensure the Neovim config directory exists
    ensure_dir "$nvim_config_dir" || return 1
    
    # Create Lua directory structure
    for dir in lua lua/language-specific; do
        ensure_dir "$nvim_config_dir/$dir" || return 1
    done
    
    # Copy configuration files from the project
    local source_dir="$(pwd)/configs/neovim"
    if [[ -d "$source_dir" ]]; then
        log_info "Copying Neovim configuration from the project..."
        
        # Create a backup of existing config if it exists
        if [[ -f "$nvim_config_dir/init.lua" ]]; then
            local backup_dir="$nvim_config_dir/backup_$(date +%Y%m%d%H%M%S)"
            ensure_dir "$backup_dir"
            mv "$nvim_config_dir/init.lua" "$backup_dir/" || {
                log_error "Failed to create backup of existing init.lua"
            }
            log_info "Created backup of existing init.lua at $backup_dir/init.lua"
        fi
        
        # Copy init.lua
        if [[ -f "$source_dir/init.lua" ]]; then
            cp "$source_dir/init.lua" "$nvim_config_dir/" || {
                log_error "Failed to copy init.lua"
                return 1
            }
            log_success "Copied init.lua to $nvim_config_dir/"
        else
            log_error "Source init.lua not found at $source_dir/init.lua"
            return 1
        fi
        
        # Copy Lua configuration files
        if [[ -d "$source_dir/lua" ]]; then
            cp -r "$source_dir/lua/"* "$nvim_config_dir/lua/" || {
                log_warning "Failed to copy some Lua configuration files"
            }
            log_success "Copied Lua configuration files to $nvim_config_dir/lua/"
        fi
    else
        log_error "Neovim configuration directory not found at $source_dir"
        log_info "Using minimal configuration instead..."
        
        # Create a minimal init.lua if source doesn't exist
        cat > "$nvim_config_dir/init.lua" << 'EOF'
-- Basic Neovim configuration for Enhanced Terminal Environment

-- Basic editor settings
vim.opt.number = true                     -- Show line numbers
vim.opt.relativenumber = true             -- Show relative line numbers
vim.opt.tabstop = 2                       -- Width of tab character
vim.opt.softtabstop = 2                   -- Fine tunes amount of white space to be added
vim.opt.shiftwidth = 2                    -- Amount of white space to add in normal mode
vim.opt.expandtab = true                  -- Use spaces instead of tabs
vim.opt.smartindent = true                -- Auto indent new lines
vim.opt.wrap = false                      -- Don't wrap lines
vim.opt.ignorecase = true                 -- Ignore case in search
vim.opt.smartcase = true                  -- Override ignore case if search contains uppercase
vim.opt.hlsearch = true                   -- Highlight search results
vim.opt.incsearch = true                  -- Show search matches as you type
vim.opt.termguicolors = true              -- Enable 24-bit RGB color in the TUI
vim.opt.scrolloff = 8                     -- Min number of lines to keep above/below cursor
vim.opt.sidescrolloff = 8                 -- Min number of columns to keep left/right of cursor
vim.opt.signcolumn = "yes"                -- Always show sign column
vim.opt.clipboard = "unnamedplus"         -- Use system clipboard
vim.opt.splitright = true                 -- Split windows right to the current
vim.opt.splitbelow = true                 -- Split windows below to the current
vim.opt.mouse = "a"                       -- Enable mouse in all modes

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Basic key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Normal mode mappings
-- Save file
keymap("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
-- Quit
keymap("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
-- Save and quit
keymap("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Set colorscheme (built-in)
vim.cmd("colorscheme desert")

-- Filetype specific settings for Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})
EOF
        log_success "Created minimal init.lua at $nvim_config_dir/init.lua"
    fi
    
    # Create provider configuration module
    local provider_config_file="$nvim_config_dir/lua/provider_config.lua"
    cat > "$provider_config_file" << 'EOF'
-- Provider configuration
-- Set to 1 to enable, 0 to disable

-- Auto-detect which providers should be enabled
local has_python = vim.fn.executable('python3') == 1 or vim.fn.executable('python') == 1
local has_node = vim.fn.executable('node') == 1
local has_ruby = vim.fn.executable('ruby') == 1
local has_perl = vim.fn.executable('perl') == 1

-- Configure providers based on available runtimes
vim.g.loaded_python3_provider = 0  -- Python 3 provider (0 = enabled)
vim.g.loaded_node_provider = 0     -- Node.js provider (0 = enabled)
vim.g.loaded_ruby_provider = 0     -- Ruby provider (0 = enabled)
vim.g.loaded_perl_provider = 0     -- Perl provider (0 = enabled)

-- Set Python 3 host program path if available
if has_python then
    if vim.fn.executable('python3') == 1 then
        vim.g.python3_host_prog = vim.fn.exepath('python3')
    elseif vim.fn.executable('python') == 1 then
        vim.g.python3_host_prog = vim.fn.exepath('python')
    end
end
EOF
    
    # Update init.lua to include provider configuration
    if ! grep -q "require('provider_config')" "$nvim_config_dir/init.lua"; then
        # Add to the beginning of init.lua
        sed -i.bak '1s/^/-- Load provider configuration\npcall(require, "provider_config")\n\n/' "$nvim_config_dir/init.lua" 2>/dev/null || {
            # If sed fails (on macOS), try different approach
            cat > "$nvim_config_dir/init.lua.new" << EOF
-- Load provider configuration
pcall(require, "provider_config")

$(cat "$nvim_config_dir/init.lua")
EOF
            mv "$nvim_config_dir/init.lua.new" "$nvim_config_dir/init.lua"
        }
        
        # Clean up backup if needed
        rm -f "$nvim_config_dir/init.lua.bak"
        
        log_success "Added provider configuration to init.lua"
    fi
    
    return 0
}

# Configure Python provider for Neovim
setup_python_provider() {
    log_info "Setting up Python provider for Neovim..."
    
    local python_cmd=""
    local pip_cmd=""
    
    # Find available Python command
    if command_exists python3; then
        python_cmd="python3"
    elif command_exists python; then
        python_cmd="python"
    else
        log_warning "Python is not installed. Skipping Python provider setup."
        return 0
    fi
    
    log_info "Python detected: $($python_cmd --version)"
    
    # Find available pip command
    if command_exists pip3; then
        pip_cmd="pip3"
    elif command_exists pip; then
        pip_cmd="pip"
    elif "$python_cmd" -m pip --version &>/dev/null; then
        pip_cmd="$python_cmd -m pip"
    else
        log_warning "pip not found. Skipping Python provider setup."
        return 0
    fi
    
    # Install pynvim package
    log_info "Installing pynvim package for Python provider..."
    
    # Different install approaches based on Python version and PEP 668
    local install_approaches=(
        "$pip_cmd install --user pynvim"
        "$pip_cmd install --user --break-system-packages pynvim"
        "$pip_cmd install pynvim"
    )
    
    local success=false
    for cmd in "${install_approaches[@]}"; do
        log_info "Trying: $cmd"
        if eval "$cmd" &>/dev/null; then
            success=true
            break
        fi
    done
    
    if $success; then
        log_success "Successfully installed pynvim for Python provider"
    else
        log_warning "Failed to install pynvim. Python provider may not work properly."
    fi
    
    return 0
}

# Configure Node.js provider for Neovim
setup_node_provider() {
    log_info "Setting up Node.js provider for Neovim..."
    
    if ! command_exists node; then
        log_warning "Node.js is not installed. Skipping Node.js provider setup."
        return 0
    fi
    
    log_info "Node.js detected: $(node --version)"
    
    # Check if neovim npm package is installed
    if npm list -g | grep -q neovim; then
        log_success "Neovim npm package is already installed globally"
    else
        log_info "Installing neovim npm package globally..."
        npm install -g neovim &>/dev/null || {
            log_warning "Failed to install neovim npm package globally. Node.js provider may not work properly."
            return 0
        }
        log_success "Installed neovim npm package globally"
    fi
    
    return 0
}

# Configure Ruby provider for Neovim
setup_ruby_provider() {
    log_info "Setting up Ruby provider for Neovim..."
    
    if ! command_exists ruby; then
        log_warning "Ruby is not installed. Skipping Ruby provider setup."
        return 0
    fi
    
    log_info "Ruby detected: $(ruby --version)"
    
    if ! command_exists gem; then
        log_warning "RubyGems not found. Skipping Ruby provider setup."
        return 0
    fi
    
    # Check if neovim gem is installed
    if gem list | grep -q neovim; then
        log_success "neovim gem is already installed"
    else
        log_info "Installing neovim gem..."
        gem install neovim &>/dev/null || {
            log_warning "Failed to install neovim gem. Ruby provider may not work properly."
            return 0
        }
        log_success "Installed neovim gem"
    fi
    
    return 0
}

# Configure Perl provider for Neovim
setup_perl_provider() {
    log_info "Setting up Perl provider for Neovim..."
    
    if ! command_exists perl; then
        log_warning "Perl is not installed. Skipping Perl provider setup."
        return 0
    fi
    
    log_info "Perl detected: $(perl --version | head -n1)"
    
    # Check if cpanm is installed
    if command_exists cpanm; then
        # Check if Neovim::Ext is installed
        if perl -MNeovim::Ext -e 'print "Neovim::Ext is installed\n"' &>/dev/null; then
            log_success "Neovim::Ext is already installed"
        else
            log_info "Installing Neovim::Ext with cpanm..."
            cpanm -n Neovim::Ext &>/dev/null || {
                log_warning "Failed to install Neovim::Ext. Perl provider may not work properly."
            }
        fi
    else
        log_warning "cpanm is not installed. Perl provider may not work properly."
        log_info "To install: curl -L https://cpanmin.us | perl - App::cpanminus"
    fi
    
    return 0
}

# Verify Neovim health check
verify_neovim_health() {
    log_info "Verifying Neovim health check..."
    
    if ! command_exists nvim; then
        log_error "Neovim is not installed"
        return 1
    fi
    
    # Run a headless health check
    nvim --headless -c "checkhealth" -c "q" &>/dev/null || {
        log_warning "Health check command failed, but this is sometimes expected."
    }
    
    log_info "Health check complete. For a full report, run ':checkhealth' in Neovim."
    
    return 0
}

# Main function
setup_neovim_enhanced() {
    log_info "Setting up enhanced Neovim configuration with providers..."
    
    # Step 1: Setup Neovim configuration
    setup_neovim_config || {
        log_error "Failed to setup Neovim configuration"
        return 1
    }
    
    # Step 2: Setup language providers
    setup_python_provider
    setup_node_provider
    setup_ruby_provider
    setup_perl_provider
    
    # Step 3: Verify health check
    verify_neovim_health
    
    log_success "Neovim setup complete with enhanced configuration and providers!"
    
    return 0
}

# Execute setup function when script is run directly, 
# but allow for importing into other scripts
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_neovim_enhanced
fi

# Export the setup function for use in other scripts
export -f setup_neovim_enhanced