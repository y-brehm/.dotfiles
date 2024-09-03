local wk = require("which-key")

wk.register({
    ["<leader>"] = {
        ["cp"] = {"<cmd>Coplot panel<CR>", "[C]opilot [p]anel" },
        ["gpd"] = {"<cmd>lua require('goto-preview').goto_preview_definition()<CR>", "[g]oto [p]review [d]efinition" },
        ["gpt"] = {"<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", "[g]oto [p]review [t]ype definition" },
        ["gpr"] = {"<cmd>lua require('goto-preview').goto_preview_references()<CR>", "[g]oto [p]review [r]eference" },
        ["gpi"] = {"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", "[g]oto [p]review [i]mplementation" },
        ["gpc"] = {"<cmd>lua require('goto-preview').close_all_win()<CR>", "[g]oto [p]review [c]lose all windows" },
        ["S"] = {"<cmd>lua require('spectre').toggle()<CR>", "[S]pectre"},
        ["Sw"] = {"<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "[S]earch current [w]ord"},
        ["Sf"] = {"<cmd>lua require('spectre').open_file_search({search_text=vim.fn.expand('<cword>')})<CR>", "[S]earch in [F]ile"},
        ["rt"] = {"<cmd>lua require('neotest').run.run()<CR>", "[r]un [t]est" },
        ["drt"] = {"<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", "[d]ebug [r]un [t]est" },
        ["rat"] = {"<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "[r]un [a]ll [t]ests" },
        ["nso"] = {"<cmd>lua require('neotest').summary.open()<CR>", "[n]eotest [s]ummary [o]pen" },
        ["tt"] = {"<cmd>NvimTreeToggle<CR>", "[t]ree [t]oggle" },
        ["tr"] = {"<cmd>NvimTreeRefresh<CR>", "[t]ree [r]efresh" },
        ["tw"] = {"<cmd>Twilight<CR>", "[t]oggle t[w]ighlight" },
        ["td"] = {"<cmd>ToggleTerm direction=horizontal name=defaultTerminal<CR>", "[t]erminal [d]efault" },
        ["tf"] = {"<cmd>ToggleTerm direction=float name=floatingTerminal<CR>", "[t]oggle [F]loating terminal" },
        ["sp"] = {"<cmd>TroubleToggle<cr>","[s]how [p]roblems"}, --check this
        ["ff"] = {"<cmd>lua require('telescope.builtin').find_files()<CR>", "[f]ind [f]iles" },
        ["fh"] = {"<cmd>lua require('telescope.builtin').help_tags()<CR>", "[f]ind [h]elp" },
        ["fg"] = {"<cmd>lua require('telescope.builtin').live_grep()<CR>", "[f]ind by [g]rep" },
        ["fd"] = {"<cmd>lua require('telescope.builtin').diagnostics()<CR>", "[f]ind [d]iagnostics" },
        ["fz"] = {"<cmd>lua require('telescope').extensions.zoxide.list()<CR>", "[f]ind [z]oxide" },
        ["fk"] = {"<cmd>lua require('telescope.builtin').keymaps()<CR>", "[f]ind [k]eymaps" },
        ["ft"] = {"<cmd>TodoTelescope<CR>", "[f]ind [t]o do" },
        ["ze"] = {"<cmd>lua require('zen-mode').toggle()<CR>", "[Z]en [E]ditor mode" },
        ["of"] = {"<cmd>:Oil --float " .. vim.fn.expand('%:p:h') .. "<CR>", "[O]il [f]loating" },
        ["lg"] = {"<cmd>LazyGit<cr>", "[L]azy [G]it"}
        }})
