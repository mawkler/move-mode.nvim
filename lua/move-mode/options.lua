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

--- @class MoveModeOptions
--- @field mappings table<string, function>
local options = {
  --- Mode name, see `:help mode()`
  mode_name = 'm',
  --- Send notification when entering/exiting move mode
  notify = true,
  --- Hide cursorline in move mode
  hide_cursorline = true,
  --- Keymaps
  mappings = {
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

--- @return MoveModeOptions
function M.get()
  return options
end

---@param opts MoveModeOptions?
function M._set(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})
end

return M
