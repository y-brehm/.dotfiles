local u = {}

u.diagnostic_signs = {
    error = ' ',
    warning = ' ',
    info = ' ',
    hint = '󱤅 ',
    other = '󰠠 ',
}

require 'trouble'.setup {
    padding = true,
    height = 11,
    use_diagnostic_signs = false,
    position = 'bottom',
    signs = u.diagnostic_signs,
    auto_preview = false
}

-- Make trouble update to the current buffer.
vim.cmd [[ autocmd BufEnter * TroubleRefresh ]]

vim.keymap.set('n', '<leader>tb', '<cmd>TroubleToggle<cr>', { desc = '[T]oggle Trou[B]le' })
