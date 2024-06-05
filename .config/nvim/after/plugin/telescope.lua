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
