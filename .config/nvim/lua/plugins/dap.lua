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

    wk.add({
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = '[D]ebug [B]reakpoint' },
        { "<leader>dc", function() require("dap").continue() end, desc = '[D]ebug [C]ontinue' },
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
      handlers = {},
    },
  }
}
