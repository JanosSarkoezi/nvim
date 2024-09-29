require("lazy-bootstrap")
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("cmd")
require("options")
require("lazy-plugins")

vim.keymap.set('n', '<DOWN>', function () return ':cn<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<UP>', function () return ':cp<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<RIGHT>', function () return ':cope<CR>' end, { silent = true, expr = true })
vim.keymap.set('n', '<LEFT>', function () return ':cclo<CR>' end, { silent = true, expr = true })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
