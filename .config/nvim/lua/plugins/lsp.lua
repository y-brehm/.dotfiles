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


    -- ### LSP servers setup ###

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

    require("lspconfig").basedpyright.setup({
      capabilities = capabilities,
      settings = {
        basedpyright = {
          -- Control diagnostic levels - options are "error", "warning", "information", or "none"
          diagnosticSeverityOverrides = {
            reportGeneralTypeIssues = "warning",       -- Type checking errors
            reportPropertyTypeMismatch = "warning",    -- Property type mismatch
            reportMissingTypeStubs = "information",    -- Missing type stubs
            reportUnknownMemberType = "information",   -- Unknown member types
            reportMissingTypeArgument = "warning",     -- Missing type arguments
            reportUntypedFunctionDecorator = "none",   -- Disable diagnostics for untyped decorators
            reportMissingParameterType = "none",       -- Disable diagnostics for missing parameter types
            reportMissingTypeAnnotation = "none",      -- Disable diagnostics for missing type annotations
          },

          -- Enable/disable type checking features
          typeCheckingMode = "basic", -- Options: "off", "basic", "standard", "strict"
        }
      }
    })

    require("lspconfig").lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim", "require" }, -- Recognize 'vim' as a global to avoid warnings
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
            checkThirdParty = false, -- Disable third-party library checking
          },
          telemetry = {
            enable = false, -- Disable telemetry
          },
        },
      },
    })

    -- C++ (clangd) setup
    require("lspconfig").clangd.setup({
      capabilities = capabilities,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
      init_options = {
        -- Use compile_commands.json from build directory if available
        compilationDatabaseDirectory = "build",
        index = {
          threads = 0, -- Use all available threads
        },
        clangTidy = {
          useBuildPath = true,
        },
      },
    })


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
        "basedpyright",
        "black",
        "flake8",
        "debugpy",
        "lua-language-server",
        "clangd",
        "clang-format",
        "cmake-language-server",
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
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
    -- Uncomment whichever supported plugin(s) you use
    --"nvim-tree/nvim-tree.lua",
    "nvim-neo-tree/neo-tree.nvim",
    -- "simonmclean/triptych.nvim"
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
}
