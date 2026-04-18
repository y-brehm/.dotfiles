-- Shared background highlights applied after every colorscheme change.
-- Ensures consistent backgrounds regardless of which theme is active.
-- Text/accent colors are read from the active theme's standard highlight groups.

local M = {}

-- Fixed background palette
M.bg = "#151815"
M.bg_dark = "#1a1d1a"
M.bg_deep = "#111411"
M.border_fg = "#3a3d3a"
M.dimmed_fg = "#8a8ea0"

--- Read the fg color from an existing highlight group, with fallback.
local function get_fg(group, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and hl and hl.fg then
    return string.format("#%06x", hl.fg)
  end
  return fallback
end

function M.apply()
  local set = vim.api.nvim_set_hl

  -- Read semantic fg colors from the active colorscheme
  local fg    = get_fg("Normal", "#c0caf5")
  local info  = get_fg("DiagnosticInfo", "#0db9d7")
  local warn  = get_fg("DiagnosticWarn", "#e0af68")
  local err   = get_fg("DiagnosticError", "#db4b4b")
  local debug_fg = get_fg("Comment", "#737aa2")
  local trace = get_fg("Special", "#bb9af7")

  -- Inactive windows
  set(0, "NormalNC", { bg = M.bg_dark, fg = M.dimmed_fg })

  -- Window infrastructure
  set(0, "WinSeparator",  { fg = M.border_fg, bg = M.bg_dark })
  set(0, "NormalFloat",   { bg = M.bg_dark })
  set(0, "FloatBorder",   { fg = M.border_fg, bg = M.bg_dark })
  set(0, "FloatTitle",    { fg = fg, bg = M.bg_dark })
  set(0, "MsgArea",       { bg = M.bg_dark })
  set(0, "StatusLine",    { bg = M.bg_dark })
  set(0, "StatusLineNC",  { bg = M.bg_dark })
  set(0, "WhichKeyFloat", { bg = M.bg_deep })
  set(0, "WhichKeyNormal",{ bg = M.bg_deep })

  -- Snacks input (rename dialog, etc.)
  set(0, "SnacksInputTitle",  { fg = info, bg = M.bg_dark })
  set(0, "SnacksInputBorder", { fg = info, bg = M.bg_dark })

  -- Snacks notifications (all levels)
  for _, level in ipairs({ "Info", "Warn", "Error", "Debug", "Trace" }) do
    local level_fg = ({
      Info = info, Warn = warn, Error = err,
      Debug = debug_fg, Trace = trace,
    })[level]
    set(0, "SnacksNotifier"       .. level, { fg = fg,       bg = M.bg_dark })
    set(0, "SnacksNotifierTitle"  .. level, { fg = level_fg, bg = M.bg_dark })
    set(0, "SnacksNotifierBorder" .. level, { fg = level_fg, bg = M.bg_dark })
    set(0, "SnacksNotifierIcon"   .. level, { fg = level_fg, bg = M.bg_dark })
    set(0, "SnacksNotifierFooter" .. level, { fg = level_fg, bg = M.bg_dark })
  end

  -- Diff highlights
  set(0, "DiffAdd",    { bg = "#2a3e2a" })
  set(0, "DiffDelete", { bg = "#5f3034" })
  set(0, "DiffChange", { bg = "#3a3a20" })
  set(0, "DiffText",   { bg = "#5c5c30" })

  -- Dashboard - neutral text
  for _, group in ipairs({
    "SnacksDashboardNormal", "SnacksDashboardDesc", "SnacksDashboardFile",
    "SnacksDashboardDir", "SnacksDashboardFooter", "SnacksDashboardHeader",
    "SnacksDashboardIcon", "SnacksDashboardKey", "SnacksDashboardTerminal",
    "SnacksDashboardSpecial", "SnacksDashboardTitle",
  }) do
    set(0, group, { fg = fg })
  end
end

-- Register autocommand so highlights are reapplied after every :colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("SharedHighlights", { clear = true }),
  callback = M.apply,
})

return M
