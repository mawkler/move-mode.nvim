local ts_shared = require('nvim-treesitter.textobjects.shared')

local M = {}

local hl_namespace = vim.api.nvim_create_namespace('move-mode')
local hl_selection_name = 'MoveModeSelection'

---@param bufnr integer
function M.clear_highlight(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, hl_namespace, 0, -1)
end

function M.highlight_current_node()
  local capture_group = require('move-mode').current_capture_group
  local bufnr, range, _ = ts_shared.textobject_at_point(capture_group)
  if not bufnr or not range then return end

  local start = { range[1], range[2] }
  local finish = { range[3], range[4] }

  -- Clear any previous highlight
  M.clear_highlight(bufnr)

  vim.highlight.range(bufnr, hl_namespace, hl_selection_name, start, finish)
end

function M.create_highlight_group()
  local name = hl_selection_name
  vim.api.nvim_set_hl(0, name, { link = 'Visual', default = true })
end

return M
