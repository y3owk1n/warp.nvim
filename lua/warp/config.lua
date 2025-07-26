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

  ---Setup to save list on closing the list window
  vim.api.nvim_create_autocmd("User", {
    pattern = {
      events.constants.close_list_win,
      events.constants.added_to_list,
      events.constants.removed_from_list,
    },
    callback = function()
      storage.save()
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
    local index = tonumber(opts.args)

    if not index then
      vim.notify("[Warp:] Failed to warp, need a number", vim.log.levels.ERROR)
      return
    end

    require("warp").goto_index(index)
  end, {
    nargs = "*",
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
