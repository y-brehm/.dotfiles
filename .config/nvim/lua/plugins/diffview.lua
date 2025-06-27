return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },

  keys = {
    { "<leader>dv", group = "[D]iff [V]iew" },
    { "<leader>dvo", "<cmd>DiffviewOpen<CR>", desc = "[O]pen Diffview" },
    { "<leader>dvc", "<cmd>DiffviewClose<CR>", desc = "[C]lose Diffview" },
    { "<leader>dvf", "<cmd>DiffviewFileHistory %<CR>", desc = "View File [H]istory" },
    {
      "<leader>dvt",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "[T]oggle Diffview",
    },
  },

  opts = {
    keymaps = {
      view = {
        ["q"] = "<Cmd>DiffviewClose<CR>",
      },
      file_panel = {
        ["q"] = "<Cmd>DiffviewClose<CR>",
      },
    },
    diagnostics = {
      disable = true,
    },
  },
}
