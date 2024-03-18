local options = require('move-mode.options')
local highlight = require('move-mode.highlight')

local M = {}

local augroup = vim.api.nvim_create_augroup('MoveMode', {})

---@param fn function
function M.on_state_changed(fn)
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'TextChanged' }, {
    group = augroup,
    callback = fn,
  })
end

---@param fn function
function M.on_exiting_mode(fn)
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = options.get().mode_name .. ':*',
    group = augroup,
    callback = fn,
  })
end

---@param split_on string
---@return string?
local function get_right_substring(split_on)
  local position = string.find(split_on, ":")
  if position ~= nil then
    return string.sub(split_on, position + 1)
  end
end

function M.create_mode_autocmds()
  M.on_state_changed(highlight.highlight_current_node)

  M.on_exiting_mode(function(autocmd)
    local switched_to_mode = get_right_substring(autocmd.match)
    -- If we switched to a mode that's not MoveMode
    if switched_to_mode ~= options.get().mode_name then
      require('move-mode').exit_mode(autocmd.buf)
    end
  end)
end

function M.clear_mode_autocmds()
  vim.api.nvim_clear_autocmds({ group = augroup })
end

return M
