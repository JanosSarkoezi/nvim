-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true
-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"
-- vim.opt.shada = ''
-- Ignore target directories 
vim.opt.wildignore:append { "**/target/**" }
-- Suche erst in lokalen tags, dann in den JDK tags
vim.opt.tags = {
  "./tags",           -- Tags im aktuellen Verzeichnis (Projekt)
  "tags",             -- Tags im Arbeitsverzeichnis
  os.getenv("HOME") .. "/dev/java/src/tags" -- Dein globaler JDK-Index
}
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"
-- Enable break indent
vim.opt.breakindent = true
-- Save undo history
vim.opt.undofile = false
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 900
-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- Show which line your cursor is on
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.opt.foldlevel = 99
-- Am ende der Suche nicht neu oben anfangen
vim.opt.wrapscan = false
-- Grep with external Programms
-- if vim.fn.executable('rg') > 0 then
--   vim.o.grepprg =
--       [[rg --hidden --glob "!.git" --no-heading --smart-case --vimgrep --follow $*]]
-- elseif vim.fn.executable('ag') > 0 then
--   vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
-- end
vim.api.nvim_set_hl(0, "MyColor", {fg="#00FF00"})
_G.statusline = function()
    return table.concat({
        "%#StatusMsg#",
        " %f ",
        "%#MyColor#",
        "%m",
        "%#StatusMsg#",
        "%=",
        " %y ",
        " %{&fileencoding?&fileencoding:&encoding} ",
        "[%{&fileformat}] ",
        "%p%% ",
        "%l:%c "
    })
end
vim.opt.statusline = "%!v:lua.statusline()"
-- vim: ts=2 sts=2 sw=2 et
