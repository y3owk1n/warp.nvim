---@mod warp.nvim.action Actions

local M = {}

local api = vim.api
local fs = vim.fs
local fn = vim.fn

local list = require("warp.list")
local utils = require("warp.utils")

--- Add or update current buffer in list
function M.add()
  local buf = api.nvim_get_current_buf()
  local path = fs.normalize(api.nvim_buf_get_name(buf))
  local current_line = fn.line(".")

  list.add_to_list(path, current_line)
end

--- Navigate to a file from warp list by index
--- @param idx number
function M.goto_index(idx)
  local entry = list.get_item(idx)
  if not entry then
    return
  end
  if not utils.file_exists(entry.path) then
    list.remove_from_list(idx)
    return
  end
  local current_path = vim.api.nvim_buf_get_name(0)
  if current_path ~= vim.fn.fnamemodify(entry.path, ":p") then
    vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
  end
  api.nvim_win_set_cursor(0, { entry.line or 1, 0 })
end

---Show the list item in window
function M.show_list()
  local index = list.get_index_by_buf(api.nvim_get_current_buf())

  local warp_list = list.get_list()

  list.prune_missing_files_from_list()

  if #warp_list == 0 then
    vim.notify("Warp: Nothing found...", vim.log.levels.INFO)
    return
  end

  require("warp.ui").open_window(index, warp_list)
end

return M
