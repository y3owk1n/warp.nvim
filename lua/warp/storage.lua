local M = {}

local fn = vim.fn

local storage_dir = fn.stdpath("data") .. "/warp"

--- Find the root directory based on root markers, or fall back to cwd
--- @return string
local function find_project_root()
  local config = require("warp.config").config

  -- List of root markers to check
  local root_markers = config.root_markers

  local path = fn.getcwd()

  if not root_markers or #root_markers == 0 then
    return path
  end

  while path ~= "/" do
    for _, marker in ipairs(root_markers) do
      if fn.isdirectory(path .. "/" .. marker) == 1 or fn.filereadable(path .. "/" .. marker) == 1 then
        return path
      end
    end

    path = fn.fnamemodify(path, ":h")
  end

  --- fallback to cwd
  return fn.getcwd()
end

--- Get a safe, unique JSON file path for the current working directory
--- @return string
function M.get_storage_path()
  fn.mkdir(storage_dir, "p")
  local root = find_project_root()
  local safe_root = fn.fnamemodify(root, ":~"):gsub("/", "%%")
  return storage_dir .. "/" .. safe_root .. ".json"
end

return M
