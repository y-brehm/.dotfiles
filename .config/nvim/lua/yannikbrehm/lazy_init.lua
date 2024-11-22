local is_mac = vim.loop.os_uname().sysname == "Darwin"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup(
{
    'nvim-lua/plenary.nvim',
    -- lsp
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'VonHeikemen/lsp-zero.nvim',
    'neovim/nvim-lspconfig',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'jose-elias-alvarez/null-ls.nvim',
    --appearance
    { 
        "catppuccin/nvim", 
        name = "catppuccin", 
        priority = 1000 
    },
    'nvim-tree/nvim-web-devicons',
    'echasnovski/mini.icons',
    'lewis6991/gitsigns.nvim',
    -- autocompletion
    'onsails/lspkind.nvim',
    'github/copilot.vim',
    'windwp/nvim-autopairs',
    'rmagatti/goto-preview',
    'L3MON4D3/LuaSnip',
    'rafamadriz/friendly-snippets',
    -- building
    'lervag/vimtex',
    -- debugging
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',
    'jay-babu/mason-nvim-dap.nvim',
    'antoinemadec/FixCursorHold.nvim',
    --  testing
    'nvim-neotest/nvim-nio',
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
      }
    },
    -- terminal
    'akinsho/toggleterm.nvim',
    --tools
    'kdheepak/lazygit.nvim',
    'RRethy/vim-illuminate',
    'nvim-tree/nvim-tree.lua',
    'rhysd/vim-clang-format',
    'folke/todo-comments.nvim',
    'folke/zen-mode.nvim',
    'nvim-pack/nvim-spectre',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
    'jvgrootveld/telescope-zoxide',
    'nvim-treesitter/nvim-treesitter',
    'folke/twilight.nvim',
    'stevearc/oil.nvim',
    {
      "goolord/alpha-nvim",
      config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.config)
      end
    },
    {
      "folke/which-key.nvim", event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {}
    },
})

require('gitsigns').setup()
require('twilight').setup()
require('todo-comments').setup()
require('mason').setup()
require("mason-lspconfig").setup()
require('nvim-autopairs').setup()
require("oil").setup()
require("mason-nvim-dap").setup({
    ensure_installed = { "python" },
    handlers = {},
})

require("neotest").setup({
  adapters = {
    require("neotest-python")({
        runner = "pytest",
      -- Add a Python test file detection function
      is_test_file = function(file_path)
        local file_ext = vim.fn.fnamemodify(file_path, ":e")
        return file_ext == "py" and (
          vim.fn.fnamemodify(file_path, ":t"):match("^test_.*%.py$") or
          vim.fn.fnamemodify(file_path, ":t"):match(".*_test%.py$")
        )
        end,
    }),
  }
})

local cmp_nvim_lsp = require "cmp_nvim_lsp"
local dap = require('dap')
