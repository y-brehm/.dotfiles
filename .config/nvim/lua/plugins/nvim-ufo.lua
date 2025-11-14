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
        "neo-tree",
        "neo-tree-popup",
        "neo-tree-preview",
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
  },
  config = function(_, opts)
    -- Set fold options
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Setup ufo
    require("ufo").setup(opts)

    -- Keymaps for ufo (default z-based)
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level" })

    -- German keyboard-friendly fold keybindings
    vim.keymap.set("n", "<leader>fo", "zo", { desc = "Open fold under cursor" })
    vim.keymap.set("n", "<leader>fc", "zc", { desc = "Close fold under cursor" })
    vim.keymap.set("n", "<leader>ft", "za", { desc = "Toggle fold under cursor" })
    vim.keymap.set("n", "<leader>fO", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "<leader>fC", require("ufo").closeAllFolds, { desc = "Close all folds" })

    -- Navigation with easier keys
    vim.keymap.set("n", "<leader>fn", "zj", { desc = "Next fold" })
    vim.keymap.set("n", "<leader>fp", "zk", { desc = "Previous fold" })

    -- Fold levels (easier than zr/zm)
    vim.keymap.set("n", "<leader>f1", function() require("ufo").closeFoldsWith(1) end, { desc = "Fold level 1" })
    vim.keymap.set("n", "<leader>f2", function() require("ufo").closeFoldsWith(2) end, { desc = "Fold level 2" })
    vim.keymap.set("n", "<leader>f3", function() require("ufo").closeFoldsWith(3) end, { desc = "Fold level 3" })

    -- Enhanced K keymap for hover and fold preview
    vim.keymap.set("n", "K", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Hover or peek fold" })

    -- Fold preview with leader key alternative
    vim.keymap.set("n", "<leader>fk", function()
      require("ufo").peekFoldedLinesUnderCursor()
    end, { desc = "Peek fold under cursor" })
  end,
}