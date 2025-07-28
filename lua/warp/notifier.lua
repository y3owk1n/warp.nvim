---@mod warp.notifier Notifier modules

---@brief [[
---Notification related implementations
---@brief ]]

local M = {}

local notify = vim.notify

local title = "warp.nvim"

---Info notification
---@param msg string The message to display
---@return nil
---@usage `require('warp.notifier').info("Hello world")`
function M.info(msg)
  notify(msg, vim.log.levels.INFO, { title = title })
end

---Warn notification
---@param msg string The message to display
---@return nil
---@usage `require('warp.notifier').warn("Hello world")`
function M.warn(msg)
  notify(msg, vim.log.levels.WARN, { title = title })
end

---Error notification
---@param msg string The message to display
---@return nil
---@usage `require('warp.notifier').error("Hello world")`
function M.error(msg)
  notify(msg, vim.log.levels.ERROR, { title = title })
end

return M
