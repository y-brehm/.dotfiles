local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.flake8.with({
            command = "flake8",
            args = { "--max-line-length=100" },
        }),
        null_ls.builtins.completion.spell,
    },
})

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { remap = false })
