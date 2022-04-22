local M = {}

M.hide_statusline = function()
  local hidden = {
    "help",
    "NvimTree",
    "terminal",
    "Undotree",
    "OUTLINE",
  }
  local shown = {}

  local api = vim.api
  local buftype = api.nvim_buf_get_option(0, "ft")

  -- shown table from config has the highest priority
  if vim.tbl_contains(shown, buftype) then
    api.nvim_set_option("laststatus", 2)
    return
  end

  if vim.tbl_contains(hidden, buftype) then
    api.nvim_set_option("laststatus", 0)
    return
  end

  api.nvim_set_option("laststatus", 2)
end

return M
