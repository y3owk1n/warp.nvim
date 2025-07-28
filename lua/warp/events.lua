---@mod warp.events Events modules

---@brief [[
---Events related implementations
---@brief ]]

local M = {}

local utils = require("warp.utils")

---@class Warp.Events
---@field open_list_win 'WarpOpenListWin' When a list window is opened
---@field close_list_win 'WarpCloseListWin' When a list window is closed
---@field added_to_list 'WarpAddedToList' When a file is added to the list
---@field removed_from_list 'WarpRemovedFromList' When a file is removed from the list
---@field moved_item_index 'WarpMovedItemIndex' When an item is moved within list
---@field updated_item_cursor 'WarpUpdatedItemCursor' When a cursor for an item is updated

---@type Warp.Events
M.constants = {
  open_list_win = "Warp" .. utils.format_string_to_pascal_case("open_list_win"),
  close_list_win = "Warp" .. utils.format_string_to_pascal_case("close_list_win"),
  added_to_list = "Warp" .. utils.format_string_to_pascal_case("added_to_list"),
  removed_from_list = "Warp" .. utils.format_string_to_pascal_case("removed_from_list"),
  moved_item_index = "Warp" .. utils.format_string_to_pascal_case("moved_item_index"),
  updated_item_cursor = "Warp" .. utils.format_string_to_pascal_case("updated_item_cursor"),
}

---Emit an event
---@param event string The event name
---@return nil
---@usage `require('warp.events').emit("my_event")`
function M.emit(event)
  vim.api.nvim_exec_autocmds("User", { pattern = event })
end

return M
