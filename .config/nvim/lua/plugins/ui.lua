local u = {}

u.diagnostic_signs = {
    error = ' ',
    warning = ' ',
    info = ' ',
    hint = '󱤅 ',
    other = '󰠠 ',
}


return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- night, storm, day, moon
      transparent = false,
      terminal_colors = true,
      dim_inactive = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "normal",
      },
      on_colors = function(colors)
        colors.bg = "#151815"
        colors.bg_dark = "#1a1d1a"
        colors.bg_float = "#1a1d1a"
        colors.bg_sidebar = "#1a1d1a"
        colors.bg_statusline = "#1a1d1a"
      end,
      on_highlights = function(hl, colors)
        -- Inactive windows: slightly lighter bg + dimmed text
        hl.NormalNC = { bg = "#1a1d1a", fg = "#8a8ea0" }

        -- Consistent backgrounds (match inactive bg to avoid dark bands)
        hl.WinSeparator = { fg = "#3a3d3a", bg = "#1a1d1a" }
        hl.NormalFloat = { bg = "#1a1d1a" }
        hl.FloatBorder = { fg = "#3a3d3a", bg = "#1a1d1a" }
        hl.FloatTitle = { fg = colors.fg, bg = "#1a1d1a" }
        hl.MsgArea = { bg = "#1a1d1a" }
        hl.StatusLine = { bg = "#1a1d1a" }
        hl.StatusLineNC = { bg = "#1a1d1a" }
        hl.WhichKeyFloat = { bg = "#111411" }
        hl.WhichKeyNormal = { bg = "#111411" }

        -- Diff highlights
        hl.DiffAdd = { bg = "#2a3e2a" }
        hl.DiffDelete = { bg = "#5f3034" }
        hl.DiffChange = { bg = "#3a3a20" }
        hl.DiffText = { bg = "#5c5c30" }

        -- Dashboard highlights - neutral/white text
        hl.SnacksDashboardNormal = { fg = colors.fg }
        hl.SnacksDashboardDesc = { fg = colors.fg }
        hl.SnacksDashboardFile = { fg = colors.fg }
        hl.SnacksDashboardDir = { fg = colors.fg }
        hl.SnacksDashboardFooter = { fg = colors.fg }
        hl.SnacksDashboardHeader = { fg = colors.fg }
        hl.SnacksDashboardIcon = { fg = colors.fg }
        hl.SnacksDashboardKey = { fg = colors.fg }
        hl.SnacksDashboardTerminal = { fg = colors.fg }
        hl.SnacksDashboardSpecial = { fg = colors.fg }
        hl.SnacksDashboardTitle = { fg = colors.fg }
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
            comments = { "italic" }, -- Change the style of comments
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        color_overrides = {
            mocha = {
                        base = "#151815",
                        mantle = "#1a1d1a",
                        crust = "#111411",
                        text = "#cdd6f4",     -- Default text color from Catppuccin Mocha
                        surface0 = "#313244", -- Another option for sidebar backgrounds
                    },
                },
        custom_highlights = function(colors) -- colors is the palette for the current flavour
          return {
            DiffAdd = { bg = "#2a3e2a" },
            DiffDelete = { bg = "#5f3034" },
            DiffChange = { bg = "#3a3a20" },
            DiffText = { bg = "#5c5c30" },

            -- Inactive windows: slightly lighter bg + dimmed text
            NormalNC = { bg = colors.mantle, fg = colors.overlay0 },

            -- Visible window borders
            WinSeparator = { fg = colors.surface0 },

            -- Dashboard highlights - make everything white/neutral
            SnacksDashboardNormal = { fg = colors.text },
            SnacksDashboardDesc = { fg = colors.text },
            SnacksDashboardFile = { fg = colors.text },
            SnacksDashboardDir = { fg = colors.text },
            SnacksDashboardFooter = { fg = colors.text },
            SnacksDashboardHeader = { fg = colors.text },
            SnacksDashboardIcon = { fg = colors.text },
            SnacksDashboardKey = { fg = colors.text },
            SnacksDashboardTerminal = { fg = colors.text },
            SnacksDashboardSpecial = { fg = colors.text },
            SnacksDashboardTitle = { fg = colors.text },
          }
        end,
        integrations = {
            cmp = true,
            gitsigns = true,
            neotest = true,
            treesitter = true,
            mason = true,
            lsp_trouble = true,
            dap = {
                enabled = true,
                enable_ui = true,
            },
            telescope = {
                enabled = true,
            },
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                },
                inlay_hints = {
                    background = true,
                },
            },
        },
    },
  },
    {
      "folke/trouble.nvim",
      opts = {}, -- for default options, refer to the configuration section for custom setup.
      cmd = "Trouble",
      keys = {
        {
          "<leader>xx",
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Diagnostics (Trouble)",
        },
        {
          "<leader>xX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer Diagnostics (Trouble)",
        },
        {
          "<leader>cs",
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        },
        {
          "<leader>cl",
          "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
          desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
          "<leader>xL",
          "<cmd>Trouble loclist toggle<cr>",
          desc = "Location List (Trouble)",
        },
        {
          "<leader>xQ",
          "<cmd>Trouble qflist toggle<cr>",
          desc = "Quickfix List (Trouble)",
        },
      },
    },
  {
    "rmagatti/goto-preview",
    opts={
      width = 120; -- Width of the floating window
      height = 15; -- Height of the floating window
      border = {"↖", "─" ,"┐", "│", "┘", "─", "└", "│"}; -- Border characters of the floating window
      default_mappings = false; -- Bind default mappings
      debug = false; -- Print debug information
      opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
      resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
      post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
      post_close_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
      references = { -- Configure the telescope UI for slowing the references cycling window.
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
      };
      -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
      focus_on_open = true; -- Focus the floating window when opening it.
      dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
      force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
      bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
      stack_floating_preview_windows = false, -- Whether to nest floating windows
      preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
    }
  },
{
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true
        },
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        preview_config = {
          border = 'rounded',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation (avoiding [ and ] for German keyboard)
          map('n', '<leader>gj', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Next hunk'})

          map('n', '<leader>gk', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Previous hunk'})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, {desc = 'Stage hunk'})
          map('n', '<leader>hr', gs.reset_hunk, {desc = 'Reset hunk'})
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = 'Stage selected hunks'})
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = 'Reset selected hunks'})
          map('n', '<leader>hS', gs.stage_buffer, {desc = 'Stage buffer'})
          map('n', '<leader>hR', gs.reset_buffer, {desc = 'Reset buffer'})
          map('n', '<leader>hp', gs.preview_hunk, {desc = 'Preview hunk'})
          map('n', '<leader>hi', gs.preview_hunk_inline, {desc = 'Preview hunk inline'})
          map('n', '<leader>hb', function() gs.blame_line{full=true} end, {desc = 'Blame line'})
          map('n', '<leader>hd', gs.diffthis, {desc = 'Diff this'})
          map('n', '<leader>hD', function() gs.diffthis('~') end, {desc = 'Diff this ~'})
          map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
          map('n', '<leader>hq', gs.setqflist)

          -- Toggles
          map('n', '<leader>htb', gs.toggle_current_line_blame, {desc = 'Toggle current line blame'})
          map('n', '<leader>htd', gs.toggle_deleted, {desc = 'Toggle deleted'})
          map('n', '<leader>htw', gs.toggle_word_diff, {desc = 'Toggle word diff'})

          -- Text object for hunks (still using ih as it's a standard)
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end,
      }
    },
    {'RRethy/vim-illuminate'},
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    },
    {
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with ':Gitsigns toggle_current_line_blame'
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        update_debounce = 100,
        max_file_length = 40000,
      }
    },
}
