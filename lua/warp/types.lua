---@mod warp.nvim.types Types

local M = {}

---@class Warp.Config
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field root_detection_fn? fun(): string The function to detect the root, defaults to `require("warp.storage").find_project_root`
---@field keymaps? Warp.Config.Keymaps The keymaps for actions

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]

---@class Warp.ListItem
---@field path string The path of the file
---@field line number The line number of the file

return M
