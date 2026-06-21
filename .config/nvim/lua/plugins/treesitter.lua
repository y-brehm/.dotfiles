-- nvim-treesitter was archived (2026-04) and split into two frozen branches:
--   master -> Neovim 0.11 only (old `nvim-treesitter.configs` API)
--   main   -> Neovim 0.12+ only (low-level API, used here)
-- We standardize on Neovim 0.12, so pin `branch = "main"`. Parser versions are
-- additionally pinned via the committed lazy-lock.json.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    init = function()
      -- Install any missing parsers (0.12 bundles some; install() skips those
      -- already present). install() is async and compiles via the tree-sitter CLI.
      local ensure_installed = { "python", "cpp", "rust", "markdown", "markdown_inline" }
      local ok, ts_config = pcall(require, "nvim-treesitter.config")
      if ok then
        local installed = ts_config.get_installed()
        local missing = vim.tbl_filter(function(parser)
          return not vim.tbl_contains(installed, parser)
        end, ensure_installed)
        if #missing > 0 then
          require("nvim-treesitter").install(missing)
        end
      end

      -- Enable highlighting + treesitter-based indentation per filetype
      -- (replaces the old `highlight = { enable = true }` option).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
