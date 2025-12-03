-- lua/plugins/clangd_extensions.lua
-- Disable on Windows, C++ tooling doesn't work well there
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

return {
  "p00f/clangd_extensions.nvim",
  enabled = not is_windows, -- Disable on Windows
  ft = {"c", "cpp"}, -- Load when opening C/C++ files
  dependencies = {
    "neovim/nvim-lspconfig", -- Ensure it loads after lspconfig
  },
  opts = {
    -- Automatically set up inlay hints when clangd attaches
    auto_config = true,
    -- Default inlay hint configuration, you can customize these
    inlay_hints = {
      -- Only show inlay hints for the current line
      only_current_line = false,
      -- Event to trigger inlay hint update
      -- Only works in Neovim 0.10 or higher
      -- update_event = "TextChanged,TextChangedI", -- Example: update on text change
      -- Options for specific hint kinds
      -- Refer to clangd_extensions.nvim documentation for all available kinds
      -- parameter_hints = { enable = true },
      -- type_hints = { enable = true },
      -- chaining_hints = { enable = true },
      -- operator_hints = { enable = true },
      -- etc.
      -- By default, most are enabled if your clangd supports them.
    },
    -- Other features like AST viewer, symbol hierarchy can be configured here
    -- For example, to configure the AST viewer:
    -- ast = {
    --   icon = "",
    --   kind_icons = {}, -- custom icons for AST node kinds
    --   keymaps = { ... } -- custom keymaps for the AST window
    -- }
  },
  config = function(_, opts)
    -- Initialize the plugin with the provided options
    require("clangd_extensions").setup(opts)

    -- Register keymaps for clangd_extensions features
    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>cda", "<cmd>ClangdAST<cr>", desc = "[C]lang[d] Display [A]ST" },
      { "<leader>cds", "<cmd>ClangdSymbolInfo<cr>", desc = "[C]lang[d] [S]ymbol Info" },
      { "<leader>cdh", "<cmd>ClangdTypeHierarchy<cr>", desc = "[C]lang[d] Type [H]ierarchy" },
      { "<leader>cdm", "<cmd>ClangdMemoryUsage<cr>", desc = "[C]lang[d] [M]emory Usage" },
    }, { prefix = "<leader>" })
  end,
}
