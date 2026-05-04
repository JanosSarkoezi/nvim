-- lua/keymaps.lua
-- Globale Leader-Mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
local map = vim.keymap.set
-- Allg. Mappings
map("n", "<Leader>w", ":w<CR>", { desc = "Buffer speichern" })
map("n", "<Leader>q", ":q<CR>", { desc = "Vim beenden" })
map("n", "<Leader>c", ":bd<CR>", { desc = "Buffer schließen" })
-- Puffer-Navigation
map("n", "<Leader>bn", ":bn<CR>", { desc = "Nächster Buffer" })
map("n", "<Leader>bp", ":bp<CR>", { desc = "Vorheriger Buffer" })
-- Fenster-Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Linkes Fenster" })
map("n", "<C-j>", "<C-w>j", { desc = "Unteres Fenster" })
map("n", "<C-k>", "<C-w>k", { desc = "Oberes Fenster" })
map("n", "<C-l>", "<C-w>l", { desc = "Rechtes Fenster" })
local core = require("core_tools")
-- Core Tools
map("n", "<Leader>wp", core.open_wiki_link, { desc = "Wiki Link öffnen" })
map("n", "<Leader>wb", core.wiki_backlinks, { desc = "Wiki Backlinks suchen" })
map("n", "<Leader>fp", core.find_projects, { desc = "Projekt suchen (.git)" })
map("n", "<Leader>fP", core.pinned_projects, { desc = "Gepinnte Projekte" })
map("n", "<Leader>fa", core.add_project, { desc = "Aktuelles Projekt pinnen" })
map("n", "<Leader>fG", ":MultiGrep ", { desc = "Multi-Grep (gepinnte Projekte)" })
map("n", "<leader>ff", core.find_files, { desc = "Dateien suchen" })
map("n", "<leader>fb", core.find_buffers, { desc = "Puffer suchen" })
map("n", "<leader>fq", core.quickfix_to_picker, { desc = "Quickfix im Picker bearbeiten" })
map("n", "<leader>fg", ":Grep ", { desc = "Grep" })
map("n", "<leader>fd", core.find_directories, { desc = "Verzeichnisse suchen" })
map("n", "<Leader>h", ":nohlsearch<CR>", { desc = "Such-Highlighting aufheben" })
map("n", "<Leader>t", core.toggle_terminal, { desc = "Terminal Toggle" })
-- Git Tools
map("n", "<Leader>gl", core.git_log, { desc = "Git Log (Datei)" })
map("n", "<Leader>ga", core.git_log_project, { desc = "Git Log (Projekt)" })
map({"n", "v"}, "<Leader>gL", core.git_log_range, { desc = "Git Log (Range)" })
map("n", "<Leader>gb", core.git_blame_line, { desc = "Git Blame (Zeile)" })
map("n", "<Leader>gs", core.git_status, { desc = "Git Status (s=Stage, u=Unstage)" })
map("n", "<Leader>gc", core.git_branches, { desc = "Git Checkout (Branch)" })
map("n", "<Leader>gh", core.git_stash, { desc = "Git Stash (h=Hide/Stash)" })
-- Mark Manager
map("n", "<Leader>mm", core.show_marks, { desc = "Marks Manager (L/A-E)" })
map("n", "<Leader>ml", function() core.set_mark_auto(false) end, { desc = "Lokales Mark setzen (Auto)" })
map("n", "<Leader>mg", function() core.set_mark_auto(true) end, { desc = "Globales Mark setzen (Auto)" })
-- Hilfe & Übersicht
map("n", "<Leader>?", core.show_keymaps, { desc = "Keymap-Übersicht zeigen" })
local function move_quickfix(direction)
    local cmd = direction == "next" and "cnext" or "cprev"
    local message = direction == "next" and "unten" or "oben"
    local ok = pcall(vim.cmd, cmd)
    if not ok then
        vim.api.nvim_echo({
            { "Quickfix: Du bist bereits ganz " .. message .. "!", "WarningMsg" }
        }, false, {})
    end
end
-- Die Keymaps nutzen jetzt die ausgelagerte Funktion
map('n', '<DOWN>', function() move_quickfix("next") end, { silent = true })
map('n', '<UP>',   function() move_quickfix("prev") end, { silent = true })
-- Quickfix-Stack Navigation (Colder/Cnewer)
local function navigate_qf_stack(cmd)
  local ok = pcall(vim.cmd, cmd)
  if ok then
    local qf_info = vim.fn.getqflist({nr = 0, title = 1})
    local qf_total = vim.fn.getqflist({nr = "$"}).nr
    print(string.format("Quickfix [%d/%d]: %s", qf_info.nr, qf_total, qf_info.title))
  else
    print("Quickfix: Keine weiteren Listen vorhanden!")
  end
end
map("n", "<Leader>co", function() navigate_qf_stack("colder") end, { desc = "Ältere Quickfix-Liste" })
map("n", "<Leader>cn", function() navigate_qf_stack("cnewer") end, { desc = "Neuere Quickfix-Liste" })
-- Deine restlichen Binds (ohne expr = true, da nicht benötigt)
map('n', '<RIGHT>', ':cope<CR>', { silent = true })
map('n', '<LEFT>',  ':cclo<CR>', { silent = true })
map('n', '<F1>', function () end, { silent = true })
map('i', '<F1>', function () end, { silent = true })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
