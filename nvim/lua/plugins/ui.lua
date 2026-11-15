return {
  {
    'nvim-tree/nvim-web-devicons',
  },
  {
    'rebelot/heirline.nvim',
    dependencies = {
      'Zeioth/heirline-components.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    event = 'VeryLazy',
    opts = function()
      local lib = require 'heirline-components.all'
      return {
        opts = {
          disable_winbar_cb = function(args)
            return not require('heirline-components.buffer').is_valid(args.buf)
              or lib.condition.buffer_matches({
                buftype = { 'terminal', 'prompt', 'nofile', 'help', 'quickfix' },
                filetype = { 'NvimTree', 'neo%-tree', 'dashboard', 'Outline', 'aerial' },
              }, args.buf)
          end,
        },
        tabline = {
          lib.component.tabline_conditional_padding(),
          lib.component.tabline_buffers(),
          lib.component.fill { hl = { bg = 'tabline_bg' } },
          lib.component.tabline_tabpages(),
        },
        statusline = {
          hl = { fg = 'fg', bg = 'bg' },
          lib.component.mode(),
          lib.component.git_branch(),
          lib.component.file_info(),
          lib.component.git_diff(),
          lib.component.diagnostics(),
          lib.component.fill(),
          lib.component.cmd_info(),
          lib.component.fill(),
          lib.component.lsp(),
          lib.component.virtual_env(),
          lib.component.nav(),
          lib.component.mode { surround = { separator = 'right' } },
        },
      }
    end,
    config = function(_, opts)
      local heirline = require 'heirline'
      local lib = require 'heirline-components.all'
      lib.init.subscribe_to_events()
      heirline.load_colors(lib.hl.get_colors())
      heirline.setup(opts)
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        transparent_background = false,
      }
      vim.cmd.colorscheme 'catppuccin-macchiato'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()
      require('nvim-treesitter').install {
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
          'terraform',
          'tsx',
          'typescript',
          'vim',
        },
      }
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
  {
    'folke/noice.nvim',
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        filter = {
          event = 'notify',
          find = 'No information available',
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd('FocusGained', {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd('FocusLost', {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = 'notify_send',
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = 'split',
          opts = { enter = true, format = 'details' },
          filter = {},
        },
      }

      opts.presets = opts.presets or {}

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function(event)
          vim.schedule(function()
            require('noice.text.markdown').keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },
}
