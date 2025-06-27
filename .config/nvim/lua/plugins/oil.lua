return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", "<cmd>Oil<CR>", desc = "Explore with Oil" },
    { "-", "<cmd>Oil<CR>", mode = "n", desc = "Open parent directory (Oil)" },
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
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- No config block is needed. lazy.nvim handles the setup call and keymaps.
}
