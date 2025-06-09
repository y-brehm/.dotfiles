local function select_python_file()
  -- Use vim.ui.select to choose a file
  local files = vim.fn.glob(vim.fn.getcwd() .. '/**/*.py', false, true)
  vim.ui.select(files, {
    prompt = "Select Python file to debug: ",
    format_item = function(item)
      -- Convert absolute path to relative for cleaner display
      return vim.fn.fnamemodify(item, ":.")
    end,
  }, function(file)
    if file then
      -- Store selected file in a global variable
      vim.g.dap_python_selected_file = file
      -- Run the debugger with this file
      require('dap').run({
        type = "python",
        request = "launch",
        name = "Launch selected file",
        program = file,
        pythonPath = function()
          if vim.fn.filereadable('.venv/bin/python') == 1 or vim.fn.filereadable('.venv/Scripts/python.exe') == 1 then
            if vim.fn.has('win32') == 1 then
              return vim.fn.getcwd() .. '\\.venv\\Scripts\\python.exe'
            else
              return vim.fn.getcwd() .. '/.venv/bin/python'
            end
          else
            return python_path
          end
        end,
      })
    end
  end)
end

local function run_attach_config(pid)
  if not (pid and tonumber(pid) and tonumber(pid) > 0) then
    vim.notify("Could not attach debugger: Invalid PID provided.", vim.log.levels.ERROR)
    return
  end

  require("dap").run({
    type = "codelldb",
    name = "Attach to Process",
    request = "attach",
    pid = pid,
  })
end

local function attach_to_reaper()
  local pid_string = vim.fn.trim(vim.fn.system("pgrep -x REAPER"))
  if pid_string ~= "" and tonumber(pid_string) then
    vim.notify("Found Reaper process with PID: " .. pid_string .. ". Attaching debugger.", vim.log.levels.INFO)
    run_attach_config(pid_string)
  else
    vim.notify("Could not find running Reaper process.", vim.log.levels.ERROR)
  end
end

-- Function to manually attach to a process by PID
local function attach_to_process_manual()
  vim.ui.input({ prompt = "Enter Process ID (PID) to attach: " }, function(pid)
    run_attach_config(pid)
  end)
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "jay-babu/mason-nvim-dap.nvim",
    },
    cmd = { "DapToggleBreakpoint", "DapContinue" },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      -- Signs
      vim.fn.sign_define('DapBreakpoint', { text='●', texthl='LspDiagnosticsDefaultError' })
      vim.fn.sign_define('DapLogPoint', { text='◉', texthl='LspDiagnosticsDefaultError' })
      vim.fn.sign_define('DapStopped', { text='➔', texthl='LspDiagnosticsDefaultInformation', linehl='CursorLine' })

      -- UI setup
      ui.setup({
        mappings = {
        expand = {'<CR>', '<LeftMouse>'},
          open = {'o'},
          remove = {'d', 'x'},
          edit = {'c'},
          repl = {'r'},
        },
        layouts = {
          {
            elements = {
              'breakpoints',
              'watches',
              'stacks',
              'scopes',
            },
            size = 70,
            position = 'right',
          },
          {
            elements = {'repl'},
            size = 20,
            position = 'bottom',
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
        },
      })
        -- CPP configurations
      dap.adapters.codelldb = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        name = "codelldb",
      }

      dap.configurations.cpp = {
        {
          name = "Launch file (cmake-tools)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = "Attach to Process",
          type = "codelldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- Automatically open/close UI
      dap.listeners.after['event_initialized']['dapui_config'] = function()
        ui.open({})
      end
      dap.listeners.before['event_terminated']['dapui_config'] = function()
        ui.close({})
      end
      dap.listeners.before['event_exited']['dapui_config'] = function()
        ui.close({})
      end

      -- Virtual text setup
      require("nvim-dap-virtual-text").setup()

    local wk = require("which-key")
    vim.api.nvim_create_user_command('DapPythonPickFile', select_python_file, {})
    vim.api.nvim_create_user_command('DapAttachReaper', attach_to_reaper, {})
      vim.api.nvim_create_user_command('DapAttachProcess', attach_to_process_manual, {})
    wk.add({
        { "<leader>d", group = "[D]ebug" },
        { "<leader>dar", "<cmd>DapAttachReaper<CR>", desc = "[A]ttach to [R]eaper" },
        { "<leader>dap", "<cmd>DapAttachProcess<CR>", desc = "[A]ttach to [P]rocess (manual)" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = '[D]ebug [B]reakpoint' },
        { "<leader>dc", function() require("dap").continue() end, desc = '[D]ebug [C]ontinue' },
        { "<leader>dui", function() require("dapui").toggle() end, desc = '[U]I Toggle' },
        { "<leader>dpf", ":DapPythonPickFile<CR>", desc = "[D]ebug [P]ython [F]ile selector" },
        { "<leader>dso", function() require("dap").step_over() end, desc = '[D]ebug [S]tep [O]ver' },
        { "<leader>dsi", function() require("dap").step_in() end, desc = '[D]ebug [S]tep [I]nto' },
        { "<leader>dt", function() require("dap").test_method() end, desc = '[D]ebug [T]est' },
    })
    end,
  },
{
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    ensure_installed = { "python" },
    handlers = {
      python = function()
        local dap = require("dap")
        -- Get the proper Python path based on OS
        local python_path
        if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
          python_path = vim.fn.stdpath("data") .. "\\mason\\packages\\debugpy\\venv\\Scripts\\python.exe"
        else
          python_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        end
        -- Configure the adapter
        dap.adapters.python = {
          type = "executable",
          command = python_path,
          args = { "-m", "debugpy.adapter" },
        }
        -- Configure Python launch configurations
        dap.configurations.python = {
          {
            type = "python",
            request = "launch",
            name = "Launch current file",
            program = "${file}",
            pythonPath = function()
              -- Try to detect the environment python
              if vim.fn.filereadable('.venv/bin/python') == 1 or vim.fn.filereadable('.venv/Scripts/python.exe') == 1 then
                if vim.fn.has('win32') == 1 then
                  return vim.fn.getcwd() .. '\\.venv\\Scripts\\python.exe'
                else
                  return vim.fn.getcwd() .. '/.venv/bin/python'
                end
              else
                return python_path
              end
            end,
          },
          {
            type = "python",
            request = "launch",
            name = "Launch test file",
            module = "pytest",
            args = { "${file}" },
            pythonPath = function()
              if vim.fn.filereadable('.venv/bin/python') == 1 or vim.fn.filereadable('.venv/Scripts/python.exe') == 1 then
                if vim.fn.has('win32') == 1 then
                  return vim.fn.getcwd() .. '\\.venv\\Scripts\\python.exe'
                else
                  return vim.fn.getcwd() .. '/.venv/bin/python'
                end
              else
                return python_path
              end
            end,
          }
        }
      end,
    },
  },

}

}

