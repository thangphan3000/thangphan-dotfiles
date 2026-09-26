local M = {
  diagnostics = {
    error = ' ',
    warn = ' ',
    info = ' ',
    hint = '󰠠 ',
  },
}

M.by_severity = {
  [vim.diagnostic.severity.ERROR] = M.diagnostics.error,
  [vim.diagnostic.severity.WARN] = M.diagnostics.warn,
  [vim.diagnostic.severity.INFO] = M.diagnostics.info,
  [vim.diagnostic.severity.HINT] = M.diagnostics.hint,
}

return M
