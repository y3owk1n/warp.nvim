---@module "warp"

---@brief [[
---*warp.nvim.txt*
---
---Warp is a lightweight project-local buffer list for Neovim — add, view, jump, reorder, and remove buffers, all from a floating window.
---
---`warp.nvim` provides a per-project list of important files, allowing you to quickly return to them later. think of it as “buffer bookmarks,” scoped to your git repo (or any project root).
---
---It's inspired by https://github.com/ThePrimeagen/harpoon, but with a simpler goal: do one thing well. No terminals, no fancy workflows — just files you care about, saved per project.
---@brief ]]

---@toc warp.nvim.toc

---@mod warp.nvim.api API

local M = {}

local api = vim.api
local fs = vim.fs
local fn = vim.fn
local events = require("warp.events")
local list = require("warp.list")
local notify = require("warp.notifier")
local utils = require("warp.utils")

---Entry point to setup the plugin
---@type fun(user_config?: Warp.Config)
---@see warp.nvim.config.config
---@see warp.nvim.types.Warp.Config
---@usage `require('warp').setup(opts)`
M.setup = require("warp.config").setup

---Add current buffer to list
---@return nil
---@usage `require('warp').add() or ':WarpAddFile'`
function M.add()
  local buf = api.nvim_get_current_buf()
  local path = fs.normalize(api.nvim_buf_get_name(buf))

  if not utils.file_exists(path) then
    return
  end

  local cursor = api.nvim_win_get_cursor(0)

  local ok = list.action.insert(path, cursor)
  if ok then
    events.emit(events.constants.added_to_list)
  end
end

---Add all on screen buffer to list
---@return nil
---@usage `require('warp').add_all_onscreen() or ':WarpAddOnScreenFiles'`
function M.add_all_onscreen()
  local bufs = utils.get_all_onscreen_bufs()

  local added_count = 0

  for _, buf in ipairs(bufs) do
    local path = fs.normalize(api.nvim_buf_get_name(buf))
    local cursor = api.nvim_win_get_cursor(0)

    local ok = list.action.insert(path, cursor)
    if ok then
      added_count = added_count + 1
    end
  end

  if added_count > 0 then
    events.emit(events.constants.added_to_list)
  end
end

---Remove current buffer from warp list
---@return nil
---@usage `require('warp').del() or ':WarpDelFile'`
function M.del()
  local buf = api.nvim_get_current_buf()
  local item = list.get.item_by_buf(buf)

  if not item then
    notify.warn("Current buffer is not in warp list")
    return
  end

  list.action.remove_one(item.index)
  events.emit(events.constants.removed_from_list)
end

---Move current buffer to a new index in list
---@param direction_or_index Warp.Config.MoveDirection | number The direction or index to move to
---@return nil
---@usage `require('warp').move_to('prev') or ':WarpMoveTo prev'`
function M.move_to(direction_or_index)
  local buf = api.nvim_get_current_buf()
  local item = list.get.item_by_buf(buf)

  if not item then
    notify.warn("Current buffer is not in warp list")
    return
  end

  local to_idx = utils.parse_direction_or_index(direction_or_index, item.index)

  if not to_idx then
    notify.warn("Invalid direction_or_index")
    return
  end

  local ok = list.action.move_to_index(item.index, to_idx)
  if ok then
    events.emit(events.constants.moved_item_index)
  end
end

---Show the list item in window
---@return nil
---@usage `require('warp').show_list() or ':WarpShowList'`
function M.show_list()
  local item = list.get.item_by_buf(api.nvim_get_current_buf())

  local entry = item and item.entry or nil

  local warp_list = list.get.all()

  list.action.prune()

  if #warp_list == 0 then
    notify.warn("Nothing found")
    return
  end

  local is_active, active_win = require("warp.ui").is_warp_list_win_active()

  if is_active then
    require("warp.ui").close_win(active_win)
    events.emit(events.constants.close_list_win)
    return
  end

  require("warp.ui").render_warp_list(entry, warp_list)
  events.emit(events.constants.open_list_win)
end

---Clear current project's list
---@return nil
---@usage `require('warp').clear_current_list()`
function M.clear_current_list()
  list.action.set({})
  require("warp.storage").save()
  notify.info("Current lists cleared")
end

---Clear all the lists across all projects
---@return nil
---@usage `require('warp').clear_all_list()`
function M.clear_all_list()
  local storage_dir = require("warp.storage").get_storage_dir()

  if fn.isdirectory(storage_dir) == 0 then
    notify.info("Not a directory, checked for: " .. storage_dir)
    return
  end

  local files = fn.readdir(storage_dir)

  if vim.tbl_isempty(files) then
    notify.info("Nothing to clear! Abort...")
    return
  end

  -- confirmation prompt
  vim.ui.input({
    prompt = "Clear all warp lists for all projects? (y/n) ",
    completion = "file",
  }, function(input)
    if input == nil then
      return
    end

    if input:lower() == "y" then
      for _, file in ipairs(files) do
        if file:match("%.json$") then
          fn.delete(storage_dir .. "/" .. file)
        end
      end

      list.action.set({})
      notify.info("All warp lists cleared")
    end
  end)
end

---Navigate to a file from warp list by index or direction
---@param direction_or_index Warp.Config.MoveDirection | number The direction or index to move to
---@return nil
---@usage `require('warp').goto_index(1) or ':WarpGoToIndex 1'`
function M.goto_index(direction_or_index)
  local buf = api.nvim_get_current_buf()
  local item = list.get.item_by_buf(buf)

  local to_idx = utils.parse_direction_or_index(direction_or_index, item and item.index or nil)

  if not to_idx then
    notify.warn("Invalid direction_or_index")
    return
  end

  if item and item.index == to_idx then
    return
  end

  local entry = list.get.item_by_index(to_idx)
  if not entry then
    notify.warn("Not in bound")
    return
  end
  if not utils.file_exists(entry.path) then
    notify.warn("file no longer exists – removed")
    list.action.remove_one(to_idx)
    events.emit(events.constants.removed_from_list)
    return
  end
  local current_path = vim.api.nvim_buf_get_name(0)
  if current_path ~= vim.fn.fnamemodify(entry.path, ":p") then
    vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
  end

  ---Try to set but do not crash it
  pcall(api.nvim_win_set_cursor, 0, entry.cursor)
end

---Update entries if file or folder was updated
---@type fun(from: string, to: string): nil
---@see warp.nvim.list.action.on_file_update
---@usage [[
---vim.api.nvim_create_autocmd("User", {
---  group = augroup,
---  pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
---  callback = function(ev)
---    local from, to = ev.data.from, ev.data.to
---    require("warp").on_file_update(from, to)
---  end,
---})
---@usage ]]
M.on_file_update = require("warp.list").action.on_file_update

---Find the item of an entry by buffer
---@type fun(buf: number): { entry: Warp.ListItem, index: number }|nil
---@see warp.nvim.list.get.item_by_buf
---@usage `require('warp').get_item_by_buf(0)`
M.get_item_by_buf = require("warp.list").get.item_by_buf

---Get the count of the items
---@type fun(): number
---@see warp.nvim.list.get.count
---@usage `require('warp').count()`
M.count = require("warp.list").get.count

return M
