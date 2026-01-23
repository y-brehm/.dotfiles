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

      -- Python LSP setup (basedpyright + ruff)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        once = true,
        callback = function()
          local venv_utils = require("config.venv_utils")

          -- Helper function to detect Python virtual environment for LSP
          local function get_python_path()
            local cwd = vim.fn.getcwd()

            -- 1. Check for project-local venv (highest priority)
            local python_path = venv_utils.find_project_venv_python(cwd)
            if python_path then
              vim.notify("LSP using project venv: " .. python_path, vim.log.levels.INFO)
              return python_path
            end

            -- 2. Check for activated venv via VIRTUAL_ENV (but skip Neovim's host venv)
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              local neovim_venv = vim.fn.expand("$USERPROFILE") .. "\\.virtualenvs\\neovim"
              if not venv:match(neovim_venv:gsub("\\", "\\\\")) then
                local python_exe = is_windows and (venv .. "\\Scripts\\python.exe") or (venv .. "/bin/python")
                vim.notify("LSP using activated venv: " .. python_exe, vim.log.levels.INFO)
                return python_exe
              end
            end

            -- 3. Fallback to system Python
            vim.notify("LSP using system Python (no project venv found)", vim.log.levels.WARN)
            return "python"
          end

          local python_path = get_python_path()

          -- Extract venv information from python_path for basedpyright
          local venv_path = nil
          local venv_name = nil

          if python_path ~= "python" then
            local venv_dir = vim.fn.fnamemodify(python_path, ":h:h")
            venv_path = vim.fn.fnamemodify(venv_dir, ":h")
            venv_name = vim.fn.fnamemodify(venv_dir, ":t")
          end

          -- Basedpyright setup
          vim.lsp.config('basedpyright', {
            capabilities = capabilities,
            filetypes = { "python" },
            position_encoding = "utf-16",
            cmd = { "basedpyright-langserver", "--stdio" },
            root_markers = {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "pyrightconfig.json",
              ".git",
            },
            settings = {
              python = {
                pythonPath = python_path,
                venvPath = venv_path,
                venv = venv_name,
              },
              basedpyright = {
                typeCheckingMode = "standard",
                analysis = {
                  autoSearchPaths = true,
                  autoImportCompletions = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "workspace",
                },
              },
            }
          })
          vim.lsp.enable('basedpyright')

          -- Ruff LSP setup
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
              interpreter = { python_path },
              configuration = nil,
              configurationPreference = "filesystemFirst",
              lineLength = 120,
              lint = {
                enable = true,
                select = {
                  "F", "E", "W", "N", "UP", "B", "A", "C4", "T10",
                  "ISC", "ICN", "PIE", "PT", "RET", "SIM", "ARG",
                  "PTH", "PERF", "RUF",
                },
                ignore = {
                  "E501", "PLR0913", "PLR2004",
                },
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
        "basedpyright",
        "ruff",
        "debugpy",
        "lua-language-server",
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
