return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            -- TODO: check if this is correct
            python = ".venv/bin/python",
            is_test_file = function(file_path)
              local file_ext = vim.fn.fnamemodify(file_path, ":e")
              return file_ext == "py" and (
                vim.fn.fnamemodify(file_path, ":t"):match("^test_.*%.py$") or
                vim.fn.fnamemodify(file_path, ":t"):match(".*_test%.py$")
              )
            end,
          }),
        }
      })
    end
  }
}
