---@mod warp.nvim.notifier Notifier

---@brief [[
---Notification related implementations
---@brief ]]

local M = {}

local notify = vim.notify

---Info notification
---@param msg string The message to display
---@usage `require('warp.notifier').info("Hello world")`
function M.info(msg)
  notify(msg, vim.log.levels.INFO, { title = "warp.nvim" })
end

---Warn notification
---@param msg string The message to display
---@usage `require('warp.notifier').warn("Hello world")`
function M.warn(msg)
  notify(msg, vim.log.levels.WARN, { title = "warp.nvim" })
end

---Error notification
---@param msg string The message to display
---@usage `require('warp.notifier').error("Hello world")`
function M.error(msg)
  notify(msg, vim.log.levels.ERROR, { title = "warp.nvim" })
end

return M
