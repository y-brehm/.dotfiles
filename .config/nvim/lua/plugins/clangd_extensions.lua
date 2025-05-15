-- lua/plugins/clangd_extensions.lua
return {
  "p00f/clangd_extensions.nvim",
  lazy = true, -- Or event = "VeryLazy" / ft = {"c", "cpp"}
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
    -- The plugin often sets up inlay hints automatically if auto_config = true
    -- and your clangd server is recent enough and configured with appropriate flags
    -- (your current --function-arg-placeholders is good for parameter hints).

    -- You might not need to call setup explicitly if auto_config handles it.
    -- If you need more control or auto_config is not working as expected:
    -- require("clangd_extensions").setup(opts)

    -- Example keymap to toggle inlay hints (if you want manual control)
    -- This is just an example; the plugin might offer its own commands.
    -- Check clangd_extensions.nvim documentation for recommended ways to toggle.
    local wk = require("which-key")
    wk.add({
      mode = "n",
      { "<leader>cdh", function() require("clangd_extensions.inlay_hints").toggle() end, desc = "[C]lang[d] Inlay [H]ints Toggle" },
      { "<leader>cda", function() require("clangd_extensions.ast").display_ast() end, desc = "[C]lang[d] Display [A]ST" },
      { "<leader>cds", function() require("clangd_extensions.symbol_hierarchy").display_hierarchy() end, desc = "[C]lang[d] Symbol [H]ierarchy" },
    }, { prefix = "<leader>" })

    -- Ensure it tries to setup inlay hints on LspAttach for clangd
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("clangd_extensions_attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "clangd" then
          -- Attempt to setup inlay hints if auto_config didn't run or needs a nudge
          -- This might be redundant if auto_config works well.
          pcall(require("clangd_extensions.inlay_hints").setup_autocmds)
          pcall(require("clangd_extensions").on_attach, args.bufnr) -- for other features like codelens
        end
      end,
    })
  end,
}
