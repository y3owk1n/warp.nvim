---@mod warp.nvim.builtins Builtins

---@brief [[
---Builtins related implementations
---@brief ]]

local M = {}

local fn = vim.fn

---Find the root directory based on root markers, or fall back to cwd
---@return string root_path The root path
---@usage `require('warp.builtins').root_detection_fn()`
function M.root_detection_fn()
  local cwd = fn.getcwd()

  local config = require("warp.config").config

  local root_markers = config.root_markers

  if not root_markers or #root_markers == 0 then
    return cwd
  end

  local path = cwd

  while path ~= "/" do
    for _, marker in ipairs(root_markers) do
      local full = path .. "/" .. marker
      if fn.isdirectory(full) == 1 or fn.filereadable(full) == 1 then
        return path
      end
    end

    path = fn.fnamemodify(path, ":h")
  end

  --- fallback to cwd
  return cwd
end

---Default format for the entry lines for warp list
---@param warp_item_entry Warp.ListItem The entry item
---@param index number The index of the entry
---@param is_active boolean|nil Whether the entry is active
---@param is_file_exists boolean|nil Whether the file exists in the system and reachable
---@return Warp.FormattedLineOpts[] formatted_entry The formatted entry
---@see warp.nvim.types.Warp.FormattedLineOpts
---@usage `require('warp.builtins').list_item_format_fn(warp_item_entry, index, is_active, is_file_exists)`
function M.list_item_format_fn(warp_item_entry, index, is_active, is_file_exists)
  ---@type Warp.FormattedLineOpts
  local virtual_spacer = {
    display_text = " ",
    is_virtual = true,
  }

  ---@type Warp.FormattedLineOpts
  local display_index = {
    display_text = tostring(index),
    is_virtual = true,
  }

  local has_devicons, nvim_web_devicons = pcall(require, "nvim-web-devicons")

  ---@type Warp.FormattedLineOpts
  ---@diagnostic disable-next-line: missing-fields
  local display_ft_icon = {}

  if has_devicons then
    local ft_icon, ft_icon_hl = nvim_web_devicons.get_icon(warp_item_entry.path, nil, { default = true })

    ---@type Warp.FormattedLineOpts
    display_ft_icon = {
      display_text = ft_icon,
      hl_group = ft_icon_hl,
      is_virtual = true,
    }
  end

  ---@type Warp.FormattedLineOpts
  local display_path = {
    display_text = fn.fnamemodify(warp_item_entry.path, ":~:."),
  }

  if not is_file_exists then
    display_path.hl_group = "Error"
  end

  ---@type Warp.FormattedLineOpts
  local display_active_marker = {
    display_text = "",
    hl_group = "Added",
    is_virtual = true,
  }

  ---@type Warp.FormattedLineOpts
  local display_error_marker = {
    display_text = "",
    hl_group = "Error",
    is_virtual = true,
  }

  return {
    display_index,
    has_devicons and virtual_spacer,
    has_devicons and display_ft_icon,
    virtual_spacer,
    display_path,
    is_active and virtual_spacer,
    is_active and display_active_marker,
    not is_file_exists and virtual_spacer,
    not is_file_exists and display_error_marker,
  }
end

---Default format for the entry lines for help
---@param keys string[] The list of keymaps for the entry
---@param description string The description of the entry
---@return Warp.FormattedLineOpts[] formatted_entry The formatted entry
---@see warp.nvim.types.Warp.FormattedLineOpts
---@usage `require('warp.builtins').help_item_format_fn(keys, description)`
function M.help_item_format_fn(keys, description)
  ---@type Warp.FormattedLineOpts
  local separator = {
    display_text = " │ ",
  }

  ---@type Warp.FormattedLineOpts
  local display_key = {
    display_text = table.concat(keys, ", "),
  }

  ---@type Warp.FormattedLineOpts
  local display_description = {
    display_text = description,
  }

  return {
    display_description,
    separator,
    display_key,
  }
end

return M
