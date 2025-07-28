---@mod warp.nvim.types Types

local M = {}
---@alias Warp.Config.MoveDirection
---| '"prev"'
---| '"next"'
---| '"first"'
---| '"last"'

---@class Warp.Config
---@field auto_prune? boolean Whether to auto prune the list, defaults to false
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field root_detection_fn? fun(): string The function to detect the root, defaults to `require("warp.storage").find_project_root`
---@field list_item_format_fn? fun(warp_item_entry: Warp.ListItem, index: number, is_active: boolean|nil): string[] The function to format the list items lines, defaults to `require("warp.ui").default_list_item_format`
---@field keymaps? Warp.Config.Keymaps The keymaps for actions
---@field window? Warp.Config.Window The windows configurations

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]
---@field split_horizontal? string[]
---@field split_vertical? string[]
---@field show_help? string[]

---@class Warp.ListItem
---@field path string The path of the file
---@field cursor number[] The cursor position as {row, col}

---@class Warp.FormattedLineOpts
---@field display_text string The display text
---@field hl_group? string The highlight group of the text
---@field is_virtual? boolean Whether the line is virtual
---@field col_start? number The start column of the text, NOTE: this is calculated and for type purpose only
---@field col_end? number The end column of the text, NOTE: this is calculated and for type purpose only

---@class Warp.Config.Window
---@field list? vim.api.keyset.win_config|fun(lines: string[]):vim.api.keyset.win_config The window configurations for the list window
---@field help? vim.api.keyset.win_config|fun(lines:string[]):vim.api.keyset.win_config The window configurations for the help window

return M
