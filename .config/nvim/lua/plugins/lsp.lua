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
      
     -- Detect OS and set appropriate Python paths
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

    if is_windows then
      -- Windows paths
      local home = vim.fn.expand('$USERPROFILE')
      vim.g.python3_host_prog = home .. '\\.virtualenvs\\neovim\\Scripts\\python.exe'
      -- Python 2 is likely not needed, but if you want to set it:
      -- vim.g.python_host_prog = 'C:\\Path\\to\\Python2\\python.exe'
    else
      -- Unix paths (keep your original settings)
      vim.g.python_host_prog = '/usr/local/bin/python'
      vim.g.python3_host_prog = '~/.virtualenvs/neovim/bin/python'
    end


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
      
    -- Use the correct Python language server based on platform
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
      -- Setup basedpyright on Windows
      require("lspconfig").basedpyright.setup({
        capabilities = capabilities,
      })
    else
      -- Setup pyright on non-Windows platforms
      require("lspconfig").pyright.setup({
        capabilities = capabilities,
      })
    end

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local wk = require("which-key")
          
          -- Register all keymaps using the new format
          wk.add({
            -- Groups
            { "<leader>c", name = "Code" },
            { "<leader>g", name = "Goto" },
            { "<leader>r", name = "Refactor" },
            
            -- Individual mappings
            { "<leader>D", vim.lsp.buf.hover, desc = "Show Documentation" },
            { "ca", vim.lsp.buf.code_action, desc = "Code Actions" },
            { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
            { "gh", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Header/Source" },
            { "gn", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
            { "gp", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
            { "gr", vim.lsp.buf.references, desc = "Find References" },
            { "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" }
          }, { buffer = event.buf })
          
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
        vim.fn.has('win32') == 1 and "basedpyright" or "pyright",
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
