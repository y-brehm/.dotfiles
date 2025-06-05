local M = {}

function M.launch_host_application()
  vim.ui.input({ prompt = "Enter path to host application executable:" }, function(app_path)
    if app_path and app_path ~= "" then
      local task_name = "Launch: " .. vim.fn.fnamemodify(app_path, ":t")
      local task_def = {
        name = task_name,
        cmd = { app_path },
        args = {},
        cwd = vim.fn.getcwd(),
        components = { "default" },
        metadata = { category = "run" }
      }

      local overseer_ok, overseer = pcall(require, "overseer")
      if overseer_ok then
        -- Old problematic line:
        -- overseer.run_task(task_def)

        -- New approach:
        local task = overseer.new_task(task_def)
        if task and type(task.start) == "function" then
          task:start()
        else
          local msg = "Overseer: Failed to create or start task."
          if not task then
            msg = msg .. " 'new_task' did not return a task object."
          elseif type(task.start) ~= "function" then
            msg = msg .. " Task object created, but ':start()' method is missing or not a function."
          end
          vim.notify(msg, vim.log.levels.ERROR)
          -- For debugging, you could print the task object if it exists
          -- if task then print(vim.inspect(task)) end
        end
      else
        vim.notify("Overseer plugin is not available.", vim.log.levels.ERROR)
      end
    else
      vim.notify("No application path entered.", vim.log.levels.WARN)
    end
  end)
end

return M
