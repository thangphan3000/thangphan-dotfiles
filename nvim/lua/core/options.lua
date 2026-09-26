local opt = vim.opt
local g = vim.g

-----------------------------------------------------------
-- General
-----------------------------------------------------------

opt.mouse = 'a'
opt.laststatus = 3
opt.showtabline = 2
opt.clipboard = 'unnamedplus'
opt.termguicolors = true
opt.cursorline = false
opt.swapfile = false
opt.undofile = true
opt.undodir = os.getenv 'HOME' .. '/.local/state/nvim/undo'
opt.shell = 'zsh'
opt.wrap = true
opt.scrolloff = 8
opt.relativenumber = true
opt.ignorecase = true
opt.background = 'dark'
opt.fixendofline = false
opt.list = false
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣'}
g.maplocalleader = ','
g.mapleader = ' '
vim.wo.number = true

-----------------------------------------------------------
-- Folding
-----------------------------------------------------------

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99 -- Start with all code unfolded
vim.o.foldcolumn = "0"
vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:⏵]]

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true        -- Use spaces instead of tabs
opt.shiftwidth = 2          -- Shift 2 spaces when tab
opt.tabstop = 2             -- 1 tab == 2 spaces
opt.smartindent = true      -- Autoindent new lines
-- Trick a tab as whitespace
opt.expandtab = true
opt.backspace = { 'start', 'eol', 'indent' }

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = true           -- Enable background buffers
opt.history = 100           -- Remember N lines in history
opt.lazyredraw = true       -- Faster scrolling
opt.synmaxcol = 240         -- Max column for syntax highlight
opt.updatetime = 250        -- ms to wait for trigger an event

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
opt.shortmess:append "sI"

-- Disable builtin plugins
local disabled_built_ins = {
   "2html_plugin",
   "getscript",
   "getscriptPlugin",
   "gzip",
   "logipat",
   "netrw",
   "netrwPlugin",
   "netrwSettings",
   "netrwFileHandlers",
   "matchit",
   "tar",
   "tarPlugin",
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
   "tutor",
   "rplugin",
   "synmenu",
   "optwin",
   "compiler",
   "bugreport",
   "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
   g["loaded_" .. plugin] = 1
end

return opt
