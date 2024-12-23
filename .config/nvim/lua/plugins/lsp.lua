return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
    },
    config = function()      
      -- Reserve space in the gutter
      vim.opt.signcolumn = 'yes'
      
      -- Python paths
      vim.g.python_host_prog = '/usr/local/bin/python'
      vim.g.python3_host_prog = '~/.virtualenvs/neovim/bin/python'

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- LSP servers setup
      require("lspconfig").pylsp.setup({
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
      
      require("lspconfig").pyright.setup({
        capabilities = capabilities,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local wk = require("which-key")
          
          -- Register groups first
          wk.register({
            ["<leader>c"] = { buffer = event.buf, group = "Code" },
            ["<leader>g"] = { buffer = event.buf, group = "Go to" },
            ["<leader>r"] = { buffer = event.buf, group = "Refactor" },
          })
          
          -- Register all keymaps
          wk.register({
            ["<leader>D"] = { vim.lsp.buf.hover, "Show Documentation", buffer = event.buf },
            ["<leader>ca"] = { vim.lsp.buf.code_action, "Code Actions", buffer = event.buf },
            ["<leader>gd"] = { vim.lsp.buf.definition, "Go to Definition", buffer = event.buf },
            ["<leader>gh"] = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Header/Source", buffer = event.buf },
            ["<leader>gn"] = { vim.diagnostic.goto_next, "Next Diagnostic", buffer = event.buf },
            ["<leader>gp"] = { vim.diagnostic.goto_prev, "Previous Diagnostic", buffer = event.buf },
            ["<leader>gr"] = { vim.lsp.buf.references, "Find References", buffer = event.buf },
            ["<leader>rn"] = { vim.lsp.buf.rename, "Rename Symbol", buffer = event.buf },
          })
          
          -- Insert mode signature help (not part of which-key)
          vim.keymap.set("i", "<leader>h", vim.lsp.buf.signature_help, { buffer = event.buf })
        end,
      })
        end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "python-lsp-server",
        "pyright",
        "black",
        "flake8",
        "debugpy",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
    },
  },
}
