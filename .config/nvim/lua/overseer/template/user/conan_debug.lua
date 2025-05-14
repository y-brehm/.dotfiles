return {
  name = "Conan Install (Debug) (User)",
  builder = function()
    local project_root = vim.fn.getcwd()
    return {
      cmd = { "conan" },
      args = { "install", ".", "-s", "build_type=Debug", "--output-folder=build/Debug", "--build=missing" },
      cwd = project_root,
      components = { { "on_output_quickfix", open = false }, "default" },
      metadata = {
        category = "build",
      }
    }
  end,
  condition = {
    -- filetype = { "c", "cpp", "cmake" },
    -- Example: Check for a conanfile.py or conanfile.txt
    callback = function()
      local cwd = vim.fn.getcwd()
      return vim.fn.filereadable(cwd .. "/conanfile.py") == 1 or
             vim.fn.filereadable(cwd .. "/conanfile.txt") == 1
    end,
  },
}
