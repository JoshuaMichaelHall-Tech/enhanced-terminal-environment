-- Ruby specific Neovim configurations
-- Enhanced Terminal Environment

local M = {}

-- Ruby specific settings
function M.setup()
  -- Set local options for Ruby files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "ruby", "eruby", "rake", "rb" },
    callback = function()
      -- Indentation (Ruby convention)
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
      vim.opt_local.autoindent = true
      
      -- Line length marker at 100 chars (common Ruby convention)
      vim.opt_local.colorcolumn = "100"
      
      -- Highlight trailing whitespace
      vim.opt_local.list = true
      vim.opt_local.listchars = "tab:→ ,trail:·,extends:▶,precedes:◀"
      
      -- Text wrapping
      vim.opt_local.formatoptions = vim.opt_local.formatoptions
        + "r"  -- Auto-insert comment leader after <Enter>
        + "o"  -- Auto-insert comment leader after o or O
        + "q"  -- Allow formatting of comments with gq
        + "j"  -- Remove comment leader when joining lines
        - "t"  -- Don't auto-wrap text
        
      -- Set commentstring for Ruby
      vim.opt_local.commentstring = "# %s"
    end,
  })
  
  -- Add Ruby specific key mappings
  local ruby_mappings = function()
    local buf = vim.api.nvim_get_current_buf()
    local opts = { noremap = true, silent = true, buffer = buf }
    
    -- Run current Ruby file
    vim.keymap.set("n", "<leader>rr", "<cmd>!ruby %<CR>", opts)
    
    -- Run with bundle exec
    vim.keymap.set("n", "<leader>be", "<cmd>!bundle exec ruby %<CR>", opts)
    
    -- Run RSpec tests
    vim.keymap.set("n", "<leader>rs", "<cmd>!bundle exec rspec<CR>", opts)
    
    -- Run current spec file
    vim.keymap.set("n", "<leader>sf", "<cmd>!bundle exec rspec %<CR>", opts)
    
    -- Format with Rubocop
    vim.keymap.set("n", "<leader>rc", "<cmd>!bundle exec rubocop -a %<CR>", opts)
    
    -- Run Rails console
    vim.keymap.set("n", "<leader>rc", "<cmd>!bundle exec rails console<CR>", opts)
    
    -- Run Rails server
    vim.keymap.set("n", "<leader>rs", "<cmd>!bundle exec rails server<CR>", opts)
    
    -- Run migrations
    vim.keymap.set("n", "<leader>rm", "<cmd>!bundle exec rails db:migrate<CR>", opts)
  end
  
  -- Set up Ruby buffer-local mappings when Ruby file is opened
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "ruby", "eruby", "rake", "rb" },
    callback = ruby_mappings,
  })
  
  -- Add custom snippets (placeholder for future expansion)
  -- This can be expanded with a snippet plugin like LuaSnip
end

-- Detect if it's a Ruby project
function M.is_ruby_project()
  local has_rb_files = vim.fn.glob("*.rb", false, true)[1] ~= nil
  local has_gemfile = vim.fn.filereadable("Gemfile") == 1
  local has_gems_rb = vim.fn.filereadable("gems.rb") == 1
  local has_rakefile = vim.fn.filereadable("Rakefile") == 1
  
  return has_rb_files or has_gemfile or has_gems_rb or has_rakefile
end

-- Detect if it's a Rails project
function M.is_rails_project()
  local has_routes = vim.fn.filereadable("config/routes.rb") == 1
  local has_app_dir = vim.fn.isdirectory("app") == 1
  local has_config_dir = vim.fn.isdirectory("config") == 1
  
  return has_routes and has_app_dir and has_config_dir
end

-- Setup RVM (Ruby Version Manager)
function M.setup_rvm()
  -- Check for RVM
  local rvm_path = vim.fn.expand("$HOME/.rvm/bin/rvm")
  if vim.fn.executable(rvm_path) == 1 then
    -- Get the Ruby version for the current project
    local rvm_info = vim.fn.system("source " .. rvm_path .. " && rvm current")
    vim.g.ruby_host_prog = vim.fn.trim(rvm_info)
  end
end

-- Setup LSP for Ruby (when plugins are installed)
function M.setup_lsp()
  -- Placeholder for LSP configuration
  -- This would be configured when Neovim is set up with LSP support
end

return M
