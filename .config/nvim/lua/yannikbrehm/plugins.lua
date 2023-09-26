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
vim.g.mapleader = " "

require("lazy").setup(
{
    'nvim-treesitter/nvim-treesitter',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
    'jvgrootveld/telescope-zoxide',
    'nvim-lua/plenary.nvim',
    'nvim-pack/nvim-spectre',
    'VonHeikemen/lsp-zero.nvim',
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    'folke/todo-comments.nvim',
    'folke/twilight.nvim',
    'lewis6991/gitsigns.nvim',
    'rhysd/vim-clang-format',
    -- autocompletion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'onsails/lspkind.nvim',
    'github/copilot.vim',
    'windwp/nvim-autopairs',
    'rmagatti/goto-preview',
    'RRethy/vim-illuminate',
    'L3MON4D3/LuaSnip',
    -- debugging
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',
    "jay-babu/mason-nvim-dap.nvim",
    'antoinemadec/FixCursorHold.nvim',
    'nvim-neotest/neotest',
    'nvim-neotest/neotest-python',
    -- colourschemes
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

require('gitsigns').setup()
require('mason').setup()
require('nvim-autopairs').setup()
require("mason-nvim-dap").setup({
    ensure_installed = { "python", "cppdbg" },
    handlers = {},
})
require("neotest").setup({
  adapters = {
    require("neotest-python")({
        runner = "pytest",
    })
  }
})

local cmp_nvim_lsp = require "cmp_nvim_lsp"

require("lspconfig").clangd.setup {
  on_attach = on_attach,
  capabilities = cmp_nvim_lsp.default_capabilities(),
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

