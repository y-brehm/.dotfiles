local ts = require 'telescope'
local actions = require 'telescope.actions'
local u = {}

function u.length(table)
    local count = 0
    for _, _ in ipairs(table) do
        count = count + 1
    end
    return count
end

 u.border_chars_outer_telescope = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" }

-- Setup.
ts.setup({
    defaults = {
        sort_mru = true,
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top'
        },
        borderchars = {
            prompt = u.border_chars_outer_telescope,
            results = u.border_chars_outer_telescope,
            preview = u.border_chars_outer_telescope
        },
        border = true,
        multi_icon = '',
        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
            },
        },
        entry_prefix = '   ',
        prompt_prefix = '  🔎 ',
        selection_caret = ' ▶ ',
        hl_result_eol = true,
        results_title = "",
        winblend = 0,
        wrap_results = true
    }
})

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fz', require('telescope').extensions.zoxide.list, { desc = '[F]ind [Z]oxide' })
vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = '[F]ind [K]eymaps' })
