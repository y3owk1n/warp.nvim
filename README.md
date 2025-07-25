# warp.nvim

> ⚡️ Warp is a lightweight project-local buffer list for Neovim — add, view, jump, reorder, and remove buffers, all from a floating window or a keymap away.

`warp.nvim` provides a per-project list of important files, allowing you to quickly return to them later. think of it as “files bookmarks,” scoped to your git repo (or any project root).

It's inspired by [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon), but with a simpler goal: **do one thing well.** No terminals, no fancy workflows — just files you care about, saved per project.

![warp-demo](https://github.com/user-attachments/assets/09ef6849-bc82-486f-8b0a-f407152bc8fd)

## ❓ Why `warp.nvim`?

Because sometimes you want a simple list of files you care about, and you want it **per project**, and you want it **to just work**.

- No extra dependencies
- No terminal management
- No session trickery
- No global state
- No Lua rocket science

Just you, your files, and a fast way to warp between them.

## 🔧 Features

- 📁 Per-project file list (based on root markers like `.git`, or custom root resolver)
- 🌪 Add current file with line number, and updatable line numbers
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
- [Integrations](#-integrations)
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
  -- [root_markers] order based markers for root detection, disable root_markers by setting it to {} and it will fallback to only `cwd` as root
  root_markers = { ".git" },
  -- [root_detection_fn] this function must return a path that exists in string
  -- `root_markers` are checked in order, if the function returns a path that doesn't exist, it will fallback to `cwd`
  root_detection_fn = require("warp.storage").find_project_root,
  -- [keymaps] if you don't want certain keymaps, just set it to {}
  keymaps = {
    quit = { "q", "<Esc>" }, -- quit the warp selection window
    select = { "<CR>" }, -- select the file in the warp selection window
    delete = { "dd" }, -- delete the file in the warp selection window
    move_up = { "<C-k>" }, -- move an item up in the warp selection window
    move_down = { "<C-j>" }, -- move an item down in the warp selection window
  },
  float_opts = {
    width = 0.5,
    height = 0.5,
    relative = "editor",
    title_pos = "left",
  },
}
```

### Type Definitions

```lua
---@class Warp.Config
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field root_detection_fn? fun(): string? The function to detect the root, defaults to `require("warp.storage").find_project_root`
---@field keymaps? Warp.Config.Keymaps The keymaps for actions
---@field float_opts? Warp.Config.FloatOpts The floating window options

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]

---@class Warp.Config.FloatOpts
---@field width? integer The width of the window, more than 1 = absolute, less than 1 = calculated percentage
---@field height? integer The height of the window, more than 1 = absolute, less than 1 = calculated percentage
---@field relative? "cursor"|"editor"|"laststatus"|"mouse"|"tabline"|"win" The relative position of the window, defaults to "editor"
---@field anchor? "NW" | "NW" | "SW" | "SE" The anchor position of the window, no default
---@field title_pos? "left" | "center" | "right" The position of the title, defaults to "left"
---@field border? "double"|"none"|"rounded"|"shadow"|"single"|"solid"|"shadow" The border style of the window, no default
---@field zindex? integer The z-index of the window, no default
---@field focusable? boolean Whether the window is focusable, no default
```

## 🚀 Quick Start

See the example below for how to configure **warp.nvim** with keybindings.

```lua
{
  "y3owk1n/warp.nvim",
  event = "VeryLazy",
  cmd = {
    "WarpAddFile",
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
      "<leader>h",
      "",
      desc = "warp",
    },
    {
      "<leader>ha",
      "<cmd>WarpAddFile<cr>",
      desc = "[Warp] Add",
    },
    {
      "<leader>hh",
      "<cmd>WarpShowList<cr>",
      desc = "[Warp] Show list",
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

### Add a file to the list

```lua
require("warp").add()

-- or any of the equivalents

:WarpAddFile
:lua require("warp").add()
```

### Go to a specific index in the list

```lua
---@param idx number
require("warp").goto_index(idx)

-- or any of the equivalents

:WarpGoToIndex {idx}
:lua require("warp").goto_index(idx)
```

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
---@return number|nil
require("warp").get_index_by_buf(buf)
```

### Get the count of the items

Useful for showing on statusline. See [Integrations](#-integrations) for more details.

```lua
---@return number
require("warp").get_list_count()
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
| `1 - 9` | Quick Select | Select the item based on the number |

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
        return warp.get_list_count() > 0
      end,
      init = function(self)
        self.current = warp.get_index_by_buf(0)
        self.total = warp.get_list_count()
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
          return string.format("󱡁 %s", statusline)
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

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
