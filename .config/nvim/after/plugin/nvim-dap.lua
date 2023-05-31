vim.keymap.set('n', '<leader>db', '<cmd>lua require"dap".toggle_breakpoint()<CR>', { desc = '[D]ebug [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', '<cmd>lua require"dap".continue()<CR>', { desc = '[D]ebug [C]ontinue' })
vim.keymap.set('n', '<leader>do', '<cmd>lua require"dap".step_over()<CR>', { desc = '[D]ebug Step [O]ver' })
vim.keymap.set('n', '<leader>di', '<cmd>lua require"dap".step_into()<CR>', { desc = '[D]ebug Step [I]nto' })
vim.keymap.set('n', '<leader>dt', '<cmd>lua require"dap-python".test_method()<CR>', { desc = '[D]ebug [T]est' })

local dap = require('dap')

vim.fn.sign_define('DapBreakpoint', { text='●', texthl='LspDiagnosticsDefaultError' })
vim.fn.sign_define('DapLogPoint' , { text='◉', texthl='LspDiagnosticsDefaultError' })
vim.fn.sign_define('DapStopped' , { text='➔', texthl='LspDiagnosticsDefaultInformation',
                                    linehl='CursorLine' })

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
            size = 150,
            position = 'right',
        }, {
            elements = {'repl'},
            size = 10,
            position = 'bottom',
        },
    },
    floating = {
        max_height = nil,  -- Either absolute integer or float
        max_width  = nil,  -- between 0 and 1 (size relative to screen size)
    },
}

local function dapui_eval()
	local expr = vim.fn.input('DAP expression: ')
	if vim.fn.empty(expr) ~= 0 then
		return
	end
	ui.eval(expr, {})
end

vim.keymap.set({'n', 'v'}, '<M-k>', ui.eval, {})
vim.keymap.set('n', '<M-K>', dapui_eval, {})

-- Python
-- requires the below referenced virtual environment with debugpy installed
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')

-- CPP
require('dap').adapters.lldb = {
	type = 'executable',
	command = '/usr/local/opt/llvm/bin/lldb-vscode',
	name = 'lldb',
}

local lldb = {
	name = 'Launch lldb',
	type = 'lldb',
	request = 'launch', -- could also attach to a currently running process
	program = function()
		return vim.fn.input(
			'Path to executable: ',
			vim.fn.getcwd() .. '/',
			'file'
		)
	end,
	cwd = '${workspaceFolder}',
	stopOnEntry = true,
	args = {},
	runInTerminal = false,
}

dap.configurations.rust = { lldb }
dap.configurations.cpp = { lldb }
