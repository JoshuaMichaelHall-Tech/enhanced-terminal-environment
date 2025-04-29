-- Python specific Neovim configurations
-- Enhanced Terminal Environment

local M = {}

-- Python specific settings
function M.setup()
  -- Set local options for Python files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      -- Indentation (PEP 8 compliant)
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.expandtab = true
      vim.opt_local.autoindent = true
      
      -- Line length marker at 88 chars (Black formatter default)
      vim.opt_local.colorcolumn = "88"
      
      -- Highlight trailing whitespace
      vim.opt_local.list = true
      vim.opt_local.listchars = "tab:→ ,trail:·,extends:▶,precedes:◀"
      
      -- Text wrapping
      vim.opt_local.textwidth = 88
      vim.opt_local.formatoptions = vim.opt_local.formatoptions
        + "r"  -- Auto-insert comment leader after <Enter>
        + "o"  -- Auto-insert comment leader after o or O
        + "q"  -- Allow formatting of comments with gq
        + "j"  -- Remove comment leader when joining lines
        - "t"  -- Don't auto-wrap text
    end,
  })
  
  -- Add Python specific key mappings
  local python_mappings = function()
    local buf = vim.api.nvim_get_current_buf()
    local opts = { noremap = true, silent = true, buffer = buf }
    
    -- Run current Python file
    vim.keymap.set("n", "<leader>rp", "<cmd>!python %<CR>", opts)
    
    -- Run pytest in current directory
    vim.keymap.set("n", "<leader>pt", "<cmd>!pytest<CR>", opts)
    
    -- Run current test file
    vim.keymap.set("n", "<leader>pf", "<cmd>!pytest %<CR>", opts)
    
    -- Format with Black
    vim.keymap.set("n", "<leader>fb", "<cmd>!black %<CR>", opts)
    
    -- Lint with flake8
    vim.keymap.set("n", "<leader>fl", "<cmd>!flake8 %<CR>", opts)
    
    -- Import sorting with isort
    vim.keymap.set("n", "<leader>is", "<cmd>!isort %<CR>", opts)
    
    -- Type checking with mypy
    vim.keymap.set("n", "<leader>my", "<cmd>!mypy %<CR>", opts)
  end
  
  -- Set up Python buffer-local mappings when Python file is opened
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = python_mappings,
  })
  
  -- Virtual environment detection
  vim.g.python3_host_prog = vim.fn.exepath("python3")
end

-- Detect if it's a Python project
function M.is_python_project()
  local has_py_files = vim.fn.glob("*.py", false, true)[1] ~= nil
  local has_requirements = vim.fn.filereadable("requirements.txt") == 1
  local has_setup_py = vim.fn.filereadable("setup.py") == 1
  local has_pyproject = vim.fn.filereadable("pyproject.toml") == 1
  
  return has_py_files or has_requirements or has_setup_py or has_pyproject
end

-- Setup Python virtual environment
function M.setup_venv()
  -- Check for virtual environments
  local venv_paths = {
    vim.fn.getcwd() .. "/venv",
    vim.fn.getcwd() .. "/.venv",
    vim.fn.expand("$HOME") .. "/.virtualenvs/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
  }
  
  for _, path in ipairs(venv_paths) do
    local python_path = path .. "/bin/python"
    if vim.fn.executable(python_path) == 1 then
      vim.g.python3_host_prog = python_path
      break
    end
  end
end

-- Setup LSP for Python (when plugins are installed)
function M.setup_lsp()
  -- Placeholder for LSP configuration
  -- This would be configured when Neovim is set up with LSP support
end

return M
