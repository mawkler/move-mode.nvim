local options = require('move-mode.options')

local M = {}

--- Used to restore cursorline when exiting move mode
local cursorline_backup = nil

function M.hide()
  if options.get().hide_cursorline then
    cursorline_backup = vim.o.cursorline
    vim.o.cursorline = false
  end
end

function M.restore()
  if options.get().hide_cursorline then
    assert(cursorline_backup ~= nil, 'Cursorline should have been backed up')
    vim.o.cursorline = cursorline_backup
  end
end

return M
