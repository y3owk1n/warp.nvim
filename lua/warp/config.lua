---@mod warp.nvim.config Configurations
---@brief [[
---
---Example Configuration:
---
--->
---{
---  root_markers = { ".git" },
---  keymaps = {
---    quit = { "q", "<Esc>" },
---    select = { "<CR>" },
---    delete = { "dd" },
---    move_up = { "<C-k>" },
---    move_down = { "<C-j>" },
---  },
---}
---<
---
---@brief ]]

local M = {}

local list = require("warp.list")
local utils = require("warp.utils")

---@type Warp.Config
M.config = {}

---@private
---@type Warp.Config
M.defaults = {
  root_markers = { ".git" },
  keymaps = {
    quit = { "q", "<Esc>" },
    select = { "<CR>" },
    delete = { "dd" },
    move_up = { "<C-k>" },
    move_down = { "<C-j>" },
  },
}

---@private
--- Setup autocommands
---@return nil
function M.setup_autocmds()
  vim.api.nvim_create_autocmd("DirChanged", {
    group = utils.augroup("dir_changed"),
    callback = function()
      list.load_list()
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = utils.augroup("checktime"),
    callback = function()
      if vim.o.buftype ~= "nofile" then
        list.load_list()
      end
    end,
  })
end

---@private
--- Setup user commands
---@return nil
function M.setup_usercmds()
  local action = require("warp.action")

  vim.api.nvim_create_user_command("WarpAddFile", function()
    action.add()
  end, {
    desc = "Add a file to the list",
  })

  vim.api.nvim_create_user_command("WarpShowList", function()
    action.show_list()
  end, {
    desc = "Show the list of files",
  })

  vim.api.nvim_create_user_command("WarpClearCurrentList", function()
    list.clear_current_list()
  end, {
    desc = "Clear the current list",
  })

  vim.api.nvim_create_user_command("WarpClearAllList", function()
    list.clear_all_list()
  end, {
    desc = "Clear all lists",
  })

  vim.api.nvim_create_user_command("WarpGoToIndex", function(opts)
    local index = tonumber(opts.args)

    if not index then
      vim.notify("Failed to warp, need a number", vim.log.levels.ERROR)
      return
    end

    action.goto_index(index)
  end, {
    nargs = "*",
    desc = "Go to a specific index in the list",
  })
end

---@private
--- Setup Warp
---@param user_config Warp.Config
---@return nil
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})

  M.setup_autocmds()
  M.setup_usercmds()

  list.load_list()
end

return M
