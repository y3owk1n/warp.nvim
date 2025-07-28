# warp.nvim

> ⚡️ Warp is a lightweight project-local file list for Neovim — add, view, jump, reorder, and remove files, all from a floating window or a keymap away.

`warp.nvim` provides a per-project list of important files, allowing you to quickly return to them later. think of it as “files bookmarks,” scoped to your git repo (or any project root).

It's inspired by [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon), but with a simpler goal: **do one thing well.** No terminals, no fancy workflows — just files you care about, saved per project (or rather per defined root path).

![warp-main](https://github.com/user-attachments/assets/59a8e78f-3c2b-4170-b6c8-d4acdf4348a4)

## ❓ Why `warp.nvim`?

Because sometimes you want a simple list of files you care about, and you want it **per project** or **defined root**, and you want it **to just work**.

- No extra dependencies
- No terminal management
- No session trickery
- No global state
- No Lua rocket science

Just you, your files, and a fast way to warp between them.

## 🔧 Features

- 📁 Per-project file list (based on root markers like `.git`, or custom root resolver)
- 🌪 Add current file with cursor position with auto cursor updates
- 👀 View list in a floating window
- ✨ Reorder entries via keymaps
- ❌ Remove entries via keymaps
- 🚀 Jump to any file instantly
- 🔁 Auto-reload list on `:cd`, `FocusGained`, `TermClose`, etc.
- 💾 Persistent storage in `stdpath("data")/warp/**`
- 🧹 Auto-prune unreachable or deleted files

## 📕 Contents

- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Quick Start](#-quick-start)
- [API](#-api)
- [Keybindings](#%EF%B8%8F-keybindings)
- [Events](#%EF%B8%8F-events)
- [Integrations](#-integrations)
- [UI Customization Example](#-ui-customization-example)
- [Contributing](#-contributing)

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- warp.lua
return {
 "y3owk1n/warp.nvim",
 version = "*", -- remove this if you want to use the `main` branch
 opts = {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
 }
}
```

If you are using other package managers you need to call `setup`:

```lua
require("warp").setup({
  -- your configuration
})
```

## ⚙️ Configuration

**warp.nvim** is highly configurable. And the default configurations are as below.

### Default Options

```lua
---@type Warp.Config
{
  -- [auto_prune] automatically prunes by checking if it's a readable file
  -- if `auto_prune` is set to `true`, it will prune all the unreadable files
  -- if `auto_prune` is set to `false`, it will not prune any files but warns you in the list and during navigation
  -- default is `false` by assuming git branch management, and files might be deleted, and you still want to keep it
  -- this gives the flexibility of how you want to keep the files in your fingertips and manage them yourself
  auto_prune = false,
  -- [root_markers] order based markers for root detection, disable root_markers by setting it to {} and it will fallback to only `cwd` as root
  root_markers = { ".git" },
  -- [root_detection_fn] this function must return a path that exists in string
  -- `root_markers` are checked in order, if the function returns a path that doesn't exist, it will fallback to `cwd`
  -- NOTE: this defines a root for the project to be saved and synced to the storage
  -- you can do fancy detection like if condition then a root that you want, else then another root or a global root
  root_detection_fn = require("warp.builtins").root_detection_fn,
  -- [list_item_format_fn] this function must return in Warp.FormattedLineOpts[]
  -- Warp.FormattedLineOpts is a table with 2 fields, display_text and optional hl_group
  -- passing anything other than specified format will be ommited
  list_item_format_fn = require("warp.builtins").list_item_format_fn,
  -- [keymaps] if you don't want certain keymaps, just set it to {}
  keymaps = {
    quit = { "q", "<Esc>" }, -- quit the warp selection window
    select = { "<CR>" }, -- select the file in the warp selection window
    delete = { "dd" }, -- delete the file in the warp selection window
    move_up = { "<C-k>" }, -- move an item up in the warp selection window
    move_down = { "<C-j>" }, -- move an item down in the warp selection window
    split_horizontal = { "<C-w>s" }, -- horizontal split
    split_vertical = { "<C-w>v" }, -- vertical split
    show_help = { "g?" }, -- show the help menu
  },
  -- [window] window configurations
  window = {
    -- [window.list] window configurations for the list window
    -- can be a table of `win_config` or a function that takes a list of lines and returns a `win_config`
    list = {},
    -- [window.help] window configurations for the help window
    -- can be a table of `win_config` or a function that takes a list of lines and returns a `win_config`
    help = {},
  },
}
```

### Type Definitions

```lua
---@class Warp.Config
---@field auto_prune? boolean Whether to auto prune the list, defaults to false
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field root_detection_fn? fun(): string? The function to detect the root, defaults to `require("warp.storage").find_project_root`
---@field list_item_format_fn? fun(entry: Warp.ListItem, idx: number, is_active: boolean|nil): string The function to format the list items lines
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

---@class Warp.Config.Window
---@field list? vim.api.keyset.win_config|fun(lines: string[]):vim.api.keyset.win_config The window configurations for the list window
---@field help? vim.api.keyset.win_config|fun(lines:string[]):vim.api.keyset.win_config The window configurations for the help window
```

## 🚀 Quick Start

See the example below for how to configure **warp.nvim** with keybindings. In my opinion, the defaults are good enough
that you probably don't need to configure anything and start working on it.

> [!NOTE]
> The example below showcases all of the potential keybindings that you can do, you don't have to use all of them...

```lua
{
  "y3owk1n/warp.nvim",
  event = "VeryLazy",
  cmd = {
    "WarpAddFile",
    "WarpAddOnScreenFiles",
    "WarpDelFile",
    "WarpMoveTo",
    "WarpShowList",
    "WarpClearCurrentList",
    "WarpClearAllList",
    "WarpGoToIndex",
  },
  ---@module "warp"
  ---@type Warp.Config
  opts = {},
  keys = {
    {
      ---For which key usage
      "<leader>h",
      "",
      desc = "warp",
    },
    {
      ---For which key usage
      "<leader>hm",
      "",
      desc = "move",
    },
    {
      "<leader>ha",
      "<cmd>WarpAddFile<cr>",
      desc = "[Warp] Add",
    },
    {
      "<leader>hA",
      "<cmd>WarpAddOnScreenFiles<cr>",
      desc = "[Warp] Add all on screen files",
    },
    {
      "<leader>hd",
      "<cmd>WarpDelFile<cr>",
      desc = "[Warp] Delete",
    },
    {
      "<leader>he",
      "<cmd>WarpShowList<cr>",
      desc = "[Warp] Show list",
    },
    {
      "<leader>hml",
      "<cmd>WarpMoveTo next<cr>",
      desc = "[Warp] Move to next index",
    },
    {
      "<leader>hmh",
      "<cmd>WarpMoveTo prev<cr>",
      desc = "[Warp] Move to prev index",
    },
    {
      "<leader>hmL",
      "<cmd>WarpMoveTo last<cr>",
      desc = "[Warp] Move to the last index",
    },
    {
      "<leader>hmH",
      "<cmd>WarpMoveTo first<cr>",
      desc = "[Warp] Move to first index",
    },
    {
      "<leader>hx",
      "<cmd>WarpClearCurrentList<cr>",
      desc = "[Warp] Clear current list",
    },
    {
      "<leader>hX",
      "<cmd>WarpClearAllList<cr>",
      desc = "[Warp] Clear all lists",
    },
    {
      "<leader>hl",
      "<cmd>WarpGoToIndex next<cr>",
      desc = "[Warp] Goto next index",
    },
    {
      "<leader>hh",
      "<cmd>WarpGoToIndex prev<cr>",
      desc = "[Warp] Goto prev index",
    },
    {
      "<leader>hH",
      "<cmd>WarpGoToIndex first<cr>",
      desc = "[Warp] Goto first index",
    },
    {
      "<leader>hL",
      "<cmd>WarpGoToIndex last<cr>",
      desc = "[Warp] Goto last index",
    },
    {
      "<leader>1",
      "<cmd>WarpGoToIndex 1<cr>",
      desc = "[Warp] Goto #1",
    },
    {
      "<leader>2",
      "<cmd>WarpGoToIndex 2<cr>",
      desc = "[Warp] Goto #2",
    },
    {
      "<leader>3",
      "<cmd>WarpGoToIndex 3<cr>",
      desc = "[Warp] Goto #3",
    },
    {
      "<leader>4",
      "<cmd>WarpGoToIndex 4<cr>",
      desc = "[Warp] Goto #4",
    },
  },
},
```

## 🌎 API

**warp.nvim** provides the following api functions that you can use to map to your own keybindings:

### Show the list of files

```lua
require("warp").show_list()

-- or any of the equivalents

:WarpShowList
:lua require("warp").show_list()
```

### Add current buffer file to the list

```lua
require("warp").add()

-- or any of the equivalents

:WarpAddFile
:lua require("warp").add()
```

### Add all on screen buffer files to the list

Sometime you're lazy to add the files one by one, this will come in handy, if you want all the files visible on screen.

```lua
require("warp").add_all_onscreen()

-- or any of the equivalents

:WarpAddOnScreenFiles
:lua require("warp").add_all_onscreen()
```

## Delete current buffer file from the list

```lua
require("warp").del()

-- or any of the equivalents

:WarpDelFile
:lua require("warp").del()
```

### Go to a specific index in the list

```lua
---@alias Warp.Config.MoveDirection
---| '"prev"'
---| '"next"'
---| '"first"'
---| '"last"'

---@param direction_or_index Warp.Config.MoveDirection | number
require("warp").goto_index(direction_or_index)

-- or any of the equivalents

:WarpGoToIndex {direction_or_index}
:lua require("warp").goto_index(direction_or_index)
```

### Move to direction or index

```lua
---@alias Warp.Config.MoveDirection
---| '"prev"'
---| '"next"'
---| '"first"'
---| '"last"'

---@param direction_or_index Warp.Config.MoveDirection | number
require("warp").move_to(direction_or_index)

-- or any of the equivalents

:WarpMoveTo {direction_or_index}
:lua require("warp").move_to(direction_or_index)
````

### Clear or empty current list

```lua
require("warp").clear_current_list()

-- or any of the equivalents

:WarpClearCurrentList
:lua require("warp").clear_current_list()
```

### Clear all lists

```lua
require("warp").clear_all_list()

-- or any of the equivalents

:WarpClearAllList
:lua require("warp").clear_all_list()
```

### Update list when file path changes

This function is normally used to integrate with other plugins that change the file path, such as `snacks.nvim`,
`mini.files` and more. See [Integrations](#-integrations) for more details.

```lua
---@param from string
---@param to string
require("warp").on_file_update(from, to)
```

### Get the index of an entry by buffer

Useful for showing on statusline. See [Integrations](#-integrations) for more details.

```lua
---@param buf number
---@return { entry: Warp.ListItem, index: number }|nil
require("warp").get_item_by_buf(buf)
```

### Get the count of the items

Useful for showing on statusline. See [Integrations](#-integrations) for more details.

```lua
---@return number
require("warp").count()
```

### Builtins

### `root_detection_fn`

This function must return a string that exists in string. It will be used as the root path for the project.

Below is the default implementation. You can override it by setting `root_detection_fn` in config.

```lua
---Find the root directory based on root markers, or fall back to cwd
---@return string root_path The root path
---@usage `require('warp.builtins').root_detection_fn()`
function M.root_detection_fn()
  local cwd = vim.fn.getcwd()

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
```

#### `list_item_format_fn`

This function must return in `Warp.FormattedLineOpts[]`. `Warp.FormattedLineOpts` is a table with 2 fields, `display_text` and optional `hl_group`. Passing anything other than specified format will be ommited.

Below is the default implementation. You can override it by setting `list_item_format_fn` in config.

```lua
---@class Warp.FormattedLineOpts
---@field display_text string The display text
---@field hl_group? string The highlight group of the text

---Default format for the entry lines
---@param entry Warp.ListItem The entry item
---@param idx number The index of the entry
---@param is_active boolean|nil Whether the entry is active
---@param is_file_exists boolean|nil Whether the file exists in the system and reachable
---@return Warp.FormattedLineOpts[] formatted_entry The formatted entry
---@usage `require('warp.builtins').list_item_format_fn(entry, idx, is_active, is_file_exists)`
function M.list_item_format_fn(warp_item_entry, index, is_active, is_file_exists)
  ---@type Warp.FormattedLineOpts
  local virtual_spacer = {
    display_text = " ",
    is_virtual = true,
  }

  ---@type Warp.FormattedLineOpts
  ---@diagnostic disable-next-line: missing-fields
  local display_index = {
    display_text = tostring(index),
    is_virtual = true,
  }

  if is_active then
    display_index.display_text = "*"
    display_index.hl_group = "Added"
  end

  if not is_file_exists then
    display_index.display_text = "x"
    display_index.hl_group = "Error"
  end

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

  return {
    display_index,
    has_devicons and virtual_spacer,
    has_devicons and display_ft_icon,
    virtual_spacer,
    display_path,
  }
end
```

## ⌨️ Keybindings

All the keybindings are customizable in config via `keymaps` field.

| Key | Action | Description |
| -------------- | --------------- | ------------ |
| `<CR>` | Select | Select the current item |
| `q`, `<ESC>` | Close | Close the window |
| `dd` | Delete | Delete the current item |
| `<C-k>` | Move item up | Move the current item up |
| `<C-j>` | Move item down | Move the current item down |
| `<C-w>s` | Split horizontal | Split the window horizontally |
| `<C-w>v` | Split vertical | Split the window vertically |
| `1 - 9` | Quick Select | Select the item based on the number |
| `g?` | Help | Show the help menu |

## 🕰️ Events

- `WarpOpenListWin` - Fired when a list window is opened
- `WarpCloseListWin` - Fired when a list window is closed
- `WarpAddedToList` - Fired when a file is added to the list
- `WarpRemovedFromList` - Fired when a file is deleted from the list
- `WarpMovedItemIndex` - Fired when an item is moved within list
- `WarpUpdatedItemCursor` - Fired when an item's cursor is updated

> [!note]
> If you want to be safe, you can use the `constants` to get the event instead of the string.
> For example `require("warp.events").constants.ev_that_you_want`

You can then listen to these user events and do something with them.

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "WarpAddedToList",
  callback = function()
    -- do something
  end,
})
```

## 🔌 Integrations

### With `mini.files`

This snippet will update the warp list when you rename or move a file from `mini.files`.

```lua
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
  callback = function(ev)
    local from, to = ev.data.from, ev.data.to

    local warp_exists, warp = pcall(require, "warp")
    if warp_exists then
      warp.on_file_update(from, to)
    end
  end,
})
```

### With `snacks.nvim`

This snippet will update the warp list when you do a file rename in `snacks.nvim`.

```lua
{
  "folke/snacks.nvim",
  opts = {},
  keys = {
    {
      "<leader>cr",
      function()
        Snacks.rename.rename_file({
          on_rename = function(to, from)
            require("warp").on_file_update(from, to)
          end,
        })
      end,
      desc = "Rename File",
    },
  },
},
```

### With `heirline.nvim` statusline

![warp-statusline](https://github.com/user-attachments/assets/82925ba3-7e65-4127-afc9-7c54a7953851)

This snippet shows how I add warp to my statusline, it shoud be similar for other statuslines.

```lua
opts = function(_, opts)
  -- rest of the config

  local warp_exists, warp = pcall(require, "warp")

  -- rest of the config

  local Warp = {}

  if warp_exists then
    Warp = {
      condition = function()
        return warp.count() > 0
      end,
      init = function(self)
        local item = warp.get_item_by_buf(0)
        self.current = item and item.index or "-"
        self.total = warp.count()
      end,
      hl = { fg = "teal", bold = true },
      {
        provider = Space.provider,
      },
      {
        provider = function(self)
          local output = {}

          if self.total > 0 then
            table.insert(output, string.format("[%s/%s]", tonumber(self.current) or "-", tonumber(self.total)))
          end

          local statusline = table.concat(output, " ")
          return string.format("󱐋 %s", statusline)
        end,
      },
    }
  end

  -- rest of the config

  local DefaultStatusline = {
    -- rest of default statusline
    Warp, --- add warp the default statusline
    -- rest of default statusline
  }

  -- rest of the config
end,
```

### With `mini.starter`

![mini-starter-demo](https://github.com/user-attachments/assets/951b9a90-c47e-4540-b617-1a4320d39c8e)

This snippet shows how I add warp to my `mini.starter`, it shoud be similar for other starters / dashboards.

```lua
opts = function(_, opts)
  -- rest of the config
  local warp_exists, warp_list = pcall(require, "warp.list")

  local new_section = function(name, action, section)
    return { name = name, action = action, section = section }
  end

  local items = {
    new_section("e: Explore", "lua require('mini.files').open(vim.uv.cwd(), true)", "Navigate"),
    new_section("f: Find File", "Pick files", "Navigate"),
    new_section("g: Grep Text", "Pick grep_live", "Navigate"),
  }

  if warp_exists then
    local warps = warp_list.get.all()

    if #warps > 0 then
      for index, warp in ipairs(warps) do
        local display = vim.fn.pathshorten(vim.fn.fnamemodify(warp.path, ":~:."))

        table.insert(items, new_section(index .. ": " .. display, "WarpGoToIndex " .. index, "Warp"))
      end
    end
  end

  local config = {
    -- rest of the config
    items = items,
    -- rest of the config
  }

  return config
end
```

## 🧩 UI Customization Example

### Put the floating window to bottom left like `mini.visits`

![warp-bottom-left-float](https://github.com/user-attachments/assets/77aaf5f4-6e8e-4595-8afd-5f3d0b193e02)

```lua
opts = {
  window = {
    list = function(lines)
      -- get all the line widths
      local line_widths = vim.tbl_map(vim.fn.strdisplaywidth, lines)
      -- set the width te either the max width or at least 20 characters
      local max_width = math.max(math.max(unpack(line_widths)), 30)
      -- set the height to if the number of lines is less than 8 then 8
      -- otherwise the number of lines
      local max_height = #lines < 8 and 8 or math.min(#lines, vim.o.lines - 3)
      -- get the current height of the TUI
      local nvim_tui_height = vim.api.nvim_list_uis()[1]

      return {
        width = max_width,
        height = max_height,
        row = nvim_tui_height.height - max_height - 4,
        col = 0,
      }
    end,
  },
}
```

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
