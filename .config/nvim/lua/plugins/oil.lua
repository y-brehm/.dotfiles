local function toggle_oil_float()
  local oil_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype == "oil"
  end, vim.api.nvim_list_wins())

  if #oil_wins > 0 then
    -- Close all oil windows
    for _, win in ipairs(oil_wins) do
      vim.api.nvim_win_close(win, false)
    end
  else
    -- Open oil in float
    vim.cmd("Oil --float")
  end
end

return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", toggle_oil_float, desc = "Toggle Oil float" },
    { "-", "<cmd>Oil --float<CR>", mode = "n", desc = "Open parent directory (Oil)" },
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
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- No config block is needed. lazy.nvim handles the setup call and keymaps.
}
