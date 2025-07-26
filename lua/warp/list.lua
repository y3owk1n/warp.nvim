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
---@return Warp.ListItem[]
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get.all()`
function M.get.all()
  return warp_list
end

---Get the count of the items
---@return number
---@usage `require('warp.list').get.count()`
function M.get.count()
  return #warp_list
end

---Get a specific item by index
---@param index number
---@return Warp.ListItem|nil
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get_item.by_index(1)`
function M.get.item_by_index(index)
  if index < 1 or index > #warp_list then
    return nil
  end
  return warp_list[index]
end

---Find the index of an entry by buffer
---@param buf number
---@return { entry: Warp.ListItem, index: number }|nil
---@usage `require('warp.list').get_item.by_buf(0)`
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
---@param data Warp.ListItem[]
---@usage `require('warp.list').action.set(data)`
function M.action.set(data)
  warp_list = data
end

---Update entries if file or folder was updated
---@param from string
---@param to string
---@return nil
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

---Insert or update current buffer in list
---@param path string
---@param current_line number
---@return nil
---@usage `require('warp.list').insert_or_update(path, current_line)`
function M.action.insert_or_update(path, current_line)
  local found = false
  for i, entry in ipairs(warp_list) do
    if entry.path == path then
      -- Update the line number
      warp_list[i].line = current_line
      found = true
      break
    end
  end

  if not found then
    table.insert(warp_list, { path = path, line = current_line })
  end

  if found then
    notify.info("Updated line number")
  else
    notify.info("Added to #" .. #warp_list)
  end
end

---Remove an entry from the list
---@param idx number
---@return nil
---@usage `require('warp.list').remove_one(idx)`
function M.action.remove_one(idx)
  table.remove(warp_list, idx)
end

---Move an entry to a new index
---@param from_idx number
---@param to_idx number
---@return boolean
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
