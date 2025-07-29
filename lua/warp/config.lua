---@mod warp.config Configurations
---@brief [[
---Configuration related implementations
---
---Default Configuration:
---
--->
---{
---  auto_prune = false,
---  root_markers = { ".git" },
---  root_detection_fn = require("warp.builtins").root_detection_fn,
---  list_item_format_fn = require("warp.builtins").list_item_format_fn,
---  keymaps = {
---    quit = { "q", "<Esc>" },
---    select = { "<CR>" },
---    delete = { "dd" },
---    move_up = { "<C-k>" },
---    move_down = { "<C-j>" },
---    show_help = { "g?" },
---  },
---  window = {
---    list = {},
---    help = {},
---  },
---  hl_groups = {
---    list_normal = { link = "Normal" },
---    list_border = { link = "FloatBorder" },
---    list_title = { link = "FloatTitle" },
---    list_footer = { link = "FloatFooter" },
---    list_cursor_line = { link = "CursorLine" },
---    list_item_active = { link = "Added" },
---    list_item_error = { link = "Error" },
---    help_normal = { link = "Normal" },
---    help_border = { link = "FloatBorder" },
---    help_title = { link = "FloatTitle" },
---    help_footer = { link = "FloatFooter" },
---    help_cursor_line = { link = "CursorLine" },
---  },
---}
---<
---
---@brief ]]

local M = {}

local api = vim.api
local events = require("warp.events")
local list = require("warp.list")
local storage = require("warp.storage")
local utils = require("warp.utils")

---@type Warp.Config
---@see warp.types.Warp.Config
M.config = {}

---@private
---@type Warp.Config
M.defaults = {
  auto_prune = false,
  root_markers = { ".git" },
  root_detection_fn = require("warp.builtins").root_detection_fn,
  list_item_format_fn = require("warp.builtins").list_item_format_fn,
  keymaps = {
    quit = { "q", "<Esc>" },
    select = { "<CR>" },
    delete = { "dd" },
    move_up = { "<C-k>" },
    move_down = { "<C-j>" },
    split_horizontal = { "<C-w>s" },
    split_vertical = { "<C-w>v" },
    show_help = { "g?" },
  },
  window = {
    list = {},
    help = {},
  },
  hl_groups = {
    --- list window hl
    list_normal = { link = "Normal" },
    list_border = { link = "FloatBorder" },
    list_title = { link = "FloatTitle" },
    list_footer = { link = "FloatFooter" },
    list_cursor_line = { link = "CursorLine" },
    list_item_active = { link = "Added" },
    list_item_error = { link = "Error" },
    --- help window hl
    help_normal = { link = "Normal" },
    help_border = { link = "FloatBorder" },
    help_title = { link = "FloatTitle" },
    help_footer = { link = "FloatFooter" },
    help_cursor_line = { link = "CursorLine" },
  },
}

---@private
---Setup autocommands
---@return nil
function M.setup_autocmds()
  -- Re-initialize the list when the directory changes
  -- So that root detection can do it's work and ensure getting the right list
  api.nvim_create_autocmd("DirChanged", {
    group = utils.augroup("dir_changed"),
    callback = function()
      list.init()
    end,
  })

  -- Re-initialize the list when the file is focused
  -- This is to ensure if so happens to edit the same list but at different terminal instance
  -- Maybe there is a better way to do this
  api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = utils.augroup("checktime"),
    callback = function()
      if vim.o.buftype ~= "nofile" then
        list.init()
      end
    end,
  })

  -- Best effor to update the cursor position when leaving the file
  -- NOTE: Not sure if these are the best events to use, but they seem to work
  api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
    callback = function(args)
      local bufnr = args.buf
      local item = list.get.item_by_buf(bufnr)

      if not item then
        return
      end

      local cursor = api.nvim_win_get_cursor(0)

      if item.entry.cursor ~= cursor then
        local ok = list.action.update_line_number(item.index, cursor)

        if ok then
          events.emit(events.constants.updated_item_cursor)
        end
      end
    end,
  })

  -- Most operations do not trigger a `save` to the fs, but emit events after the operation is done
  -- I am assuming that most of these events will cause a diff in the list, so we should save it to the fs and
  -- redraw the statusline
  api.nvim_create_autocmd("User", {
    pattern = {
      events.constants.close_list_win,
      events.constants.added_to_list,
      events.constants.removed_from_list,
      events.constants.moved_item_index,
      events.constants.updated_item_cursor,
    },
    callback = function()
      storage.save()
      vim.cmd("redrawstatus")
    end,
  })
end

---@private
----Setup user commands
---@return nil
function M.setup_usercmds()
  api.nvim_create_user_command("WarpAddFile", function()
    require("warp").add()
  end, {
    desc = "Add a file to the list",
  })

  api.nvim_create_user_command("WarpAddOnScreenFiles", function()
    require("warp").add_all_onscreen()
  end, {
    desc = "Add all on screen buffer to list",
  })

  api.nvim_create_user_command("WarpDelFile", function()
    require("warp").del()
  end, {
    desc = "Delete a file to the list",
  })

  api.nvim_create_user_command("WarpMoveTo", function(opts)
    ---@type number | Warp.Config.MoveDirection
    local parsed_direction

    local number_index = tonumber(opts.args)
    if number_index then
      parsed_direction = number_index
    else
      local direction = opts.args
      parsed_direction = direction
    end

    require("warp").move_to(parsed_direction)
  end, {
    nargs = "*",
    complete = function()
      local count = require("warp").count()

      ---@type Warp.Config.MoveDirection[]
      local directions = { "prev", "next", "first", "last" }

      if count > 0 then
        for i = 1, count do
          table.insert(directions, tostring(i))
        end
      end

      return directions
    end,
    desc = "Move current buffer to a new index in list",
  })

  api.nvim_create_user_command("WarpShowList", function()
    require("warp").show_list()
  end, {
    desc = "Show the list of files",
  })

  api.nvim_create_user_command("WarpClearCurrentList", function()
    require("warp").clear_current_list()
  end, {
    desc = "Clear the current list",
  })

  api.nvim_create_user_command("WarpClearAllList", function()
    require("warp").clear_all_list()
  end, {
    desc = "Clear all lists",
  })

  api.nvim_create_user_command("WarpGoToIndex", function(opts)
    ---@type number | Warp.Config.MoveDirection
    local parsed_direction

    local number_index = tonumber(opts.args)
    if number_index then
      parsed_direction = number_index
    else
      local direction = opts.args
      parsed_direction = direction
    end

    require("warp").goto_index(parsed_direction)
  end, {
    nargs = "*",
    complete = function()
      local count = require("warp").count()

      ---@type Warp.Config.MoveDirection[]
      local directions = { "prev", "next", "first", "last" }

      if count > 0 then
        for i = 1, count do
          table.insert(directions, tostring(i))
        end
      end

      return directions
    end,
    desc = "Go to a specific index in the list",
  })
end

---@private
---Setup highlight groups
---@return nil
function M.setup_hl_groups()
  local hl_groups = M.config.hl_groups or {}

  for group_name, hl_group in pairs(hl_groups) do
    group_name = utils.hlname(group_name)
    vim.api.nvim_set_hl(0, group_name, hl_group)
  end
end

---@private
---Setup Warp
---@param user_config Warp.Config
---@return nil
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})

  M.setup_autocmds()
  M.setup_usercmds()
  M.setup_hl_groups()

  list.init()
end

return M
