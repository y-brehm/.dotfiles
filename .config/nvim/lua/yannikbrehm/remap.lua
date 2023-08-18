vim.g.mapleader = " "

-- create new tab
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>")

-- block nvim editor (causes error)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- move text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y', {noremap = true})
vim.keymap.set('n', '<leader>Y', '"+yg_', {noremap = true})
vim.keymap.set('n', '<leader>y', '"+y', {noremap = true})
vim.keymap.set('n', '<leader>yy', '"+yy', {noremap = true})

-- Paste from clipboard
vim.keymap.set('n', '<leader>p', '"+p', {noremap = true})
vim.keymap.set('n', '<leader>P', '"+P', {noremap = true})
vim.keymap.set('v', '<leader>p', '"+p', {noremap = true})
vim.keymap.set('v', '<leader>P', '"+P', {noremap = true})

-- Move between splits
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Spectre
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
})
