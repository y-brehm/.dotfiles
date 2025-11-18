-- File: lua/overseer/template/user/launch_reaper.lua
return {
  name = "Launch Reaper (VST3 Host)",
  builder = function()
    local reaper_cmd_path
    local os_type = ""

    if vim.fn.has("macunix") == 1 then
      os_type = "macOS"
      -- Common paths for Reaper on macOS. Adjust if your installation path differs.
      local common_paths_mac = {
        "/Applications/REAPER.app/Contents/MacOS/REAPER",
        "/Applications/REAPER64.app/Contents/MacOS/REAPER", -- Older naming
        vim.fn.expand("$HOME/Applications/REAPER.app/Contents/MacOS/REAPER"),
        vim.fn.expand("$HOME/Applications/REAPER64.app/Contents/MacOS/REAPER")
      }
      for _, path in ipairs(common_paths_mac) do
        if vim.fn.executable(path) == 1 then
          reaper_cmd_path = path
          break
        end
      end
      if not reaper_cmd_path then
         vim.notify("REAPER executable not found in common macOS paths. Please check your installation or update the launch_reaper.lua template.", vim.log.levels.ERROR)
         return
      end
    elseif vim.fn.has("win32") == 1 then
      os_type = "Windows"
      -- Common paths for Reaper on Windows. Adjust if your installation path differs.
      local common_paths_win = {
        vim.fn.expand("$PROGRAMFILES\\REAPER (x64)\\reaper.exe"),
        vim.fn.expand("$ProgramFiles(x86)\\REAPER\\reaper.exe"), -- For 32-bit Reaper or on 32-bit system
        vim.fn.expand(vim.fn.getenv("ProgramW6432") .. "\\REAPER (x64)\\reaper.exe"), -- More robust for Program Files
        vim.fn.expand(vim.fn.getenv("ProgramFiles(x86)") .. "\\REAPER\\reaper.exe"),
        vim.fn.expand("$LOCALAPPDATA\\Programs\\REAPER (x64)\\reaper.exe") -- User-specific install
      }
      for _, path in ipairs(common_paths_win) do
        if vim.fn.filereadable(path) == 1 then -- executable() can be tricky on Windows for .exe
            reaper_cmd_path = path
            break
        end
      end
       if not reaper_cmd_path then
         vim.notify("REAPER executable not found in common Windows paths. Please check your installation or update the launch_reaper.lua template.", vim.log.levels.ERROR)
         return
      end
    else -- Assuming Linux
      os_type = "Linux"
      if vim.fn.executable("reaper") == 1 then
        reaper_cmd_path = "reaper" -- Assumes 'reaper' is in your PATH
      else
        -- You might add checks for common install locations like /opt/REAPER/reaper if needed
        vim.notify("REAPER command not found in PATH on Linux. Please ensure it's installed and in PATH, or update the launch_reaper.lua template with the full path.", vim.log.levels.ERROR)
        return
      end
    end

    vim.notify("Attempting to launch Reaper for " .. os_type .. " using: " .. reaper_cmd_path, vim.log.levels.INFO)

    return {
      cmd = { reaper_cmd_path },
      args = {}, -- Add arguments if Reaper needs them for your workflow (e.g., loading a specific project)
      cwd = vim.fn.getcwd(), -- Or specific directory if needed
      -- This will use your default Overseer strategy, which is 'terminal' (native).
      -- The 'default' component handles standard output processing.
      components = { "default" },
      metadata = {
        category = "run",
        description = "Launches the REAPER Digital Audio Workstation."
      }
    }
  end,
  -- This template is generally always available to be run.
  condition = {
    callback = function() return true end,
  },
}
