local libmodal = require 'libmodal'
local ts_swap = require('nvim-treesitter.textobjects.swap')
local ts_move = require('nvim-treesitter.textobjects.move')
local ts_shared = require('nvim-treesitter.textobjects.shared')

local utils = require('move-mode.utils')
local highlight = require('move-mode.highlight')
local autocmds = require('move-mode.autocmds')
local cursorline = require('move-mode.cursorline')
local options = require('move-mode.options')

---@alias Direction 'next' | 'previous'

---@class MoveMode
---@field current_capture_group? string
local M = {
  ---The current capture group if Move mode is active, otherwise `nil`
  current_capture_group = nil,
}

---@param direction Direction
function M.move(direction)
  local message = 'move() must be called from Move Mode'
  utils.assert(M.current_capture_group ~= nil, message)

  ts_swap['swap_' .. direction](M.current_capture_group)
end

---@param direction Direction
function M.goto(direction)
  local message = 'goto() must be called from Move Mode'
  utils.assert(M.current_capture_group ~= nil, message)

  -- nvim-libmodal sets this variable since vim.v.count1 is immutable
  local count = vim.g.mModeCount1 or 1
  for _ = 1, count do
    local fn = string.format('goto_%s_start', direction)
    ts_move[fn](M.current_capture_group)
  end
end

---@param message string
---@param level integer?
local function notify(message, level)
  if options.get().notify then
    vim.notify(message, level)
  end
end

---@param bufnr integer
function M.exit_move_mode(bufnr)
  vim.g[options.get().mode_name .. 'ModeExit' ] = true
  M.current_capture_group = nil

  highlight.clear_highlight(bufnr)
  autocmds.clear_mode_autocmds()
  cursorline.restore()

  notify('Move mode disabled')
end

---@return boolean
local function cursor_is_on_textobject()
  local _, range, _ = ts_shared.textobject_at_point(M.current_capture_group)
  return range ~= nil
end

---@param capture_group string
function M.enter_move_mode(capture_group)
  notify('Move mode enabled')

  cursorline.hide()

  M.current_capture_group = capture_group

  if not cursor_is_on_textobject() then
    M.goto('next')
  end

  highlight.highlight_current_node()
  autocmds.create_mode_autocmds()
  libmodal.mode.enter(options.get().mode_name, options.get_mode_keymaps())
end

---@param capture_group string
function M.switch_mode(capture_group )
  if M.current_capture_group == capture_group then
    return
  end

  notify('Move mode switched to ' .. capture_group)

  M.current_capture_group = capture_group

  if not cursor_is_on_textobject() then
    M.goto('next')
  end

  highlight.highlight_current_node()
  libmodal.mode.switch(options.get().mode_name, options.get_mode_keymaps())
end

---@param opts MoveModeOptions?
function M.setup(opts)
  options._set(opts)
  options.create_default_trigger_keymaps()
  highlight.create_highlight_group()
end

return M
