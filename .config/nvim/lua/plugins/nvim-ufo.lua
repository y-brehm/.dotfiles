return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  event = "BufReadPost",
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      -- Disable folding for specific buffer types and filetypes
      if buftype == "nofile" or buftype == "terminal" or buftype == "prompt" then
        return ""
      end

      -- Disable folding for file explorers and similar
      local exclude_filetypes = {
        "NvimTree",
        "oil",
        "fugitive",
        "gitcommit",
        "help",
        "man",
        "lspinfo",
        "mason",
        "lazy",
        "TelescopePrompt",
        "TelescopeResults",
        "TelescopePreview",
        "overseer",
        "qf", -- quickfix
        "trouble",
      }

      for _, ft in ipairs(exclude_filetypes) do
        if filetype == ft then
          return ""
        end
      end

      return { "lsp", "indent" }
    end,
    preview = {
      win_config = {
        border = "rounded",
        winblend = 0,
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
  },
  config = function(_, opts)
    -- Set fold options
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Setup ufo
    require("ufo").setup(opts)

    -- Override default z-based fold keys to work with ufo
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Reduce fold level" })
    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Increase fold level" })

    -- Toggle fold under cursor
    vim.keymap.set("n", "<leader>uf", "za", { desc = "Toggle fold under cursor" })

    -- Fold levels
    vim.keymap.set("n", "<leader>u0", require("ufo").closeAllFolds, { desc = "Fold level 0 (all)" })
    vim.keymap.set("n", "<leader>u1", function() require("ufo").closeFoldsWith(1) end, { desc = "Fold level 1" })
    vim.keymap.set("n", "<leader>u2", function() require("ufo").closeFoldsWith(2) end, { desc = "Fold level 2" })
    vim.keymap.set("n", "<leader>u3", function() require("ufo").closeFoldsWith(3) end, { desc = "Fold level 3" })
    vim.keymap.set("n", "<leader>u9", require("ufo").openAllFolds, { desc = "Fold level 9 (none)" })

    -- Enhanced K keymap for hover and fold preview
    vim.keymap.set("n", "K", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Hover or peek fold" })

    -- Fold preview with leader key alternative
    vim.keymap.set("n", "<leader>up", function()
      require("ufo").peekFoldedLinesUnderCursor()
    end, { desc = "Peek fold under cursor" })
  end,
}
