local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')

local M = {}

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
    ['a'] =  function() M.enter_move_mode('@parameter.inner') end,
    ['f'] =  function() M.enter_move_mode('@function.outer') end,
  }
end

--- @param capture_group string
--- @param mode_display_name string?
function M.enter_move_mode(capture_group, mode_display_name)
  mode_display_name = mode_display_name or capture_group
  libmodal.mode.enter(mode_display_name, move_mode_commands(capture_group))
end

function M.setup()
  vim.keymap.set('n', 'gma', function() M.enter_move_mode('@parameter.inner') end)
  vim.keymap.set('n', 'gmf', function() M.enter_move_mode('@function.outer') end)
  vim.keymap.set('n', 'gmc', function() M.enter_move_mode('@class.outer') end)
end

return M
