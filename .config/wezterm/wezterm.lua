-- WezTerm — single cross-platform config. Ported from ~/.config/kitty/kitty.conf.
-- Native tabs / splits / search / vi copy-mode, so no multiplexer needed.

local wezterm = require('wezterm')
local act = wezterm.action
local config = wezterm.config_builder()

-- Font (from kitty) ----------------------------------------------------------
config.font = wezterm.font_with_fallback({ 'CodeNewRoman Nerd Font Mono' })
config.font_size = 16.0

-- Theme ----------------------------------------------------------------------
-- Built-in scheme matching your kitty Tokyo Night. Swap the string to try
-- another, e.g. 'Catppuccin Mocha'. List all: `wezterm ls-fonts` / docs.
config.color_scheme = 'Tokyo Night'

-- Start maximized (fills the screen but keeps decorations — not fullscreen) ---
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Window ---------------------------------------------------------------------
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_decorations = 'RESIZE'  -- clean/frameless, still resizable (cross-platform)
config.window_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false

-- Tabs: slim, and hidden entirely when there's only one ----------------------
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 24

-- Cursor: solid block, no blink (mirrors kitty) ------------------------------
config.default_cursor_style = 'SteadyBlock'

config.scrollback_lines = 100000

-- macOS: right Option sends Alt/Meta for the keybinds below + nvim.
-- Left Option stays as compose for special characters. (Ignored off macOS.)
config.send_composed_key_when_right_alt_is_pressed = false

-- Keybindings ----------------------------------------------------------------
config.keys = {
  -- Tabs (echoes your kitty ctrl+shift+h/l muscle memory)
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },

  -- Splits — Enter splits right in cwd (like kitty new_window_with_cwd), d splits down
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'd',     mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'x',     mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = false }) },

  -- Pane focus — Omarchy/i3-style directional (Alt = right Option on macOS)
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection('Right') },

  -- Search + vi copy-mode (the Alacritty feel you liked: hjkl, / to search, v select, y yank)
  -- Copy-mode on '[' (tmux-style). NOT Space: macOS IME swallows Ctrl+Shift+Space.
  { key = 'f',     mods = 'CTRL|SHIFT',     action = act.Search('CurrentSelectionOrEmptyString') },
  { key = '[',     mods = 'CTRL|SHIFT',     action = act.ActivateCopyMode },

  -- Debug overlay (Lua REPL + logs). Ctrl+Shift+D is taken by split-down, so add Alt.
  { key = 'd',     mods = 'CTRL|SHIFT|ALT', action = act.ShowDebugOverlay },
}

-- Copy/paste on macOS uses Cmd+C / Cmd+V (defaults). Selecting text copies it.

-- Shell ----------------------------------------------------------------------
-- On Windows WezTerm otherwise defaults to %ComSpec% (cmd.exe), which never
-- loads the PowerShell profile (so aliases like `ls`->lsd are missing). Launch
-- PowerShell 7 instead. On macOS/Linux WezTerm uses your login shell ($SHELL),
-- so this branch is skipped there.
if wezterm.target_triple:find('windows') then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

return config
