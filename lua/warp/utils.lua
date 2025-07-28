---@mod warp.utils Utility functions

---@brief [[
---Utilities related implementations
---@brief ]]

local M = {}

local api = vim.api

---Convert a string to PascalCase
---@param string string The string to convert
---@return string The formatted string
---@usage `require('warp.utils').format_string_to_pascal_case("hello_world")`
function M.format_string_to_pascal_case(string)
  local formatted = string
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

  return api.nvim_create_augroup("Warp" .. formatted, { clear = true })
end

---Check if a file exists
---@param path string The path of the file
---@return boolean exists Whether the file exists
---@usage `require('warp.utils').file_exists(path)`
function M.file_exists(path)
  return vim.uv.fs_stat(path) ~= nil
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
---@param current_item_index number|nil The current index of the item
---@return number|nil parsed_index The parsed index
---@see warp.types.Warp.Config.MoveDirection
---@usage `require('warp.utils').parse_direction_or_index('prev')`
function M.parse_direction_or_index(direction_or_index, current_item_index)
  ---@type number
  local parsed_index

  if type(direction_or_index) == "number" then
    parsed_index = direction_or_index
  end

  if direction_or_index == "first" then
    parsed_index = 1
  end

  if direction_or_index == "last" then
    parsed_index = require("warp.list").get.count()
  end

  if current_item_index and direction_or_index == "prev" then
    parsed_index = current_item_index - 1
  end

  if current_item_index and direction_or_index == "next" then
    parsed_index = current_item_index + 1
  end

  return parsed_index
end

---Get all on screen visible buffers
---@return number[] bufs The list of all on screen buffers
---@usage `require('warp.utils').get_all_onscreen_bufs()`
function M.get_all_onscreen_bufs()
  local bufs = {}

  for _, win in ipairs(api.nvim_list_wins()) do
    local bufnr = api.nvim_win_get_buf(win)

    local path = vim.fs.normalize(api.nvim_buf_get_name(bufnr))

    if M.file_exists(path) then
      bufs[bufnr] = true
    end
  end

  -- Convert keys to list
  local result = {}
  for buf, _ in pairs(bufs) do
    table.insert(result, buf)
  end

  return result
end

---Parse a format result and ensure all in string
---@param format_result Warp.FormattedLineOpts[] The format result
---@return Warp.ComputedLineOpts[] raw The parsed format result
---@see warp.types.Warp.FormattedLineOpts
---@see warp.types.Warp.ComputedLineOpts
---@usage `require('warp.utils').parse_format_fn_result(format_result)`
function M.parse_format_fn_result(format_result)
  ---@type Warp.ComputedLineOpts[]
  local parsed = {}

  ---@type number keep track of the col counts to proper compute every col position
  local current_line_col = 0

  for _, item in ipairs(format_result) do
    if type(item) ~= "table" then
      goto continue
    end

    ---@type Warp.ComputedLineOpts
    ---@diagnostic disable-next-line: missing-fields
    local parsed_item = {}

    -- force `is_virtual` to false just in case
    parsed_item.is_virtual = item.is_virtual or false

    if item.display_text then
      if type(item.display_text) == "string" then
        parsed_item.display_text = item.display_text
      end

      -- just in case user did not `tostring` the number
      if type(item.display_text) == "number" then
        parsed_item.display_text = tostring(item.display_text)
      end

      if not parsed_item.is_virtual then
        ---calculate the start and end column one by one
        parsed_item.col_start = current_line_col
        current_line_col = parsed_item.col_start + #parsed_item.display_text
        parsed_item.col_end = current_line_col
      else
        parsed_item.col_start = current_line_col
      end
    end

    if item.hl_group then
      if type(item.hl_group) == "string" then
        parsed_item.hl_group = item.hl_group
      end
    end

    table.insert(parsed, parsed_item)

    ::continue::
  end

  return parsed
end

---Convert a parsed format result to string
---@param parsed Warp.ComputedLineOpts[] The parsed format result
---@return string lines The formatted lines
---@see warp.types.Warp.ComputedLineOpts
---@usage `require('warp.utils').convert_parsed_format_result_to_string(parsed)`
function M.convert_parsed_format_result_to_string(parsed)
  local display_lines = {}

  for _, item in ipairs(parsed) do
    if item.display_text and not item.is_virtual then
      table.insert(display_lines, item.display_text)
    end
  end

  return table.concat(display_lines, "")
end

return M
