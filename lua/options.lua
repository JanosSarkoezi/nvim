-- lua/options.lua
-- vim.opt Einstellungen

local opt = vim.opt

-- Zeilennummern
opt.number = true
opt.relativenumber = true

-- Tab-Einstellungen
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Suche
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"

-- System
opt.clipboard = "unnamedplus"
opt.backup = false
opt.swapfile = false
opt.undofile = true
-- opt.updatecall = 300
opt.timeoutlen = 400
