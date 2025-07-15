-- lua/plugins/edgy.lua
return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-neo-tree/neo-tree.nvim" },
  opts = {
    -- (Your view configurations are unchanged)
    bottom = {
      {
        ft = "toggleterm",
        size = { height = 0.3 },
        filter = function(buf, win)
          local config = vim.api.nvim_win_get_config(win)
          return config.relative == ""
        end,
        wo = {
          winhighlight = "Normal:EdgyToggleTermActive,NormalNC:NormalNC",
        },
      },
    },
    left = {
      {
        title = "Neo-Tree",
        ft = "neo-tree",
        filter = function(buf)
          return vim.b[buf].neo_tree_source ~= nil
        end,
        size = { width = 50 },
        wo = {
          winhighlight = "Normal:EdgyNeoTreeActive,NormalNC:NormalNC",
        },
      },
    },
    right = {
      {
        title = "Overseer Tasks",
        ft = "OverseerList",
        size = { width = 70 },
        wo = {
          winhighlight = "Normal:EdgyOverseerActive,NormalNC:NormalNC",
        },
      },
    },
    animate = {
      enabled = false,
      fps = 60,
      cps = 120,
    },
  },
  config = function(_, opts)
    local edgy = require("edgy")
    edgy.setup(opts)
    vim.opt.splitkeep = "screen"

    local edgy_group = vim.api.nvim_create_augroup("MyEdgyKeymaps", { clear = true })

    vim.api.nvim_create_autocmd("WinEnter", {
      group = edgy_group,
      pattern = "*",
      desc = "Set buffer-local keymaps for edgy windows",
      callback = function()
          local win = edgy.get_win()
          local map = vim.keymap.set
          map('n', '<leader>s>', function() win:resize("width", 5) end, { desc = "Edgy: Increase Width", buffer = true })
          map('n', '<leader>s<', function() win:resize("width", -5) end, { desc = "Edgy: Decrease Width", buffer = true })
          map('n', '<leader>s+', function() win:resize("height", 5) end, { desc = "Edgy: Increase Height", buffer = true })
          map('n', '<leader>s-', function() win:resize("height", -5) end, { desc = "Edgy: Decrease Height", buffer = true })
          map('n', '<leader>s=', function() win.view.edgebar:equalize() end, { desc = "Edgy: Equalize Sizes", buffer = true })
      end,
    })
  end,
}
