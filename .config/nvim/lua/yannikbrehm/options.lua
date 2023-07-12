-- :help options
local options = {
    cursorline = true,
    updatetime = 300,
    nu = true,
    relativenumber = true,
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    smartindent = true,
    wildmenu = true,
    wrap = false,
    termguicolors = true,
    hlsearch = false,
    incsearch = true,
    scrolloff = 8,
    swapfile = false,
    clipboard = 'unnamedplus',
    cmdheight = 0,
}

for key, value in pairs(options) do
    vim.opt[key] = value
end

vim.g.noswapfile = 1
