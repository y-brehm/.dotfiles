-- Rust-specific keymaps for rustaceanvim
-- This file is sourced after the plugin loads for Rust files

local bufnr = vim.api.nvim_get_current_buf()
local wk = require("which-key")

-- Rust-specific keymaps
wk.add({
  -- Rust code actions and commands
  { "<leader>ca", function() vim.cmd.RustLsp('codeAction') end, desc = "Rust Code Actions", buffer = bufnr },
  { "<leader>ce", function() vim.cmd.RustLsp('explainError') end, desc = "Explain Error", buffer = bufnr },
  { "<leader>cR", function() vim.cmd.RustLsp('renderDiagnostic') end, desc = "Render Diagnostics", buffer = bufnr },

  -- Rust runnables and debuggables
  { "<leader>rr", function() vim.cmd.RustLsp('runnables') end, desc = "Rust Runnables", buffer = bufnr },
  { "<leader>rd", function() vim.cmd.RustLsp('debuggables') end, desc = "Rust Debuggables", buffer = bufnr },
  { "<leader>rt", function() vim.cmd.RustLsp('testables') end, desc = "Rust Testables", buffer = bufnr },

  -- Rust-specific navigation and tools
  { "<leader>rm", function() vim.cmd.RustLsp('expandMacro') end, desc = "Expand Macro", buffer = bufnr },
  { "<leader>rp", function() vim.cmd.RustLsp('rebuildProcMacros') end, desc = "Rebuild Proc Macros", buffer = bufnr },
  { "<leader>rM", function() vim.cmd.RustLsp('parentModule') end, desc = "Go to Parent Module", buffer = bufnr },

  -- Cargo commands
  { "<leader>rc", function() vim.cmd.RustLsp('openCargo') end, desc = "Open Cargo.toml", buffer = bufnr },

  -- View helpers
  { "<leader>rg", function() vim.cmd.RustLsp('crateGraph') end, desc = "View Crate Graph", buffer = bufnr },
  { "<leader>rv", function() vim.cmd.RustLsp('view', 'syntaxTree') end, desc = "View Syntax Tree", buffer = bufnr },
  { "<leader>rh", function() vim.cmd.RustLsp('view', 'hir') end, desc = "View HIR", buffer = bufnr },
  { "<leader>ri", function() vim.cmd.RustLsp('view', 'mir') end, desc = "View MIR", buffer = bufnr },

  -- Hover actions (extends the default LSP hover)
  { "K", function() vim.cmd.RustLsp({ 'hover', 'actions' }) end, desc = "Hover Actions", buffer = bufnr },

  -- Join lines (Rust-aware)
  { "J", function() vim.cmd.RustLsp('joinLines') end, desc = "Join Lines", buffer = bufnr },

  -- Move items
  { "<leader>rmu", function() vim.cmd.RustLsp('moveItem', 'up') end, desc = "Move Item Up", buffer = bufnr },
  { "<leader>rmd", function() vim.cmd.RustLsp('moveItem', 'down') end, desc = "Move Item Down", buffer = bufnr },
})

-- Rust formatting with rustfmt (overrides default LSP format)
vim.keymap.set("n", "<leader>fb", function()
  vim.lsp.buf.format({ async = false })
end, { buffer = bufnr, desc = "Format Buffer (rustfmt)" })
