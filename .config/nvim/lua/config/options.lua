local opt = vim.opt
local g = vim.g

-- General
opt.cursorline = false
opt.updatetime = 300
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wildmenu = true
opt.wrap = false
opt.termguicolors = true
opt.hlsearch = false
opt.incsearch = true
opt.scrolloff = 8
opt.swapfile = false
opt.clipboard = 'unnamedplus'
opt.signcolumn = 'yes'

g.noswapfile = true
g.loaded_netrw = true
g.loaded_netrwPlugin = true

-- Latex compiler
g.vimtex_compiler_latexmk = {
  engine = '-xelatex'
}

-- In options.lua
if vim.fn.has('win32') == 1 then
    -- Use PowerShell as the default shell on Windows
    opt.shell = "powershell"
    opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellquote = ""
    opt.shellxquote = ""
end
