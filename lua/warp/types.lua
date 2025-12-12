---@mod warp.types Types

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
---@field list_item_format_fn? fun(warp_item_entry: Warp.ListItem, index: number, is_active: boolean|nil, is_file_exists: boolean|nil): Warp.FormattedLineOpts[] The function to format the list items lines, defaults to `require("warp.ui").default_list_item_format`
---@field keymaps? Warp.Config.Keymaps The keymaps for actions
---@field window? Warp.Config.Window The windows configurations
---@field hl_groups? table<string, Warp.HighlightConfig> The highlight groups for the list

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

---@class Warp.ComputedLineOpts : Warp.FormattedLineOpts
---@field col_start? number The start column of the text, NOTE: this is calculated and for type purpose only
---@field col_end? number The end column of the text, NOTE: this is calculated and for type purpose only

---@class Warp.Config.Window
---@field list? Warp.WindowConfig|fun(lines: string[]):Warp.WindowConfig The window configurations for the list window
---@field help? Warp.WindowConfig|fun(lines:string[]):Warp.WindowConfig The window configurations for the help window

---@class Warp.WindowConfig
---@field relative? "editor"|"win"|"cursor"|"mouse"
---@field win? integer
---@field anchor? "NW"|"NE"|"SW"|"SE"
---@field width? integer
---@field height? integer
---@field bufpos? integer[]
---@field row? integer
---@field col? integer
---@field focusable? boolean
---@field external? boolean
---@field zindex? integer
---@field style? "minimal"
---@field border? string|string[]|table[]
---@field title? string|string[]
---@field title_pos? "left"|"center"|"right"
---@field noautocmd? boolean

---@class Warp.HighlightConfig
---@field fg? integer|string
---@field bg? integer|string
---@field sp? integer|string
---@field blend? integer
---@field bold? boolean
---@field standout? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field underdouble? boolean
---@field underdotted? boolean
---@field underdashed? boolean
---@field strikethrough? boolean
---@field italic? boolean
---@field reverse? boolean
---@field nocombine? boolean
---@field link? string
---@field default? boolean
---@field ctermfg? integer|string
---@field ctermbg? integer|string
---@field cterm? table

return M
