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
