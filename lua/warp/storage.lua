---@mod warp.nvim.storage Storage

---@brief [[
---Storage related implementations
---@brief ]]

local M = {}

local fn = vim.fn
local builtins = require("warp.builtins")
local notify = require("warp.notifier")

local storage_dir = fn.stdpath("data") .. "/warp"

---Get the storage directory
---@return string storage_dir The storage directory
---@usage `require('warp.storage').get_storage_dir()`
function M.get_storage_dir()
  return storage_dir
end

---Get a safe, unique JSON file path for the current working directory
---@return string storage_path The storage path
---@usage `require('warp.storage').get_storage_path()`
function M.get_storage_path()
  local config = require("warp.config").config
  fn.mkdir(storage_dir, "p")

  local root_detection_fn = builtins.root_detection_fn

  if type(config.root_detection_fn) == "function" then
    root_detection_fn = config.root_detection_fn
  else
    notify.warn("`root_detection_fn` is not a function, fallback to default implementation.")
  end

  ---@diagnostic disable-next-line: need-check-nil
  local root = root_detection_fn()

  if not root or fn.isdirectory(root) == 0 then
    notify.warn("`root_detection_fn` returned an invalid directory, fallback to default implementation.")
    root = builtins.root_detection_fn()
  end

  local safe_root = fn.fnamemodify(root, ":~"):gsub("/", "%%")
  return storage_dir .. "/" .. safe_root .. ".json"
end

---Load the data from the storage file and set it to the list
---@param storage_path? string The path of the storage file
---@return Warp.ListItem[] items The list of items
---@usage `require('warp.storage').load()`
function M.load(storage_path)
  if not storage_path then
    storage_path = M.get_storage_path()
  end

  local f = io.open(storage_path, "r")

  if f then
    local contents = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, contents)
    if ok then
      return data
    else
      fn.rename(storage_path, storage_path .. ".bak")
      notify.warn("Corrupted JSON backed up")
      return {}
    end
  else
    return {}
  end
end

---Save data to disk
---@param data? Warp.ListItem[] The list of items
---@param storage_path? string The path of the storage file
---@return nil
---@usage `require('warp.storage').save()`
function M.save(data, storage_path)
  if not storage_path then
    storage_path = M.get_storage_path()
  end

  if not data then
    data = require("warp.list").get.all()
  end

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    notify.error("Failed to save list")
    return
  end

  local f = assert(io.open(storage_path, "w"))
  f:write(encoded)
  f:close()
end

return M
