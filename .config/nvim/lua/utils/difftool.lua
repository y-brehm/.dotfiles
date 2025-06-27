-- File: lua/utils/difftool.lua
-- Fixed version with proper quickfix timing

local M = {
  config = {
    rename = { detect = true, similarity = 0.5, max_size = 1024 * 1024 },
    highlight = { A = 'DiffAdd', D = 'DiffDelete', M = 'DiffText', R = 'DiffChange' },
  },
}

-- This variable tracks our UI state (windows and tab).
local layout = { left_win = nil, right_win = nil, tabnr = nil }

-- Helper to calculate file similarity (unchanged)
local function calculate_similarity(file1, file2)
  local size1 = vim.fn.getfsize(file1)
  local size2 = vim.fn.getfsize(file2)
  if size1 <= 0 or size2 <= 0 or size1 / size2 > 2 or size2 / size1 > 2 then return 0 end
  if size1 >= M.config.rename.max_size or size2 >= M.config.rename.max_size then return 0 end
  local ok1, content1 = pcall(vim.fn.readfile, file1)
  local ok2, content2 = pcall(vim.fn.readfile, file2)
  if not ok1 or not ok2 then return 0 end
  local common_lines, total_lines = 0, math.max(#content1, #content2)
  if total_lines == 0 then return 0 end
  local seen = {}
  for _, line in ipairs(content1) do
    if #line > 0 then seen[line] = (seen[line] or 0) + 1 end
  end
  for _, line in ipairs(content2) do
    if #line > 0 and seen[line] and seen[line] > 0 then
      seen[line] = seen[line] - 1
      common_lines = common_lines + 1
    end
  end
  return common_lines / total_lines
end

-- Sets up the isolated tabbed layout for the diff session (unchanged)
local function setup_layout(with_qf)
  if layout.tabnr and vim.api.nvim_tabpage_is_valid(layout.tabnr) and vim.api.nvim_get_current_tabpage() == layout.tabnr and layout.left_win and vim.api.nvim_win_is_valid(layout.left_win) and layout.right_win and vim.api.nvim_win_is_valid(layout.right_win) then
    return false
  end
  vim.cmd.tabnew()
  layout.tabnr = vim.api.nvim_get_current_tabpage()
  layout.left_win = vim.api.nvim_get_current_win()
  vim.cmd.vsplit()
  layout.right_win = vim.api.nvim_get_current_win()
  if with_qf then vim.cmd('botright copen') end
  return true
end

-- Edits a file in a specific window (fixed for compatibility)
local function edit_in(winnr, file)
  vim.api.nvim_win_call(winnr, function()
    local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winnr)), ':p')
    if current == (file and vim.fn.fnamemodify(file, ':p') or '') then return end
    vim.cmd.edit(vim.fn.fnameescape(file))
  end)
end

-- Sets up the diff between two files (with debug)
local function diff_files(left_file, right_file, with_qf)
  setup_layout(with_qf)
  print("DEBUG: Actually loading - LEFT window gets: " .. tostring(left_file))
  print("DEBUG: Actually loading - RIGHT window gets: " .. tostring(right_file))
  edit_in(layout.left_win, left_file)
  edit_in(layout.right_win, right_file)
  vim.cmd('diffoff!')
  vim.api.nvim_win_call(layout.left_win, vim.cmd.diffthis)
  vim.api.nvim_win_call(layout.right_win, vim.cmd.diffthis)
end

-- The directory scanning and data generation logic - FIXED VERSION
local function diff_directories(left_dir, right_dir)
  local all_paths = {}
  local function scan_directory(base_dir, side)
    local clean_base_dir = vim.fn.fnamemodify(base_dir, ':p'):gsub("[/\\]$", "")
    local files = vim.fs.find(function() return true end, { limit = math.huge, path = clean_base_dir, follow = false, type = 'file' })
    for _, full_path in ipairs(files) do
      local rel_path = full_path:sub(#clean_base_dir + 2)
      all_paths[rel_path] = all_paths[rel_path] or { left = nil, right = nil }
      all_paths[rel_path][side] = full_path
    end
  end
  scan_directory(left_dir, 'left')
  scan_directory(right_dir, 'right')
  local left_only, right_only = {}, {}
  for rel_path, files in pairs(all_paths) do
    if files.left and not files.right then
      left_only[rel_path] = files.left
    elseif files.right and not files.left then
      right_only[rel_path] = files.right
    end
  end
  local renamed = {}
  if M.config.rename.detect then
    for left_rel, left_path in pairs(left_only) do
      local best_match = { similarity = M.config.rename.similarity, path = nil }
      for right_rel, right_path in pairs(right_only) do
        local similarity = calculate_similarity(left_path, right_path)
        if similarity > best_match.similarity then
          best_match = { similarity = similarity, path = right_path, rel = right_rel }
        end
      end
      if best_match.path then
        renamed[left_rel] = best_match.rel
        all_paths[left_rel].right = best_match.path
        all_paths[best_match.rel] = nil
      end
    end
  end
  local qf_entries = {}
  local clean_left_dir = vim.fn.fnamemodify(left_dir, ':p'):gsub("[/\\]$", "")
  local clean_right_dir = vim.fn.fnamemodify(right_dir, ':p'):gsub("[/\\]$", "")
  for rel_path, files in pairs(all_paths) do
    local status = 'M'
    if not files.left then
      status = 'A'
      files.left = clean_left_dir .. '/' .. rel_path
    elseif not files.right then
      status = 'D'
      files.right = clean_right_dir .. '/' .. rel_path
    elseif renamed[rel_path] then
      status = 'R'
    end
    table.insert(qf_entries, {
      filename = files.right,
      text = status,
      user_data = { diff = true, rel = rel_path, left = files.left, right = files.right },
    })
  end
  table.sort(qf_entries, function(a, b) return a.user_data.rel < b.user_data.rel end)
  
  -- Set up the layout first
  setup_layout(true)
  
  -- Set the quickfix list
  vim.fn.setqflist({}, 'r', {
    title = 'DiffTool',
    items = qf_entries,
    quickfixtextfunc = function(info)
      local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
      local out = {}
      for item = info.start_idx, info.end_idx do
        local entry = items[item]
        table.insert(out, entry.text .. ' ' .. entry.user_data.rel)
      end
      return out
    end,
  })
  
  -- CRITICAL FIX: Store the data immediately and defer the first diff
  local qf_win_id = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win_id > 0 then
    local buf_nr = vim.api.nvim_win_get_buf(qf_win_id)
    vim.b[buf_nr].difftool_data = qf_entries
  end
  
  -- Use vim.schedule to ensure the data is attached before diffing
  vim.schedule(function()
    if #qf_entries > 0 then
      local first_entry = qf_entries[1]
      if first_entry and first_entry.user_data then
        -- Debug: Print what we're about to diff
        print("DEBUG: Diffing left=" .. tostring(first_entry.user_data.left) .. " right=" .. tostring(first_entry.user_data.right))
        diff_files(first_entry.user_data.left, first_entry.user_data.right, true)
        -- Navigate to the first quickfix entry
        vim.cmd.cfirst()
      else
        print("DEBUG: No user_data found in first entry")
      end
    else
      print("DEBUG: No quickfix entries found")
    end
  end)
end

-- Main entry point for the :DiffTool command (unchanged)
function M.diff(left, right)
  if not left or not right then
    vim.notify('Both arguments are required', vim.log.levels.ERROR)
    return
  end
  if vim.fn.isdirectory(left) == 1 and vim.fn.isdirectory(right) == 1 then
    diff_directories(left, right)
  elseif vim.fn.filereadable(left) == 1 and vim.fn.filereadable(right) == 1 then
    diff_files(left, right)
  else
    vim.notify('Both arguments must be files or directories', vim.log.levels.ERROR)
  end
end

-- The setup function - SIMPLIFIED VERSION
function M.setup(config)
  M.config = vim.tbl_deep_extend('force', M.config, config or {})
  local group = vim.api.nvim_create_augroup('myplugins-difftool', { clear = true })
  local ns_id = vim.api.nvim_create_namespace('difftool_qf')

  -- This autocommand handles quickfix buffer setup
  vim.api.nvim_create_autocmd('BufRead', {
    group = group,
    pattern = 'quickfix',
    callback = function(args)
      -- Check if our data is attached to this buffer
      if not vim.b[args.buf].difftool_data then return end

      -- Highlight the status characters
      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
      for i, line in ipairs(lines) do
        local status = line:match('^(%a) ')
        local hl_group = M.config.highlight[status]
        if hl_group then vim.api.nvim_buf_add_highlight(args.buf, ns_id, hl_group, i - 1, 0, 1) end
      end

      -- Helper function to diff current line
      local function diff_current_line()
        local qf_data = vim.b[vim.api.nvim_get_current_buf()].difftool_data
        local lnum = vim.fn.line('.')
        local entry = qf_data and qf_data[lnum]

        if entry and entry.user_data and entry.user_data.diff then
          print("DEBUG: Diffing line " .. lnum .. " - left=" .. tostring(entry.user_data.left) .. " right=" .. tostring(entry.user_data.right))
          diff_files(entry.user_data.left, entry.user_data.right, true)
          return true
        else
          vim.notify("DiffTool: Could not find data for line " .. lnum, vim.log.levels.ERROR)
          return false
        end
      end

      -- Create buffer-local mappings
      vim.keymap.set('n', '<CR>', diff_current_line, { buffer = true, noremap = true, silent = true, desc = "Run DiffTool on this entry" })
      
      -- Override j and k to trigger diff on movement
      vim.keymap.set('n', 'j', function()
        vim.cmd('normal! j')
        vim.schedule(diff_current_line)
      end, { buffer = true, noremap = true, silent = true, desc = "Move down and diff" })
      
      vim.keymap.set('n', 'k', function()
        vim.cmd('normal! k')
        vim.schedule(diff_current_line)
      end, { buffer = true, noremap = true, silent = true, desc = "Move up and diff" })
      
      -- Override arrow keys too
      vim.keymap.set('n', '<Down>', function()
        vim.cmd('normal! j')
        vim.schedule(diff_current_line)
      end, { buffer = true, noremap = true, silent = true })
      
      vim.keymap.set('n', '<Up>', function()
        vim.cmd('normal! k')
        vim.schedule(diff_current_line)
      end, { buffer = true, noremap = true, silent = true })
    end,
  })
  
  -- Defines the :DiffTool user command
  vim.api.nvim_create_user_command('DiffTool', function(opts)
    if #opts.fargs >= 2 then
      M.diff(opts.fargs[1], opts.fargs[2])
    else
      vim.notify('Usage: DiffTool <left> <right>', vim.log.levels.ERROR)
    end
  end, { nargs = '*', force = true })
end

return M
