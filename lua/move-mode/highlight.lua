local ts_shared = require('nvim-treesitter.textobjects.shared')

local hl_namespace = vim.api.nvim_create_namespace('move-mode')

local M = {
  hl_name_selection = 'MoveModeSelection',
}

---@param bufnr integer
function M.clear_highlight(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, hl_namespace, 0, -1)
end

--- @param capture_group string
function M.highlight_current_node(capture_group)
  local bufnr, range, _ = ts_shared.textobject_at_point(capture_group)
  if not bufnr or not range then return end

  local row = range[1]
  local start_col = range[2]
  local end_col = range[4]

  M.clear_highlight(bufnr)
  vim.api.nvim_buf_add_highlight(bufnr, hl_namespace, M.hl_name_selection, row, start_col, end_col)
end

function M.create_highlight_group()
  vim.api.nvim_set_hl(0, M.hl_name_selection, { link = 'Visual' })
end

return M
