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
    'VonHeikemen/lsp-zero.nvim',
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    'folke/todo-comments.nvim',
    'folke/twilight.nvim',
    'lewis6991/gitsigns.nvim',
    'Pocco81/auto-save.nvim',
    'rhysd/vim-clang-format',
    {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
    -- autocompletion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'rafamadriz/friendly-snippets',
    'onsails/lspkind.nvim',
    'github/copilot.vim',
    'windwp/nvim-autopairs', -- Autopairs, integrates with cmp
    'rmagatti/goto-preview',
    'RRethy/vim-illuminate',
    -- debugging
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',
    -- colourschemes
    --'tiagovla/tokyodark.nvim',
    --'AlexvZyl/nordic.nvim',
    'folke/tokyonight.nvim',
})

require('bufferline').setup{}
require('gitsigns').setup()
require('mason').setup()
require('auto-save').setup()
require('goto-preview').setup {}

--colour schemes
--vim.g.tokyodark_color_gamma = "0.8"
--vim.cmd[[colorscheme tokyodark]]
--require('nordic').load()
vim.cmd[[colorscheme tokyonight]]
