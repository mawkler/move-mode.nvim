local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')
local ts_shared = require('nvim-treesitter.textobjects.shared')
local highlight = require('move-mode.highlight')

local M = {}

local options = {
  mode_name = 'Move'
}

--- @param capture_group string
--- @param direction string
--- @return function
local function move(direction, capture_group)
  return function()
    ts_swap['swap_' .. direction](capture_group)
    highlight.highlight_current_node(capture_group)
  end
end

--- @param capture_group string
--- @param direction string
--- @return function
local function goto(direction, capture_group)
  return function()
    ts_move[string.format('goto_%s_start', direction)](capture_group)
    highlight.highlight_current_node(capture_group)
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
    ['a'] = function() M.enter_move_mode('@parameter.inner') end,
    ['f'] = function() M.enter_move_mode('@function.outer') end,
    ['c'] = function() M.enter_move_mode('@class.outer') end,
  }
end

--- @param capture_group string
--- @return boolean
local function cursor_is_on_textobject(capture_group)
  local _, range, _ = ts_shared.textobject_at_point(capture_group)
  return range ~= nil
end

--- @param capture_group string
function M.enter_move_mode(capture_group)
  -- TODO: perhaps have capture_group as a local variable instead of passing it around
  if not cursor_is_on_textobject(capture_group) then
    goto('next', capture_group)()
  end

  highlight.highlight_current_node(capture_group)

  libmodal.mode.enter(options.mode_name, move_mode_commands(capture_group))
end

local function create_autocmds()
  local augroup = vim.api.nvim_create_augroup('MoveMode', {})
  -- On exit
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = options.mode_name .. ':*',
    group = augroup,
    callback = function(event)
      highlight.clear_highlight(event.buf)
    end,
  })
end

function M.setup()
  vim.keymap.set('n', 'gma', function() M.enter_move_mode('@parameter.inner') end)
  vim.keymap.set('n', 'gmf', function() M.enter_move_mode('@function.outer') end)
  vim.keymap.set('n', 'gmc', function() M.enter_move_mode('@class.outer') end)

  vim.api.nvim_set_hl(0, highlight.hl_selection_name, { link = 'Visual' })

  create_autocmds()
end

return M
