---@mod warp.nvim.ui UI

---@brief [[
---UI related implementations
---@brief ]]

local M = {}

local api = vim.api
local str_utfindex = vim.str_utfindex
local builtins = require("warp.builtins")
local events = require("warp.events")
local notify = require("warp.notifier")
local utils = require("warp.utils")

local ns = api.nvim_create_namespace("warp_list_ns")

---Create a floating window for native
---@param bufnr integer The buffer to open
---@param title? string The title appended after `Time Machine`
---@param target_win? integer The window number to render the list
---@return integer|nil win_id The window handle
---@usage `require('warp.ui').create_native_float_win(bufnr, title, target_win)`
function M.create_native_float_win(bufnr, title, target_win)
  if target_win then
    return target_win
  end

  local config_float_opts = require("warp.config").config.float_opts or {}

  ---@type vim.api.keyset.win_config
  local win_opts = {
    relative = config_float_opts.relative,
    anchor = config_float_opts.anchor,
    style = "minimal",
    width = config_float_opts.width,
    height = config_float_opts.height,
    title = "Warp" .. (title and (" - " .. title) or ""),
    title_pos = "left",
    border = config_float_opts.border,
    zindex = config_float_opts.zindex,
    focusable = config_float_opts.focusable,
  }

  win_opts.width = math.floor(vim.o.columns * win_opts.width)
  win_opts.height = math.floor(vim.o.lines * win_opts.height)
  win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
  win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)

  local win = api.nvim_open_win(bufnr, true, win_opts)

  return win
end

---Set standard buffer options
---@param bufnr integer The buffer number
---@param ft string The filetype
---@return nil
---@usage `require('warp.ui').set_standard_buf_options(bufnr, ft)`
function M.set_standard_buf_options(bufnr, ft)
  api.nvim_set_option_value("filetype", ft, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("buftype", "nofile", { scope = "local", buf = bufnr })
  api.nvim_set_option_value("bufhidden", "wipe", { scope = "local", buf = bufnr })
  api.nvim_set_option_value("swapfile", false, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("modifiable", false, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("buflisted", false, { scope = "local", buf = bufnr })
end

---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[] The list of items
---@param target_win? integer The window number to render the list
---@return nil
---@usage `require('warp.ui').render_warp_list(parent_item, warp_list, target_win)`
function M.render_warp_list(parent_item, warp_list, target_win)
  local lines, active_idx, line_data = M.get_formatted_list_items(parent_item, warp_list)

  local _, _, active_warp_list_bufnr = M.is_warp_list_win_active()

  local bufnr = active_warp_list_bufnr

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  else
    api.nvim_set_option_value("modifiable", true, { scope = "local", buf = bufnr })
    api.nvim_set_option_value("readonly", false, { scope = "local", buf = bufnr })
  end

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  M.set_list_item_hl_fn(bufnr, lines, line_data)

  M.set_standard_buf_options(bufnr, "warp-list")

  local title = "List"

  local warp_list_win_id = M.create_native_float_win(bufnr, title, target_win)

  if not warp_list_win_id then
    notify.error("Failed to open native float window for warp list")
    return
  end

  ---Set the cursor to the current sequence
  if active_idx then
    api.nvim_win_set_cursor(warp_list_win_id, { active_idx, 0 })
  end

  ---Start setting keymaps
  local default_keymaps = require("warp.config").defaults.keymaps or {}
  local keymaps = require("warp.config").config.keymaps or default_keymaps
  local warp = require("warp")

  ---Setup for quit keymaps
  for _, key in ipairs(keymaps.quit) do
    utils.buf_set_keymap(bufnr, key, function()
      M.close_win(warp_list_win_id)
      events.emit(events.constants.close_list_win)
    end)
  end

  ---Setup for select keymaps
  for _, key in ipairs(keymaps.select) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_win_id)
      events.emit(events.constants.close_list_win)

      warp.goto_index(line_num)
    end)
  end

  ---Setup for select and horizontal split keymaps
  for _, key in ipairs(keymaps.split_horizontal) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_win_id)
      events.emit(events.constants.close_list_win)

      vim.cmd("split")

      warp.goto_index(line_num)
    end)
  end

  ---Setup for select and vertical split keymaps
  for _, key in ipairs(keymaps.split_vertical) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_win_id)
      events.emit(events.constants.close_list_win)

      vim.cmd("vsplit")

      warp.goto_index(line_num)
    end)
  end

  ---Setup for delete keymaps
  for _, key in ipairs(keymaps.delete) do
    utils.buf_set_keymap(bufnr, key, function()
      local old = api.nvim_win_get_cursor(0)[1]
      require("warp.list").action.remove_one(old)
      if #warp_list > 0 then
        M.render_warp_list(parent_item, warp_list, warp_list_win_id)
        pcall(api.nvim_win_set_cursor, warp_list_win_id, { math.max(1, old), 0 })
      else
        M.close_win(warp_list_win_id)
        events.emit(events.constants.close_list_win)

        notify.info("Warp List is emptied")
      end
    end)
  end

  ---Setup for move up keymaps
  for _, key in ipairs(keymaps.move_up) do
    utils.buf_set_keymap(bufnr, key, function()
      local from_idx = api.nvim_win_get_cursor(0)[1]
      local to_idx = from_idx - 1

      if to_idx == 0 then
        return
      end

      local ok = require("warp.list").action.move_to_index(from_idx, from_idx - 1)

      if ok then
        M.render_warp_list(parent_item, warp_list, warp_list_win_id)
        pcall(api.nvim_win_set_cursor, warp_list_win_id, { math.max(1, to_idx), 0 })
      end
    end)
  end

  ---Setup for move down keymaps
  for _, key in ipairs(keymaps.move_down) do
    utils.buf_set_keymap(bufnr, key, function()
      local from_idx = api.nvim_win_get_cursor(0)[1]
      local to_idx = from_idx + 1

      if to_idx > #warp_list then
        return
      end

      local ok = require("warp.list").action.move_to_index(from_idx, to_idx)

      if ok then
        M.render_warp_list(parent_item, warp_list, warp_list_win_id)
        pcall(api.nvim_win_set_cursor, warp_list_win_id, { math.min(#warp_list, to_idx), 0 })
      end
    end)
  end

  ---Setup quick 1-9 action
  for idx = 1, 9 do
    utils.buf_set_keymap(bufnr, tostring(idx), function()
      M.close_win(warp_list_win_id)
      events.emit(events.constants.close_list_win)

      warp.goto_index(idx)
    end)
  end
end

---Close a window
---@param win? integer The window number
---@return nil
---@usage `require('warp.ui').close_win(win)`
function M.close_win(win)
  if win and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
end

---Find if the warp list window is active and get it's detail
---@return boolean is_active window is active
---@return integer|nil win window id
---@return integer|nil bufnr buffer id
---@usage `require('warp.ui').is_warp_list_win_active()`
function M.is_warp_list_win_active()
  local wins = api.nvim_list_wins()

  for _, win in ipairs(wins) do
    local bufnr = api.nvim_win_get_buf(win)
    if api.nvim_get_option_value("filetype", { scope = "local", buf = bufnr }) == "warp-list" then
      return true, win, bufnr
    end
  end

  return false, nil, nil
end

---Render the entries as lines
---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[] The list of items
---@return string[] lines The formatted lines
---@return number|nil active_idx The active index
---@return Warp.FormattedLineOpts[] formatted_raw_data The raw data of the formatted lines
---@usage `require("warp.ui").get_formatted_list_items(parent_item, warp_list)`
function M.get_formatted_list_items(parent_item, warp_list)
  local lines = {}
  local formatted_raw_data = {}

  ---@type number|nil
  local active_idx

  local config = require("warp.config").config

  local formatter_fn = builtins.list_item_format_fn

  if type(config.list_item_format_fn) == "function" then
    formatter_fn = config.list_item_format_fn
  else
    notify.warn("`list_item_format_fn` is not a function, fallback to default implementation")
  end

  for idx, entry in ipairs(warp_list) do
    local is_active = parent_item and entry.path == parent_item.path

    if is_active then
      active_idx = idx
    end

    ---@diagnostic disable-next-line: need-check-nil
    local formatted_line_data = utils.parse_format_fn_result(formatter_fn(entry, idx, is_active))

    local formatted_line = utils.convert_parsed_format_result_to_string(formatted_line_data)

    lines[idx] = formatted_line
    formatted_raw_data[idx] = formatted_line_data
  end

  return lines, active_idx, formatted_raw_data
end

---Set the highlight for the list items
---@param bufnr number The buffer number
---@param lines string[] The lines in the buffer
---@param line_data Warp.ListItem[] The list items
---@return nil
---@usage `require("warp.ui").set_list_item_hl_fn(bufnr, lines, line_data)`
function M.set_list_item_hl_fn(bufnr, lines, line_data)
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for line_number, line in ipairs(line_data) do
    local actual_line = lines[line_number]

    for _, data in ipairs(line) do
      if data.hl_group then
        local byte_start = actual_line:find(data.display_text, 1, true)

        local hl_item_start_col = str_utfindex(actual_line:sub(1, byte_start - 1), "utf-8")
        local hl_item_end_col = hl_item_start_col + str_utfindex(data.display_text, "utf-8")

        if hl_item_start_col then
          api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, hl_item_start_col, {
            end_col = hl_item_end_col,
            hl_group = data.hl_group,
          })
        end
      end
    end
  end
end

return M
