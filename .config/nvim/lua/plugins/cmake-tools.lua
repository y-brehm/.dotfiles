return {
  "Civitasv/cmake-tools.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/overseer.nvim",
  },
  opts = {
    cmake_build_directory = "build",
    cmake_generate_compile_commands = true,
    cmake_use_preset = "auto",
    cmake_configure_on_edit = false,
    cmake_configure_on_variant_change = false,
    cmake_executor = { -- executor to use
      name = "terminal", -- Use built-in terminal executor
      opts = {
        direction = "horizontal",
        focus = false,
      },
    },
    cmake_runner = { -- runner to use
      name = "terminal", -- Use built-in terminal executor
      opts = {
        direction = "horizontal",
        focus = false,
      },
    },
    cmake_debugger = {
      name = "dap",
      opts = {
        setup_dap_config = function(dap_config)
          dap_config.type = "codelldb"
          return dap_config
        end,
      },
    },
    cmake_notifications = {
      runner = { enabled = true },
      executor = { enabled = true },
      spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
      refresh_rate_ms = 100, -- how often to iterate icons
    },
    cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
  },

  config = function(_, opts)
    require("cmake-tools").setup(opts)

    -- Workaround for Windows path issues with cmake presets
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

    -- Clean build directory completely
    local function clean_build_dir()
      local cmt = require("cmake-tools")
      local build_dir = cmt.get_build_directory()
      if build_dir then
        local dir_str = tostring(build_dir)
        if is_windows then
          os.execute('rmdir /S /Q "' .. dir_str:gsub('/', '\\') .. '" 2>nul')
        else
          os.execute('rm -rf "' .. dir_str .. '"')
        end
        vim.notify("Cleaned build directory: " .. dir_str, vim.log.levels.INFO)
      end
    end

    -- Ensure build directory exists before CMake runs
    local function ensure_build_dir()
      local cmt = require("cmake-tools")
      local build_dir = cmt.get_build_directory()
      if build_dir then
        local dir_str = tostring(build_dir)
        if is_windows then
          os.execute('mkdir "' .. dir_str:gsub('/', '\\') .. '" 2>nul')
        else
          os.execute('mkdir -p "' .. dir_str .. '"')
        end
      end
    end

    -- Override CMakeGenerate to ensure directory exists first
    -- With bang (!), clean build directory completely before generating
    vim.api.nvim_create_user_command('CMakeGenerate', function(cmd_opts)
      if cmd_opts.bang then
        clean_build_dir()
      end
      ensure_build_dir()
      require("cmake-tools").generate({}, function() end)
    end, { bang = true, nargs = '?' })

    -- Override CMakeBuild to ensure directory exists first
    -- With bang (!), clean build directory completely before building
    vim.api.nvim_create_user_command('CMakeBuild', function(cmd_opts)
      if cmd_opts.bang then
        clean_build_dir()
      end
      ensure_build_dir()
      require("cmake-tools").build({}, function() end)
    end, { bang = true, nargs = '?' })

    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>cm", group = "[C][M]ake Tools" },

      -- Configuration / Generation
      { "<leader>cmg", "<cmd>CMakeGenerate<CR>", desc = "[G]enerate Build System (Configure)" },
      { "<leader>cmG", "<cmd>CMakeGenerate!<CR>", desc = "Clean & [G]enerate Build System" },

      -- Building
      { "<leader>cmb", "<cmd>CMakeBuild<CR>", desc = "[B]uild Project" },
      { "<leader>cmB", "<cmd>CMakeBuild!<CR>", desc = "Clean & [B]uild Project" },

      -- Running & Debugging
      { "<leader>cmr", "<cmd>CMakeRun<CR>", desc = "[R]un Launch Target" },
      { "<leader>cmd", "<cmd>CMakeDebug<CR>", desc = "[D]ebug Launch Target" },
      { "<leader>cma", "<cmd>CMakeLaunchArgs<CR>", desc = "Set Launch [A]rguments" },

      -- Selecting Targets, Types, Kits
      { "<leader>cmt", "<cmd>CMakeSelectBuildTarget<CR>", desc = "Select Build [T]arget" },
      { "<leader>cml", "<cmd>CMakeSelectLaunchTarget<CR>", desc = "Select [L]aunch Target" },
      { "<leader>cmv", "<cmd>CMakeSelectBuildType<CR>", desc = "Select Build [V]ariant/Type" },
      { "<leader>cmk", "<cmd>CMakeSelectKit<CR>", desc = "Select [K]it" },

    }, { prefix = "<leader>" }) -- which-key prefix
  end,
}
