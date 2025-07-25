---@module "warp"

---@brief [[
---*warp.nvim.txt*
---
---Warp is a lightweight project-local buffer list for Neovim — add, view, jump, reorder, and remove buffers, all from a floating window.
---
---`warp.nvim` provides a per-project list of important files, allowing you to quickly return to them later. think of it as “buffer bookmarks,” scoped to your git repo (or any project root).
---
---It's inspired by https://github.com/ThePrimeagen/harpoon, but with a simpler goal: do one thing well. No terminals, no fancy workflows — just files you care about, saved per project.
---@brief ]]

---@toc warp.nvim.toc

---@mod warp.nvim.api API

local M = {}

local api = vim.api
local fs = vim.fs
local fn = vim.fn
local list = require("warp.list")
local notify = require("warp.notifier")
local utils = require("warp.utils")

---Entry point to setup the plugin
---@type fun(user_config?: Warp.Config)
---@see warp.nvim.config.config
---@see warp.nvim.types.Warp.Config
---@usage `require('warp').setup(opts)`
M.setup = require("warp.config").setup

---Add or update current buffer in list
---@return nil
---@usage `require('warp').add() or ':WarpAddFile'`
function M.add()
  local buf = api.nvim_get_current_buf()
  local path = fs.normalize(api.nvim_buf_get_name(buf))
  local current_line = fn.line(".")

  list.add_to_list(path, current_line)
end

---Show the list item in window
---@return nil
---@usage `require('warp').show_list() or ':WarpShowList'`
function M.show_list()
  local index = list.get_index_by_buf(api.nvim_get_current_buf())

  local warp_list = list.get_list()

  list.prune_missing_files_from_list()

  if #warp_list == 0 then
    notify.warn("Nothing found")
    return
  end

  require("warp.ui").open_window(index, warp_list)
end

---Clear current project's list
---@type fun(): nil
---@see warp.nvim.list.clear_current_list
---@usage `require('warp').clear_current_list() or ':WarpClearCurrentList'`
M.clear_current_list = require("warp.list").clear_current_list

---Clear all the lists across all projects
---@type fun(): nil
---@see warp.nvim.list.clear_all_list
---@usage `require('warp').clear_all_list() or ':WarpClearAllList'`
M.clear_all_list = require("warp.list").clear_all_list

---Navigate to a file from warp list by index
---@param idx number
---@return nil
---@usage `require('warp').goto_index(1) or ':WarpGoToIndex 1'`
function M.goto_index(idx)
  local entry = list.get_item_by_index(idx)
  if not entry then
    return
  end
  if not utils.file_exists(entry.path) then
    M.remove_from_list(idx)
    return
  end
  local current_path = vim.api.nvim_buf_get_name(0)
  if current_path ~= vim.fn.fnamemodify(entry.path, ":p") then
    vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
  end

  ---Try to set but do not crash it
  pcall(api.nvim_win_set_cursor, 0, { entry.line or 1, 0 })
end

---Update entries if file or folder was updated
---@type fun(from: string, to: string): nil
---@see warp.nvim.list.on_file_update
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
M.on_file_update = require("warp.list").on_file_update

---Find the index of an entry by buffer
---@type fun(buf: number): number|nil
---@see warp.nvim.list.get_index_by_buf
---@usage `require('warp').get_index_by_buf(0)`
M.get_index_by_buf = require("warp.list").get_index_by_buf

---Get the count of the items
---@type fun(): number
---@see warp.nvim.list.get_list_count
---@usage `require('warp').get_list_count()`
M.get_list_count = require("warp.list").get_list_count

return M
