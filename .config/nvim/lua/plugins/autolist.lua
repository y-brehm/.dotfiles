return {
  {
    "gaoDean/autolist.nvim",
    ft = "markdown",
    config = function()
      require("autolist").setup()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          -- Insert mode: continue list on Enter, indent/dedent on Tab/Shift-Tab.
          -- cmp's <CR> confirm falls back to this mapping when the menu is hidden.
          -- Autolist's Tab handlers fall back to default Tab when not on a list item.
          vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)
          vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<cr>", opts)
          vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<cr>", opts)

          -- Normal mode: o/O open a new line with a continued bullet.
          vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
          vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)

          -- Recalculate list numbering after edits (e.g. deleting an item
          -- in the middle of a numbered list leaves gaps).
          vim.keymap.set("n", "<leader>mn", "<cmd>AutolistRecalculate<cr>",
            vim.tbl_extend("force", opts, { desc = "[M]arkdown re[N]umber list" }))
        end,
      })
    end,
  },
}
