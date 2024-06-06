require("zen-mode").setup {
  window = {
    backdrop = 0.95,
    width = 120,
    height = 1,
    options = {
    },
  },
  plugins = {
    options = {
      enabled = true,
      ruler = false,
      showcmd = false,
      laststatus = 0,
    },
    twilight = { enabled = false },
    gitsigns = { enabled = true },
  },
}
