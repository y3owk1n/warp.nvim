---@mod warp.nvim.config Configurations
---@brief [[
---Configuration related implementations
---
---Default Configuration:
---
--->
---{
---  root_markers = { ".git" },
---  root_detection_fn = require("warp.builtins").root_detection_fn,
---  list_item_format_fn = require("warp.builtins").list_item_format_fn,
---  keymaps = {
---    quit = { "q", "<Esc>" },
---    select = { "<CR>" },
---    delete = { "dd" },
---    move_up = { "<C-k>" },
---    move_down = { "<C-j>" },
---  },
--- float_opts = {
---   width = 0.5,
---   height = 0.5,
---   relative = "editor",
---   title_pos = "left",
--- },
---}
---<
---
---@brief ]]

local M = {}

local events = require("warp.events")
local list = require("warp.list")
local storage = require("warp.storage")
local utils = require("warp.utils")

---@type Warp.Config
---@see warp.nvim.types.Warp.Config
M.config = {}

---@private
---@type Warp.Config
M.defaults = {
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
  },
  float_opts = {
    width = 0.5,
    height = 0.5,
    relative = "editor",
    title_pos = "left",
  },
}

---@private
---Setup autocommands
---@return nil
function M.setup_autocmds()
  vim.api.nvim_create_autocmd("DirChanged", {
    group = utils.augroup("dir_changed"),
    callback = function()
      list.init()
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = utils.augroup("checktime"),
    callback = function()
      if vim.o.buftype ~= "nofile" then
        list.init()
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    callback = function(args)
      local buf = args.buf
      local item = list.get.item_by_buf(buf)
      local cursor = vim.api.nvim_win_get_cursor(0)

      if not item then
        return
      end

      if item.entry.cursor ~= cursor then
        local ok = list.action.update_line_number(item.index, cursor)

        if ok then
          events.emit(events.constants.updated_item_cursor)
        end
      end
    end,
  })

  ---Setup to save list on closing the list window
  vim.api.nvim_create_autocmd("User", {
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
  vim.api.nvim_create_user_command("WarpAddFile", function()
    require("warp").add()
  end, {
    desc = "Add a file to the list",
  })

  vim.api.nvim_create_user_command("WarpAddOnScreenFiles", function()
    require("warp").add_all_onscreen()
  end, {
    desc = "Add all on screen buffer to list",
  })

  vim.api.nvim_create_user_command("WarpDelFile", function()
    require("warp").del()
  end, {
    desc = "Delete a file to the list",
  })

  vim.api.nvim_create_user_command("WarpMoveTo", function(opts)
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

  vim.api.nvim_create_user_command("WarpShowList", function()
    require("warp").show_list()
  end, {
    desc = "Show the list of files",
  })

  vim.api.nvim_create_user_command("WarpClearCurrentList", function()
    require("warp").clear_current_list()
  end, {
    desc = "Clear the current list",
  })

  vim.api.nvim_create_user_command("WarpClearAllList", function()
    require("warp").clear_all_list()
  end, {
    desc = "Clear all lists",
  })

  vim.api.nvim_create_user_command("WarpGoToIndex", function(opts)
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
---Setup Warp
---@param user_config Warp.Config
---@return nil
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})

  M.setup_autocmds()
  M.setup_usercmds()

  list.init()
end

return M
