-- Oil records the focused window as the "origin" to open files into.
-- If that window is a terminal, the file would replace the terminal buffer.
-- This guard switches focus to a regular window (or creates one) before opening Oil.
local function ensure_non_terminal_focus()
  local cur_buf = vim.api.nvim_get_current_buf()
  if vim.bo[cur_buf].buftype ~= "terminal" then return end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == "" and vim.bo[buf].buftype ~= "terminal" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  -- No regular window found — create one so Oil has a valid target
  vim.cmd("new")
end

local function open_oil_float()
  ensure_non_terminal_focus()
  vim.cmd("Oil --float")
end

local function toggle_oil_float()
  local oil_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype == "oil"
  end, vim.api.nvim_list_wins())

  if #oil_wins > 0 then
    for _, win in ipairs(oil_wins) do
      vim.api.nvim_win_close(win, false)
    end
  else
    open_oil_float()
  end
end

return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", toggle_oil_float, desc = "Toggle Oil float" },
    { "-", open_oil_float, mode = "n", desc = "Open parent directory (Oil)" },
  },

  opts = {
    default_file_explorer = true,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_width = 100,
      max_height = 30,
      border = "rounded",
    },
    keymaps = {
      ["<leader>cd"] = {
        callback = function()
          local oil = require("oil")
          local dir = oil.get_current_dir()
          if dir then
            -- Change Neovim's working directory
            vim.cmd("cd " .. dir)

            -- Update all existing ToggleTerm terminals
            local toggleterm_ok, terms = pcall(require, "toggleterm.terminal")
            if toggleterm_ok then
              local all_terms = terms.get_all()
              for _, term in pairs(all_terms) do
                if term:is_open() then
                  -- Send cd command to the terminal
                  vim.api.nvim_chan_send(term.job_id, "cd " .. vim.fn.shellescape(dir) .. "\r")
                end
              end
            end

            vim.notify("Changed directory to: " .. dir, vim.log.levels.INFO)
          end
        end,
        desc = "Change working directory to current",
      },
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- No config block is needed. lazy.nvim handles the setup call and keymaps.
}
