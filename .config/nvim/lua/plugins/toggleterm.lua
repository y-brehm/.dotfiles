-- toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*", -- Consider pinning to a specific tag/commit for stability
  event = "VeryLazy",
  cmd = "ToggleTermDefault",
  config = function()
    local toggleterm_main_module = require("toggleterm") -- Require the main module
    toggleterm_main_module.setup({
      size = 10,
      open_mapping = nil, -- Crucial for custom mapping
      hide_numbers = true,
      shade_terminals = false,
      shade_filetypes = {},
      persist_size = false,
      direction = "horizontal", -- This will be used by the default toggle action
      close_on_exit = true,
      shell = vim.o.shell,
      open_in_new_tab = false,
      -- Auto-close terminal when process exits
      auto_scroll = true,
      -- Ensure terminal is cleaned up on close
      on_close = function(term)
        -- Send clear screen sequence when terminal closes
        vim.schedule(function()
          io.write("\027[2J\027[H")
          io.flush()
        end)
      end,
    })

    vim.api.nvim_create_user_command('ToggleTermDefault', function()
      -- Use the toggle() function from the main toggleterm module.
      -- Calling toggle() or toggle(nil) should operate on the default terminal,
      -- creating it if necessary, according to your setup.
      local tt = require("toggleterm") -- Ensure it's accessible here too
      tt.toggle(nil) -- Passing nil (or no argument) targets the default terminal
    end, {})

    local wk_status, wk = pcall(require, "which-key")
    if not wk_status then
      vim.notify("which-key not found, cannot set ToggleTerm keymap", vim.log.levels.WARN)
      return
    end

    wk.add({
      { "<leader>td", "<cmd>ToggleTermDefault<CR>", desc = "[T]erminal [D]efault" },
    })
  end,
}
