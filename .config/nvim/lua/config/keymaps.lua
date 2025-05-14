local map = vim.keymap.set

-- Basic mappings
map("n", "<leader>tn", ":tabnew<CR>")
map("n", "<leader>pv", vim.cmd.Ex)
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

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
