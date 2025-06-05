return {
  "stevearc/overseer.nvim",
  event = "VeryLazy",
  opts = { -- All options for overseer.setup() go in here
    strategy = {
      "toggleterm",
      opts = {      -- Options specifically for the toggleterm strategy
        direction = "horizontal", -- Crucial: tells toggleterm to open as a horizontal split (non-floating)
        close_on_exit = false,
        auto_scroll = true,
        hidden = false,          -- If true, terminal starts hidden until TaskAction
        open_on_start = true,    -- If true, automatically opens the terminal when a task starts
        shading_factor = nil,    -- Let Catppuccin/Edgy handle shading via highlights
      },
    },
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
      default_detail = 1, -- 1 = output, 2 = detail
      bindings = {
        ["q"] = function() vim.cmd("OverseerClose") end,
        ["<CR>"] = "TaskAction", -- This will open the task output (terminal)
        ["o"] = "TaskAction",
        ["gd"] = "TaskDelete",
        ["gs"] = "TaskStart",
        ["gp"] = "TaskPause",
        ["gr"] = "TaskRestart",
        ["<C-c>"] = "TaskStop",
        ["?"] = "TaskQuickHelp",
      },
    },
    templates = {
      "builtin", -- Loads all built-in Overseer templates
      "user.conan_debug",   -- Refers to lua/overseer/template/user/conan_debug.lua
      "user.conan_release", -- Refers to lua/overseer/template/user/conan_release.lua
      "user.launch_reaper", -- Refers to Lua/overseer/template/user/launch_reaper.lua
    },
  },
  config = function(_, opts)
    require("overseer").setup(opts) -- 'opts' now correctly includes your strategy

    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>o", group = "[O]verseer Tasks" },
      { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "[T]oggle UI" },
      { "<leader>oa", "<cmd>OverseerRun<CR>", desc = "[A]vailable Tasks (Run)" },
      { "<leader>oo", "<cmd>OverseerOpen<CR>", desc = "[O]pen Task List" },
      { "<leader>ocd", function() require("overseer").run_template({ name = "Conan Install (Debug) (User)" }) end, desc = "[C]onan Install [D]ebug" },
      { "<leader>ocr", function() require("overseer").run_template({ name = "Conan Install (Release) (User)" }) end, desc = "[C]onan Install [R]elease" },
      { "<leader>oR", function() require("overseer").run_template({ name = "Launch Reaper (VST3 Host)" }) end, desc = "Launch [R]eaper Host" },
    }, { prefix = "<leader>" })
  end,
}
