local M = {}

--- @param direction Direction
local function move(direction)
  return function() require('move-mode').move(direction) end
end

--- @param direction Direction
local function goto(direction)
  return function() require('move-mode').goto(direction) end
end

--- @param capture_group string
local function switch_mode(capture_group)
    return function()
      require('move-mode').switch_mode(capture_group)
    end
end

--- @param capture_group string
local function enter(capture_group)
  return function() require('move-mode').enter_move_mode(capture_group) end
end

--- @class MoveModeOptions
--- @field mode_keymaps table<string, function>
local options = {
  --- Mode name, see `:help mode()`
  mode_name = 'm',
  --- Send notification when entering/exiting move mode
  notify = false,
  --- Hide cursorline in move mode
  hide_cursorline = true,
  --- Key map to trigger Move Mode (followed by text-object). Set it to `nil`
  --- if you want to manually set your keymaps
  trigger_key_prefix = 'gm',
  --- Keymaps inside Move Mode
  mode_keymaps = {
    ['l']     = move('next'),
    ['h']     = move('previous'),
    ['j']     = move('next'),
    ['k']     = move('previous'),
    [']']     = goto('next'),
    ['[']     = goto('previous'),
    ['a']     = switch_mode('@parameter.inner'),
    ['f']     = switch_mode('@function.outer'),
    ['c']     = switch_mode('@class.outer'),
    ['u']     = vim.cmd.undo,
    ['<c-r>'] = vim.cmd.redo,
  }
}

function M.create_default_trigger_keymaps()
  local prefix = M.get().trigger_key_prefix

  if prefix == nil then return end

  vim.keymap.set('n', prefix .. 'a', enter('@parameter.inner'))
  vim.keymap.set('n', prefix .. 'f', enter('@function.outer'))
  vim.keymap.set('n', prefix .. 'c', enter('@class.outer'))
end

--- @return MoveModeOptions
function M.get()
  return options
end

---@param opts MoveModeOptions?
function M._set(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})
end

return M
