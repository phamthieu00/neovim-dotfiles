local opt = vim.opt

-- Sensible editor defaults, kept explicit and local.
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.splitbelow = true
opt.splitright = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true
opt.mouse = "a"
opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 500
opt.completeopt = { "menuone", "noselect" }
opt.pumheight = 10
opt.showmode = false
opt.laststatus = 3
opt.showtabline = 2
opt.fillchars = { eob = " " }

-- Keep netrw from competing with Oil as the file explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
