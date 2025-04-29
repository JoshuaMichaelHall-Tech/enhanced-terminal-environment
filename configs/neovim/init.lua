-- Minimal Neovim configuration for terminal environment learning
-- Focused on essential functionality without overwhelming options

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
vim.opt.undofile = true                   -- Enable persistent undo
vim.opt.updatetime = 300                  -- Faster completion
vim.opt.backup = false                    -- No backup file
vim.opt.writebackup = false               -- No backup file
vim.opt.showmode = false                  -- Don't show mode (displayed in statusline)
vim.opt.laststatus = 3                    -- Global statusline
vim.opt.completeopt = "menuone,noselect"  -- Completion options
vim.opt.cursorline = true                 -- Highlight current line

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

-- Window management
keymap("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
keymap("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current split" })

-- Buffer navigation
keymap("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Clear search highlight
keymap("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Better movement
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Text editing
keymap("n", "J", "mzJ`z", opts)  -- Keep cursor in place when joining lines
keymap("n", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
keymap("n", "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Visual mode mappings
keymap("v", "<", "<gv", opts)  -- Better indenting
keymap("v", ">", ">gv", opts)  -- Better indenting
keymap("v", "p", '"_dP', opts)  -- Don't overwrite register when pasting
keymap("v", "J", ":move '>+1<CR>gv=gv", opts)  -- Move text down
keymap("v", "K", ":move '<-2<CR>gv=gv", opts)  -- Move text up
keymap("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("v", "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Keep your cursor centered while searching
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Essential status line (no plugins required)
vim.cmd([[
set statusline=
set statusline+=\ %f                           " File name
set statusline+=%m                             " Modified flag
set statusline+=%r                             " Readonly flag
set statusline+=%h                             " Help buffer flag
set statusline+=%w                             " Preview window flag
set statusline+=%=                             " Switch to right side
set statusline+=%y                             " Filetype
set statusline+=\ %{&fileencoding?&fileencoding:&encoding} " File encoding
set statusline+=\ %p%%                         " Percentage through file
set statusline+=\ %l:%c                        " Line and column
]])

-- Optional: Add more advanced features as you progress
-- This section can be uncommented later in your learning journey

--[[
-- Bootstrap lazy.nvim plugin manager after 1-2 months of learning
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure essential plugins
require("lazy").setup({
  -- Colorscheme
  { "navarasu/onedark.nvim", lazy = false, priority = 1000 },
  
  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  
  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  
  -- Git integration
  { "lewis6991/gitsigns.nvim" },
  
  -- Treesitter for better syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  
  -- LSP Configuration
  { "neovim/nvim-lspconfig" },
  
  -- Auto completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
})
--]]

-- Filetype specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "javascript", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Set colorscheme (basic, no plugins required)
vim.cmd("colorscheme desert")
