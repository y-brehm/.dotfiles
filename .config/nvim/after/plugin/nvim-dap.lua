local dap = require('dap')

vim.fn.sign_define('DapBreakpoint', { text='●', texthl='LspDiagnosticsDefaultError' })
vim.fn.sign_define('DapLogPoint' , { text='◉', texthl='LspDiagnosticsDefaultError' })
vim.fn.sign_define('DapStopped' , { text='➔', texthl='LspDiagnosticsDefaultInformation', linehl='CursorLine' })

-- dap UI
local ui  = require 'dapui'
dap.listeners.after['event_initialized']['dapui_config'] = function() ui.open({})
end
dap.listeners.before['event_terminated']['dapui_config'] = function()
	ui.close({})
end

dap.listeners.before['event_exited']['dapui_config'] = function()
	ui.close({})
end

require 'nvim-dap-virtual-text'.setup {}

ui.setup {
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
        }, {
            elements = {'repl'},
            size = 20,
            position = 'bottom',
        },
    },
    floating = {
        max_height = nil,
        max_width  = nil,
    },
}

local function dapui_eval()
	local expr = vim.fn.input('DAP expression: ')
	if vim.fn.empty(expr) ~= 0 then
		return
	end
	ui.eval(expr, {})
end


--[[
-- Python
-- requires the below referenced virtual environment with debugpy installed
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
--]]
--

function AttachToProcess()
    local dap = require('dap')
    dap.configurations.cpp = {
        {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            pid = require'dap.utils'.pick_process(),
            args = {},
        }
    }
end

vim.keymap.set('n', '<leader>db', '<cmd>lua require"dap".toggle_breakpoint()<CR>', { desc = '[D]ebug [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', '<cmd>lua require"dap".continue()<CR>', { desc = '[D]ebug [C]ontinue' })
vim.keymap.set('n', '<leader>dso', '<cmd>lua require"dap".step_over()<CR>', { desc = '[D]ebug [S]tep [O]ver' })
vim.keymap.set('n', '<leader>dsi', '<cmd>lua require"dap".step_into()<CR>', { desc = '[D]ebug [S]tep [I]nto' })
vim.keymap.set('n', '<leader>dt', '<cmd>lua require"dap-python".test_method()<CR>', { desc = '[D]ebug [T]est' })
vim.keymap.set('n', '<leader>ds', '<cmd>lua AttachToProcess()<CR>', { desc = '[D]ebug [S]tart' })

vim.keymap.set({'n', 'v'}, '<M-k>', ui.eval, {})
vim.keymap.set('n', '<M-K>', dapui_eval, {})
