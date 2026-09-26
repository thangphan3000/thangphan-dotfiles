return {
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = { 'cspell', 'stylua' },
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        config = function(_, opts)
          require('mason').setup(opts)
          require('mason-lspconfig').setup {
            ensure_installed = {
              'bashls',
              'biome',
              'gopls',
              'jsonls',
              'lua_ls',
              'pyright',
              'stylua',
              'terraformls',
              'vtsls',
            },
          }
        end,
      },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'yioneko/nvim-vtsls' },
      { 'j-hui/fidget.nvim' },
      {
        'nvimdev/lspsaga.nvim',
        config = function()
          require('lspsaga').setup {
            symbol_in_winbar = {
              enable = true,
              hide_keyword = true,
            },
            lightbulb = {
              enable = false,
              sign = true,
              virtual_text = false,
              debounce = 10,
              sign_priority = 20,
            },
            diagnostic = {
              enable = true,
            },
          }
        end,
      },
      { 'onsails/lspkind-nvim' },
    },
    config = function()
      local lsp_icons = require 'config.lsp_icons'

      local lsp_document_highlight = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = lsp_document_highlight,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or not client.server_capabilities.documentHighlightProvider then
            return
          end

          local bufnr = args.buf
          vim.api.nvim_clear_autocmds { group = lsp_document_highlight, buffer = bufnr }

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = lsp_document_highlight,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
            desc = 'LSP document highlight',
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
            group = lsp_document_highlight,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
            desc = 'LSP clear references',
          })
        end,
      })

      vim.lsp.enable 'lua_ls'
      vim.lsp.enable 'pyright'
      vim.lsp.enable 'bashls'
      vim.lsp.enable 'gopls'
      vim.lsp.enable 'vtsls'
      vim.lsp.enable 'terraform'
      vim.lsp.enable 'jsonls'
      vim.lsp.config('jsonls', {
        on_new_config = function() end,
        settings = {
          json = {
            format = {
              enable = false,
            },
            validate = {
              enable = true,
            },
          },
        },
      })

      vim.diagnostic.config {
        underline = true,
        update_in_insert = false,
        virtual_text = false,
        serverity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = lsp_icons.by_severity[vim.diagnostic.severity.ERROR],
            [vim.diagnostic.severity.WARN] = lsp_icons.by_severity[vim.diagnostic.severity.WARN],
            [vim.diagnostic.severity.HINT] = lsp_icons.by_severity[vim.diagnostic.severity.HINT],
            [vim.diagnostic.severity.INFO] = lsp_icons.by_severity[vim.diagnostic.severity.INFO],
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
          },
        },
      }
    end,
  },
}
