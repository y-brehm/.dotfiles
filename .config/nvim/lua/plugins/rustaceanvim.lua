return {
  {
    'mrcjkb/rustaceanvim',
    version = '^7', -- Recommended to use the latest stable version
    lazy = false,   -- Already lazy by design (filetype plugin)
    ft = { 'rust' },

    init = function()
      -- Configure rustaceanvim before it loads
      -- IMPORTANT: This must be in init, not config
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          -- Options for opening URLs
          executor = 'termopen', -- can be quickfix, termopen, toggleterm, vimux

          -- Options for viewing crate graph
          crate_graph = {
            enabled_graphviz_backends = { 'x11' },
          },
        },

        -- LSP configuration
        server = {
          -- Standalone file support (e.g., single Rust file not in a project)
          standalone = true,

          -- rust-analyzer settings
          settings = {
            ['rust-analyzer'] = {
              -- Enable check on save
              checkOnSave = true,

              -- Configure the check command (use clippy instead of cargo check)
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },

              -- Cargo settings
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },

              -- Proc macro settings
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },

              -- Completion settings
              completion = {
                postfix = {
                  enable = true,
                },
                autoimport = {
                  enable = true,
                },
              },

              -- Inlay hints
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "never",
                },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "never",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },

              -- Diagnostics
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
            },
          },
        },

        -- DAP configuration (integrates with your existing nvim-dap setup)
        dap = {
          -- Automatically load DAP configurations when LSP attaches
          autoload_configurations = true,
          -- Don't override adapter config - use the existing codelldb from dap.lua
        },
      }
    end,
  },
}
