return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jvgrootveld/telescope-zoxide",
    },
    opts = {
      defaults = {
        sort_mru = true,
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
        border = true,
        multi_icon = "",
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
        entry_prefix = "   ",
        prompt_prefix = "  🔎 ",
        selection_caret = " ▶ ",
        hl_result_eol = true,
        results_title = "",
        winblend = 0,
        wrap_results = true,
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("zoxide")
    end,
  },
}
