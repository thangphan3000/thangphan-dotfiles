local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Load Helm Treesitter highlight
autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*/templates/*.yaml,*/templates/*.yml,*/charts/*.yaml,*/charts/*.yml',
  callback = function()
    vim.bo.filetype = 'helm'
  end,
})

-- Load Dockerfile Treesitter highlight
autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'Dockerfile*',
  callback = function()
    vim.bo.filetype = 'dockerfile'
  end,
})

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank { timeout = '200' }
  end,
})

-- Don't auto commenting new lines
autocmd('BufEnter', {
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o',
})

-- Disable cursorline in the CodeDiff tab
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffOpen",
  callback = function(event)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(event.data.tabpage)) do
      vim.wo[win].cursorline = false
    end
  end,
})
