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
-- Zeigt alle Keymaps mit einer Beschreibung (desc) im Picker an, gruppiert nach Präfix
function M.show_keymaps()
    local global_maps = vim.api.nvim_get_keymap("n")
    local buffer_maps = vim.api.nvim_buf_get_keymap(0, "n")
    
    local grouped = {}
    local function process_maps(maps)
        for _, map in ipairs(maps) do
            if map.desc then
                local lhs = map.lhs:gsub(" ", "<Leader>")
                -- Gruppe bestimmen (erster Teil nach <Leader>, z.B. "b" aus "<Leader>bw")
                local group = "Andere"
                if lhs:find("^<Leader>%a") then
                    group = lhs:sub(1, 9) -- Nimmt "<Leader>X"
                elseif not lhs:find("^<Leader>") then
                    group = "Native / Andere"
                end
                
                if not grouped[group] then grouped[group] = {} end
                table.insert(grouped[group], string.format("%-12s │ %s", lhs, map.desc))
            end
        end
    end

    process_maps(global_maps)
    process_maps(buffer_maps)

    local lines = {}
    local sorted_groups = {}
    for g in pairs(grouped) do table.insert(sorted_groups, g) end
    table.sort(sorted_groups)

    for _, group in ipairs(sorted_groups) do
        table.insert(lines, "── " .. group .. " ──")
        table.sort(grouped[group])
        for _, map_line in ipairs(grouped[group]) do
            table.insert(lines, "  " .. map_line)
        end
        table.insert(lines, "") -- Leerzeile zwischen Gruppen
    end

    if #lines == 0 then
        print("Keine Keymaps mit Beschreibung gefunden.")
        return
    end

    picker.open_picker(lines, "Keymap-Übersicht", function(selected)
        -- Zeile ignorieren, wenn es ein Header ist
        if selected:find("^──") then return end
    end)
end

return M
