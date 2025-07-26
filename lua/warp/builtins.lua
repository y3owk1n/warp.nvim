---@mod warp.nvim.builtins Builtins

---@brief [[
---Builtins related implementations
---@brief ]]

local M = {}

local fn = vim.fn

---Find the root directory based on root markers, or fall back to cwd
---@return string
---@usage `require('warp.builtins').root_detection_fn()`
function M.root_detection_fn()
  local cwd = vim.fn.getcwd()

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

---Default format for the entry lines
---@param entry Warp.ListItem
---@param idx number
---@param is_active boolean|nil
---@return string
---@usage `require('warp.builtins').list_item_format_fn(entry, idx, is_active)`
function M.list_item_format_fn(entry, idx, is_active)
  local display = fn.fnamemodify(entry.path, ":~:.")

  if is_active then
    display = display .. " *"
  end

  return string.format(" %d %s", idx, display)
end

return M
