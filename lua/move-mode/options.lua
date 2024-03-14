local M = {}

--- @class MoveModeOptions
local options = {
  --- Mode name, see `:help mode()`
  mode_name = 'm',
  --- Send notification when entering/exiting move mode
  notify = true,
  --- Hide cursorline in move mode
  hide_cursorline = true,
}

--- @return MoveModeOptions
function M.get()
  return options
end

---@param opts MoveModeOptions?
function M._set(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})
end

return M
