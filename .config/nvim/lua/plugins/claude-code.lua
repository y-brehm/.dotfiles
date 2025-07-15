return {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "ClaudeCode" }, -- Lazy-load the plugin until the command is called

  keys = {
    {
      "<leader>ac",
      "<cmd>ClaudeCode<CR>",
      desc = "[A]I [C]laude Toggle",
    },
    {
      "<C-,>",
      "<cmd>ClaudeCode<CR>",
      desc = "Claude Toggle (Normal/Terminal)",
      -- As per the plugin docs, this should work in normal and terminal mode
      mode = { "n", "t" },
    },
  },

  -- The config function now only needs to set up the plugin's options.
  config = function()
    require("claude-code").setup({
      -- We remove `default_key_mappings` as we are now defining them ourselves.
      window = {
        position = "float",
        float = {
          width = "90%",
          height = "90%",
          row = "center",
          col = "center",
          relative = "editor",
          border = "double",
        },
      },
    })
  end,
}
