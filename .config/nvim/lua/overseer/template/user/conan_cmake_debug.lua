return {
  name = "Conan + CMake Full Build (Debug) (User)",
  builder = function()
    local project_root = vim.fn.getcwd()
    return {
      cmd = { "sh" },
      args = {
        "-c",
        "conan install . -of=build/debug -s build_type=Debug --build=missing && " ..
        "cmake --preset debug && " ..
        "ln -sf build/debug/compile_commands.json compile_commands.json && " ..
        "cmake --build --preset debug"
      },
      cwd = project_root,
      components = { { "on_output_quickfix", open = false }, "default" },
      metadata = {
        category = "build",
      }
    }
  end,
  condition = {
    callback = function()
      local cwd = vim.fn.getcwd()
      return vim.fn.filereadable(cwd .. "/conanfile.py") == 1 or
             vim.fn.filereadable(cwd .. "/conanfile.txt") == 1
    end,
  },
}
