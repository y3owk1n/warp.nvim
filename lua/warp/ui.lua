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

---Set standard buffer options
---@param bufnr integer The buffer number
---@param ft string The filetype
---@return nil
---@usage `require('warp.ui').set_standard_buf_options(bufnr, ft)`
function M.set_standard_buf_options(bufnr, ft)
  api.nvim_set_option_value("filetype", ft, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("bufhidden", "wipe", { scope = "local", buf = bufnr })
  api.nvim_set_option_value("buftype", "nofile", { scope = "local", buf = bufnr })
  api.nvim_set_option_value("swapfile", false, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("modifiable", false, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("buflisted", false, { scope = "local", buf = bufnr })
end

---Render the warp list
---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[] The list of items
---@param target_win? integer The window number to render the list
---@param active_bufnr? integer The active buffer number
---@param ft_name string The filetype name
---@return nil
---@usage `require('warp.ui').render_warp_list(parent_item, warp_list, target_win, active_bufnr, ft_name)`
function M.render_warp_list(parent_item, warp_list, target_win, active_bufnr, ft_name)
  local title = "list"

  local bufnr = active_bufnr

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  end

  api.nvim_set_option_value("modifiable", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", false, { scope = "local", buf = bufnr })

  local lines, active_idx, line_data = M.get_formatted_list_items(parent_item, warp_list)

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  M.set_list_item_hl_fn(bufnr, lines, line_data)
  M.set_standard_buf_options(bufnr, ft_name)

  local line_widths = vim.tbl_map(vim.fn.strdisplaywidth, lines)
  local max_line_width = math.max(unpack(line_widths), 60)
  local max_height = #lines < 8 and 8 or math.min(#lines, vim.o.lines - 3)

  ---@type vim.api.keyset.win_config
  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = max_line_width,
    height = max_height,
    row = math.floor((vim.o.lines - max_height) / 2),
    col = math.floor((vim.o.columns - max_line_width) / 2),
    title = string.format("'warp.nvim' %s", title),
  }

  local warp_list_win_id = target_win or api.nvim_open_win(bufnr, false, win_opts)

  vim.wo[warp_list_win_id].cursorline = true

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
        M.render_warp_list(parent_item, warp_list, warp_list_win_id, bufnr, ft_name)
        local validated_cursor_row = old > #warp_list and #warp_list or old
        pcall(api.nvim_win_set_cursor, warp_list_win_id, { validated_cursor_row, 0 })
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
        M.render_warp_list(parent_item, warp_list, warp_list_win_id, bufnr, ft_name)
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
        M.render_warp_list(parent_item, warp_list, warp_list_win_id, bufnr, ft_name)
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

  ---Setup for showing help window keymaps
  for _, key in ipairs(keymaps.show_help) do
    utils.buf_set_keymap(bufnr, key, function()
      M.render_help()
    end)
  end

  vim.api.nvim_set_current_win(warp_list_win_id)
end

---Render the help window
---@param target_win? integer The window number to render the list
---@return nil
---@usage `require('warp.ui').render_help(target_win)`
function M.render_help(target_win)
  local ft = "warp-help"

  local title = "help"

  local _, _, active_warp_help_bufnr = M.is_ft_win_active(ft)

  local bufnr = active_warp_help_bufnr

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  end

  api.nvim_set_option_value("modifiable", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", false, { scope = "local", buf = bufnr })

  local lines, line_data = M.get_formatted_help_lines()

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  M.set_list_item_hl_fn(bufnr, lines, line_data)
  M.set_standard_buf_options(bufnr, ft)

  local line_widths = vim.tbl_map(vim.fn.strdisplaywidth, lines)
  local max_line_width = math.max(unpack(line_widths))

  ---@type vim.api.keyset.win_config
  local win_opts = {
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 0,
    width = max_line_width,
    height = #lines,
    title = string.format("'warp.nvim' %s", title),
  }

  local warp_help_win_id = target_win or api.nvim_open_win(bufnr, false, win_opts)

  vim.wo[warp_help_win_id].cursorline = true

  if not warp_help_win_id then
    notify.error("Failed to open native float window for warp help")
    return
  end

  ---Start setting keymaps
  local default_keymaps = require("warp.config").defaults.keymaps or {}
  local keymaps = require("warp.config").config.keymaps or default_keymaps

  ---Setup for quit keymaps
  for _, key in ipairs(keymaps.quit) do
    utils.buf_set_keymap(bufnr, key, function()
      M.close_win(warp_help_win_id)
    end)
  end

  vim.api.nvim_set_current_win(warp_help_win_id)
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

---Find if the the given filetype window is active and get it's detail
---@param ft string The filetype
---@return boolean is_active window is active
---@return integer|nil win window id
---@return integer|nil bufnr buffer id
---@usage `require('warp.ui').is_ft_win_active(ft)`
function M.is_ft_win_active(ft)
  local wins = api.nvim_list_wins()

  for _, win in ipairs(wins) do
    local bufnr = api.nvim_win_get_buf(win)
    if api.nvim_get_option_value("filetype", { scope = "local", buf = bufnr }) == ft then
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

    local is_file_exists = require("warp.utils").file_exists(entry.path)

    ---@diagnostic disable-next-line: need-check-nil
    local formatted_line_data = utils.parse_format_fn_result(formatter_fn(entry, idx, is_active, is_file_exists))

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

---@return string[] lines The formatted lines
---@return Warp.FormattedLineOpts[] formatted_entry The formatted entry
---@usage `require('warp.ui').get_help_lines()`
function M.get_formatted_help_lines()
  local lines = {}
  local formatted_raw_data = {}

  local keymaps = require("warp.config").defaults.keymaps or {}

  ---@type table<string, string>
  local description_map = {
    quit = "Quit warp list",
    select = "Select current item",
    split_horizontal = "Select current item & split horizontally",
    split_vertical = "Select current item & split vertically",
    delete = "Delete current item",
    move_up = "Move current item upwards",
    move_down = "Move current item downwards",
    show_help = "Show help menu",
  }

  ---@type number
  local longest_description_char = 0

  for _, description in pairs(description_map) do
    local description_len = vim.fn.strdisplaywidth(description)
    if description_len > longest_description_char then
      longest_description_char = description_len
    end
  end

  for key, value in pairs(keymaps) do
    local to_render_description = description_map[key] or "No description"

    local description_len = vim.fn.strdisplaywidth(to_render_description)

    if description_len < longest_description_char then
      to_render_description = to_render_description .. string.rep(" ", longest_description_char - description_len)
    end

    ---@diagnostic disable-next-line: need-check-nil
    local formatted_line_data = utils.parse_format_fn_result(builtins.help_item_format_fn(value, to_render_description))

    local formatted_line = utils.convert_parsed_format_result_to_string(formatted_line_data)

    table.insert(lines, formatted_line)
    table.insert(formatted_raw_data, formatted_line_data)
  end

  return lines, formatted_raw_data
end

return M
