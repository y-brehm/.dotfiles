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

    -- Add folding range capability for ufo
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }

    -- ### LSP servers setup using new vim.lsp.config() API (Neovim 0.11+) ###

    -- Removed pylsp as Basedpyright + Ruff provide all needed functionality
    vim.lsp.config('basedpyright', {
      capabilities = capabilities,
      settings = {
        basedpyright = {
          -- Use basic type checking to reduce third-party library warnings
          typeCheckingMode = "basic", -- Use basic mode to reduce noise from libraries
          
          -- Fine-tune diagnostic levels for practical development
          diagnosticSeverityOverrides = {
            reportGeneralTypeIssues = "warning",           -- Type checking errors
            reportPropertyTypeMismatch = "warning",        -- Property type mismatch
            reportFunctionMemberAccess = "warning",        -- Incorrect function member access
            reportMissingImports = "error",                -- Missing imports
            reportUndefinedVariable = "error",             -- Undefined variables
            reportAssignmentType = "warning",              -- Assignment type issues
            reportArgumentType = "warning",                -- Argument type mismatches
            reportReturnType = "warning",                  -- Return type issues
            reportMissingTypeStubs = "none",               -- Missing type stubs (disabled for 3rd party libs)
            reportUnknownMemberType = "none",              -- Unknown types in libraries (disabled)
            reportUnknownArgumentType = "none",            -- Unknown argument types (disabled)
            reportUnknownLambdaType = "none",              -- Unknown lambda types (disabled)
            reportUnknownVariableType = "none",            -- Unknown variable types (disabled)
            reportUnknownParameterType = "none",           -- Unknown parameter types (disabled)
            reportMissingTypeArgument = "warning",         -- Missing generics
            reportUnnecessaryIsInstance = "none",          -- Disable - handled by Ruff
            reportUnnecessaryCast = "none",                -- Disable - handled by Ruff
            reportUnnecessaryComparison = "warning",       -- Keep - not well covered by Ruff
            reportConstantRedefinition = "error",          -- Redefining constants
            reportIncompatibleMethodOverride = "error",    -- Incorrect method overrides
            reportIncompatibleVariableOverride = "error",  -- Incorrect variable overrides
            reportOverlappingOverload = "warning",         -- Overlapping overloads
            reportUninitializedInstanceVariable = "warning", -- Uninitialized instance vars
            reportCallInDefaultInitializer = "warning",    -- Calls in default initializers
            reportUnnecessaryTypeIgnoreComment = "warning", -- Unnecessary # type: ignore
            reportMatchNotExhaustive = "warning",          -- Non-exhaustive match statements
            reportShadowedImports = "warning",             -- Shadowed imports
            reportPrivateUsage = "warning",                -- Using private members
            -- Relaxed settings for convenience
            reportMissingParameterType = "none",           -- Allow untyped parameters in simple functions
            reportMissingTypeAnnotation = "none",          -- Allow missing annotations in simple cases
            reportUnusedImport = "none",                   -- Disable - handled by Ruff
            reportUnusedClass = "none",                    -- Disable - handled by Ruff
            reportUnusedFunction = "none",                 -- Disable - handled by Ruff
            reportUnusedVariable = "none",                 -- Disable - handled by Ruff
            reportUnusedParameter = "none",                -- Disable - handled by Ruff ARG002
            reportDuplicateImport = "none",                -- Disable - handled by Ruff
          },

          -- Enable additional analysis features
          analysis = {
            autoSearchPaths = true,
            autoImportCompletions = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",  -- Check entire workspace
          },
        },
        python = {
          analysis = {
            typeCheckingMode = "basic",
          }
        }
      }
    })
    vim.lsp.enable('basedpyright')

    -- Ruff LSP setup for formatting and linting (using built-in LSP server)
    -- NOTE: Ruff automatically detects and uses project-specific configuration from:
    -- 1. ruff.toml in project root
    -- 2. .ruff.toml in project root
    -- 3. pyproject.toml with [tool.ruff] section
    -- The settings below serve as fallbacks when no project config exists
    vim.lsp.config('ruff', {
      capabilities = capabilities,
      cmd = { "ruff", "server", "--preview" },  -- Use the built-in LSP server with preview features
      init_options = {
        settings = {
          -- These settings are used as FALLBACKS when no project config exists
          -- Project-specific ruff.toml or pyproject.toml takes precedence
          -- Configuration search behavior
          configuration = nil,  -- Let Ruff auto-detect config files
          configurationPreference = "filesystemFirst", -- Prefer project config over LSP settings
          -- Workspace settings (only applied if no project config found)
          lineLength = 120,  -- Fallback line length
          -- Linting fallbacks - comprehensive rules for projects without config
          lint = {
            enable = true,
            -- Default rule selection for projects without ruff.toml
            select = {
              "F",     -- Pyflakes (errors and warnings)
              "E",     -- pycodestyle errors
              "W",     -- pycodestyle warnings
              -- "I",  -- isort (import sorting) - removed as requested
              "N",     -- pep8-naming
              "UP",    -- pyupgrade (Python version upgrade suggestions)
              "B",     -- flake8-bugbear
              "A",     -- flake8-builtins
              "C4",    -- flake8-comprehensions
              "T10",   -- flake8-debugger
              "ISC",   -- flake8-implicit-str-concat
              "ICN",   -- flake8-import-conventions
              "PIE",   -- flake8-pie
              "PT",    -- flake8-pytest-style
              "RET",   -- flake8-return
              "SIM",   -- flake8-simplify
              "ARG",   -- flake8-unused-arguments
              "PTH",   -- flake8-use-pathlib
              -- "PL", -- Pylint (basic checks) - removed as it includes too many methods/variables rules
              "PERF",  -- Performance linting
              "RUF",   -- Ruff-specific rules
            },
            -- Default ignores for projects without config
            ignore = {
              "E501",   -- Line too long (handled by formatter)
              "PLR0913", -- Too many arguments
              "PLR2004", -- Magic value comparison
            },
          },
          -- Format fallbacks
          format = {
            -- Only used if project has no format config
            quoteStyle = "double",
            indentStyle = "space",
          },
          -- Allow Ruff to auto-fix issues
          fixable = { "ALL" },
          organizeImports = true,
        }
      }
    })
    vim.lsp.enable('ruff')

    vim.lsp.config('lua_ls', {
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
    vim.lsp.enable('lua_ls')

    -- C++ (clangd) setup
    vim.lsp.config('clangd', {
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
    vim.lsp.enable('clangd')

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
        
        -- Custom format function that calls Ruff directly for Python files
        local function format_buffer()
          local filetype = vim.bo.filetype
          
          if filetype == "python" then
            -- Save current cursor position
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            
            -- Run ruff format with import sorting on the current file
            local filepath = vim.fn.expand("%:p")
            vim.cmd("silent! write")  -- Save file first
            
            -- Run ruff check --fix to organize imports and fix issues
            vim.fn.system({"ruff", "check", "--fix", "--select", "I", filepath})
            
            -- Run ruff format to format the code
            vim.fn.system({"ruff", "format", filepath})
            
            -- Reload the buffer to show changes
            vim.cmd("edit!")
            
            -- Restore cursor position
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            
            vim.notify("Formatted with Ruff", vim.log.levels.INFO)
          else
            -- For non-Python files, use standard LSP formatting
            vim.lsp.buf.format({ async = false })
          end
        end
        
        -- Override the format keybinding for this buffer
        vim.keymap.set("n", "<leader>lfb", format_buffer, { buffer = event.buf, desc = "[l]sp [f]ormat [b]uffer" })
      end,
    })
  end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate", -- Update Mason registry
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "debugpy",
        "lua-language-server",
        "clangd",
        "clang-format",
        "cmake-language-server",
        "codelldb",
        "ty",
      },
      -- Configure Python path for Mason on Windows
      PATH = "prepend",
    },
    config = function(_, opts)
      -- Set up Python for Mason on Windows
      local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
      if is_windows then
        local home = vim.fn.expand('$USERPROFILE')
        local venv_python = home .. '\\.virtualenvs\\neovim\\Scripts\\python.exe'
        
        -- Check if virtualenv Python exists, otherwise use system Python
        if vim.fn.filereadable(venv_python) == 1 then
          vim.env.VIRTUAL_ENV = home .. '\\.virtualenvs\\neovim'
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
    "nvim-neo-tree/neo-tree.nvim",
    -- "simonmclean/triptych.nvim"
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
}
