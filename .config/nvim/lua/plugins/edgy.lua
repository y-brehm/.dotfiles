-- lua/plugins/edgy.lua
return {
  "folke/edgy.nvim",
  event = "VeryLazy", -- Load Edgy when needed, or on an event like "WinEnter"
  dependencies = { "nvim-neo-tree/neo-tree.nvim" }, -- Optional: if you want to ensure neo-tree is loaded for edgy
  opts = {
    -- Configure a bottom edge for toggleterm
    bottom = {
      {
        ft = "toggleterm", -- Edgy will look for filetype 'toggleterm'
        -- You can also filter by title if you have specific named terminals
        -- title = "MySpecificToggleterm",
        size = { height = 0.3 }, -- e.g., 30% of the screen height
        -- Only manage non-floating toggleterm windows in this edge
        filter = function(buf, win)
          -- Check if the window is not a floating window
          local config = vim.api.nvim_win_get_config(win)
          return config.relative == "" -- Empty string means not floating
        end,
        wo = {
          -- When this edgy view is active (focused), its Normal content uses EdgyToggleTermActive.
          -- When it's inactive, its NormalNC content uses the standard NormalNC.
          -- Catppuccin's `dim_inactive` will make NormalNC a dimmed version of EdgyToggleTermActive.
          winhighlight = "Normal:EdgyToggleTermActive,NormalNC:NormalNC",
        },
      },
      -- You can add other bottom panels here later (e.g., quickfix)
      -- { ft = "qf", title = "Quickfix List", size = { height = 0.25 } },
    },

    -- Configure a left edge for neo-tree
    left = {
      {
        title = "Neo-Tree", -- Optional: a display title for this edgy view
        ft = "neo-tree",    -- Edgy will look for filetype 'neo-tree'
        -- A more robust filter for neo-tree buffers
        filter = function(buf)
          return vim.b[buf].neo_tree_source ~= nil
        end,
        size = { width = 50 }, -- e.g., 35 columns wide
        wo = {
          winhighlight = "Normal:EdgyNeoTreeActive,NormalNC:NormalNC",
        },
      },
      -- You could add other left panels here, like a symbols outline
    },
    -- Configure a right edge for Overseer Task List
    right = {
      {
        title = "Overseer Tasks", -- A display title for this edgy view
        ft = "OverseerList",     -- Overseer uses this filetype for its task list
        size = { width = 70 },    -- Fixed width of 70 columns, similar to your DAP UI [cite: 133]
                                  -- You could also use a ratio, e.g., { width = 0.25 } for 25% screen width
        wo = {
          -- Style for consistent theming, we'll define EdgyOverseerActive in catppuccin
          winhighlight = "Normal:EdgyOverseerActive,NormalNC:NormalNC",
        },
      },
    },

    -- You can also configure 'right' and 'top' edges
    -- right = {},
    -- top = {},

    -- Animation settings (optional)
    animate = {
      enabled = false,
      fps = 60,
      cps = 120, -- For pinning/unpinning
    },

    -- Other edgy options you might find useful:
    -- exit_when_last = true, -- Close edgy views when they are the last window
    -- options = {
    --   -- Default options for edgebars (can be overridden per view)
    --   left = { size = 30 },
    --   bottom = { size = { height = 0.25 } },
    --   -- ...
    -- },
  },
  -- Optional: Configure recommended Neovim settings for edgy
  config = function(_, opts)
    require("edgy").setup(opts)
    -- Recommended settings for edgy to prevent unexpected window jumping
    vim.opt.splitkeep = "screen" -- Or "topline"
    -- vim.opt.laststatus = 3 -- If you want views to be able to fully collapse (global statusline)
  end,
}
