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
---@param bufnr number The buffer number
---@return { entry: Warp.ListItem, index: number }|nil item The entry item and index
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get.item_by_buf(0)`
function M.get.item_by_buf(bufnr)
  local path = fs.normalize(api.nvim_buf_get_name(bufnr))
  for index, entry in ipairs(warp_list) do
    if fs.normalize(entry.path) == path then
      return {
        entry = entry,
        index = index,
      }
    end
  end
  return nil
end

---@divider -
M.action = {}

---Set the list
---@param data Warp.ListItem[] The list of items
---@see warp.nvim.types.Warp.ListItem
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
  for _, warp_list_entry in ipairs(warp_list) do
    if warp_list_entry.path == from then
      warp_list_entry.path = to
      changed = true
    elseif vim.startswith(warp_list_entry.path, from .. "/") then
      -- also fix sub-paths if the renamed item is a directory
      warp_list_entry.path = to .. warp_list_entry.path:sub(#from + 1)
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
  local warp_list_entry = warp_list[index]

  if not warp_list_entry then
    return false
  end

  warp_list_entry.cursor = cursor
  return true
end

---Insert current buffer to current list
---@param path string The path of the file
---@param cursor number[] The cursor position as {row, col}
---@return boolean ok Whether the operation was successful
---@usage `require('warp.list').insert(path, cursor)`
function M.action.insert(path, cursor)
  local found = false
  for _, warp_list_entry in ipairs(warp_list) do
    if warp_list_entry.path == path then
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
---@param index number The index of the entry
---@return nil
---@usage `require('warp.list').remove_one(index)`
function M.action.remove_one(index)
  table.remove(warp_list, index)
end

---Move an entry to a new index
---@param from_index number The index of the entry
---@param to_index number The index of the entry
---@return boolean ok Whether the operation was successful
---@usage `require('warp.list').action.move_to_index(1, 2)`
function M.action.move_to_index(from_index, to_index)
  if from_index == to_index then
    notify.info("Source and destination indices are the same, abort...")
    return false
  end

  local warp_list_length = #warp_list
  if from_index < 1 or from_index > warp_list_length or to_index < 1 or to_index > warp_list_length then
    notify.info("Source and destination indices are out of bounds, abort...")
    return false
  end

  local warp_list_entry = warp_list[from_index]

  table.remove(warp_list, from_index)

  table.insert(warp_list, to_index, warp_list_entry)

  return true
end

---Prune missing files from list
---@return nil
---@usage `require('warp.list').action.prune()`
function M.action.prune()
  if not require("warp.config").config.auto_prune then
    return
  end

  local walked_index = 1
  local pruned = 0
  while walked_index <= #warp_list do
    if not utils.file_exists(warp_list[walked_index].path) then
      M.action.remove_one(walked_index)
      pruned = pruned + 1
    else
      walked_index = walked_index + 1
    end
  end

  if pruned > 0 then
    require("warp.storage").save()
    notify.info("Pruned " .. pruned .. " entries")
  end
end

return M
