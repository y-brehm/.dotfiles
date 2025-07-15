pcall(vim.keymap.del, 'n', '<C-h>', { buffer = true })
pcall(vim.keymap.del, 'n', '<C-j>', { buffer = true })

vim.keymap.set('n', '<leader>oi', '<Plug>OverseerTask:IncreaseDetail', { buffer = true, silent = true, desc = "Overseer: Increase Detail" })
vim.keymap.set('n', '<leader>od', '<Plug>OverseerTask:DecreaseDetail', { buffer = true, silent = true, desc = "Overseer: Decrease Detail" })
