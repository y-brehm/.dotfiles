return {
    {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
    config = function()
    local wk = require("which-key")

    wk.add({
        { "<leader>S", "<cmd>lua require('spectre').toggle()<CR>", desc = "[S]pectre" },
        { "<leader>Sf", "<cmd>lua require('spectre').open_file_search({search_text=vim.fn.expand('<cword>')})<CR>", desc = "[S]earch in [F]ile" },
        { "<leader>Sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", desc = "[S]earch current [w]ord" },
        { "<leader>drt", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", desc = "[d]ebug [r]un [t]est" },
        { "<leader>fd", "<cmd>lua require('telescope.builtin').diagnostics()<CR>", desc = "[f]ind [d]iagnostics" },
        { "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>", desc = "[f]ind [f]iles" },
        { "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", desc = "[f]ind by [g]rep" },
        { "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", desc = "[f]ind [h]elp" },
        { "<leader>fk", "<cmd>lua require('telescope.builtin').keymaps()<CR>", desc = "[f]ind [k]eymaps" },
        { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "[f]ind [t]o do" },
        { "<leader>fz", "<cmd>lua require('telescope').extensions.zoxide.list()<CR>", desc = "[f]ind [z]oxide" },
        { "<leader>pc", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "goto [p]review [c]lose all windows" },
        { "<leader>pd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "goto [p]review [d]efinition" },
        { "<leader>pi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "goto [p]review [i]mplementation" },
        { "<leader>pr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "goto [p]review [r]eference" },
        { "<leader>pt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "goto [p]review [t]ype definition" },
        { "<leader>nso", "<cmd>lua require('neotest').summary.open()<CR>", desc = "[n]eotest [s]ummary [o]pen" },
        { "<leader>rat", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "[r]un [a]ll [t]ests" },
        { "<leader>rt", "<cmd>lua require('neotest').run.run()<CR>", desc = "[r]un [t]est" },
        { "<leader>sp", "<cmd>TroubleToggle<cr>", desc = "[s]how [p]roblems" },
        { "<leader>tw", "<cmd>Twilight<CR>", desc = "[t]oggle t[w]ighlight" },
        { "<leader>lg", function() require("snacks.lazygit").open(opts) end, desc = "[L]azy [G]it" },
        { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>go", function() require("snacks.gitbrowse").open() end, desc = "[G]it [O]pen file in browser" },
        { "<leader>gr", function() require("snacks.gitbrowse").open({ what = "repo" }) end, desc = "[G]it open [R]epo" },
        { "<leader>fG", function()
            local fixed_args = vim.deepcopy(require('telescope.config').values.vimgrep_arguments)
            table.insert(fixed_args, '--fixed-strings')
            require('telescope.builtin').live_grep({
              vimgrep_arguments = fixed_args
            })
          end,
          desc = "[f]ind by [G]rep (fixed string)"
        },
        })
    end,
    },
}
