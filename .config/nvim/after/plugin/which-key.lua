local wk = require("which-key")

wk.register({
    ["<leader>"] = {
        ["gpd"] = {"<cmd>lua require('goto-preview').goto_preview_definition()<CR>", "[g]oto [p]review [d]efinition" },
        ["gpt"] = {"<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", "[g]oto [p]review [t]ype definition" },
        ["gpr"] = {"<cmd>lua require('goto-preview').goto_preview_references()<CR>", "[g]oto [p]review [r]eference" },
        ["gpi"] = {"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", "[g]oto [p]review [i]mplementation" },
        ["gpc"] = {"<cmd>lua require('goto-preview').close_all_win()<CR>", "[g]oto [p]review [c]lose all windows" },
        ["cp"] = {"<cmd>Coplot panel<CR>", "[C]opilot [p]anel" },
        }})
