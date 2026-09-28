return {
  {
    'nvim-tree/nvim-web-devicons',
  },
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = false,
    config = function()
      require('bufferline').setup {}
    end,
  },
  {
    'beauwilliams/statusline.lua',
    dependencies = {
      'nvim-lua/lsp-status.nvim',
    },
    config = function()
      local lsp_icons = require 'config.lsp_icons'

      local ok, lsp_section = pcall(require, 'sections._lsp')
      if ok then
        lsp_section.diagnostics = function()
          local diagnostics = ''
          local res = { 0, 0, 0, 0 }

          for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
            res[diagnostic.severity] = res[diagnostic.severity] + 1
          end

          local e = res[vim.diagnostic.severity.ERROR]
          local w = res[vim.diagnostic.severity.WARN]
          local i = res[vim.diagnostic.severity.INFO]
          local h = res[vim.diagnostic.severity.HINT]

          diagnostics = e ~= 0 and diagnostics .. lsp_icons.diagnostics.error .. e .. ' ' or diagnostics
          diagnostics = w ~= 0 and diagnostics .. lsp_icons.diagnostics.warn .. w .. ' ' or diagnostics
          diagnostics = i ~= 0 and diagnostics .. lsp_icons.diagnostics.info .. i .. ' ' or diagnostics
          diagnostics = h ~= 0 and diagnostics .. lsp_icons.diagnostics.hint .. h .. ' ' or diagnostics

          return diagnostics
        end
      end

      require('statusline').setup {
        match_colorscheme = true,
        tabline = false,
        lsp_diagnostics = true,
        ale_diagnostics = false,
      }
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {}
      vim.cmd.colorscheme 'catppuccin-nvim'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    dependencies = {
      'windwp/nvim-ts-autotag',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-ts-autotag').setup {}
      require('nvim-treesitter.install').prefer_git = true
      local function first_node(node)
        return type(node) == 'table' and node[1] or node
      end

      local function parser_from_markdown_info_string(lang)
        return vim.filetype.match { filename = 'a.' .. lang }
          or ({ ex = 'elixir', pl = 'perl', sh = 'bash', ts = 'typescript', uxn = 'uxntal' })[lang]
          or lang
      end

      vim.treesitter.query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
        local node = first_node(match[pred[2]])
        if node then
          local lang = vim.treesitter.get_node_text(node, bufnr):lower()
          metadata['injection.language'] = parser_from_markdown_info_string(lang)
        end
      end, { force = true, all = false })
      vim.treesitter.query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
        local node = first_node(match[pred[2]])
        if node then
          local value = vim.treesitter.get_node_text(node, bufnr)
          local parts = vim.split(value, '/', {})
          metadata['injection.language'] = ({
            importmap = 'json',
            module = 'javascript',
            ['application/ecmascript'] = 'javascript',
            ['text/ecmascript'] = 'javascript',
          })[value] or parts[#parts]
        end
      end, { force = true, all = false })
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'hcl',
          'helm',
          'html',
          'jsdoc',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'scss',
          'terraform',
          'tsx',
          'typescript',
          'vim',
        },
        highlight = { enable = true, use_languagetree = true },
        indent = { enable = true },
        context_commentstring = { enable = true },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
        },
      }
      vim.filetype.add {
        extension = {
          mdx = 'mdx',
        },
      }
      vim.treesitter.language.register('markdown', 'mdx')
    end,
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = false,
    config = function()
      require('render-markdown').setup {}
    end,
  },
}
