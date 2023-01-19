vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
    local is_bootstrap = false
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        is_bootstrap = true
        vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
    end

    use 'wbthomason/packer.nvim'

    use {
        {'nvim-telescope/telescope.nvim', tag = '0.1.0'},
        {'jvgrootveld/telescope-zoxide'},
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use 'navarasu/onedark.nvim'
    require('onedark').setup {
        style = 'darker'
    }
    require('onedark').load()

    use({'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'})

    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    }

    use {
        "puremourning/vimspector",
        cmd = { "VimspectorInstall", "VimspectorUpdate" },
        fn = { "vimspector#Launch()", "vimspector#ToggleBreakpoint", "vimspector#Continue" },
        config = function()
            require("plugin.vimspector").setup()
        end,
    }

    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end
    }

    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        tag = 'nightly'
    }

    use {
      "folke/todo-comments.nvim",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("todo-comments").setup{}
      end
    }

    use {
      "folke/twilight.nvim",
      config = function()
        require("twilight").setup {}
      end
    }

    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" },
    })

    if is_bootstrap then
        require('packer').sync()
    end

    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup()
      end
    }

    use {
        'jiangmiao/auto-pairs'
    }

end)

