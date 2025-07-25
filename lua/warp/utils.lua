local M = {}

local api = vim.api

--- Create an augroup
---@param name string The name of the augroup
---@return integer The augroup ID
function M.augroup(name)
  return vim.api.nvim_create_augroup("Warp" .. name, { clear = true })
end

--- Check if a file exists
--- @param path string
--- @return boolean
function M.file_exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

---Set a keymap for a buffer
---@param bufnr number
--- @param lhs string
--- @param rhs fun()
function M.buf_set_keymap(bufnr, lhs, rhs)
  api.nvim_buf_set_keymap(bufnr, "n", lhs, "", { callback = rhs, nowait = true })
end

return M
