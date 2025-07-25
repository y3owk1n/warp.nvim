# warp.nvim

⚡️ Warp is a lightweight project-local buffer list for Neovim — add, view, jump, reorder, and remove buffers, all from a floating window.

## ✨ Intro

`warp.nvim` provides a per-project list of important files, allowing you to quickly return to them later. Think of it as “buffer bookmarks,” scoped to your Git repo (or any project root).

It's inspired by [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon), but with a simpler goal: **do one thing well.** No terminals, no fancy workflows — just files you care about, saved per project.

## ❓ Why `warp.nvim`?

Because sometimes you want a simple list of buffers you care about, and you want it **per project**, and you want it **to just work**.

- No extra dependencies
- No terminal management
- No session trickery
- No global state
- No Lua rocket science

Just you, your files, and a fast way to warp between them.

## 🔧 Features

- 📁 Per-project buffer list (based on root markers like `.git`)
- 🌪 Add current file with line number
- 👀 View list in a floating window
- ✨ Reorder entries via keymaps
- ❌ Remove entries via keymaps
- 🚀 Jump to any file instantly
- 🔁 Auto-reload list on `:cd`, `FocusGained`, `TermClose`, etc.
- 💾 Persistent storage in `stdpath("data")/warp/`

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
  root_markers = { ".git" }, -- order based markers for root detection, disable root_markers by setting it to {} and it
  will fallback to only `cwd` as root
  keymaps = { -- if you don't want certain keymaps, just set it to {}
    quit = { "q", "<Esc>" }, -- quit the warp selection window
    select = { "<CR>" }, -- select the file in the warp selection window
    delete = { "dd" }, -- delete the file in the warp selection window
    move_up = { "<C-k>" }, -- move an item up in the warp selection window
    move_down = { "<C-j>" }, -- move an item down in the warp selection window
  },
}
```

### Type Definitions

```lua
---@class Warp.Config
---@field root_markers? string[] The root markers to check, defaults to { ".git" } and fallback to cwd, set to {} to nil it
---@field keymaps? Warp.Config.Keymaps The keymaps for actions

---@class Warp.Config.Keymaps
---@field quit? string[]
---@field select? string[]
---@field delete? string[]
---@field move_up? string[]
---@field move_down? string[]
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
require("warp.action").show_list()

-- or any of the equivalents

:WarpShowList
:lua require("warp.action").show_list()
```

### Add a file to the list

```lua
require("warp.action").add()

-- or any of the equivalents

:WarpAddFile
:lua require("warp.action").add()
```

### Go to a specific index in the list

```lua
--- @param idx number
require("warp.action").goto_index(idx)

-- or any of the equivalents

:WarpGoToIndex {idx}
:lua require("warp.action").goto_index(idx)
```

### Clear or empty current list

```lua
require("warp.list").clear_current_list()

-- or any of the equivalents

:WarpClearCurrentList
:lua require("warp.list").clear_current_list()
```

### Clear all lists

```lua
require("warp.list").clear_all_list()

-- or any of the equivalents

:WarpClearAllList
:lua require("warp.list").clear_all_list()
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

## 🔌 Integrations

### With `mini.files`

This snippet will update the warp list when you rename or move a file from `mini.files`.

```lua
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
  callback = function(ev)
    local from, to = ev.data.from, ev.data.to

    local warp_exists, warp_list = pcall(require, "warp.list")
    if warp_exists then
      warp_list.on_file_update(from, to)
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
            require("warp.list").on_file_update(from, to)
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

  local warp_exists, warp_list = pcall(require, "warp.list")

  -- rest of the config

  local Warp = {}

  if warp_exists then
    Warp = {
      condition = function()
        return warp_list.get_list_count() > 0
      end,
      init = function(self)
        self.current = warp_list.get_index_by_buf(0)
        self.total = warp_list.get_list_count()
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
    ViMode,
    Git,
    Warp, --- add warp the default statusline
    Align,
    FileNameBlock,
    Diagnostics,
    Align,
    LSPActive,
    Space,
    FileTypeBlock,
    Space,
    FileSize,
    Space,
    Ruler,
  }

  -- rest of the config
end,
```

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
