call plug#begin('~/.vim/plugged')

" looks
Plug 'frazrepo/vim-rainbow'
Plug 'joshdick/onedark.vim'

"Telescope
Plug 'BurntSushi/ripgrep'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

call plug#end()

" BASIC
set nowrap
set breakindent
set number relativenumber
set numberwidth=4
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
let mapleader=" "

" LOOK
syntax on
colorscheme onedark
" let g:airline_theme='onedark'
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
au FileType c,cpp,objc,objcpp call rainbow#load()
set encoding=utf8
