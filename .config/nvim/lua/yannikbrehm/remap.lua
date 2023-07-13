vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

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

