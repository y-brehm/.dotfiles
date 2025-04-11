-- Detect OS and choose appropriate path
local function get_python_path()
  local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

  if is_windows then
    -- Windows-style path (.venv\Scripts\python.exe)
    return ".venv\\Scripts\\python.exe"
  else
    -- Unix-style path
    return ".venv/bin/python"
  end
end

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
            python = get_python_path(),
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
