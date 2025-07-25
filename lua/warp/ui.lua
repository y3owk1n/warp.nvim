---@mod warp.nvim.ui UI

---@brief [[
---UI related implementations
---@brief ]]

local M = {}

local api = vim.api
local fn = vim.fn
local list = require("warp.list")
local notify = require("warp.notifier")
local utils = require("warp.utils")

---@type number|nil
local floating_win

---@type number|nil
local floating_buf

--- Show the floating window with the warp list
---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[]
---@param title? string The title of the window
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.ui').open_window(parent_item, warp_list, title)`
function M.open_window(parent_item, warp_list, title)
  if floating_win and api.nvim_win_is_valid(floating_win) then
    api.nvim_win_close(floating_win, true)
  end

  floating_buf = api.nvim_create_buf(false, true)

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

  win_opts.width = win_opts.width > 1 and win_opts.width or math.floor(vim.o.columns * win_opts.width)
  win_opts.height = win_opts.height > 1 and win_opts.height or math.floor(vim.o.lines * win_opts.height)
  win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
  win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)

  floating_win = api.nvim_open_win(floating_buf, true, win_opts)

  api.nvim_set_option_value("filetype", "warp-list", { buf = floating_buf })
  api.nvim_set_option_value("buftype", "nofile", { buf = floating_buf })
  api.nvim_set_option_value("bufhidden", "wipe", { buf = floating_buf })
  api.nvim_set_option_value("swapfile", false, { buf = floating_buf })

  local lines, active_idx = M.render_entries(parent_item, warp_list)

  api.nvim_buf_set_lines(floating_buf, 0, -1, false, lines)
  api.nvim_win_set_cursor(floating_win, { active_idx or 1, 0 })

  ---Not modifiable after setting lines
  api.nvim_set_option_value("modifiable", false, { buf = floating_buf })
  api.nvim_set_option_value("readonly", true, { buf = floating_buf })

  local default_keymaps = require("warp.config").defaults.keymaps or {}
  local keymaps = require("warp.config").config.keymaps or default_keymaps
  local warp = require("warp")

  ---Setup for quit keymaps
  for _, key in ipairs(keymaps.quit) do
    utils.buf_set_keymap(floating_buf, key, function()
      api.nvim_win_close(floating_win, true)
    end)
  end

  ---Setup for select keymaps
  for _, key in ipairs(keymaps.select) do
    utils.buf_set_keymap(floating_buf, key, function()
      local line_num = api.nvim_win_get_cursor(0)[1]
      api.nvim_win_close(floating_win, true)
      warp.goto_index(line_num)
    end)
  end

  ---Setup for delete keymaps
  for _, key in ipairs(keymaps.delete) do
    utils.buf_set_keymap(floating_buf, key, function()
      local l = api.nvim_win_get_cursor(0)[1]
      table.remove(warp_list, l)
      list.save_list()
      if #warp_list > 0 then
        M.open_window(parent_item, warp_list, title)
      else
        api.nvim_win_close(floating_win, true)
        notify.info("Warp List is emptied")
      end
    end)
  end

  ---Setup for move up keymaps
  for _, key in ipairs(keymaps.move_up) do
    utils.buf_set_keymap(floating_buf, key, function()
      local old = api.nvim_win_get_cursor(0)[1]
      if old > 1 then
        warp_list[old], warp_list[old - 1] = warp_list[old - 1], warp_list[old]
        list.save_list()
        M.open_window(parent_item, warp_list, title)
        api.nvim_win_set_cursor(floating_win, { math.max(1, old - 1), 0 })
      end
    end)
  end

  ---Setup for move down keymaps
  for _, key in ipairs(keymaps.move_down) do
    utils.buf_set_keymap(floating_buf, key, function()
      local old = api.nvim_win_get_cursor(0)[1]
      if old < #warp_list then
        warp_list[old], warp_list[old + 1] = warp_list[old + 1], warp_list[old]
        list.save_list()
        M.open_window(parent_item, warp_list, title)
        api.nvim_win_set_cursor(floating_win, { math.min(#warp_list, old + 1), 0 })
      end
    end)
  end

  ---Setup quick 1-9 action
  for idx = 1, 9 do
    utils.buf_set_keymap(floating_buf, tostring(idx), function()
      api.nvim_win_close(floating_win, true)
      warp.goto_index(idx)
    end)
  end
end

---Default format for the entry lines
---@param entry Warp.ListItem
---@param idx number
---@param is_active boolean|nil
---@return string
---@usage `require('warp.ui').default_list_item_format(entry, idx, is_active)`
function M.default_list_item_format(entry, idx, is_active)
  local display = fn.fnamemodify(entry.path, ":~:.")

  if is_active then
    display = display .. " *"
  end

  return string.format(" %d %s", idx, display)
end

---Render the entries as lines
---@param parent_item Warp.ListItem|nil The parent item before open the window
---@param warp_list Warp.ListItem[]
---@usage `require("warp.ui").render_entries(parent_item, warp_list)`
function M.render_entries(parent_item, warp_list)
  local lines = {}

  ---@type number|nil
  local active_idx

  local config = require("warp.config").config

  local formatter_fn = M.default_list_item_format

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
    local formatted_line = formatter_fn(entry, idx, is_active)

    if type(formatted_line) ~= "string" then
      notify.warn("`list_item_format_fn` should return a string, fallback to default implementation")
      formatted_line = M.default_list_item_format(entry, idx, is_active)
    end

    lines[idx] = formatted_line
  end

  return lines, active_idx
end

return M
