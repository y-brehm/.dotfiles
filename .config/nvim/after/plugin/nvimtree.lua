vim.g.loaded_netrw = true
vim.g.loaded_netrwPlugin = true

vim.keymap.set('n', '<leader>tt', '<cmd>NvimTreeToggle<cr>', { desc = '[t]ree [t]oggle' })

local renderer = {
    root_folder_label = root_label,
    indent_width = 2,
    indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = {
            corner = '╰'
        }
    },
    icons = {
        git_placement = 'after',
        modified_placement = 'after',
        padding = ' ',
        glyphs = {
            folder = {
                arrow_closed = '▶',
                arrow_open = '▼',
                default = ' ',
                open = ' ',
                empty = ' ',
                empty_open = ' ',
                symlink = '󰉒 ',
                symlink_open = '󰉒 ',

            },
            git = {
                deleted = '',
                unstaged = '',
                untracked = '',
                staged = '',
                unmerged = '',
            }
        }
    }
}

local view = {
    cursorline = false,
    hide_root_folder = false,
    signcolumn = 'no',
    width = {
        max = 40,
        min = 40,
        padding = 1
    },
}

-- Setup.
require 'nvim-tree'.setup {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = view,
    git = {
        ignore = false
    },
    renderer = renderer,
    diagnostics = {
        enable = true
    }
}

vim.cmd[[highlight NvimTreeGitNew guifg=#83a598 guibg=NONE gui=bold]]
vim.cmd[[highlight NvimTreeGitStaged guifg=#8ec07c guibg=NONE gui=bold]]
vim.cmd[[highlight NvimTreeGitMerge guifg=#b8bb26 guibg=NONE gui=bold]]
vim.cmd[[highlight NvimTreeGitRenamed guifg=#fe8019 guibg=NONE gui=bold]]
vim.cmd[[highlight NvimTreeGitDeleted guifg=#fb4934 guibg=NONE gui=bold]]
