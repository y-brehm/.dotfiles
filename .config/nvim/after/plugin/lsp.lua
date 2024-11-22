-- Reserve a space in the gutter
-- This will avoid an annoying layout shift in the screen
vim.opt.signcolumn = 'yes'


local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>gn", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>gp", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<leader>h", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", '<leader>gh', '<cmd>ClangdSwitchSourceHeader<cr>')
    end,
})

-- Python
vim.g.python_host_prog = '/usr/local/bin/python'
vim.g.python3_host_prog = '~/.virtualenvs/neovim/bin/python'

-- Set up nvim-cmp.
local cmp = require'cmp'
local luasnip = require 'luasnip'

cmp.setup({
    window = {
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    }),
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- Function to expand snippets
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip'}
    },
    {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').pylsp.setup ({
  capabilities = capabilities,
  settings = {
    pylsp = {
        plugins = {
            pycodestyle = {
                maxLineLength = 100
                }
            }
        }
    },
})

require'lspconfig'.pyright.setup{}

local lspkind = require('lspkind')
cmp.setup {
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol',
      maxwidth = 50,
      ellipsis_char = '...',
    })
  }
}
