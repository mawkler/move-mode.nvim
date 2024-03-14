local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')
local ts_shared = require('nvim-treesitter.textobjects.shared')

local highlight = require('move-mode.highlight')
local autocmds = require('move-mode.autocmds')
local options = require('move-mode.options')

--- Used to restore cursorline when exiting move mode
local cursorline_backup = nil

--- @class MoveMode
--- @field current_capture_group? string
local M = {
  --- The current capture group if Move mode is active, otherwise `nil`
  current_capture_group = nil,
}

--- @param direction string
--- @return function
local function move(direction)
  return function()
    ts_swap['swap_' .. direction](M.current_capture_group)
  end
end

--- @param direction string
--- @return function
local function goto(direction)
  return function()
    -- nvim-libmodal sets this variable since vim.v.count1 is immutable
    local count = vim.g.mModeCount1 or 1
    for _ = 1, count do
      local fn = string.format('goto_%s_start', direction)
      ts_move[fn](M.current_capture_group)
    end
  end
end

---@param keys table<string, any>
---@return table<string, any>
local function replace_termcodes(keys)
  local new_keys = {}
  for key, value in pairs(keys) do
    local new_key = vim.api.nvim_replace_termcodes(key, true, true, true)
    new_keys[new_key] = value
  end

  return new_keys
end

--- @param command function
local function do_then_highlight(command)
  return function()
    command()
    highlight.highlight_current_node()
  end
end

-- TODO: move to options.lua
--- @return table
local function move_mode_commands()
  local mappings = {
    ['l']     = move('next'),
    ['h']     = move('previous'),
    ['j']     = move('next'),
    ['k']     = move('previous'),
    [']']     = goto('next'),
    ['[']     = goto('previous'),
    ['a']     = function() M.switch_move_mode('@parameter.inner') end,
    ['f']     = function() M.switch_move_mode('@function.outer') end,
    ['c']     = function() M.switch_move_mode('@class.outer') end,
    ['u']     = do_then_highlight(vim.cmd.undo),
    ['<c-r>'] = do_then_highlight(vim.cmd.redo),
  }

  return replace_termcodes(mappings)
end

--- @return boolean
local function cursor_is_on_textobject()
  local _, range, _ = ts_shared.textobject_at_point(M.current_capture_group)
  return range ~= nil
end

--- @param message string
--- @param level integer?
local function notify(message, level)
  if options.get().notify then
    vim.notify(message, level)
  end
end

--- @param split_on string
--- @return string?
local function get_right_substring(split_on)
  local position = string.find(split_on, ":")
  if position ~= nil then
    return string.sub(split_on, position + 1)
  end
end

local function hide_cursorline()
  if options.get().hide_cursorline then
    cursorline_backup = vim.o.cursorline
    vim.o.cursorline = false
  end
end

local function restore_cursorline()
  if options.get().hide_cursorline then
    assert(cursorline_backup ~= nil, 'Cursorline should have been backed up')
    vim.o.cursorline = cursorline_backup
  end
end

--- @param bufnr integer
function M.exit_move_mode(bufnr)
  -- TODO: doesn't actually exit, should call libmodal
  notify('Move mode disabled')

  highlight.clear_highlight(bufnr)
  autocmds.clear_mode_autocmds()
  M.current_capture_group = nil
  restore_cursorline()
end

local function create_mode_autocmds()
  autocmds.on_cursor_moved(highlight.highlight_current_node)

  autocmds.on_exiting_mode(function(autocmd)
      local switched_to_mode = get_right_substring(autocmd.match)
      -- If we switched to a mode that's not MoveMode
      if switched_to_mode ~= options.get().mode_name then
        M.exit_move_mode(autocmd.buf)
      end
    end)
end

--- @param capture_group string
function M.enter_move_mode(capture_group)
  notify('Move mode enabled')

  hide_cursorline()

  M.current_capture_group = capture_group

  if not cursor_is_on_textobject() then
    goto('next')()
  end

  highlight.highlight_current_node()
  create_mode_autocmds()

  libmodal.mode.enter(options.get().mode_name, move_mode_commands())
end

--- @param capture_group string
function M.switch_move_mode(capture_group)
  if M.current_capture_group == capture_group then
    return
  end

  notify('Move mode switched to ' .. capture_group)

  M.current_capture_group = capture_group

  if not cursor_is_on_textobject() then
    goto('next')()
  end

  highlight.highlight_current_node()

  libmodal.mode.switch(options.get().mode_name, move_mode_commands())
end

--- @param opts MoveModeOptions?
function M.setup(opts)
  options._set(opts)

  vim.keymap.set('n', 'gma', function() M.enter_move_mode('@parameter.inner') end)
  vim.keymap.set('n', 'gmf', function() M.enter_move_mode('@function.outer') end)
  vim.keymap.set('n', 'gmc', function() M.enter_move_mode('@class.outer') end)

  highlight.create_highlight_group()
end

return M
