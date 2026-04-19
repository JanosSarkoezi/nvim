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
map("n", "<Leader>fp", core.find_projects, { desc = "Projekt suchen" })
map("n", "<leader>ff", core.find_files, { desc = "Dateien suchen" })
map("n", "<leader>fg", core.live_grep, { desc = "Live Grep" })
map("n", "<leader>fd", core.find_directories, { desc = "Verzeichnisse suchen" })
map("n", "<Leader>h", ":nohlsearch<CR>", { desc = "Such-Highlighting aufheben" })

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
