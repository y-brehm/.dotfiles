return {
  "Civitasv/cmake-tools.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/overseer.nvim",
    "akinsho/toggleterm.nvim",
  },
  opts = {
    cmake_build_directory = function()
    local osys = require("cmake-tools.osys")
      if osys.iswin32 then
        return "build\\${variant:buildType}"
      end
      return "build/${variant:buildType}"
    end,
    cmake_generate_compile_commands = true,
    cmake_configure_on_edit = true,
    cmake_configure_on_variant_change = true,
    cmake_executor = { -- executor to use
      name = "overseer", -- name of the executor
      opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
      default_opts = { -- a list of default and possible values for executors
        overseer = {
          new_task_opts = {
              strategy = {
                  "toggleterm",
                  direction = "horizontal",
                  auto_scroll = true,
                  quit_on_exit = "never"
              }
          }, -- options to pass into the `overseer.new_task` command
          on_new_task = function(task)
              require("overseer").open(
                  { enter = false, direction = "right" }
              )
          end,   -- a function that gets overseer.Task when it is created, before calling `task:start`
        },
      },
    },
    cmake_runner = { -- runner to use
      name = "overseer", -- name of the runner
      default_opts = { -- a list of default and possible values for runners
        overseer = {
          new_task_opts = {
              strategy = {
                  "toggleterm",
                  direction = "horizontal",
                  autos_croll = true,
                  quit_on_exit = "success"
              }
          }, -- options to pass into the `overseer.new_task` command
          on_new_task = function(task)
          end,   -- a function that gets overseer.Task when it is created, before calling `task:start`
        },
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
