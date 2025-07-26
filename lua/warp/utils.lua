---@mod warp.nvim.utils Utilities

---@brief [[
---Utilities related implementations
---@brief ]]

local M = {}

local api = vim.api

---Convert a string to PascalCase
---@param str string The string to convert
---@return string The formatted string
---@usage `require('warp.utils').format_string_to_pascal_case("hello_world")`
function M.format_string_to_pascal_case(str)
  local formatted = str
    :gsub("[^%w]", " ") -- Replace non-alphanumeric with space
    :gsub("(%a)(%w*)", function(a, b) -- Capitalize each word
      return a:upper() .. b:lower()
    end)
    :gsub("%s+", "") -- Remove all spaces

  return formatted
end

---Create an augroup
---@param name string The name of the augroup
---@return integer The augroup ID
---@usage `require('warp.utils').augroup("my_augroup")`
function M.augroup(name)
  local formatted = M.format_string_to_pascal_case(name)

  return vim.api.nvim_create_augroup("Warp" .. formatted, { clear = true })
end

---Check if a file exists
---@param path string The path of the file
---@return boolean exists Whether the file exists
---@usage `require('warp.utils').file_exists(path)`
function M.file_exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

---Set a keymap for a buffer
---@param bufnr number The buffer number
---@param lhs string The keymap
---@param rhs fun() The function to execute
---@usage `require('warp.utils').buf_set_keymap(bufnr, lhs, rhs)`
function M.buf_set_keymap(bufnr, lhs, rhs)
  vim.keymap.set("n", lhs, rhs, {
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true,
  })
end

---Parse a direction_or_index to a number
---@param direction_or_index Warp.Config.MoveDirection | number The direction or index to move to
---@param current_item_idx number|nil The current index of the item
---@return number|nil parsed_idx The parsed index
---@usage `require('warp.utils').parse_direction_or_index('prev')`
function M.parse_direction_or_index(direction_or_index, current_item_idx)
  ---@type number
  local parsed_idx

  if type(direction_or_index) == "number" then
    parsed_idx = direction_or_index
  end

  if direction_or_index == "first" then
    parsed_idx = 1
  end

  if direction_or_index == "last" then
    parsed_idx = require("warp.list").get.count()
  end

  if current_item_idx and direction_or_index == "prev" then
    parsed_idx = current_item_idx - 1
  end

  if current_item_idx and direction_or_index == "next" then
    parsed_idx = current_item_idx + 1
  end

  return parsed_idx
end

---Get all on screen visible buffers
---@return number[] bufs The list of all on screen buffers
---@usage `require('warp.utils').get_all_onscreen_bufs()`
function M.get_all_onscreen_bufs()
  local bufs = {}
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)

    local path = vim.fs.normalize(api.nvim_buf_get_name(buf))

    if M.file_exists(path) then
      bufs[buf] = true
    end
  end

  -- Convert keys to list
  local result = {}
  for buf, _ in pairs(bufs) do
    table.insert(result, buf)
  end

  return result
end

return M
