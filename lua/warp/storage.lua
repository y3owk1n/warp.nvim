---@mod warp.nvim.storage Storage

---@brief [[
---Storage related implementations
---@brief ]]

local M = {}

local fn = vim.fn

local storage_dir = fn.stdpath("data") .. "/warp"
local cwd = fn.getcwd()

---Find the root directory based on root markers, or fall back to cwd
---@return string
---@usage `require('warp.storage').find_project_root()`
function M.find_project_root()
  local config = require("warp.config").config

  local root_markers = config.root_markers

  if not root_markers or #root_markers == 0 then
    return cwd
  end

  local path = cwd

  while path ~= "/" do
    for _, marker in ipairs(root_markers) do
      local full = path .. "/" .. marker
      if fn.isdirectory(full) == 1 or fn.filereadable(full) == 1 then
        return path
      end
    end

    path = fn.fnamemodify(path, ":h")
  end

  --- fallback to cwd
  return cwd
end

---Get a safe, unique JSON file path for the current working directory
---@return string
---@usage `require('warp.storage').get_storage_path()`
function M.get_storage_path()
  local config = require("warp.config").config
  fn.mkdir(storage_dir, "p")

  local root

  if type(config.root_detection_fn) ~= "function" then
    vim.notify("[Warp] root_detection_fn is not a function, fallback to default implementation.", vim.log.levels.WARN)
    root = M.find_project_root()
  else
    root = config.root_detection_fn()
  end

  if not root or fn.isdirectory(root) == 0 then
    vim.notify(
      "[Warp] Root detection that setup is not resolving to an actual directory, fallback to default implementation.",
      vim.log.levels.WARN
    )
    root = M.find_project_root()
  end

  local safe_root = fn.fnamemodify(root, ":~"):gsub("/", "%%")
  return storage_dir .. "/" .. safe_root .. ".json"
end

return M
