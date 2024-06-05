-- Define the clangFormat function
function clangFormat()
  vim.cmd('silent! ClangFormat')
end

-- Set up an autocmd for BufWritePost event
vim.cmd([[
  augroup AutoClangFormat
    autocmd!
    autocmd BufWritePost *.c,*.cpp,*.h lua clangFormat()
  augroup END
]])
