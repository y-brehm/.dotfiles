local lsp = require('lsp-zero')
lsp.preset('recommended')
lsp.ensure_installed({
    'clangd',
    'pylsp',
    'cmake',
})

-- Python
vim.g.python_host_prog = '/usr/local/bin/python'
vim.g.python3_host_prog = '~/.virtualenvs/neovim/bin/python'

-- CPP
require'lspconfig'.clangd.setup{}

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	if client.name == "eslint" then
		vim.cmd.LspStop('eslint') return
	end

	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>gn", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<leader>gp", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<leader>h", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", '<leader>gh', '<cmd>ClangdSwitchSourceHeader<cr>')
end)

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    window = {
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
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

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['pylsp'].setup {
  capabilities = capabilities
}

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
