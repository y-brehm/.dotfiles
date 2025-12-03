-- venv_utils.lua
-- Shared utilities for Python virtual environment detection

local M = {}

-- Detect if running on Windows
M.is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

-- Common virtual environment directory names (in priority order)
M.venv_patterns = {".venv", "venv", ".env", "env"}

-- Get the Python executable path for a given venv directory
-- @param venv_dir string: Virtual environment directory name
-- @param cwd string: Current working directory (optional, defaults to vim.fn.getcwd())
-- @return string|nil: Full path to Python executable, or nil if not found
function M.get_venv_python(venv_dir, cwd)
  cwd = cwd or vim.fn.getcwd()
  local python_path = M.is_windows
    and (cwd .. "\\" .. venv_dir .. "\\Scripts\\python.exe")
    or (cwd .. "/" .. venv_dir .. "/bin/python")

  if vim.fn.filereadable(python_path) == 1 then
    return python_path
  end
  return nil
end

-- Find the first available project virtual environment
-- @param cwd string: Current working directory (optional, defaults to vim.fn.getcwd())
-- @return string|nil: Full path to Python executable, or nil if not found
function M.find_project_venv_python(cwd)
  cwd = cwd or vim.fn.getcwd()

  for _, pattern in ipairs(M.venv_patterns) do
    local python_path = M.get_venv_python(pattern, cwd)
    if python_path then
      return python_path
    end
  end

  return nil
end

-- Get the activation command for a virtual environment
-- @param venv_dir string: Virtual environment directory name
-- @return string: Shell command to activate the venv
function M.get_activation_command(venv_dir)
  if M.is_windows then
    return venv_dir .. "\\Scripts\\Activate.ps1"
  else
    return "source " .. venv_dir .. "/bin/activate"
  end
end

-- Find and return the activation command for the project venv
-- @param cwd string: Current working directory (optional, defaults to vim.fn.getcwd())
-- @return string|nil: Activation command, or nil if no venv found
function M.find_project_venv_activation(cwd)
  cwd = cwd or vim.fn.getcwd()

  for _, pattern in ipairs(M.venv_patterns) do
    local python_path = M.get_venv_python(pattern, cwd)
    if python_path then
      return M.get_activation_command(pattern)
    end
  end

  return nil
end

return M
