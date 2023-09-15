local bufferline = require('bufferline')
bufferline.setup {
    options = {
        mode = "tabs", -- set to "tabs" to only show tabpages instead
        style_preset = bufferline.style_preset.minimal, -- or bufferline.style_preset.minimal,
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        truncate_names = true, -- whether or not tab names should be truncated
        tab_size = 18,
        diagnostics = false,
        offsets = {
            {
                filetype = "NvimTree",
                text = "Nvim Tree", 
                text_align = "center", 
                padding = 1,
                separator = false
            }
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        separator_style = "thin",
        --close_command = "bdelete! %d",
    },
}

vim.keymap.set('n', '<leader>bp', '<CMD>BufferLinePick<CR>', { desc = '[b]ufferline [p]ick' })
vim.keymap.set('n', '<leader>bpc', '<CMD>BufferLinePickClose<CR>', { desc = '[b]ufferline [p]ick [c]lose' })
vim.keymap.set('n', '<S-l>', '<CMD>BufferLineCycleNext<CR>')
vim.keymap.set('n', '<S-h>', '<CMD>BufferLineCyclePrev<CR>')
