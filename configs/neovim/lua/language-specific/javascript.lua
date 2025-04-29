-- JavaScript/Node.js specific Neovim configurations
-- Enhanced Terminal Environment

local M = {}

-- JavaScript/Node.js specific settings
function M.setup()
  -- Set local options for JavaScript files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json" },
    callback = function()
      -- Indentation
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
      
      -- Format on save
      vim.opt_local.formatoptions = vim.opt_local.formatoptions
        + "r"  -- Auto-insert comment leader after <Enter>
        + "o"  -- Auto-insert comment leader after o or O
        + "q"  -- Allow formatting of comments with gq
        + "j"  -- Remove comment leader when joining lines
        - "t"  -- Don't auto-wrap text
        
      -- JavaScript specific options
      vim.opt_local.conceallevel = 0
      
      -- Set maximum line length marker
      vim.opt_local.colorcolumn = "100"
    end,
  })
  
  -- Add JavaScript/Node.js specific key mappings
  local js_mappings = function()
    local buf = vim.api.nvim_get_current_buf()
    local opts = { noremap = true, silent = true, buffer = buf }
    
    -- Run current JavaScript file with Node.js
    vim.keymap.set("n", "<leader>rn", "<cmd>!node %<CR>", opts)
    
    -- Run with nodemon for auto-reload
    vim.keymap.set("n", "<leader>nm", "<cmd>!nodemon %<CR>", opts)
    
    -- Run npm scripts
    vim.keymap.set("n", "<leader>ns", "<cmd>!npm start<CR>", opts)
    vim.keymap.set("n", "<leader>nt", "<cmd>!npm test<CR>", opts)
    vim.keymap.set("n", "<leader>nd", "<cmd>!npm run dev<CR>", opts)
    
    -- Format with prettier
    vim.keymap.set("n", "<leader>fp", "<cmd>!npx prettier --write %<CR>", opts)
    
    -- Lint with ESLint
    vim.keymap.set("n", "<leader>el", "<cmd>!npx eslint %<CR>", opts)
  end
  
  -- Set up JavaScript buffer-local mappings when JavaScript file is opened
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    callback = js_mappings,
  })
  
  -- Add custom snippets (placeholder for future expansion)
  -- This can be expanded with a snippet plugin like LuaSnip
end

-- Detect if it's a Node.js project
function M.is_node_project()
  local package_json = vim.fn.findfile("package.json", ".;")
  return package_json ~= ""
end

-- Setup LSP for JavaScript (when plugins are installed)
function M.setup_lsp()
  -- Placeholder for LSP configuration
  -- This would be configured when Neovim is set up with LSP support
end

return M
