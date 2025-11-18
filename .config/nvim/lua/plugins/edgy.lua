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
      {
        ft = "cmake_tools_terminal",
        size = { height = 0.3 },
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
        size = { width = 50 },
        wo = {
          winhighlight = "Normal:EdgyOverseerActive,NormalNC:NormalNC",
        },
      },
      {
        title = "Overseer Output",
        ft = "terminal",
        size = { width = 50 },
        filter = function(buf, win)
          -- Only accept terminal buffers that are NOT toggleterm
          return vim.bo[buf].buftype == "terminal" and vim.bo[buf].filetype ~= "toggleterm"
        end,
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

    -- Set global keymaps that work from any window
    local map = vim.keymap.set
    map('n', '<leader>s>', function() 
      local win = edgy.get_win()
      if win then win:resize("width", 15) end
    end, { desc = "Edgy: Increase Width" })
    map('n', '<leader>s<', function() 
      local win = edgy.get_win()
      if win then win:resize("width", -15) end
    end, { desc = "Edgy: Decrease Width" })
    map('n', '<leader>s+', function() 
      local win = edgy.get_win()
      if win then win:resize("height", 15) end
    end, { desc = "Edgy: Increase Height" })
    map('n', '<leader>s-', function() 
      local win = edgy.get_win()
      if win then win:resize("height", -15) end
    end, { desc = "Edgy: Decrease Height" })
    map('n', '<leader>s=', function() 
      local win = edgy.get_win()
      if win then win.view.edgebar:equalize() end
    end, { desc = "Edgy: Equalize Sizes" })
  end,
}
