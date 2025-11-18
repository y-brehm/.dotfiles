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

-- Latex compiler
g.vimtex_compiler_latexmk = {
  engine = '-xelatex'
}

-- Terminal cleanup settings
-- Restore cursor shape on exit and ensure terminal state is properly reset
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Clear terminal on exit to prevent UI artifacts
vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    callback = function()
        -- Reset terminal state with escape sequences
        -- Clear screen and reset cursor position
        io.write("\027[2J")  -- Clear entire screen
        io.write("\027[H")   -- Move cursor to home position
        io.write("\027[?25h") -- Show cursor
        io.write("\027[0m")  -- Reset all attributes
        io.flush()

        -- Give terminal a moment to process escape sequences
        vim.loop.sleep(10)
    end,
})

-- Note: TermClose cleanup removed as it interferes with plugin terminal buffers
-- (Overseer, ToggleTerm, etc.). VimLeave cleanup above is sufficient.

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
