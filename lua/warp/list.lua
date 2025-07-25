---@mod warp.nvim.list List

---@brief [[
---List related implementations, important functions are re-exported to the main module.
---@brief ]]

local M = {}

local api = vim.api
local fs = vim.fs
local fn = vim.fn
local utils = require("warp.utils")

---@type Warp.ListItem[]
local warp_list = {}

---Load list from disk into memory
---@return nil
---@usage `require('warp.list').load_list()`
function M.load_list()
  local storage_path = require("warp.storage").get_storage_path()
  local f = io.open(storage_path, "r")
  if f then
    local contents = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, contents)
    if ok then
      warp_list = data
    else
      warp_list = {}
      fn.rename(storage_path, storage_path .. ".bak")
      vim.notify("Warp: Corrupted JSON backed up", vim.log.levels.WARN)
    end
  else
    warp_list = {}
  end
end

---Save list to disk
---@return nil
---@usage `require('warp.list').save_list()`
function M.save_list()
  local ok, encoded = pcall(vim.json.encode, warp_list)
  if not ok then
    vim.notify("Warp: Failed to save list", vim.log.levels.ERROR)
    return
  end
  local storage_path = require("warp.storage").get_storage_path()
  local f = assert(io.open(storage_path, "w"))
  f:write(encoded)
  f:close()
end

---Get all items
---@return Warp.ListItem[]
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get_list()`
function M.get_list()
  return warp_list
end

---Get the count of the items
---@return number
---@usage `require('warp.list').get_list_count()`
function M.get_list_count()
  return #warp_list
end

---Get a specific item by index
---@param index number
---@return Warp.ListItem|nil
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.list').get_item_by_index(1)`
function M.get_item_by_index(index)
  if index < 1 or index > #warp_list then
    return nil
  end
  return warp_list[index]
end

---Find the index of an entry by buffer
---@param buf number
---@return number|nil
---@usage `require('warp.list').get_index_by_buf(0)`
function M.get_index_by_buf(buf)
  local path = fs.normalize(api.nvim_buf_get_name(buf))
  for i, entry in ipairs(warp_list) do
    if fs.normalize(entry.path) == path then
      return i
    end
  end
  return nil
end

---Update entries if file or folder was updated
---@param from string
---@param to string
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
function M.on_file_update(from, to)
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
    M.save_list()
    vim.notify("Warp: updated after source updates", vim.log.levels.INFO)
  end
end

---Add or update current buffer in list
---@param path string
---@param current_line number
---@usage `require('warp.list').add_to_list(path, current_line)`
function M.add_to_list(path, current_line)
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

  M.save_list()

  if found then
    vim.notify("Warp: Updated line number", vim.log.levels.INFO)
  else
    vim.notify("Warp: Added to #" .. #warp_list, vim.log.levels.INFO)
  end
end

---Remove an entry from the list
---@param idx number
---@return nil
---@usage `require('warp.list').remove_from_list(idx)`
function M.remove_from_list(idx)
  vim.notify("Warp: file no longer exists – removed", vim.log.levels.WARN)
  table.remove(warp_list, idx)
  M.save_list()
end

---Prune missing files from list
---@return nil
---@usage `require('warp.list').prune_missing_files_from_list()`
function M.prune_missing_files_from_list()
  local i = 1
  while i <= #warp_list do
    if not utils.file_exists(warp_list[i].path) then
      table.remove(warp_list, i)
    else
      i = i + 1
    end
  end
  M.save_list()
end

---Clear current project's list
---@return nil
---@usage `require('warp.list').clear_current_list()`
function M.clear_current_list()
  warp_list = {}
  M.save_list()
end

---Clear all the lists across all projects
---@return nil
---@usage `require('warp.list').clear_all_list()`
function M.clear_all_list()
  local storage_path = require("warp.storage").get_storage_path()
  local files = fn.readdir(storage_path)
  if not files then
    vim.notify("Warp: No warp data found", vim.log.levels.INFO)
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
      M.clear_current_list()
      for _, file in ipairs(files) do
        if file:match("%.json$") then
          fn.delete(storage_path .. "/" .. file)
        end
      end
      vim.notify("Warp: All warp lists cleared", vim.log.levels.INFO)
    end
  end)
end

return M
