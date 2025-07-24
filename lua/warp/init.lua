---@module "warp"

---@brief [[
---*warp.nvim.txt*
---
---Mark your files and go. Simpler `harpoon` alternative.
---@brief ]]

---@toc warp.nvim.toc

---@mod warp.nvim.api API

local M = {}

---Entry point to setup the plugin
---@type fun(user_config?: Warp.Config)
M.setup = require("warp.config").setup

return M
