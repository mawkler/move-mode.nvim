local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')

local M = {}

function M.termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.feedkeys(keys, mode)
  if mode == nil then mode = 'in' end
  return vim.api.nvim_feedkeys(M.termcodes(keys), mode, true)
end

--- @param capture_group string
--- @param direction string
--- @return function
local function move(direction, capture_group)
  return function()
    ts_swap['swap_' .. direction](capture_group)
  end
end

--- @param capture_group string
--- @param direction string
--- @return function
local function goto(direction, capture_group)
  return function()
    ts_move[string.format('goto_%s_start', direction)](capture_group)
  end
end

--- @param capture_group string
--- @return table
local function move_mode_commands(capture_group )
  return {
    ['l'] = move('next',     capture_group),
    ['h'] = move('previous', capture_group),
    ['j'] = move('next',     capture_group),
    ['k'] = move('previous', capture_group),
    [']'] = goto('next',     capture_group),
    ['['] = goto('previous', capture_group),
    ['a'] = M.move_argument,
    ['f'] = M.move_function,
  }
end

function M.move_argument()
  libmodal.mode.enter('Move argument', move_mode_commands('@parameter.inner'))
end

function M.move_function()
  libmodal.mode.enter('Move function', move_mode_commands('@function.outer'))
end

function M.setup()
  vim.keymap.set('n', 'gMa', M.move_argument)
  vim.keymap.set('n', 'gMf', M.move_function)
end

return M
