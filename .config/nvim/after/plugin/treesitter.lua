require'nvim-treesitter.configs'.setup {
  ensure_installed = { "cpp", "python", "javascript", "c", "lua"},
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
