local toggle_key = "<C-,>"

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },

  keys = {
    -- Your preferred toggle key (in addition to defaults)
    {
      toggle_key,
      "<cmd>ClaudeCode<cr>",
      desc = "Claude Toggle",
      mode = { "n", "x", "t" },
    },

    -- Default plugin keybindings (all under <leader>a for AI/Claude)
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },

  opts = {
    terminal = {
      provider = "snacks",

      snacks_win_opts = {
        position = "float",
        width = 0.9,
        height = 0.9,
        border = "single",
        backdrop = false, -- Must be false or omitted - causes rendering glitches if enabled
        wo = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
        keys = {
          claude_hide = {
            toggle_key,
            function(self)
              self:hide()
            end,
            mode = "t",
            desc = "Hide Claude",
          },
        },
      },
    },

    diff_opts = {
      layout = "vertical",
      open_in_new_tab = true,
      keep_terminal_focus = true, -- Focus the split terminal in the diff tab after opening
    },
  },

  config = true,
}
