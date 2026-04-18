return {
  'echasnovski/mini.nvim',
  version = '*',
  config = function()
    -- Setup mini.icons (file icons support)
    require('mini.icons').setup()

    -- Setup mini.trailspace (highlighting + trim)
    require('mini.trailspace').setup()

    -- Subtle yellow highlight, persists through colorscheme changes
    local function set_trail_hl()
      vim.api.nvim_set_hl(0, 'MiniTrailspace', { bg = '#3b3520' })
    end
    set_trail_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_trail_hl })

    -- Set up keybindings for whitespace management
    local wk = require("which-key")
    wk.add({
      { "<leader>w", group = "Whitespace" },
      { "<leader>wt", "<cmd>lua MiniTrailspace.trim()<cr>", desc = "Trim trailing whitespace" },
      { "<leader>wl", "<cmd>lua MiniTrailspace.trim_last_lines()<cr>", desc = "Trim last blank lines" },
      { "<leader>wa", "<cmd>lua MiniTrailspace.trim()<cr><cmd>lua MiniTrailspace.trim_last_lines()<cr>", desc = "Trim all whitespace" },
    })
  end,
}
