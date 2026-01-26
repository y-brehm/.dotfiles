return {
  "stevearc/overseer.nvim",
  event = "VeryLazy",
  opts = {
    component_aliases = {
      default = {
        "on_exit_set_status",
        "on_complete_notify",
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
        { "open_output", on_start = "always" },
      },
    },
    task_list = {
      direction = "right",  -- Task list on right side with Edgy
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
      "user.conan_debug",        -- Refers to lua/overseer/template/user/conan_debug.lua
      "user.conan_release",      -- Refers to lua/overseer/template/user/conan_release.lua
      "user.conan_cmake_debug",  -- Refers to lua/overseer/template/user/conan_cmake_debug.lua
      "user.conan_cmake_release",-- Refers to lua/overseer/template/user/conan_cmake_release.lua
      "user.launch_reaper",      -- Refers to Lua/overseer/template/user/launch_reaper.lua
    },
  },
  config = function(_, opts)
    require("overseer").setup(opts)

    -- Set filetype for Overseer terminal buffers so Edgy can catch them
    -- Add task name patterns here when adding new Overseer templates
    local overseer_patterns = { "conan", "cmake", "reaper" }

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- Check if this terminal matches any Overseer task pattern
        for _, pattern in ipairs(overseer_patterns) do
          if bufname:match(pattern) then
            vim.bo.filetype = "terminal"
            -- Prevent entering terminal-insert mode (which causes weird closing behavior)
            vim.keymap.set('n', 'i', '<nop>', { buffer = true, silent = true })
            vim.keymap.set('n', 'a', '<nop>', { buffer = true, silent = true })
            vim.keymap.set('n', 'I', '<nop>', { buffer = true, silent = true })
            vim.keymap.set('n', 'A', '<nop>', { buffer = true, silent = true })
            break
          end
        end
      end,
    })

    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>o", group = "[O]verseer Tasks" },
      { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "[T]oggle UI" },
      { "<leader>oa", "<cmd>OverseerRun<CR>", desc = "[A]vailable Tasks (Run)" },
      { "<leader>oo", "<cmd>OverseerOpen<CR>", desc = "[O]pen Task List" },
      { "<leader>ocd", function() require("overseer").run_task({ name = "Conan Install (Debug) (User)" }) end, desc = "[C]onan Install [D]ebug" },
      { "<leader>ocr", function() require("overseer").run_task({ name = "Conan Install (Release) (User)" }) end, desc = "[C]onan Install [R]elease" },
      { "<leader>obd", function() require("overseer").run_task({ name = "Conan + CMake Full Build (Debug) (User)" }) end, desc = "Full [B]uild [D]ebug (Conan+CMake)" },
      { "<leader>obr", function() require("overseer").run_task({ name = "Conan + CMake Full Build (Release) (User)" }) end, desc = "Full [B]uild [R]elease (Conan+CMake)" },
      { "<leader>oR", function() require("overseer").run_task({ name = "Launch Reaper (VST3 Host)" }) end, desc = "Launch [R]eaper Host" },
    }, { prefix = "<leader>" })
  end,
}
