-- Neovim Keymaps for Enhanced Terminal Environment
-- Contains keyboard shortcuts and mappings

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = ","

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

-- Insert mode mappings
keymap("i", "jk", "<ESC>", opts)  -- Quick escape from insert mode

-- Language specific mappings
-- Python
keymap("n", "<leader>rp", "<cmd>!python %<CR>", { desc = "Run Python file" })

-- JavaScript/Node.js
keymap("n", "<leader>rn", "<cmd>!node %<CR>", { desc = "Run Node.js file" })

-- Ruby
keymap("n", "<leader>rr", "<cmd>!ruby %<CR>", { desc = "Run Ruby file" })

-- Terminal mappings
keymap("t", "<Esc>", "<C-\\><C-n>", opts)  -- Exit terminal mode
keymap("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Open terminal" })
