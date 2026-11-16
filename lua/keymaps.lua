-- lua/keymaps.lua
-- Globale Leader-Mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
local map = vim.keymap.set
local core = require("core_tools")

-- --- BUFFER (b) ---
map("n", "<Leader>bw", ":w<CR>", { desc = "Buffer: Speichern" })
map("n", "<Leader>bd", ":bd<CR>", { desc = "Buffer: Schließen" })
map("n", "<Leader>bn", ":bn<CR>", { desc = "Buffer: Nächster" })
map("n", "<Leader>bp", ":bp<CR>", { desc = "Buffer: Vorheriger" })
map("n", "<Leader>bl", core.find_buffers, { desc = "Buffer: Liste (Picker)" })

-- --- FIND / SUCHE (f) ---
map("n", "<Leader>ff", core.find_files, { desc = "Find: Dateien" })
map("n", "<Leader>fd", core.find_directories, { desc = "Find: Verzeichnisse" })
map("n", "<Leader>fg", ":Grep ", { desc = "Find: Grep (rg)" })
map("n", "<Leader>fp", core.find_projects, { desc = "Find: Projekte (.git)" })
map("n", "<Leader>fP", core.pinned_projects, { desc = "Find: Gepinnte Projekte" })
map("n", "<Leader>fa", core.add_project, { desc = "Find: Aktuelles Projekt pinnen" })
map("n", "<Leader>fG", ":MultiGrep ", { desc = "Find: Multi-Grep (Gepinnt)" })

-- --- GIT (g) ---
map("n", "<Leader>gs", core.git_status, { desc = "Git: Status" })
map("n", "<Leader>gl", core.git_log, { desc = "Git: Log (Datei)" })
map("n", "<Leader>ga", core.git_log_project, { desc = "Git: Log (Projekt)" })
map({"n", "v"}, "<Leader>gL", core.git_log_range, { desc = "Git: Log (Bereich)" })
map("n", "<Leader>gb", core.git_blame_line, { desc = "Git: Blame (Zeile)" })
map("n", "<Leader>gc", core.git_branches, { desc = "Git: Checkout" })
map("n", "<Leader>gh", core.git_stash, { desc = "Git: Stash" })

-- --- MARKS / JUMPS (m) ---
map("n", "<Leader>mm", core.show_marks, { desc = "Mark: Manager" })
map("n", "<Leader>mj", core.show_jumps, { desc = "Mark: Jumplist" })
map("n", "<Leader>ml", function() core.set_mark_auto(false) end, { desc = "Mark: Lokales setzen" })
map("n", "<Leader>mg", function() core.set_mark_auto(true) end, { desc = "Mark: Globales setzen" })

-- --- QUICKFIX (q) ---
map("n", "<Leader>ql", core.quickfix_to_picker, { desc = "Quickfix: Im Picker bearbeiten" })
map("n", "<Leader>qq", ":q<CR>", { desc = "Vim: Beenden" })

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
map("n", "<Leader>qn", function() navigate_qf_stack("cnewer") end, { desc = "Quickfix: Neuere Liste" })
map("n", "<Leader>qp", function() navigate_qf_stack("colder") end, { desc = "Quickfix: Ältere Liste" })

-- Native Arrow-Keys für Quickfix (immer noch nützlich)
local function move_quickfix(direction)
    -- Ohne Quickfix-Liste: normale Cursor-Bewegung statt Fehler-Spam
    if #vim.fn.getqflist() == 0 then
        vim.cmd(direction == "next" and "normal! j" or "normal! k")
        return
    end
    local cmd = direction == "next" and "cnext" or "cprev"
    local ok = pcall(vim.cmd, cmd)
    if not ok then
        print("Quickfix: Ende der Liste erreicht.")
    end
end
map('n', '<DOWN>',  function() move_quickfix("next") end, { silent = true })
map('n', '<UP>',    function() move_quickfix("prev") end, { silent = true })
map('n', '<RIGHT>', ':cope<CR>', { silent = true, desc = "Quickfix: Fenster öffnen" })
map('n', '<LEFT>',  ':cclo<CR>', { silent = true, desc = "Quickfix: Fenster schließen" })

-- --- WIKI (w) ---
map("n", "<Leader>ww", core.open_wiki_link, { desc = "Wiki: Link öffnen" })
map("n", "<Leader>wb", core.wiki_backlinks, { desc = "Wiki: Backlinks" })

-- --- MISC / HILFE ---
map("n", "<Leader>h", ":nohlsearch<CR>", { desc = "Hide: Such-Highlighting" })
map("n", "<Leader>t", core.toggle_terminal, { desc = "Terminal: Toggle" })
map("n", "<Leader>?", core.show_keymaps, { desc = "Hilfe: Alle Keymaps" })

-- Native Fixes
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Terminal: Exit Mode' })
map('n', '<F1>', function () end, { silent = true })
map('i', '<F1>', function () end, { silent = true })
