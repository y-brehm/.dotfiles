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

-- Startup: single maximized tab running yazi ---------------------------------
-- Launched via the `y` wrapper (not bare `yazi`) so quitting it cd's the shell
-- to the navigated dir — which, with OSC 7 in the pwsh profile, lets the
-- Ctrl+Shift+D dev layout open right there.
wezterm.on('gui-startup', function(cmd)
  local _, pane, window = wezterm.mux.spawn_window(cmd or {})
  pane:send_text('y\r')
  window:gui_window():maximize()
end)

-- Dev layout (hotkey: Ctrl+Shift+G) ------------------------------------------
-- Opens a new tab in the CURRENT pane's cwd, laid out as:
--   ┌────────────┬────────────┐
--   │  claude    │            │
--   ├────────────┤   nvim     │
--   │  yazi      │            │
--   └────────────┴────────────┘
-- Bound to a key (not auto-triggered): WezTerm has no native cwd-change event,
-- and yazi navigation doesn't update the shell cwd until exit — so a hotkey
-- fires exactly when I decide a dir is worth a full dev workspace.
-- Pull a spawn-ready path out of a pane's cwd. WezTerm reports cwd as a Url
-- (newer) or a file:// string (older); on Windows both can yield a "/C:/..."
-- form, which spawn() rejects and silently falls back to home — so normalize
-- the leading slash before a drive letter to "C:/...".
local function pane_cwd(pane)
  local uri = pane:get_current_working_dir()
  if not uri then return nil end
  local path = (type(uri) == 'userdata' and uri.file_path) or tostring(uri)
  if not path then return nil end
  path = path:gsub('^file://[^/]*', '')   -- strip scheme+host from string form
  path = path:gsub('^/([A-Za-z]:)', '%1') -- /C:/... -> C:/...
  return path
end

-- Last path component, e.g. C:/Users/me/win_dev -> win_dev
local function basename(path)
  if not path then return nil end
  return (path:gsub('[/\\]+$', '')):match('[^/\\]+$')
end

local function spawn_dev_layout(window, pane)
  -- Inherit the cwd of the pane the hotkey was pressed in.
  local cwd = pane_cwd(pane)
  local opts = cwd and { cwd = cwd } or {}

  -- New tab; its initial pane becomes the top-left (claude).
  local tab, left_top = window:mux_window():spawn_tab(opts)
  tab:set_title(basename(cwd) or 'dev')  -- name the tab after the project dir

  -- Right half (nvim), then split the left half top/bottom (yazi at the bottom).
  local right = left_top:split({ direction = 'Right', size = 0.5, cwd = cwd })
  local left_bottom = left_top:split({ direction = 'Bottom', size = 0.5, cwd = cwd })

  left_top:send_text('claude\r')
  left_bottom:send_text('yazi\r')
  right:send_text('nvim\r')

  left_top:activate()
end

-- Window ---------------------------------------------------------------------
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_decorations = 'RESIZE'  -- clean/frameless, still resizable (cross-platform)
config.window_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false

-- Tabs: slim, and hidden entirely when there's only one ----------------------
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 40

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
  { key = 'x', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },

  -- Splits — Enter splits right in cwd (like kitty new_window_with_cwd), v splits down
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'v',     mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'w',     mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = false }) },

  -- Dev workspace: new tab in current cwd → claude (top-left) / yazi (bottom-left) / nvim (right)
  { key = 'd',     mods = 'CTRL|SHIFT', action = wezterm.action_callback(spawn_dev_layout) },

  -- Pane focus — Omarchy/i3-style directional (Alt = right Option on macOS)
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection('Right') },

  -- Search + vi copy-mode (the Alacritty feel you liked: hjkl, / to search, v select, y yank)
  -- Copy-mode on '[' (tmux-style). NOT Space: macOS IME swallows Ctrl+Shift+Space.
  { key = 'f',     mods = 'CTRL|SHIFT',     action = act.Search('CurrentSelectionOrEmptyString') },
  { key = '[',     mods = 'CTRL|SHIFT',     action = act.ActivateCopyMode },

  -- Debug overlay (Lua REPL + logs). Ctrl+Shift+D is taken by the dev layout, so add Alt.
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
