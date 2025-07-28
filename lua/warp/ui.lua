---@mod warp.nvim.ui UI

---@brief [[
---UI related implementations
---@brief ]]

local M = {}

local api = vim.api
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
---@param active_winid? integer The active window to render the list, if exists then will use it
---@param active_bufnr? integer The active buffer number
---@param ft_name string The filetype name
---@return nil
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.ui').render_warp_list(parent_item, warp_list, active_winid, active_bufnr, ft_name)`
function M.render_warp_list(parent_item, warp_list, active_winid, active_bufnr, ft_name)
  local title = "list"

  local bufnr = active_bufnr

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  end

  api.nvim_set_option_value("modifiable", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", false, { scope = "local", buf = bufnr })

  local lines, active_index, line_data = M.get_formatted_list_items(parent_item, warp_list)

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  M.set_list_item_hl_fn(bufnr, line_data)
  M.set_standard_buf_options(bufnr, ft_name)

  local line_widths = vim.tbl_map(vim.fn.strdisplaywidth, lines)
  local max_line_width = math.max(unpack(line_widths), 60)
  local max_height = #lines < 8 and 8 or math.min(#lines, vim.o.lines - 3)

  local user_win_opts = require("warp.config").config.window.list or {}

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

  if type(user_win_opts) == "table" then
    win_opts = vim.tbl_deep_extend("force", win_opts, user_win_opts)
  end

  if type(user_win_opts) == "function" then
    win_opts = vim.tbl_deep_extend("force", win_opts, user_win_opts(lines))
  end

  local warp_list_winid = active_winid or api.nvim_open_win(bufnr, false, win_opts)

  vim.wo[warp_list_winid].cursorline = vim.o.cursorline

  if not warp_list_winid then
    notify.error("Failed to open native float window for warp list")
    return
  end

  ---Set the cursor to the current active index
  if active_index then
    api.nvim_win_set_cursor(warp_list_winid, { active_index, 0 })
  end

  ---Start setting keymaps
  local default_keymaps = require("warp.config").defaults.keymaps or {}
  local keymaps = require("warp.config").config.keymaps or default_keymaps
  local warp = require("warp")

  ---Setup for quit keymaps
  for _, key in ipairs(keymaps.quit) do
    utils.buf_set_keymap(bufnr, key, function()
      M.close_win(warp_list_winid)
      events.emit(events.constants.close_list_win)
    end)
  end

  ---Setup for select keymaps
  for _, key in ipairs(keymaps.select) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_winid)
      events.emit(events.constants.close_list_win)

      warp.goto_index(line_num)
    end)
  end

  ---Setup for select and horizontal split keymaps
  for _, key in ipairs(keymaps.split_horizontal) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_winid)
      events.emit(events.constants.close_list_win)

      vim.cmd("split")

      warp.goto_index(line_num)
    end)
  end

  ---Setup for select and vertical split keymaps
  for _, key in ipairs(keymaps.split_vertical) do
    utils.buf_set_keymap(bufnr, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]

      M.close_win(warp_list_winid)
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
        M.render_warp_list(parent_item, warp_list, warp_list_winid, bufnr, ft_name)
        local validated_cursor_row = old > #warp_list and #warp_list or old
        pcall(api.nvim_win_set_cursor, warp_list_winid, { validated_cursor_row, 0 })
      else
        M.close_win(warp_list_winid)
        events.emit(events.constants.close_list_win)

        notify.info("Warp List is emptied")
      end
    end)
  end

  ---Setup for move up keymaps
  for _, key in ipairs(keymaps.move_up) do
    utils.buf_set_keymap(bufnr, key, function()
      local from_index = api.nvim_win_get_cursor(0)[1]
      local to_index = from_index - 1

      if to_index == 0 then
        return
      end

      local ok = require("warp.list").action.move_to_index(from_index, from_index - 1)

      if ok then
        M.render_warp_list(parent_item, warp_list, warp_list_winid, bufnr, ft_name)
        pcall(api.nvim_win_set_cursor, warp_list_winid, { math.max(1, to_index), 0 })
      end
    end)
  end

  ---Setup for move down keymaps
  for _, key in ipairs(keymaps.move_down) do
    utils.buf_set_keymap(bufnr, key, function()
      local from_index = api.nvim_win_get_cursor(0)[1]
      local to_index = from_index + 1

      if to_index > #warp_list then
        return
      end

      local ok = require("warp.list").action.move_to_index(from_index, to_index)

      if ok then
        M.render_warp_list(parent_item, warp_list, warp_list_winid, bufnr, ft_name)
        pcall(api.nvim_win_set_cursor, warp_list_winid, { math.min(#warp_list, to_index), 0 })
      end
    end)
  end

  ---Setup quick 1-9 action
  for index = 1, 9 do
    utils.buf_set_keymap(bufnr, tostring(index), function()
      M.close_win(warp_list_winid)
      events.emit(events.constants.close_list_win)

      warp.goto_index(index)
    end)
  end

  ---Setup for showing help window keymaps
  for _, key in ipairs(keymaps.show_help) do
    utils.buf_set_keymap(bufnr, key, function()
      M.render_help()
    end)
  end

  vim.api.nvim_set_current_win(warp_list_winid)
end

---Render the help window
---@param active_winid? integer The active window to render the list, if exists then will use it
---@return nil
---@usage `require('warp.ui').render_help(active_winid)`
function M.render_help(active_winid)
  local ft_name = "warp-help"

  local title = "help"

  local _, _, active_warp_help_bufnr = M.is_ft_win_active(ft_name)

  local bufnr = active_warp_help_bufnr

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
  end

  api.nvim_set_option_value("modifiable", true, { scope = "local", buf = bufnr })
  api.nvim_set_option_value("readonly", false, { scope = "local", buf = bufnr })

  local lines, line_data = M.get_formatted_help_lines()

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  M.set_list_item_hl_fn(bufnr, line_data)
  M.set_standard_buf_options(bufnr, ft_name)

  local line_widths = vim.tbl_map(vim.fn.strdisplaywidth, lines)
  local max_line_width = math.max(unpack(line_widths))

  local user_win_opts = require("warp.config").config.window.help or {}

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

  if type(user_win_opts) == "table" then
    win_opts = vim.tbl_deep_extend("force", win_opts, user_win_opts)
  end

  if type(user_win_opts) == "function" then
    win_opts = vim.tbl_deep_extend("force", win_opts, user_win_opts(lines))
  end

  local warp_help_winid = active_winid or api.nvim_open_win(bufnr, false, win_opts)

  vim.wo[warp_help_winid].cursorline = vim.o.cursorline

  if not warp_help_winid then
    notify.error("Failed to open native float window for warp help")
    return
  end

  ---Start setting keymaps
  local default_keymaps = require("warp.config").defaults.keymaps or {}
  local keymaps = require("warp.config").config.keymaps or default_keymaps

  ---Setup for quit keymaps
  for _, key in ipairs(keymaps.quit) do
    utils.buf_set_keymap(bufnr, key, function()
      M.close_win(warp_help_winid)
    end)
  end

  vim.api.nvim_set_current_win(warp_help_winid)
end

---Close a window
---@param winid? integer The window number
---@return nil
---@usage `require('warp.ui').close_win(winid)`
function M.close_win(winid)
  if winid and api.nvim_win_is_valid(winid) then
    api.nvim_win_close(winid, true)
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

---Render the entries of list items as lines
---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[] The list of items
---@return string[] lines The formatted lines
---@return number|nil active_index The active index
---@return Warp.FormattedLineOpts[][] formatted_raw_data The raw data of the formatted lines
---@see warp.nvim.types.Warp.ListItem
---@see warp.nvim.types.Warp.FormattedLineOpts
---@usage `require("warp.ui").get_formatted_list_items(parent_item, warp_list)`
function M.get_formatted_list_items(parent_item, warp_list)
  ---@type string[]
  local lines = {}

  ---@type Warp.FormattedLineOpts[][]
  local formatted_raw_data = {}

  ---@type number|nil
  local active_index

  local config = require("warp.config").config

  local formatter_fn = builtins.list_item_format_fn

  if type(config.list_item_format_fn) == "function" then
    formatter_fn = config.list_item_format_fn
  else
    notify.warn("`list_item_format_fn` is not a function, fallback to default implementation")
  end

  for index, warp_item in ipairs(warp_list) do
    local is_active = parent_item and warp_item.path == parent_item.path

    if is_active then
      active_index = index
    end

    local is_file_exists = require("warp.utils").file_exists(warp_item.path)

    ---@diagnostic disable-next-line: need-check-nil
    local formatted_line_data = utils.parse_format_fn_result(formatter_fn(warp_item, index, is_active, is_file_exists))

    local formatted_line = utils.convert_parsed_format_result_to_string(formatted_line_data)

    lines[index] = formatted_line
    formatted_raw_data[index] = formatted_line_data
  end

  return lines, active_index, formatted_raw_data
end

---Render the entries of help items as lines
---@return string[] lines The formatted lines
---@return Warp.FormattedLineOpts[][] formatted_raw_data The raw data of the formatted lines
---@see warp.nvim.types.Warp.FormattedLineOpts
---@usage `require('warp.ui').get_help_lines()`
function M.get_formatted_help_lines()
  ---@type string[]
  local lines = {}

  ---@type Warp.FormattedLineOpts[][]
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
    local description_length = vim.fn.strdisplaywidth(description)
    if description_length > longest_description_char then
      longest_description_char = description_length
    end
  end

  for key, keys in pairs(keymaps) do
    local to_render_description = description_map[key] or "No description"

    local description_length = vim.fn.strdisplaywidth(to_render_description)

    if description_length < longest_description_char then
      to_render_description = to_render_description .. string.rep(" ", longest_description_char - description_length)
    end

    ---@diagnostic disable-next-line: need-check-nil
    local formatted_line_data = utils.parse_format_fn_result(builtins.help_item_format_fn(keys, to_render_description))

    local formatted_line = utils.convert_parsed_format_result_to_string(formatted_line_data)

    table.insert(lines, formatted_line)
    table.insert(formatted_raw_data, formatted_line_data)
  end

  return lines, formatted_raw_data
end

---Set the highlight for the list items
---@param bufnr number The buffer number
---@param line_data Warp.FormattedLineOpts[][] The formatted line data
---@return nil
---@see warp.nvim.types.Warp.FormattedLineOpts
---@usage `require("warp.ui").set_list_item_hl_fn(bufnr, lines, line_data)`
function M.set_list_item_hl_fn(bufnr, line_data)
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for line_number, line in ipairs(line_data) do
    local temp_position = "before"
    local virt_text_before = {}
    local virt_text_after = {}

    -- Assuming that whatever before the first `non virtual` data is for the front part
    -- and whatever after the first `non virtual` data is for the back part
    -- The first `non virtual` text will be the anchor and the rest are rendered accordingly
    for _, data in ipairs(line) do
      if data.is_virtual then
        if temp_position == "before" then
          table.insert(virt_text_before, { data.display_text, data.hl_group })
        end
        if temp_position == "after" then
          table.insert(virt_text_after, { data.display_text, data.hl_group })
        end
      end

      if not data.is_virtual then
        temp_position = "after"
      end

      if data.hl_group then
        if data.col_start and data.col_end then
          api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, data.col_start, {
            end_col = data.col_end,
            hl_group = data.hl_group,
          })
        end
      end
    end

    api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
      virt_text = virt_text_before,
      virt_text_pos = "inline",
    })

    api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
      virt_text = virt_text_after,
      virt_text_pos = "eol_right_align",
    })
  end
end

return M
