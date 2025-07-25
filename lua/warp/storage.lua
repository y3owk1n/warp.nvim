local M = {}

local fn = vim.fn

local storage_dir = fn.stdpath("data") .. "/warp"

--- Find the root directory based on root markers, or fall back to cwd
--- @return string
local function find_project_root()
  local config = require("warp.config").config

  local root_markers = config.root_markers

  local start_path = fn.getcwd()

  if not root_markers or #root_markers == 0 then
    return start_path
  end

  local path = start_path

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
  return start_path
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
