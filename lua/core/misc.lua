-- lua/core/misc.lua
local M = {}
local picker = require("core.picker")

-- --- TERMINAL TOGGLE ---
local term_buf = nil
local term_win = nil
function M.toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
    else
        vim.cmd("botright split")
        vim.cmd("resize 10")
        term_win = vim.api.nvim_get_current_win()
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_win_set_buf(term_win, term_buf)
        else
            vim.cmd("term")
            term_buf = vim.api.nvim_get_current_buf()
            -- Terminal-spezifische Optionen
            vim.wo[term_win].number = false
            vim.wo[term_win].relativenumber = false
            vim.wo[term_win].signcolumn = "no"
        end
        vim.cmd("startinsert")
    end
end

-- --- HILFE & ÜBERSICHT ---
-- Zeigt alle Keymaps mit einer Beschreibung (desc) im Picker an
function M.show_keymaps()
    local global_maps = vim.api.nvim_get_keymap("n")
    local buffer_maps = vim.api.nvim_buf_get_keymap(0, "n")
    local lines = {}
    local function process_maps(maps)
        for _, map in ipairs(maps) do
            if map.desc then
                -- Formatiere: "LHS | Beschreibung"
                -- Wir ersetzen das Leerzeichen (Leader) durch <Leader> für bessere Lesbarkeit
                local lhs = map.lhs:gsub(" ", "<Leader>")
                table.insert(lines, string.format("%-12s │ %s", lhs, map.desc))
            end
        end
    end
    process_maps(global_maps)
    process_maps(buffer_maps)
    table.sort(lines)
    if #lines == 0 then
        print("Keine Keymaps mit Beschreibung gefunden.")
        return
    end
    picker.open_picker(lines, "Keymap-Übersicht", function(selected)
        -- Optional: Bei <CR> könnte man die Keymap erklären oder ausführen
    end)
end

return M
