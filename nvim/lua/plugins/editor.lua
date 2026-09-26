return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      enabled = true,
      exclude = {
        filetypes = { 'help', 'Trouble', 'lazy' },
      },
      scope = {
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      },
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>cg',
        function()
          local grug = require 'grug-far'
          grug.open { transient = true }
        end,
        desc = 'GrugFar',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      -- Disable folding.
      folding = { enabled = false },
      -- Don't numerate the result list.
      resultLocation = { showNumberLabel = false },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    keys = {
      { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'NvimTree toggle' },
    },
    config = function()
      require('nvim-tree').setup {
        filters = { dotfiles = false },
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          side = 'left',
          width = 40,
          preserve_window_proportions = true,
        },
        git = {
          enable = false,
        },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          indent_markers = { enable = true },
          icons = {
            glyphs = {
              default = '󰈚',
              folder = {
                default = '',
                empty = '',
                empty_open = '',
                open = '',
                symlink = '',
              },
              git = { unmerged = '' },
            },
          },
        },
      }

      vim.cmd 'hi NvimTreeNormal guibg=NONE ctermbg=NONE'
    end,
  },
  { 'terryma/vim-multiple-cursors' },
  { 'tpope/vim-commentary' },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },
  {
    'stevearc/conform.nvim',
    cond = not vim.g.vscode,
    event = { 'BufWritePre' },
    opts = {
      quiet = true,
      lsp_format = 'fallback',
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'biome' },
        typescript = { 'biome' },
        javascriptreact = { 'prettier', 'rustywind' },
        typescriptreact = { 'prettier', 'rustywind' },
        svelte = { 'prettier', 'rustywind' },
        html = { 'prettier', 'rustywind' },
        css = { 'prettier' },
        scss = { 'prettier' },
        less = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'yamlfmt' },
        markdown = { 'prettier' },
        mdx = { 'prettier' },
        go = { 'gofmt' },
        cs = { 'csharpier' },
        xml = { 'xmlformatter' },
        svg = { 'xmlformatter' },
      },
      formatters = {
        xmlformatter = {
          cmd = { 'xmlformatter' },
          args = { '--selfclose', '-' },
        },
        injected = { options = { ignore_errors = false } },
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = function()
      --- @type Gitsigns.Config
      local C = {
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '┃' },
          topdelete = { text = '‾' },
          changedelete = { text = '┃' },
          untracked = { text = '┆' },
        },
        current_line_blame = false,
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          map({ 'n', 'v' }, '<leader>gg', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
          map({ 'n', 'v' }, '<leader>gx', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
          map('n', '<leader>gp', gs.preview_hunk, 'Stage Buffer')
          map('n', '<leader>gn', gs.next_hunk, 'Stage Buffer')
          map('n', '<leader>gG', gs.stage_buffer, 'Stage Buffer')
          map('n', '<leader>gX', gs.reset_buffer, 'Reset Buffer')
          map('n', '<leader>gb', function()
            gs.blame_line { full = true }
          end, 'Blame Line')
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
          map('n', '<leader>gd', function()
            gs.diffthis '~'
          end)
        end,
      }
      return C
    end,
    keys = {
      { 'gh', ':Gitsigns next_hunk<CR>', desc = 'Goto next git hunk' },
      { 'gH', ':Gitsigns prev_hunk<CR>', desc = 'Goto previous git hunk' },
    },
  },
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'FzfLua',
    config = function()
      require('fzf-lua').setup { 'ivy' }
    end,
    keys = {
      { '<C-b>', '<cmd>FzfLua buffers<cr>', desc = 'Find recent buffers' },
      { '<C-p>', '<cmd>FzfLua files<cr>', desc = 'Find files in dir' },
      { '<C-s>', '<cmd>FzfLua grep_cword<cr>', desc = 'Searches for the word under the cursor' },
      { '<C-g>', '<cmd>FzfLua live_grep<cr>', desc = 'Grep through the project dir' },
      { '<leader>gd', '<cmd>FzfLua git_diff<cr>', desc = 'Git Diff' },
      { '<leader>gs', '<cmd>FzfLua git_status<cr>', desc = 'Git status' },
      { '<leader>gc', '<cmd>FzfLua git_commits<cr>', desc = 'Git commits' },
    },
  },
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '1.*',
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
      },
      completion = {
        menu = {
          border = 'rounded',
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 200,
        },
      },
      signature = {
        enabled = false,
        trigger = {
          enabled = false,
          show_on_keyword = false,
          show_on_trigger_character = false,
          show_on_insert = false,
          show_on_insert_on_trigger_character = false,
        },
        window = {
          treesitter_highlighting = true,
          show_documentation = false,
        },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          snippets = {
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath 'config' .. '/snippets' },
            },
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    'claudecode-tmux',
    dir = vim.fn.stdpath 'config',
    name = 'claudecode-tmux',
    lazy = true,
    config = function() end,
  },
  {
    'claude-tmux',
    dir = vim.fn.stdpath 'config',
    name = 'claude-tmux',
    lazy = true,
    keys = {
      {
        '<C-S-c>',
        function()
          require('claudecode_tmux').send_selection()
        end,
        mode = 'v',
        desc = 'Send selection to Claude code',
      },
    },
    config = function() end,
  },
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {
      explorer = {
        auto_open_on_cursor = true,
      },
    },
    keys = {
      { '<C-S-d>', '<cmd>CodeDiff<cr>', desc = 'Code diff' },
    },
  },
}
