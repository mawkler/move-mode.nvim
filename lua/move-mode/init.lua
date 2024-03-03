local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')

-- TODO: move between textobject modes (argument/function, etc. by pressing
-- `a`/`f` in move-mode)

local M = {}

function M.termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.feedkeys(keys, mode)
  if mode == nil then mode = 'in' end
  return vim.api.nvim_feedkeys(M.termcodes(keys), mode, true)
end

--- @param query_group string
--- @param direction string
--- @return function
local function swap(direction, query_group)
  return function()
    ts_swap['swap_' .. direction](query_group)
  end
end

--- @param query_group string
local function move_mode_commands(query_group)
  return {
    l = swap('next', query_group),
    h = swap('previous', query_group),
    j = swap('next', query_group),
    k = swap('previous', query_group),
    J = function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
  }
end

local function move_argument()
  libmodal.mode.enter('Move argument', move_mode_commands('@parameter.inner'))
end

local function move_function()
  libmodal.mode.enter('Move function', move_mode_commands('@function.outer'))
end

function M.setup()
  vim.keymap.set('n', 'gMa', move_argument)
  vim.keymap.set('n', 'gMf', move_function)
end

return M
