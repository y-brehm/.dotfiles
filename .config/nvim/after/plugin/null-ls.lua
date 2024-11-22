local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black.with({extra_args = {"--line-length", "100"}}),
        null_ls.builtins.diagnostics.flake8.with({extra_args = {"--max-line-length", "100"}}),
    },
})

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { remap = false })

function format_save_quit()
  vim.lsp.buf.format()
  vim.cmd('write')
  vim.cmd('quit')
end

vim.cmd [[ command! Fwq lua format_save_quit() ]]
