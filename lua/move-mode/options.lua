local M = {}

---@param direction Direction
local function move(direction)
  return function() require('move-mode').move(direction) end
end

---@param direction Direction
local function goto(direction)
  return function() require('move-mode').goto(direction) end
end

---@param capture_group string
local function switch_mode(capture_group)
    return function()
      require('move-mode').switch_mode(capture_group)
    end
end

---@param capture_group string
local function enter(capture_group)
  return function() require('move-mode').enter_mode(capture_group) end
end

---@class MoveModeOptions
---@field mode_keymaps table<string, function>
local options = {
  ---Mode name, see `:help mode()`
  mode_name = 'm',
  ---Send notification when entering/exiting move mode
  notify = false,
  ---Hide cursorline in move mode
  hide_cursorline = true,
  ---Key map to trigger Move Mode (followed by text-object). Set it to `nil`
  ---if you want to manually set your keymaps
  trigger_key_prefix = 'gm',
  ---Keymaps inside Move Mode, set keymap value to `nil` to disable
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

---Replace any termcode in every keymap and remove any parameter passed from
---libmodal to `fn`
---@param mappings table<string, function>
---@return table<string, function>
local function clean_mappings(mappings)
  local new_mappings = {}
  for keymap, fn in pairs(mappings) do
    local new_key = vim.api.nvim_replace_termcodes(keymap, true, true, true)
    new_mappings[new_key] = function() fn() end
  end

  return new_mappings
end

---Get key mappings inside Move Mode
---@return table
function M.get_mode_keymaps()
  return clean_mappings(M.get().mode_keymaps)
end

---Get options
---@return MoveModeOptions
function M.get()
  return options
end

---@param opts MoveModeOptions?
function M._set(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})
end

return M
