local options = require('move-mode.options')

local M = {}

local augroup = vim.api.nvim_create_augroup('MoveMode', {})

--- @param fn function
function M.on_cursor_moved(fn)
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = augroup,
    callback = fn,
  })
end

function M.on_exiting_mode(fn)
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = options.get().mode_name .. ':*',
    group = augroup,
    callback = fn,
  })
end

function M.clear_mode_autocmds()
  vim.api.nvim_clear_autocmds({ group = augroup })
end

return M
