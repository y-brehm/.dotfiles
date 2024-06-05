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
        ["lf"] = {"<cmd>lua vim.lsp.buf.formatting()<CR>", "[l]sp [f]ormat" },
        ["tt"] = {"<cmd>NvimTreeToggle<CR>", "[t]ree [t]oggle" }, --check this 
        ["tr"] = {"<cmd>NvimTreeRefresh<CR>", "[t]ree [r]efresh" },
        ["tff"] = {"<cmd>NvimTreeFindFile<CR>", "[t]ree [f]ind [f]ile" },
        ["sp"] = {"<cmd>TroubleToggle<cr>","[s]how [p]roblems"},
        ["tw"] = {"<cmd>Twilight<CR>", "[T]oggle T[w]ighlight" },
        ["ff"] = {"<cmd>lua require('telescope.builtin').find_files()<CR>", "[f]ind [f]iles" },
        ["fh"] = {"<cmd>lua require('telescope.builtin').help_tags()<CR>", "[f]ind [h]elp" },
        ["fg"] = {"<cmd>lua require('telescope.builtin').live_grep()<CR>", "[f]ind by [g]rep" },
        ["fd"] = {"<cmd>lua require('telescope.builtin').diagnostics()<CR>", "[f]ind [d]iagnostics" },
        ["fz"] = {"<cmd>lua require('telescope').extensions.zoxide.list()<CR>", "[f]ind [z]oxide" },
        ["fk"] = {"<cmd>lua require('telescope.builtin').keymaps()<CR>", "[f]ind [k]eymaps" },
        ["ft"] = {"<cmd>TodoTelescope<CR>", "[f]ind [t]o do" },
        }})
