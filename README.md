# move-mode.nvim

This plugin adds a new Vim mode that lets you move nodes like functions or parameters around using Treesitter.

## Setup

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'mawkler/move-mode.nvim',
  dependencies = {
    'Iron-E/nvim-libmodal',
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  opts = {},
}
```

## Default configuration

Default options passed to `setup()`:

```lua
{
  -- Mode name, see `:help mode()`
  mode_name = 'm',
  -- Send notification when entering/exiting move mode
  notify = false,
  -- Hide cursorline in move mode
  hide_cursorline = true,
  -- Key map prefix to trigger move mode. Set it to `false` if you want to
  -- manually set your keymaps
  trigger_key_prefix = 'gm',
  -- Keymaps inside move mode, set keymap value to `nil` to disable
  mode_keymaps = {
    ['l']     = function() require('move-mode').move('next') end,
    ['h']     = function() require('move-mode').move('previous') end,
    ['j']     = function() require('move-mode').move('next') end,
    ['k']     = function() require('move-mode').move('previous') end,
    [']']     = function() require('move-mode').goto('next') end,
    ['[']     = function() require('move-mode').goto('previous') end,
    ['a']     = function() require('move-mode').switch_mode('@parameter.inner') end,
    ['f']     = function() require('move-mode').switch_mode('@function.outer') end,
    ['c']     = function() require('move-mode').switch_mode('@class.outer') end,
    ['u']     = vim.cmd.undo,
    ['<c-r>'] = vim.cmd.redo,
  },
}
```

These are the default keymaps to trigger move mode:

```lua
local function enter(capture_group)
  return function() require('move-mode').enter_mode(capture_group) end
end

vim.keymap.set('n', 'gma', enter('@parameter.inner'))
vim.keymap.set('n', 'gmf', enter('@function.outer'))
vim.keymap.set('n', 'gmc', enter('@class.outer'))
```

To disable these or to change `gm` to something else, see the option `trigger_key_prefix`.

You can also create your own keymaps with more Treesitter capture groups. [Here](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights) is a complete list of all available Treesitter capture groups.

## Credit

This plugin would not have been possible without [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) or [nvim-libmodal](https://github.com/Iron-E/nvim-libmodal). A huge thank you to the maintainers of both these plugins!
