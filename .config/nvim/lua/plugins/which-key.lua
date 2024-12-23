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
        { "<leader>cp", "<cmd>Coplot panel<CR>", desc = "[C]opilot [p]anel" },
        { "<leader>drt", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", desc = "[d]ebug [r]un [t]est" },
        { "<leader>fd", "<cmd>lua require('telescope.builtin').diagnostics()<CR>", desc = "[f]ind [d]iagnostics" },
        { "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>", desc = "[f]ind [f]iles" },
        { "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", desc = "[f]ind by [g]rep" },
        { "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", desc = "[f]ind [h]elp" },
        { "<leader>fk", "<cmd>lua require('telescope.builtin').keymaps()<CR>", desc = "[f]ind [k]eymaps" },
        { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "[f]ind [t]o do" },
        { "<leader>fz", "<cmd>lua require('telescope').extensions.zoxide.list()<CR>", desc = "[f]ind [z]oxide" },
        { "<leader>gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "[g]oto [p]review [c]lose all windows" },
        { "<leader>gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "[g]oto [p]review [d]efinition" },
        { "<leader>gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "[g]oto [p]review [i]mplementation" },
        { "<leader>gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "[g]oto [p]review [r]eference" },
        { "<leader>gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "[g]oto [p]review [t]ype definition" },
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "[L]azy [G]it" },
        { "<leader>nso", "<cmd>lua require('neotest').summary.open()<CR>", desc = "[n]eotest [s]ummary [o]pen" },
        { "<leader>of", "<cmd>:Oil --float " .. vim.fn.expand('%:p:h') .. "<CR>", desc = "[O]il [f]loating" },
        { "<leader>rat", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "[r]un [a]ll [t]ests" },
        { "<leader>rt", "<cmd>lua require('neotest').run.run()<CR>", desc = "[r]un [t]est" },
        { "<leader>sp", "<cmd>TroubleToggle<cr>", desc = "[s]how [p]roblems" },
        { "<leader>td", "<cmd>ToggleTerm direction=horizontal name=defaultTerminal<CR>", desc = "[t]erminal [d]efault" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float name=floatingTerminal<CR>", desc = "[t]oggle [F]loating terminal" },
        { "<leader>tt", "<cmd>Neotree toggle<CR>", desc = "[t]ree [t]oggle" },
        { "<leader>tw", "<cmd>Twilight<CR>", desc = "[t]oggle t[w]ighlight" },
        { "<leader>ze", "<cmd>lua require('zen-mode').toggle()<CR>", desc = "[Z]en [E]ditor mode" },
        })
    end,
    },
}
