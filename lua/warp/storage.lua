---@mod warp.nvim.storage Storage

---@brief [[
---Storage related implementations
---@brief ]]

local M = {}

local fn = vim.fn
local json = vim.json
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
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.storage').load()`
function M.load(storage_path)
  if not storage_path then
    storage_path = M.get_storage_path()
  end

  if not require("warp.utils").file_exists(storage_path) then
    return {}
  end

  local contents_ok, contents = pcall(function()
    local lines = fn.readfile(storage_path)
    return table.concat(lines, "\n")
  end)

  if not contents_ok or contents == "" then
    return {}
  end

  local data_ok, data = pcall(json.decode, contents)

  if not data_ok then
    fn.rename(storage_path, storage_path .. ".bak")
    notify.warn("Corrupted JSON backed up")
    return {}
  end

  return data
end

---Track the last saved encoded data
local last_saved_encoded = nil

---Track the last saved storage path
local last_saved_storage_path = nil

---Save data to disk
---@param data? Warp.ListItem[] The list of items
---@param storage_path? string The path of the storage file
---@return nil
---@see warp.nvim.types.Warp.ListItem
---@usage `require('warp.storage').save()`
function M.save(data, storage_path)
  if not storage_path then
    storage_path = M.get_storage_path()
  end

  if not data then
    data = require("warp.list").get.all()
  end

  local ok, encoded = pcall(json.encode, data)
  if not ok then
    notify.error("Failed to save list")
    return
  end

  if last_saved_encoded == encoded and last_saved_storage_path == storage_path then
    return
  end

  last_saved_encoded = encoded
  last_saved_storage_path = storage_path

  local tmp_path = storage_path .. ".tmp"
  fn.writefile({ encoded }, tmp_path)
  os.rename(tmp_path, storage_path)
end

return M
