-- Disable on Windows, C++ tooling doesn't work well there
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

return {
  "Civitasv/cmake-tools.nvim",
  enabled = not is_windows, -- Disable on Windows
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/overseer.nvim",
  },
  -- Builds/configures run through Overseer (see lua/overseer/template/user/).
  -- cmake-tools is kept only for selecting targets and running/debugging them.
  opts = {
    cmake_build_directory = "build/${variant:buildType}",
    cmake_generate_compile_commands = true,
    cmake_use_preset = "auto",
    cmake_configure_on_edit = false,
    cmake_configure_on_variant_change = false,
    cmake_executor = {
      name = "overseer",
      opts = {
        new_task_opts = {
          strategy = "jobstart",
        },
        on_new_task = function(task)
          require("overseer").open({ enter = false, direction = "right" })
        end,
      },
    },
    cmake_runner = {
      name = "overseer",
      opts = {
        new_task_opts = {
          strategy = "jobstart",
        },
        on_new_task = function(task)
          require("overseer").open({ enter = false, direction = "right" })
        end,
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
      spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      refresh_rate_ms = 100,
    },
    cmake_virtual_text_support = true,
  },

  config = function(_, opts)
    require("cmake-tools").setup(opts)

    -- Fix E141 on every cmake-tools operation.
    -- Before each command, cmake-tools runs `:wall` (utils.lua) to save buffers.
    -- `:wall` raises `E141: No file name for buffer 1` whenever a modified,
    -- no-name normal buffer exists (e.g. the empty startup buffer). That error
    -- aborts generate/build/run/debug. Clearing the `modified` flag on such
    -- unnamed buffers lets the plugin's `:wall` save only real, named files.
    local cmt_utils = require("cmake-tools.utils")
    local function neutralize_nameless_buffers()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
          and vim.bo[buf].modified
          and vim.bo[buf].buftype == ""
          and vim.api.nvim_buf_get_name(buf) == ""
        then
          vim.bo[buf].modified = false
        end
      end
    end
    for _, fn in ipairs({ "execute", "run" }) do
      local original = cmt_utils[fn]
      cmt_utils[fn] = function(...)
        neutralize_nameless_buffers()
        return original(...)
      end
    end

    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>cm", group = "[C][M]ake Tools" },

      -- Run & Debug (builds are handled by Overseer)
      { "<leader>cmr", "<cmd>CMakeRun<CR>", desc = "[R]un Launch Target" },
      { "<leader>cmd", "<cmd>CMakeDebug<CR>", desc = "[D]ebug Launch Target" },

      -- Target / preset selection
      { "<leader>cmt", "<cmd>CMakeSelectBuildTarget<CR>", desc = "Select Build [T]arget" },
      { "<leader>cml", "<cmd>CMakeSelectLaunchTarget<CR>", desc = "Select [L]aunch Target" },
      { "<leader>cmp", "<cmd>CMakeSelectConfigurePreset<CR>", desc = "Select Configure [P]reset" },
    }, { prefix = "<leader>" }) -- which-key prefix
  end,
}
