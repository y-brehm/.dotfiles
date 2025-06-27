return {
  -- This is a special way to load a local module.
  -- 'dir' points to your config directory, and lazy.nvim will add it to the runtime path.
  dir = vim.fn.stdpath("config"),

  -- We don't need to specify a 'name' or 'repo' as it's a local module.
  -- We'll use the config function to require and set it up.
  config = function()
    -- Require the module using its path relative to 'lua/'
    local difftool = require("utils.difftool")

    -- Call the setup function from the module.
    -- We can pass custom highlight groups here if we want,
    -- but your catppuccin theme already defines the defaults.
    difftool.setup({
      -- You can override default highlights here if needed, for example:
      -- highlight = {
      --   A = 'MyCustomAddHl',
      --   D = 'MyCustomDeleteHl',
      -- }
    })
  end,
}
