return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local lspkind = require('lspkind')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            ellipsis_char = '...',
          })
        }
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {'lervag/vimtex'},
  {
    "nvimtools/none-ls.nvim",  -- note: null-ls was moved to nvimtools/none-ls.nvim
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- Ruff is handled by its LSP server instead
          null_ls.builtins.formatting.clang_format.with({
            extra_args = function()
              local cwd = vim.fn.getcwd()
              local project_clang_format = cwd .. "/.clang-format"
              local nvim_clang_format = vim.fn.stdpath("config") .. "/clang-format/.clang-format"
              if vim.fn.filereadable(project_clang_format) == 1 then
                vim.notify("Using project .clang-format: " .. project_clang_format, vim.log.levels.INFO)
                return { "--style=file:" .. project_clang_format }
              elseif vim.fn.filereadable(nvim_clang_format) == 1 then
                vim.notify("Using nvim config .clang-format: " .. nvim_clang_format, vim.log.levels.INFO)
                return { "--style=file:" .. nvim_clang_format }
              else
                vim.notify("No .clang-format found, using Google style fallback", vim.log.levels.WARN)
                return { "--style=Google" }
              end
            end,
          }),
        },
      })

      -- Format keybinding moved to lsp.lua to handle Ruff import sorting
    end,
  },
}
