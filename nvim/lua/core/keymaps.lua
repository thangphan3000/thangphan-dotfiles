local BORDER_STYLE = "rounded"
local DIAGNOSTIC_NEXT = 1
local DIAGNOSTIC_PREVIOUS = -1

local function km(mode, keys, actions, desc)
  desc = desc or ''
  local opts = { noremap = true, silent = true, desc = desc }
  vim.keymap.set(mode, keys, actions, opts)
end

-- Insert mode
km('i', '<c-l>', '<C-o>A')
km('i', 'jk', '<esc>')

-- Visual mode
km('v', '<Tab>', '>gv')
km('v', '<S-Tab>', '<gv')
km('v', "<leader>'", "c''<Esc>P")
km('v', '<leader>"', 'c""<Esc>P')
km('x', '<leader>p', [["_dP]])

-- Normal mode
km('n', '<Esc><Esc>', ':nohlsearch<CR>')
km('n', '<leader>a', 'gg<S-v>G')
km('n', 'ss', ':split<Return><C-w>w')
km('n', 'sv', ':vsplit<Return><C-w>w')
km('n', '<C-u>', '<C-u>zz')
km('n', '<C-d>', '<C-d>zz')
km('n', '<C-h>', '<C-w>h')
km('n', '<C-j>', '<C-w>j')
km('n', '<C-k>', '<C-w>k')
km('n', '<C-l>', '<C-w>l')
km('n', '<Tab>', '<cmd>bnext<CR>')
km('n', '<s-Tab>', '<cmd>bprev<CR>')
km('n', 'gr', '<cmd>Lspsaga lsp_finder<CR>')
km('n', 'gd', '<cmd>Lspsaga goto_definition<CR>')
km('n', '[b', '<cmd>Lspsaga show_buf_diagnostics<CR>')
km('n', 'K', '<cmd>Lspsaga hover_doc<CR>')
km('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>')
km("n", "[w", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
km('n', '[d', function() vim.diagnostic.jump({ count = DIAGNOSTIC_PREVIOUS, float = { border = BORDER_STYLE } }) end)
km('n', ']d', function() vim.diagnostic.jump({ count = DIAGNOSTIC_NEXT, float = { border = BORDER_STYLE } }) end)
km('n', '<space>rn', '<cmd>Lspsaga rename<CR>')
km('n', '<leader>d', '<Cmd>Lspsaga show_line_diagnostics<CR>')
