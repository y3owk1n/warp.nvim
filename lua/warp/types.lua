---@mod warp.nvim.types Types

local M = {}

---@class Warp.Config
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field keymaps? Warp.Config.Keymaps The keymaps for actions

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]

---@class Warp.ListItem
---@field path string
---@field line number

return M
