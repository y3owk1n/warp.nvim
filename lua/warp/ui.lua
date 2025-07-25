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
---@param item_idx number|nil The index of the warp list item before open the window
---@param warp_list Warp.ListItem[]
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.ui').open_window(item_idx, warp_list)`
function M.open_window(item_idx, warp_list)
  if floating_win and api.nvim_win_is_valid(floating_win) then
    api.nvim_win_close(floating_win, true)
  end

  floating_buf = api.nvim_create_buf(false, true)

  floating_win = api.nvim_open_win(floating_buf, true, {
    relative = "editor",
    width = 60,
    height = math.min(#warp_list, 20),
    col = (vim.o.columns - 60) / 2,
    row = (vim.o.lines - #warp_list - 2) / 2,
    style = "minimal",
    border = "rounded",
    title = "Warp List",
  })

  api.nvim_set_option_value("filetype", "warp-list", { buf = floating_buf })
  api.nvim_set_option_value("buftype", "nofile", { buf = floating_buf })
  api.nvim_set_option_value("bufhidden", "wipe", { buf = floating_buf })
  api.nvim_set_option_value("swapfile", false, { buf = floating_buf })

  local lines = {}
  for idx, entry in ipairs(warp_list) do
    local display = fn.fnamemodify(entry.path, ":~:.")
    if idx == item_idx then
      display = display .. " *"
    end
    lines[idx] = string.format(" %d %s", idx, display)
  end
  api.nvim_buf_set_lines(floating_buf, 0, -1, false, lines)
  api.nvim_win_set_cursor(floating_win, { item_idx or 1, 0 })

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
        M.open_window(item_idx, warp_list)
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
        M.open_window(item_idx, warp_list)
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
        M.open_window(item_idx, warp_list)
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

return M
