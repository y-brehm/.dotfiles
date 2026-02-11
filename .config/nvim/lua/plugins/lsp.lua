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
      else
        -- Unix paths
        vim.g.python_host_prog = '/usr/local/bin/python'
        vim.g.python3_host_prog = '~/.virtualenvs/neovim/bin/python'
      end

      -- Common LSP capabilities setup
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      -- ### Language-specific LSP setup (deferred until file type is opened) ###

      -- Python LSP setup (ty + ruff)
      -- Both auto-detect .venv in project root; configure via ty.toml / ruff.toml
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        once = true,
        callback = function()
          vim.lsp.config('ty', {
            capabilities = capabilities,
            filetypes = { "python" },
            position_encoding = "utf-16",
            root_markers = {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              ".git",
            },
            settings = {
              ty = {
                configuration = {
                  rules = {
                    all = "warn",
                  },
                },
              },
            },
          })
          vim.lsp.enable('ty')

          vim.lsp.config('ruff', {
            capabilities = capabilities,
            filetypes = { "python" },
            position_encoding = "utf-16",
            cmd = { "ruff", "server", "--preview" },
            root_markers = {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "ruff.toml",
              ".ruff.toml",
              ".git",
            },
            settings = {
              configurationPreference = "filesystemFirst",
              lineLength = 120,
              lint = {
                enable = true,
                select = {
                  "F", "E", "W",       -- pyflakes, pycodestyle errors/warnings
                  "N", "UP",            -- pep8-naming, pyupgrade
                  "B", "A", "C4",       -- bugbear, builtins, comprehensions
                  "T10", "T20",         -- debugger, print statements
                  "ISC", "ICN",         -- implicit-str-concat, import-conventions
                  "PIE", "PT",          -- misc lints, pytest-style
                  "RET", "SIM",         -- return, simplify
                  "ARG", "PTH",         -- unused-arguments, pathlib
                  "PERF", "RUF",        -- performance, ruff-specific
                  "S",                  -- bandit (security)
                  "C90",                -- mccabe (complexity)
                  "I",                  -- isort (import sorting)
                  "PL",                 -- pylint
                  "ERA",                -- commented-out code
                  "TRY",                -- exception handling
                  "FURB",               -- refurb (modern Python)
                  "LOG",                -- logging best practices
                  "FLY",                -- flynt (f-string conversion)
                },
                ignore = {},
              },
              format = {
                quoteStyle = "double",
                indentStyle = "space",
              },
              fixable = { "ALL" },
              organizeImports = true,
            }
          })
          vim.lsp.enable('ruff')
        end,
      })

      -- Lua LSP setup
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        once = true,
        callback = function()
          vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            filetypes = { "lua" },
            position_encoding = "utf-16",
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim", "require" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
          vim.lsp.enable('lua_ls')
        end,
      })

      -- C/C++ LSP setup (clangd) - disabled on Windows
      if not is_windows then
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "c", "cpp" },
          once = true,
          callback = function()
            vim.lsp.config('clangd', {
              capabilities = capabilities,
              filetypes = { "c", "cpp" },
              position_encoding = "utf-16",
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
                compilationDatabaseDirectory = "build",
                index = {
                  threads = 0,
                },
                clangTidy = {
                  useBuildPath = true,
                },
              },
            })
            vim.lsp.enable('clangd')
          end,
        })
      end

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local wk = require("which-key")

        -- Register all keymaps using the new format
        local keymaps = {
          -- Groups
          { "<leader>c", name = "Code" },
          { "<leader>g", name = "Goto" },
          { "<leader>r", name = "Refactor" },

          -- Individual mappings
          { "<leader>D", vim.lsp.buf.hover, desc = "Show Documentation" },
          { "ca", vim.lsp.buf.code_action, desc = "Code Actions" },
          { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
          { "gn", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
          { "gp", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
          { "gr", vim.lsp.buf.references, desc = "Find References" },
          { "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" }
        }

        -- Add clangd-specific keybinding only on non-Windows platforms
        if not is_windows then
          table.insert(keymaps, { "gh", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Header/Source" })
        end

        wk.add(keymaps, { buffer = event.buf })

        -- Override built-in gO with a proper description for which-key
        vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, { buffer = event.buf, desc = "Document Symbols" })

        -- Insert mode signature help (not part of which-key)
        vim.keymap.set("i", "<leader>h", vim.lsp.buf.signature_help, { buffer = event.buf })

        -- Format via LSP (ruff handles Python formatting + import sorting)
        local function format_buffer()
          vim.lsp.buf.format({
            async = false,
            filter = function(client) return client.name ~= "ty" end,
          })
        end

        -- Override the format keybinding for this buffer
        vim.keymap.set("n", "<leader>fb", format_buffer, { buffer = event.buf, desc = "[f]ormat [b]uffer" })
      end,
    })
  end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate", -- Update Mason registry
    opts = function()
      local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

      local ensure_installed = {
        "ty",
        "ruff",
        "debugpy",
        "lua-language-server",
        "rust-analyzer",
      }

      -- Only add C++ tools on non-Windows platforms
      if not is_windows then
        vim.list_extend(ensure_installed, {
          "clangd",
          "clang-format",
          "cmake-language-server",
          "codelldb",
        })
      end

      return {
        ensure_installed = ensure_installed,
        -- Configure Python path for Mason on Windows
        PATH = "prepend",
      }
    end,
    config = function(_, opts)
      -- Set up Python for Mason on Windows
      local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
      if is_windows then
        local home = vim.fn.expand('$USERPROFILE')
        local venv_python = home .. '\\.virtualenvs\\neovim\\Scripts\\python.exe'

        -- Check if virtualenv Python exists, add to PATH for Mason
        -- Note: Do NOT set VIRTUAL_ENV here — it would cause ty/ruff to use
        -- the neovim venv instead of the project's .venv
        if vim.fn.filereadable(venv_python) == 1 then
          vim.env.PATH = home .. '\\.virtualenvs\\neovim\\Scripts;' .. vim.env.PATH
        end
      end

      require("mason").setup(opts)
      local mr = require("mason-registry")

      -- Refresh registry before installing
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if p and not p:is_installed() then
            p:install()
          end
        end
      end)
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
    --"nvim-neo-tree/neo-tree.nvim",
    -- "simonmclean/triptych.nvim"
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
}
