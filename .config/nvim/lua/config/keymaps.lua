local map = vim.keymap.set
-- Basic mappings
map("n", "<leader>tn", ":tabnew<CR>")
map("n", "<leader>pv", vim.cmd.Ex)
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Insert blank lines without entering insert mode
map("n", "oo", "o<Esc>k", { noremap = true, silent = true, desc = "Insert line below" })
map("n", "OO", "O<Esc>j", { noremap = true, silent = true, desc = "Insert line above" })

-- Copy/Paste
map('x', 'p', 'pgvy', { noremap = true, silent = true })
map('v', '<leader>y', '"+y', {noremap = true})
map('n', '<leader>Y', '"+yg_', {noremap = true})
map('n', '<leader>y', '"+y', {noremap = true})
map('n', '<leader>yy', '"+yy', {noremap = true})
map('n', '<leader>p', '"+p', {noremap = true})
map('n', '<leader>P', '"+P', {noremap = true})
map('v', '<leader>p', '"+p', {noremap = true})
map('v', '<leader>P', '"+P', {noremap = true})

-- Split navigation
map('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
map('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
map('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
map('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Terminal buffer navigation
vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { noremap = true, silent = true, desc = 'Terminal: Win Nav Left' })
vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { noremap = true, silent = true, desc = 'Terminal: Win Nav Down' })
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { noremap = true, silent = true, desc = 'Terminal: Win Nav Up' })
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { noremap = true, silent = true, desc = 'Terminal: Win Nav Right' })

-- Terminal normal mode
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-N>]], { noremap = true, silent = true, desc = 'Terminal: Enter Normal Mode (Dbl Esc)' })
vim.keymap.set('t', '<C-Space>', [[<C-\><C-N>]], { noremap = true, silent = true, desc = 'Terminal: Enter Normal Mode (Ctrl+Space)' })

-- Launch Host Application
local custom_actions = require("config.custom_actions")
map("n", "<leader>ola", custom_actions.launch_host_application, { desc = "Overseer: Launch Generic Host Application" })

local function prompt_and_diff_dirs()
  vim.ui.input({ prompt = "Diff Directory 1:", completion = "dir" }, function(dir1)
    if not dir1 or dir1 == "" then
      vim.notify("Diff cancelled.", vim.log.levels.WARN)
      return
    end

    vim.ui.input({ prompt = "Diff Directory 2:", completion = "dir" }, function(dir2)
      if not dir2 or dir2 == "" then
        vim.notify("Diff cancelled.", vim.log.levels.WARN)
        return
      end

      -- THIS IS THE CORRECTED PART:
      -- Defer the command execution to escape the protected UI context
      vim.schedule(function()
        local cmd = "DiffTool " .. vim.fn.fnameescape(dir1) .. " " .. vim.fn.fnameescape(dir2)
        vim.cmd(cmd)
      end)
    end)
  end)
end

map("n", "<leader>dD", prompt_and_diff_dirs, { silent = true, desc = "[D]iff [D]irectories" })

-- Merge conflict resolution mappings
map("n", "<leader>mo", ":diffget LOCAL<CR>", { desc = "[M]erge get [O]urs (LOCAL)" })
map("n", "<leader>mt", ":diffget REMOTE<CR>", { desc = "[M]erge get [T]heirs (REMOTE)" })
map("n", "<leader>mO", ":%diffget LOCAL<CR>", { desc = "[M]erge get ALL [O]urs (LOCAL)" })
map("n", "<leader>mT", ":%diffget REMOTE<CR>", { desc = "[M]erge get ALL [T]heirs (REMOTE)" })
