---@mod warp.nvim.types Types

local M = {}

---@class Warp.Config
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field root_detection_fn? fun(): string The function to detect the root, defaults to `require("warp.storage").find_project_root`
---@field list_item_format_fn? fun(entry: Warp.ListItem, idx: number, is_active: boolean|nil): string The function to format the list items lines
---@field keymaps? Warp.Config.Keymaps The keymaps for actions
---@field float_opts? Warp.Config.FloatOpts The floating window options

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]

---@class Warp.Config.FloatOpts
---@field width? integer The width of the window, more than 1 = absolute, less than 1 = calculated percentage
---@field height? integer The height of the window, more than 1 = absolute, less than 1 = calculated percentage
---@field relative? "cursor"|"editor"|"laststatus"|"mouse"|"tabline"|"win" The relative position of the window, defaults to "editor"
---@field anchor? "NW" | "NW" | "SW" | "SE" The anchor position of the window, no default
---@field title_pos? "left" | "center" | "right" The position of the title, defaults to "left"
---@field border? "double"|"none"|"rounded"|"shadow"|"single"|"solid"|"shadow" The border style of the window, no default
---@field zindex? integer The z-index of the window, no default
---@field focusable? boolean Whether the window is focusable, no default

---@class Warp.ListItem
---@field path string The path of the file
---@field line number The line number of the file

return M
