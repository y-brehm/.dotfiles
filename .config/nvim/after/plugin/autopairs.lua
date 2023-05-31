local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
  return
end

-- change default fast_wrap
npairs.setup({
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'Search',
      highlight_grey='Comment'
    },
})


