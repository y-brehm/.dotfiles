local toggle_key = "<C-,>"

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },

  keys = {
    -- Your preferred toggle key (in addition to defaults)
    {
      toggle_key,
      "<cmd>ClaudeCodeFocus<cr>",
      desc = "Claude Toggle",
      mode = { "n", "x" },
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
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },

  opts = {
    -- Server Configuration
    log_level = "info",
    focus_after_send = false,

    -- Terminal Configuration matching your floating window preferences
    terminal = {
      provider = "auto", -- Uses snacks.nvim for better terminal support
      auto_close = true,

      -- Floating window configuration (matching your 90% width/height, centered, single border)
      ---@module "snacks"
      ---@type snacks.win.Config|{}
      snacks_win_opts = {
        position = "float",
        width = 0.9,
        height = 0.9,
        border = "single",
        backdrop = 80, -- Adds a subtle backdrop dimming
        keys = {
          -- Enable Ctrl+, to hide from terminal mode as well
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

    -- Diff Integration
    diff_opts = {
      auto_close_on_accept = true,
      auto_close_on_deny = true,
      vertical_split = true,
      open_in_current_tab = false, -- Open in new tab to avoid buffer stacking
      keep_terminal_focus = false, -- Auto-switch focus to diff view
    },
  },

  config = true,
}
