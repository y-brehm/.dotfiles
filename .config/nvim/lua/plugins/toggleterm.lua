-- toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*", -- Consider pinning to a specific tag/commit for stability
  event = "VeryLazy",
  cmd = "ToggleTermDefault",
  config = function()
    local toggleterm_main_module = require("toggleterm") -- Require the main module
    local venv_utils = require("config.venv_utils")

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
      -- on_close removed - was interfering with terminal display
      -- Auto-activate project venv when terminal opens
      on_open = function(term)
        local activate_cmd = venv_utils.find_project_venv_activation()
        if activate_cmd then
          vim.defer_fn(function()
            vim.api.nvim_chan_send(term.job_id, activate_cmd .. "\r")
          end, 100)
        end
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
