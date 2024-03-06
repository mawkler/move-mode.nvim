local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')
local ts_shared = require('nvim-treesitter.textobjects.shared')

local M = {}

local options = {
  mode_name = 'Move'
}

local hl_namespace = vim.api.nvim_create_namespace('move-mode')
local hl_name_selection = 'MoveModeSelection'

---@param bufnr integer
local function clear_highlight(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, hl_namespace, 0, -1)
end

--- @param capture_group string
local function highlight_current_node(capture_group)
  local bufnr, range, _ = ts_shared.textobject_at_point(capture_group)
  if not bufnr or not range then return end

  local row = range[1]
  local start_col = range[2]
  local end_col =  range[4]

  clear_highlight(bufnr)
  vim.api.nvim_buf_add_highlight(bufnr, hl_namespace, hl_name_selection, row, start_col, end_col)
end

--- @param capture_group string
--- @param direction string
--- @return function
local function move(direction, capture_group)
  return function()
    ts_swap['swap_' .. direction](capture_group)
    highlight_current_node(capture_group)
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
    ['a'] = function() M.enter_move_mode('@parameter.inner') end,
    ['f'] = function() M.enter_move_mode('@function.outer') end,
    ['c'] = function() M.enter_move_mode('@class.outer') end,
  }
end

--- @param capture_group string
function M.enter_move_mode(capture_group)
  highlight_current_node(capture_group)

  libmodal.mode.enter(options.mode_name, move_mode_commands(capture_group))
end

local function create_autocmds()
  local augroup = vim.api.nvim_create_augroup('MoveMode', {})
  -- On exit
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = options.mode_name .. ':*',
    group = augroup,
    callback = function(event)
      clear_highlight(event.buf)
    end,
  })
end

function M.setup()
  -- TODO: handle v.count
  vim.keymap.set('n', 'gma', function() M.enter_move_mode('@parameter.inner') end)
  vim.keymap.set('n', 'gmf', function() M.enter_move_mode('@function.outer') end)
  vim.keymap.set('n', 'gmc', function() M.enter_move_mode('@class.outer') end)

  vim.api.nvim_set_hl(0, hl_name_selection, { link = 'Visual' })

  create_autocmds()
end

return M
