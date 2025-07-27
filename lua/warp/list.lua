---@mod warp.nvim.list List

---@brief [[
---List related implementations, important functions are re-exported to the main module.
---@brief ]]

local M = {}

local api = vim.api
local fs = vim.fs
local notify = require("warp.notifier")
local utils = require("warp.utils")

---@type Warp.ListItem[]
local warp_list = {}

---Initialize the list by getting the data from storage and set it
---@return nil
---@usage `require('warp.list').init()`
M.init = function()
  local data = require("warp.storage").load()
  M.action.set(data)
end

---@divider -

---Getters
M.get = {}

---Get all items
---@return Warp.ListItem[] warp_list The list of items
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get.all()`
function M.get.all()
  return warp_list
end

---Get the count of the items
---@return number count The count of items in the list
---@usage `require('warp.list').get.count()`
function M.get.count()
  return #warp_list
end

---Get a specific item by index
---@param index number The index of the entry
---@return Warp.ListItem|nil item The entry item
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get.item_by_index(1)`
function M.get.item_by_index(index)
  if index < 1 or index > #warp_list then
    return nil
  end
  return warp_list[index]
end

---Find the index of an entry by buffer
---@param buf number The buffer number
---@return { entry: Warp.ListItem, index: number }|nil item The entry item and index
---@usage `require('warp.list').get.item_by_buf(0)`
function M.get.item_by_buf(buf)
  local path = fs.normalize(api.nvim_buf_get_name(buf))
  for i, entry in ipairs(warp_list) do
    if fs.normalize(entry.path) == path then
      return {
        entry = entry,
        index = i,
      }
    end
  end
  return nil
end

---@divider -
M.action = {}

---Set the list
---@param data Warp.ListItem[] The list of items
---@usage `require('warp.list').action.set(data)`
function M.action.set(data)
  warp_list = data
end

---Update entries if file or folder was updated
---@param from string The path of the file
---@param to string The path of the file
---@return nil
---@usage `require('warp.list').action.on_file_update(from, to)`
function M.action.on_file_update(from, to)
  local changed = false
  for _, entry in ipairs(warp_list) do
    if entry.path == from then
      entry.path = to
      changed = true
    elseif vim.startswith(entry.path, from .. "/") then
      -- also fix sub-paths if the renamed item is a directory
      entry.path = to .. entry.path:sub(#from + 1)
      changed = true
    end
  end
  if changed then
    require("warp.storage").save()
    notify.info("updated after source updates")
  end
end

---@param index number The index of the entry
---@param cursor number[] The cursor position as {row, col}
---@return boolean ok Whether the operation was successful
---@usage `require('warp.list').action.update_line_number(1, [1, 1])`
function M.action.update_line_number(index, cursor)
  local entry = warp_list[index]

  if not entry then
    return false
  end

  entry.cursor = cursor
  return true
end

---Insert current buffer to current list
---@param path string The path of the file
---@param cursor number[] The cursor position as {row, col}
---@return boolean ok Whether the operation was successful
---@usage `require('warp.list').insert(path, cursor)`
function M.action.insert(path, cursor)
  local found = false
  for _, entry in ipairs(warp_list) do
    if entry.path == path then
      found = true
      break
    end
  end

  if found then
    return false
  end

  table.insert(warp_list, { path = path, cursor = cursor })
  return true
end

---Remove an entry from the list
---@param idx number The index of the entry
---@return nil
---@usage `require('warp.list').remove_one(idx)`
function M.action.remove_one(idx)
  table.remove(warp_list, idx)
end

---Move an entry to a new index
---@param from_idx number The index of the entry
---@param to_idx number The index of the entry
---@return boolean ok Whether the operation was successful
---@usage `require('warp.list').action.move_to_index(1, 2)`
function M.action.move_to_index(from_idx, to_idx)
  if from_idx == to_idx then
    notify.info("Source and destination indices are the same, abort...")
    return false
  end

  local len = #warp_list
  if from_idx < 1 or from_idx > len or to_idx < 1 or to_idx > len then
    notify.info("Source and destination indices are out of bounds, abort...")
    return false
  end

  local entry = warp_list[from_idx]

  table.remove(warp_list, from_idx)

  table.insert(warp_list, to_idx, entry)

  return true
end

---Prune missing files from list
---@return nil
---@usage `require('warp.list').action.prune()`
function M.action.prune()
  if not require("warp.config").config.auto_prune then
    return
  end

  local i = 1
  local pruned = 0
  while i <= #warp_list do
    if not utils.file_exists(warp_list[i].path) then
      M.action.remove_one(i)
      pruned = pruned + 1
    else
      i = i + 1
    end
  end

  if pruned > 0 then
    require("warp.storage").save()
    notify.info("Pruned " .. pruned .. " entries")
  end
end

return M
