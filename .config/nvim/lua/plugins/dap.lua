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
    wk.add({
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = '[D]ebug [B]reakpoint' },
        { "<leader>dc", function() require("dap").continue() end, desc = '[D]ebug [C]ontinue' },
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

