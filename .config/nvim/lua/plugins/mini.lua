return {
  'echasnovski/mini.nvim',
  version = '*',
  config = function()
    -- Setup mini.icons (file icons support)
    require('mini.icons').setup()

    -- Setup mini.trailspace for trailing whitespace detection and removal
    require('mini.trailspace').setup()

    -- Customize the highlight color for trailing whitespace
    -- Using a red background to make it clearly visible
    vim.api.nvim_set_hl(0, 'MiniTrailspace', { bg = '#5f3034' })

    -- Start with highlighting disabled by default
    vim.g.minitrailspace_disable = true

    -- Toggle function for whitespace highlighting
    local function toggle_trailspace()
      vim.g.minitrailspace_disable = not vim.g.minitrailspace_disable
      -- Force a redraw to update highlighting
      if vim.fn.expand('%') ~= '' then
        vim.cmd('edit')
      else
        vim.cmd('redraw!')
      end
    end

    -- Set up keybindings for whitespace management
    local wk = require("which-key")
    wk.add({
      { "<leader>w", group = "Whitespace" },
      { "<leader>wt", "<cmd>lua MiniTrailspace.trim()<cr>", desc = "Trim trailing whitespace" },
      { "<leader>wl", "<cmd>lua MiniTrailspace.trim_last_lines()<cr>", desc = "Trim last blank lines" },
      { "<leader>wa", "<cmd>lua MiniTrailspace.trim()<cr><cmd>lua MiniTrailspace.trim_last_lines()<cr>", desc = "Trim all whitespace" },
      { "<leader>ws", toggle_trailspace, desc = "Toggle whitespace highlighting" },
    })
  end,
}
