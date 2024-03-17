local M = {}

---@param value boolean
---@param message string
function M.assert(value, message)
  assert(value, 'move-mode.nvim: ' .. message)
end

return M
